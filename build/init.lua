_G.require = require;
local futils = require("build.futils");
local fs = require("fs");
local prettyPrint = require("pretty-print");
local p = prettyPrint.prettyPrint;

local function buildHtml(from,to)

end

local function concatPath(path1,path2)
    return (path1 and (path1 .. (path2 and "/" or "")) or "") .. (path2 or "");
end

local function buildItem(origin,to,path)
    origin = concatPath(origin,path);
    to = concatPath(to,path);
    local ext = futils.getExt(origin);
    if ext == "html" then
        
    else
        os.execute("cp " .. origin .. " " .. to);
    end
end

local function buildScan(from,to,path)
    for _,item in pairs(futils.scan(concatPath(from,path))) do
        local name = item.name;
        local this = concatPath(path,name);
        if item.isFolder then
            buildScan(from,to,this);
        else
            buildItem(from,to,this);
        end
    end
end

buildScan("src","docs")
