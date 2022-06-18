local module = {};

local insert = table.insert;
local concat = table.concat;

local function scan(list,env,url)
    local extandable,opened;
    local childs = "{#:next:#}";
    if #list > 0 then
        extandable = true;
        for index,child in ipairs(list)  do
            local childStr,childOpened = scan(child,env,url);
            childs = childs:gsub("{#:next:#}",childStr);
            opened = opened or childOpened;
        end
    end

    local isUrlMatch = list.ref == url;

    return env.sitemap_templates[concat {
        extandable and "collapsible" or "normal";
        isUrlMatch and "_selected" or "";
        (not list.url) and "_nourl" or "";
        (opened or isUrlMatch) and "_open" or "";
    }]
    :gsub("{#:child:#}",concat(childs))
    :gsub("{#:url:#}",list.ref or "")
    :gsub("{#:title:#}",list.name "NONE")
    ,isUrlMatch;
end

function module.mapbuild(env)
    local filename = env.name:gsub(".%w+$","");

    -- scan(,env,filename)
    -- env.sitemap_list
    -- env.sitemap_templates
    return "여긴 아직 공사중";
end

return module;