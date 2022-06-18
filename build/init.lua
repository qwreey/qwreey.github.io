_G.require = require;
package.path = package.path .. ";./?/init.lua";
local futils = require("build.futils");
local concatPath = futils.concatPath;
local insert = table.insert;
local spawn = require("coro-spawn");
local logger = require("logger");
local promise = require("promise");
local waitter = promise.waitter;
local fs = require("fs");
local buildMD = require("build.buildMD");
local buildHTML = require("build.buildHTML");
local env = require("site");
local concat = table.concat;

---폴더 안에서 빌드할수 있는것들을 싹 찾는다
---@param from string 빌드하고 싶은 디렉터리 트리 (path)
---@param to string 결과물을 담고 싶은 디렉터리 트리 (path)
---@param path any 사용하지 마세요 (재귀 전달) - 아이템의 트리를 자식 재귀로 넘겨줌
---@param items table 사용하지 마세요 (재귀 전달) - 빌드 목록을 자식 재귀로 넘겨줌
---@return table
local function scan(from,to,path,items)
    items = items or {}; -- 빌드해야될 목록을 담는곳
    for _,item in pairs(futils.scan(concatPath(from,path))) do -- 받은 path 를 스캔한다
        local name = item.name; -- 아이템 이름
        local this = concatPath(path,name); -- 아이템의 풀 path
        if item.isFolder then -- 만약 폴더면 재귀한다 (inner search)
            scan(from,to,this,items); -- 자기 자신으로 재귀;
        else
            -- 빌드해야될 목록에 푸시한다
            insert(items,{
                name = this;
                ext = futils.getExt(this);
                from = concatPath(from,this);
                to = concatPath(to,this);
            });
        end
    end
    return items; -- 빌드해야될 목록을 반환한다
end

local function mkfile(path)
    futils.mkpath(path:match("(.+)/.-"));
end

local buildTypes = {
    ["md"] = function (object,builder)
        local lastFrom = object.from;
        local tindex = builder.tmpIndex;
        local newFrom = concat{concatPath(builder.tmp,tindex),"_",object.name};
        builder.tmpIndex = tindex + 1;
        local mdbuilder = builder.mdbuilder;
        if not mdbuilder then
            mdbuilder = buildMD.init();
            builder.mdbuilder = mdbuilder;
        end
        insert(builder.waitter,buildMD.buildAsync(mdbuilder,{
            from = lastFrom;
            to = newFrom;
        }));
        insert(builder.rebuild,{
            ext = "html";
            from = newFrom;
            name = object.name;
            to = object.to:sub(1,-4) .. ".html";
        });
    end;
    ["html"] = function (object,builder)
        local this = fs.readFileSync(object.from);
        if not this:match("<!--DO NOT BUILD-->") then
            -- call the html builder (custom html var)
            this = buildHTML.build(this,setmetatable(object,{__index = env}));
        end
        mkfile(object.to);
        fs.writeFileSync(object.to,this);
    end;
    ["*"] = function (object,builder)
        mkfile(object.to);
        if jit.os == "Windows" then
            -- 래거시 카피
            -- os.execute(("copy %s %s > NUL"):format(object.from:gsub("/","\\"),object.to:gsub("/","\\")));

            insert(builder.waitter,
                spawn("copy",{
                    args = {
                        object.from:gsub("/","\\"),
                        object.to:gsub("/","\\")
                    },
                    stdio = {nil,nil,2}
                }).waitExit
            );
        else
            insert(builder.waitter,
                spawn("cp",{
                    args = {object.from,object.to},
                    stdio = {nil,nil,2}
                }).waitExit
            );
        end
    end;
};
local buildTypes_default = buildTypes["*"];

---받은 테이블 쌍을 빌드한다, 역시나 재귀가 사용되는 함수
---@param items table 재귀할 아이템이 담긴 테이블, from과 to 쌍으로 이룬다
---@param tmp any 빌드에 사용될 템프 폴더
---@param tmpIndex number|nil 사용하지 마세요 (재귀 전달) - 템프파일 아이드를 자식 재귀로 넘겨줌
local function buildItems(items,tmp,root,tmpIndex)
    futils.mkpath(tmp);
    local builder = {
        tmpIndex = tmpIndex or 0; -- 임시파일 번째
        tmp = tmp; -- 임시파일 루트
        rebuild = {}; -- 다시 빌드 해야 하는것
        waitter = {}; -- 기다려야하는것
        root = root; -- 출력 결과가 저장될곳
        sitemap = concatPath(root,"sitemap.json"); -- 빌드된 목록이 나열될 곳
    };

    -- 빌드
    for _,item in pairs(items) do
        local from = item.from;
        local ext = item.ext;
        if not ext then
            ext = futils.getExt(from);
            item.ext = ext;
        end
        local buildFunction = buildTypes[ext] or buildTypes_default;
        buildFunction(item,builder);
    end

    -- 기다려야할 await 리스트들을 모두 기다림
    for _,work in ipairs(builder.waitter) do
        local typeWork = type(work);
        if typeWork == "function" then
            work();
        elseif typeWork == "table" then
            if  work.__name == waitter.__name or
                work.__name == promise.__name then
                work:wait();
            else
                work[1][work[2]](work[1]);
            end
        end
    end
    -- 리빌드 리스트 다시 빌드 (재귀빌드)
    local rebuild = builder.rebuild;
    if #rebuild ~= 0 then
        buildItems(rebuild,tmp,root,builder.tmpIndex);
    end
    local mdbuilder = builder.mdbuilder;
    if mdbuilder then
        mdbuilder:kill();
    end
end

-- local function cleanupLastBuild(root)
--     local path = concatPath(root,"sitemap.json");
--     local raw = fs.readFileSync(path);
--     if not raw then
--         return;
--     end

--     local last = json.decode(raw);
--     if not last then
--         return;
--     end
--     for i,v in pairs(last) do
--         os.remove(v);
--     end
--     fs.writeFileSync(path,"");
-- end

local watch = promise.async(function (err,file,status,path,last)
    if(err) then
        print(err);
    else
        file = file:gsub("\\","/");
        local time = os.time() * (jit.os == "Linux" and 500 or 1);
        local this = concatPath(path,file);
        local ltime = last[this];
        if ltime and ltime+1 >= time then return; end
        last[this] = time;

        logger.infof("build: %s",tostring(this));
        buildItems({{
            name = file;
            ext = futils.getExt(file);
            from = this;
            to = concatPath("docs",file);
        }},"build/tmp","docs");
    end
end);

local last = {};
local arg = args[2];
if arg == "watch" then
    local uv = require("uv");
    for _,path in pairs({
		"./src";
	}) do
		local fse = uv.new_fs_event();
		uv.fs_event_start(fse,path,{
			recursive = true;
            watch_entry = true;
		},function (err,file,status)
			watch(err,file,status,path,last);
		end);
	end
    require("server");
else
    buildItems(scan("src","docs"),"build/tmp","docs");
end
