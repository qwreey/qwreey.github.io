--[[
module name :: File Utils
--]]
local fs = fs or require("fs");
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
function module.scan(path)
    local items = {};
    for child in fs.scandirSync(path) do
        local status = fs.statSync(path .. "/" .. child);
        local type = status.type;
        table.insert(items,{
            isFolder = type == "folder";
            name = child;
        });
    end
    return items;
end
function module.getExt(path)
    return path:match("%..+$");
end

return module;
