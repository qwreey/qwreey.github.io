local bundlePaths = require('luvi').bundle.paths
local uv = require "uv"
local json = require "json"

---@class worker
local worker = {}
worker.__index = worker

---private function, used on creating child thread
function worker.__inner(dumped,bundles,path,cpath,read_fd,write_fd,thread_name,...)

    local insert = table.insert
    local gmatch = string.gmatch
    local wrap = coroutine.wrap
    local traceback = debug.traceback
    local format = string.format
    local match = string.match
    local concat = table.concat
    local pack = table.pack
    local yield = coroutine.yield
    local running = coroutine.running

    -- resolve lua require paths
    package.path = path
    package.cpath = cpath

    -- convert bundle paths back to table, and resolve luvi environment
    local paths = {}
    for str in bundles:gmatch("[^;]+") do
        paths[#paths + 1] = str
    end
    local _, mainRequire = require('luvibundle').commonBundle(paths)

    -- inject the global process table
    _G.process = mainRequire('process').globalProcess()

    -- print function
    local luaprint = print
    local print,printerr do
        local pass,module = pcall(require,"logger")
        if not pass then
            pass,module = pcall(require,"logger/init")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger/init")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger/init")
        end

        if pass then
            module.prefix = thread_name
            print = function (...)
                local args = pack(...)
                for i=1,args.n do
                    module.info(tostring(args[i]))
                end
            end
            printerr = function (...)
                local args = pack(...)
                for i=1,args.n do
                    module.error(tostring(args[i]))
                end
            end
        else
            local function rawprint(head,...)
                local str = {head}
                local args = pack(...)
                for i=1,args.n do
                    insert(str,tostring(args[i]))
                    if i ~= args.n then
                        insert(str,"\t")
                    end
                end
                insert(str,"\n")
                local content = concat(str)

                local stdout = process and process.stdout
                local write = stdout.write
                local passWrite
                if write then
                    passWrite = pcall(write,stdout,content)
                end
                if (not write) or (not passWrite) then
                    if io then
                        io.write(content)
                    else luaprint(content)
                    end
                end
            end
            local printHead = format("[THREAD %s] ",thread_name)
            print = function (...)
                rawprint(printHead,...)
            end
            local errHead = format("*ERROR* [THREAD %s] ",thread_name)
            printerr = function (...)
                rawprint(errHead,...)
            end
        end
    end

    -- load dumped function and set environment
    local fn = loadstring(dumped) if not fn then return end
    local fn_env = getfenv(fn)
    fn_env.require = mainRequire
    fn_env.print = print
    fn_env.printerr = printerr

    -- load libs
    local uv = require "uv"
    local json = require "json"

    -- setup read/write pipe
    local read_pipe = uv.new_pipe()
    read_pipe:open(read_fd)
    local write_pipe = uv.new_pipe()
    write_pipe:open(write_fd)

    -- setup handler class
    ---Handleing data receiving/sending on child thread
    ---@class workerChildHandler
    local handler = {__request_ids = 0}
    ---Set callback function on message receive return value is sent to main thread.
    ---@param func function set Callback function, return value is sent into main thread. if alreadly setted, will overwrite last function
    function handler.onRequest(func)
        handler.__func = func
        setfenv(func,{require = require "require"(".")})
    end
    ---Set this worker thread ready and make handshake with main thread
    ---YOU SHOULD CALL THIS FUNCTION AFTER ALL HANDLER FUNCTION BINDED
    function handler.ready()
        local routine = running()
        if not routine then
            error("handler.ready must be called on coroutine")
        end

        if handler.__is_ready then return end
        write_pipe:write('{"id":"READY"}\n')
        handler.__waiting_ready = routine
        yield()
        handler.__is_ready = true
    end
    ---Send request to main thread
    function handler.request(data)
        local routine = running()
        if not routine then
            error("handler.request must be called on coroutine")
        end

        local id = handler.__request_ids
        handler[id] = routine
        handler.__request_ids = id+1
        write_pipe:write(json.encode({r=1; d=data; i=id}))
        local hasError,result = yield()

        if hasError then error(result) end
        return result
    end
    ---Print error on console, this function not make actual error (not throw thread)
    handler.printerr = printerr
    ---A print function, if logger library exist, use logger library. or using process.stdout or io.write or lua's default print function
    handler.print = print
    ---args from main thread (worker:ready(...))
    handler.args = pack(...)
    fn_env.handler = handler

    local READY_CHUNK = '{"id":"READY"}'
    local READY_REQUEST = '{"id":"READY"}\n'
    local KILL_REQUEST = '{"id":"KILL"}\n'
    local KILL_CHUNK = '{"id":"KILL"}'

    local function onRead(err, chunk)
        if err then
            printerr(format("error occurred on reading pipe : %s",tostring(err)))
            uv.close(read_pipe)
            pcall(write_pipe.write,write_pipe,'{"id":"CLOSE"}\n')
            uv.close(write_pipe)
            return
        end

        -- handshake
        if chunk == READY_CHUNK then
            local waitter = handler.__waiting_ready
            if waitter then
                local pass,resumeErr = coroutine.resume(waitter)
                if not pass then printerr(format("error occurred on resume READY routine\n%s",tostring(resumeErr))) end
            else
                printerr("received READY before waitter setted")
            end
            write_pipe:write('{"id":"START"}\n')
            return
        elseif chunk == KILL_CHUNK then
            read_pipe:read_stop()
            read_pipe:close()
            write_pipe:close()
            pcall(uv.stop)
            return
        end

        if not handler.__is_ready then
            printerr("received data before handler.ready called")
            return
        end

        -- decode data
        local data,_,decodeErr = json.decode(chunk)
        if not data then
            printerr(format("error occurred on decoding json.\n%s\nchunk : %s",tostring(decodeErr),tostring(chunk)))
            return
        end

        -- check data
        local id = data.i
        local direction = data.r
        if not id then
            printerr(format("job id not got.\nchunk : %s",chunk))
            return
        elseif not direction then
            printerr(format("direction not got.\nchunk : %s",chunk))
            return
        end

        -- reverse pipe, request result received (child thread => main thread)
        if direction == 1 then
            local routine = handler[id]
            handler[id] = nil
            if not routine then
                printerr(format("got request result from main thread, but callback routine was not found\bchunk : %s",tostring(chunk)))
                return
            end
            local derr = data.e
            local ddata = data.d
            local hasError = derr and true or false
            local pass,errResume = coroutine.resume(routine,hasError,hasError and derr or ddata)
            if not pass then
                printerr(format("got request result from main thread, but error occurred on callback routine\n%s\nchunk : %s",tostring(errResume),tostring(chunk)))
            end
            return
        -- main thread => child thread (request from main)
        elseif direction == 0 then
            local func = handler.__func
            if not func then
                printerr(format("received data before onRequest called\nchunk : %s",tostring(chunk)))
                return
            end

            local pass,result = pcall(func,data.d)
            if not pass then -- catch error
                printerr(format("error occurred on calling onRequest function\n%s\nchunk : %s",tostring(result),tostring(chunk)))
                write_pipe:write(json.encode{
                    i=id; e=tostring(result); r=0
                }.."\n")
                return
            end

            -- write result
            write_pipe:write(json.encode{
                i=id; d=result; r=0
            }.."\n")
            return
        else
            printerr(format("unknown direction int got (%s)\nchunk : %s",tostring(direction),tostring(chunk)))
            return
        end
    end

    local buffer = {}
    local function queueOnRead(pipeError,pipeChunk)
        local passed,err
        if pipeError or not pipeChunk then
            passed,err = pcall(onRead,pipeError,pipeChunk)
            if not passed then
                printerr(format("error occurred on onRead() \n%s",err))
            end
        else
            local base
            if match(pipeChunk,"\n") then
                if #buffer == 0 then
                    base = pipeChunk
                else
                    insert(buffer,pipeChunk)
                    base = concat(buffer)
                    buffer = {}
                end
                for content,linebreak in gmatch(base,"([^\n]+)(\n?)") do
                    if linebreak == "\n" then
                        passed,err = pcall(onRead,pipeError,content)
                        if not passed then
                            printerr(format("error occurred on onRead() \n%s",err))
                        end
                    else
                        insert(buffer,content)
                    end
                end
            else
                insert(buffer,pipeChunk)
            end
        end
    end

    read_pipe:read_start(function (...)
        wrap(queueOnRead)(...)
    end)

    -- set error handler
    local function protected()
        xpcall(fn,function (err)
            local stackTrace = traceback(err)
            printerr(format("Uncaught exception:\n %s",tostring(stackTrace)))
            return stackTrace
        end,handler)
    end
    wrap(protected)()

    uv.run()
end

local pack = table.pack
local dump = string.dump
local wrap = coroutine.wrap
local resume = coroutine.resume
local gmatch = string.gmatch
local concat = table.concat
local insert = table.insert
local match = string.match
local gsub = string.gsub
local format = string.format
local running = coroutine.running
local yield = coroutine.yield

---Set callback function on message receive return value is sent to child thread.
---@param func function set Callback function, return value is sent into child thread. if alreadly setted, will overwrite last function
function worker:onRequest(func)
    self.__func = func
    return self
end

function worker:request(data)
    local routine = running()
    if not routine then
        error("handler.request must be called on coroutine")
    end

    local id = self.__request_ids
    self[id] = routine
    self.__request_ids = id+1

    self.__write_pipe:write(json.encode({r=0; d=data; i=id}).."\n")
    local hasError,result = yield()

    if hasError then error(result) end
    return result
end

function worker:protectedRequest(data)
    local routine = running()
    if not routine then
        error("handler.protectedRequest must be called on coroutine")
    end

    local id = self.__request_ids
    self[id] = routine
    self.__request_ids = id+1

    self.__write_pipe:write(json.encode({r=0; d=data; i=id}).."\n")
    local hasError,result = yield()
    return not hasError,result
end

local KILL = '{"id":"KILL"}\n'
function worker:kill()
    self.__write_pipe:write(KILL)
    self.__read_pipe:read_stop()
    self.__read_pipe:close()
    self.__write_pipe:close()
    uv.thread_join(self.__thread)
    self.__thread = nil
    self.__read_pipe = nil
    self.__write_pipe = nil
    self.__pipeOut = nil
    self.__pipeIn = nil
    self.__name = nil
    self.__func = nil
    self.__print = nil
    self.__printerr = nil
    self.__request_ids = nil
    setmetatable(self,nil)
end

---Set this worker thread ready and make handshake with main child
---YOU SHOULD CALL THIS FUNCTION AFTER ALL HANDLER FUNCTION BINDED
function worker:ready(...)
    local dumped = self.__dumped;
    self.__waiting_start = running()
    if not self.__waiting_start then
        error("handler.ready must be called on coroutine")
    end
    local thread = uv.new_thread(
        worker.__inner,
        dumped,
        concat(bundlePaths, ";"),
        package.path,
        package.cpath,
        self.__pipeIn.read,
        self.__pipeOut.write,
        self.__name or "DEFAULT",
        ...
    )
    self.__thread = thread
    yield()
    return self
end

---A print function, if logger library exist, use logger library. or using process.stdout or io.write or lua's default print function
function worker:print(...)
    self.__print(...)
end

---Print error on console, this function not make actual error (not throw thread)
function worker:printerr(...)
    self.__printerr(...)
end

---Set child thread work handler function, this function can be called when only ready was not called
function worker:setWorkHandler(workHandler)
    if type(workHandler) ~= "function" then
        error(format("worker:setWorkHandler argument #1 'workHandler' must be function, but got %s",workHandler))
    end
    local dumped = type(workHandler)=='function'
        and dump(workHandler) or workHandler
    self.__dumped = dumped
end

local START_REQUEST = '{"id":"START"}\n'
local READY_REQUEST = '{"id":"READY"}\n'
local START_CHUNK = '{"id":"START"}'
local READY_CHUNK = '{"id":"READY"}'
function worker.new(name,workHandler)
    if type(name) ~= "string" then
        error(format("worker.new argument #1 'name' must be string, but got %s",name))
    elseif workHandler ~= nil and type(workHandler) ~= "function" and type(workHandler) ~= "string" then
        error(format("worker.new argument #2 'workHandler' must be function or string or nil, but got %s",workHandler))
    end

    ---@type worker
    local this = {__request_ids=0,__name = name,__buffer = {}}

    if workHandler then
        local dumped = type(workHandler)=='function'
            and dump(workHandler) or workHandler
        this.__dumped = dumped
    end

    local pipeIn = uv.pipe({nonblock=true}, {nonblock=true})
    local pipeOut = uv.pipe({nonblock=true}, {nonblock=true})

    this.__pipeIn = pipeIn
    this.__pipeOut = pipeOut

    local read_pipe = uv.new_pipe()
    read_pipe:open(pipeOut.read)
    this.__read_pipe = read_pipe

    local write_pipe = uv.new_pipe()
    write_pipe:open(pipeIn.write)
    this.__write_pipe = write_pipe

    -- print function
    local luaprint = print
    local print,printerr do
        local pass,module = pcall(require,"logger")
        if not pass then
            pass,module = pcall(require,"logger/init")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger")
        end
        if not pass then
            pass,module = pcall(require,"libs/logger/init")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger")
        end
        if not pass then
            pass,module = pcall(require,"deps/logger/init")
        end

        if pass then
            print = function (...)
                local args = pack(...)
                for i=1,args.n do
                    module.info(format("[MAIN THREAD %s] %s",tostring(this.__name),tostring(args[i])))
                end
            end
            printerr = function (...)
                local args = pack(...)
                for i=1,args.n do
                    module.error(format("*ERROR* [MAIN THREAD %s] %s",tostring(this.__name),tostring(args[i])))
                end
            end
        else
            local function rawprint(head,...)
                local str = {head}
                local args = pack(...)
                for i=1,args.n do
                    insert(str,tostring(args[i]))
                    if i ~= args.n then
                        insert(str,"\t")
                    end
                end
                insert(str,"\n")
                local content = concat(str)

                local stdout = process and process.stdout
                local write = stdout.write
                local passWrite
                if write then
                    passWrite = pcall(write,stdout,content)
                end
                if (not write) or (not passWrite) then
                    if io then
                        io.write(content)
                    else luaprint(content)
                    end
                end
            end
            local printHead = format("[MAIN THREAD %s] ",tostring(this.__name))
            print = function (...)
                rawprint(printHead,...)
            end
            local errHead = format("*ERROR* [MAIN THREAD %s] ",tostring(this.__name))
            printerr = function (...)
                rawprint(errHead,...)
            end
        end
    end
    this.__print = print
    this.__printerr = printerr

    setmetatable(this,worker)

    read_pipe:read_start(function(err, chunk)
        wrap(this.queueOnRead)(this,err,chunk)
    end)

    return this
end

function worker:clone()
    local name = self.__name
    if not name then error("This worker may broken (have no name)") end
    if match(name,"%(%d+%)$") then
        name = gsub(name,"%((%d+)%)$",function(str)
            return format("(%d)",tonumber(str)+1)
        end)
    else name = name .. " - Clone (1)"
    end
    return worker.new(name,self.__dumped)
end

function worker:onRead(err, chunk)
    if err then
        self:printerr(format("error occurred on reading pipe\n%s",tostring(err)))
        return
    end

    -- handshake
    if chunk == READY_CHUNK then
        self.__write_pipe:write(READY_REQUEST)
        return
    elseif chunk == START_CHUNK then
        local waittingStart = self.__waiting_start
        if not waittingStart then
            self:printerr("received START before worker:ready called")
            return
        end
        self.__waiting_start = nil

        local pass,resumeErr = coroutine.resume(waittingStart)
        if not pass then self:printerr(format("error occurred on resume READY routine\n%s",tostring(resumeErr))) end
        return
    end

    -- decode data
    local data,_,decodeErr = json.decode(chunk)
    if not data then
        self:printerr(format("error occurred on decoding json.\n%s\nchunk : %s",tostring(decodeErr),tostring(chunk)))
        return
    end

    -- check data
    local id = data.i
    local direction = data.r
    if not id then
        self:printerr(format("job id not got.\nchunk : %s",chunk))
        return
    elseif not direction then
        self:printerr(format("direction not got.\nchunk : %s",chunk))
        return
    end

    -- reverse pipe, request result received (child thread => main thread)
    if direction == 1 then
        local func = self.__func
        if not func then
            self:printerr(format("received data before onRequest called\nchunk : %s",tostring(chunk)))
            return
        end

        local pass,result = pcall(func,data.d)
        if not pass then -- catch error
            self:printerr(format("error occurred on calling onRequest function\n%s\nchunk : %s",tostring(result),tostring(chunk)))
            self.__write_pipe:write(json.encode{
                i=id; e=tostring(result); r=1
            }.."\n")
            return
        end

        -- write result
        self.__write_pipe:write(json.encode{
            i=id; d=result; r=1
        }.."\n")
        return
    -- main thread => child thread
    elseif direction == 0 then
        local routine = self[id]
        self[id] = nil
        if not routine then
            self:printerr(format("got request result from child thread, but callback routine was not found\bchunk : %s",tostring(chunk)))
            return
        end
        local derr = data.e
        local ddata = data.d
        local hasError = derr and true or false
        local pass,errResume = resume(routine,hasError,hasError and derr or ddata)
        if not pass then
            self:printerr(format("got request result from child thread, but error occurred on callback routine\n%s\nchunk : %s",tostring(errResume),tostring(chunk)))
        end
        return
    else
        self:printerr(format("unknown direction int got (%s)\nchunk : %s",tostring(direction),tostring(chunk)))
        return
    end
end

function worker:queueOnRead(pipeErr,pipeChunk)
    if pipeErr or not pipeChunk then
        self:onRead(pipeErr,pipeChunk)
    else
        if match(pipeChunk,"\n") then
            local base
            if #self.__buffer == 0 then
                base = pipeChunk
            else
                insert(self.__buffer,pipeChunk)
                base = concat(self.__buffer)
                self.__buffer = {}
            end
            for content,linebreak in gmatch(base,"([^\n]+)(\n?)") do
                if linebreak == "\n" then
                    self:onRead(pipeErr,content)
                else
                    insert(self.__buffer,content)
                end
            end
        else
            insert(self.__buffer,pipeChunk)
        end
    end
end

-- local work = worker.new("testingThread",
--     ---@param handler workerChildHandler
--     function(handler)
--         handler.onRequest(function(data)
--             print(handler.request())
--             return data + 1
--         end)
--         handler.ready()
--     end
-- )

-- work:onRequest(function(data)
--     return "wow"
-- end)
-- work:ready()
-- print(work:request(32))

return worker
