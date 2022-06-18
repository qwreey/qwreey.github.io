local module = {dir = (...):gsub("%.","/")};

local json = require("json");
local cmd = ('python %s/buildmd.py "%%s"'):format(module.dir);

function module.build(items)
    os.execute(cmd:format(json.encode(items):gsub('"','\\"')));
end

return module;