local module = {dir = (...):gsub("%.","/")};

local IPC = require("IPC");
local promise = require"promise";
local uv = require("uv");

function module.init()
    local server = IPC.new({"python","python3"},{"build/buildMD/main.py"},true," pydown");
    local this = {server = server,pid = pid};
    setmetatable(this,module);
    return this;
end

module.__index = module;
function module:build(item)
    self.server:request(item);
end
module.buildAsync = promise.async(module.build);

function module:kill()
    self.server:kill();
end

return module;