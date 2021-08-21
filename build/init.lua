local futils = require("build.futils");

local function build(path,to,root)
    for item in pairs(futils.scan(path)) do
        local name = item.name;
        local this = path .. "/" .. name;
        if item.isFolder then
            scan(this,to,path);
        else
            if futils.getExt(name) == ".html" then

            end
        end
    end
end

scan("src","docs")
