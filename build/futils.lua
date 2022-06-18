--[[
module name :: File Utils
--]]
local fs = require("fs");
local module = {};

--[[
just simply scan folder; and returns data that includes scaned files, folders

returnData = {
    {
        isFolder = false;
        name = "someFolder";
    };
    {
        isFolder = true;
        name = "someFolder";
    };
}
]]
function module.concatPath(path1,path2)
    return (path1 and (path1 .. (path2 and "/" or "")) or "") .. (path2 or "");
end
local concatPath = module.concatPath;

function module.scan(path)
    local items = {};
    for child in fs.scandirSync(path) do
        local status = fs.statSync(concatPath(path,child));
        local type = status.type;
        table.insert(items,{
            isFolder = type == "directory";
            name = child;
        });
    end
    return items;
end

function module.getExt(path)
    return path:match("%.(.+)$");
end

function module.mkpath(path)
    local dir;
    for str in (path):gmatch("[^/]+") do
        dir = concatPath(dir,str);
        fs.mkdirSync(dir);
    end
end

return module;
