_G.require = require;
local futils = require("build.futils");
local concatPath = futils.concatPath;

local buildMd = require("build.buildMd");
local 

local fs = require("fs");
local prettyPrint = require("pretty-print");
local p = prettyPrint.prettyPrint;

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
            table.insert(items,{
                ext = futils.getExt(this);
                from = from .. this;
                to = to .. this;
            });
        end
    end
    return items; -- 빌드해야될 목록을 반환한다
end

local buildTypes = {
    ["md"] = function (o)
        local lastFrom = o.from;
        local tindex = o.dat.tmpIndex;
        local newFrom = concatPath(o.dat.tmp,tindex);
        o.dat.tmpIndex = tindex + 1;
        table.insert(o.dat.mdbuilds,{
            from = lastFrom;
            to = newFrom;
        });
        table.insert(o.dat.rebuild,{
            ext = "html";
            from = newFrom;
            to = o.to;
        });
    end;
    ["html"] = function (o)
        local this = fs.readFileSync(o.from);
        if not this:match("<!--DO NOT BUILD-->") then
            this = 
        end
        fs.writeFileSync(this);
    end;
    ["*"] = function (o)
        if jit.os == "Windows" then
            os.execute(("copy %s %s"):format(o.from,o.to));
        else
            os.execute(("cp %s %s"):format(o.from,o.to));
        end
    end;
};
local buildTypes_default = buildTypes["*"];
local buildTypes_html = buildTypes["html"];
---받은 테이블 쌍을 빌드한다, 역시나 재귀가 사용되는 함수
---@param items table 재귀할 아이템이 담긴 테이블, from과 to 쌍으로 이룬다
---@param tmp any 빌드에 사용될 템프 폴더
---@param tmpIndex number 사용하지 마세요 (재귀 전달) - 템프파일 아이드를 자식 재귀로 넘겨줌
local function buildItems(items,tmp,tmpIndex)
    local dat = {
        tmpIndex = tmpIndex or 0;
        tmp = tmp;
        mdbuilds = {};
        rebuild = {};
    };
    for _,item in pairs(items) do
        local from = item.from;
        local ext = item.ext;
        if not ext then
            ext = futils.getExt(from);
            item.ext = ext;
        end
        local bfn = buildTypes[ext] or buildTypes_default;
        item.dat = dat;
        bfn(item);
    end
    buildMd.build(dat.mdbuilds);
    local rebuild = dat.rebuild;
    if #rebuild ~= 0 then
        buildItems(rebuild,tmp,dat.tmpIndex);
    end
end

buildItems(scan("src","docs"),"build/tmp");
