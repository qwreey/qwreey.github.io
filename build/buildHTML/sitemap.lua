local module = {};

local insert = table.insert;
local concat = table.concat;

local function scan(list,env,url)
    local extandable,opened;
    local childs = {};
    if #list > 0 then
        extandable = true;
        for index,child in ipairs(list)  do
            local childStr,childOpened = scan(child,env,url);
            insert(childs,childStr);
            opened = opened or childOpened;
        end
    end
    if list.ref == url then
        if opened then
            return env.sitemap_templates.collapsible_selected,true;
        end
    end
end

function module.mapbuild(env)
    local filename = env.name:gsub(".%w+$","");
    -- env.sitemap_list
    -- env.sitemap_templates
    return "여긴 아직 공사중";
end

return module;