local module = {dir = (...):gsub("%.","/")};

local logger = require("logger");
local fs = require("fs");
local base = fs.readFileSync("build/base.html");
local futils = require("build.futils");

local luaPrefix = "lua:";
local globalEnv = require("site");
local envMeta = {__index = globalEnv, __newindex = globalEnv};

function module.build(content,env)
    env = env or {};
    env = setmetatable(env,envMeta);
    local page = env.page or {};
    env.page = page;
    page.content = content;

    --read meta datas
    local meta = {};
    string.gsub(content,"<!%-%-META:(.-):(.-)%-%->",function(key,value)
        meta[key] = value;
        return "";
    end);
    setmetatable(page,{__index = meta});

    return string.gsub(base,"/?/?{#:(.-):#}",function (this)
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
                    setfenv(fn,setmetatable({env = env},_G));
                    local passed2,result = pcall(fn);
                    if passed2 then
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
                        env = env;
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
    end);
end

return module;