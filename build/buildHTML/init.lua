local module = {dir = (...):gsub("%.","/")};

local logger = require("logger");
local fs = require("fs");
local base = fs.readFileSync("build/base.html");
local futils = require("build.futils");
local promise = require("promise");
local random = require("random");
local myXml = require("myXml");
local worker = require("worker");
local insert = table.insert

local luaPrefix = "lua:";
local globalEnv = require("site");
local envMeta = {__index = globalEnv, __newindex = globalEnv};

function module.build(content,env)
    env = env or {};
    env = setmetatable(env,envMeta);
    local page = env.page or {};
    env.page = page;

    --read meta datas
    local meta = {};
    string.gsub(content,"<!%-%-META:(.-):(.-)%-%->",function(key,value)
        meta[key] = value;
        return "";
    end);
    setmetatable(page,{__index = meta});
    local function execute(this)
        do -- find this on env and if it exsit; return that
            local fromEnv = env;
            for str in this:gmatch("[^%.]+") do
                if fromEnv == nil then
                    break;
                end
                fromEnv = fromEnv[str];
            end
            if (fromEnv ~= nil) and (fromEnv ~= env) then
                return fromEnv;
            end
        end

        do -- if it's lua script; run it and return result
            if this:sub(1,#luaPrefix) == luaPrefix then
                this = this:sub(#luaPrefix+1,-1);
                local passed,fn = pcall(loadstring,this);
                if passed then
                    setfenv(fn,setmetatable({
                        page = page;
                        env = env;
                        logger = logger;
                        promise = promise;
                        random = random;
                        myXml = myXml;
                        worker = worker;
                        require = require;
                        fs = fs;
                    },{
                        __index = _G;
                        __newindex = _G;
                    }));
                    local passed2,result = pcall(fn);
                    if passed2 then
                        if type(result) == "table" and result.__name == promise.__name then
                            result:wait()
                            local failed,err = result:isFailed();
                            if failed then
                                logger.errorf("(in promise) Error occurred on file %s\nLua:An error occur on executing luascript\nerror was . . .\n%s",env.to,result);
                                return ("<pre>Lua:An error occur on executing luascript\nerror was . . .\n%s</pre>")
                                    :format(err);
                            end
                            result = result:await();
                            return result;
                        end
                        return result;
                    else
                        logger.errorf("Error occurred on file %s\nLua:An error occur on executing luascript\nerror was . . .\n%s",env.to,result);
                        return ("<pre>Lua:An error occur on executing luascript\nerror was . . .\n%s</pre>")
                            :format(result);
                    end
                else
                    logger.errorf("Error occurred on file %s\nLua:An error occur on parsing luascript\nerror was . . .\n%s",env.to,fn);
                    return ("<pre>Lua:An error occur on parsing luascript\nerror was . . .\n%s</pre>")
                        :format(fn);
                end
            end
        end

        -- find module for this
        local thisRequirePath = this:match("^[^|]+");
        local passed,callback = pcall(require,futils.concatPath(module.dir,thisRequirePath));
        if passed then
            local arg = this:match("^[^|]+|(.+)");
            if not arg then
                return tostring(callback);
            end
            -- it will allows call modules item and index items
            -- such : {#:test.module|.method("call!");:#}
            --        {#:path.tofile|.index.like.table:#}
            local passed2,fn = pcall(loadstring,"return CALLBACK" .. (arg or ""));
            if passed2 then
                setfenv(fn,setmetatable(
                    {
                        page = page;
                        env = env;
                        promise = promise;
                        random = random;
                        myXml = myXml;
                        worker = worker;
                        require = require;
                        fs = fs;
                        arg = arg;
                        CALLBACK = callback;
                    },{
                        __index = _G;
                        __newindex = _G;
                    }
                ));
                local passed3,result = pcall(fn);
                if not passed3 then
                    logger.errorf("Error occurred on file %s\nLua:An error occur on parsing luascript\nerror was . . .\n%s",env.to,result);
                    return ("<pre>Lua:An error occur on calling module\nerror was . . .\n%s</pre>")
                        :format(result);
                end
                return result;
            else
                logger.errorf("Error occurred on file %s\nError occurred on parsing module caller\nerror was . . .\n%s",env.to,fn);
                return ("<pre>Lua:An error occur on parsing module caller\nerror was . . .\n%s</pre>")
                    :format(fn);
            end
        end

        -- if we can't find anything exist; return UNDEFIND for debugging
        logger.errorf("Error occurred on file %s\nCouldn't find anything exist\n%s",tostring(env and env.to),tostring(callback));
        return "<pre>LUA:UNDEFIND:'" .. this .. "'</pre>";
    end
    local function formatting(str)
        local replaceMap = {}
        for this in string.gmatch(str,"/?/?{#:(.-):#}") do
            insert(replaceMap,execute(this))
        end
        local count = 0
        return string.gsub(str,"/?/?{#:(.-):#}",function (this)
            count = count + 1
            return replaceMap[count]
        end);
    end
    page.content = formatting(content);

    return formatting(base)
end

return module;