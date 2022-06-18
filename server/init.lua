_G.require = require;
local http = require('http');
local url = require('url');
local fs = require('fs');
local Response = require('http').ServerResponse;
local mimes = require('server.mimes');
local root = "docs";
local logger = require("logger");

-- Return 404 error (file was not found)
local notFound = fs.readFileSync("./docs/404.html");
local notFoundLen = notFound and #notFound;
function Response:notFound(reason)
    self:writeHead(404, {
        ["Content-Type"] = "text/plain";
        ["Content-Length"] = notFound and notFoundLen or #reason;
    })
    self:write(notFound or reason);
end

-- Return 500 error
function Response:error(reason)
    self:writeHead(500, {
        ["Content-Type"] = "text/plain";
        ["Content-Length"] = #reason;
    })
    self:write(reason);
end

http.createServer(function(req, res)
    req.uri = url.parse(req.url);
    local path do
        local pathName = req.uri.pathname;
        if pathName == "/" then
            pathName = "/index.html";
        elseif not pathName:match("%.[^/]+$") then
            pathName = pathName .. ".html";
        end
        path = root .. pathName;
    end
    if path:match"%.html$" then
        logger.infof("load page: %s",path);
    else logger.infof("request file: %s",path);
    end
    fs.stat(path, function (err, stat)
        if err then
            if err:match(".-:") == "ENOENT:" then
                path = "./docs/404.html";
                stat = fs.statSync("./docs/404.html");
                -- return res:notFound(err.message .. "\n");
            else
                return res:error((err.message or tostring(err)) .. "\n");
            end
        end
        if stat.type ~= 'file' then
            return res:notFound("Requested url is not a file\n");
        end

        res:writeHead(200, {
            ["Content-Type"] = mimes.getType(path),
            ["Content-Length"] = stat.size
        });

        fs.createReadStream(path):pipe(res);
    end);
end):listen(8080);

logger.info("Http static file server listening at http://localhost:8080/");
