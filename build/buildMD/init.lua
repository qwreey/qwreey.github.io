local json = require("json");
local cmd = ('python %s/buildmd.py "%%s"'):format(module.dir);
local module = {};

function module.build(items)
    os.execute(cmd:format(json.encode(items)));
end

return module;