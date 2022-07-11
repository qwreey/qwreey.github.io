local module = {};

local ogformat = '	<meta property="og:%s" content="%s">';
local concat = table.concat;
local insert = table.insert;

function module.ogbuild(content)
    local strs = {};

    for index,value in pairs(content) do
        if value then
            insert(strs,ogformat:format(index:gsub("_",":"),value));
        end
    end
    
    return concat(strs,"\n")
end

return module;
