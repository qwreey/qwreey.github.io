local module = {};
local fs = require("fs");
local replaceFormat = "%%-?%%-?/?/?{#:%s:#}";
local concat = table.concat;

local function doRawformat(str,format)
    for key,value in pairs(format) do
        if type(value) == "table" then
            str = doRawformat(str,value);
        else str = str:gsub(key,value);
        end
    end
    return str;
end

function module.read(file,settings)
    local str = fs.readFileSync(file);
    local format = settings.format;
    if format and next(format) then
        for key,value in pairs(format) do -- value is can be a string
            str = str:gsub(replaceFormat:format(key),value);
        end
    end

    local rawformat = settings.rawformat;
    if rawformat and next(rawformat) then
        str = doRawformat(str,rawformat);
    end

    if settings.removeIndent then
        str = str:gsub("\r?\n\r?[ \t]+","\n");
    end

    local removeNewline = settings.removeNewline;
    if removeNewline then
        str = str:gsub("[\n\r]+[ \t]*",type(removeNewline) == "string" and removeNewline or " ");
    end

    local tag = settings.tag;
    local attributes = settings.attributes;
    if tag then
        str = concat{"<",tag,attributes and " " or "",attributes or "",">",str,"</",tag,">"};
    end
    return str;
end

return module;
