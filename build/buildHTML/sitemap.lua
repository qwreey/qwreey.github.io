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
        childs = childs:gsub("{#:next:#}","")
    else
        childs = "";
    end

    local isUrlMatch = list.ref == url;

    return env.sitemap_templates[concat {
        extandable and "collapsible" or "normal";
        isUrlMatch and "_selected" or "";
        (not list.ref) and "_nourl" or "";
        extandable and (opened or isUrlMatch) and "_open" or "";
    }]
    :gsub("{#:child:#}",childs)
    :gsub("{#:url:#}",list.ref or "")
    :gsub("{#:title:#}",list.name or "NONE")
    ,isUrlMatch;
end

function module.mapbuild(env)
    local filename = env.name:gsub(".%w+$","");
    local mapStr = "{#:next:#}";

    for _,item in ipairs(env.sitemap_list) do
        local childStr = scan(item,env,filename);
        mapStr = mapStr:gsub("{#:next:#}",childStr);
    end

    return mapStr:gsub("{#:next:#}","");


    -- return scan(env.sitemap_list,env,filename):gsub("{#:next:#}","");
    -- for k,_ in pairs(getmetatable(env).__index) do
    --     require"logger".info(k);
    -- end
    -- require"logger".info("");

    -- scan(,env,filename)
    -- env.sitemap_list
    -- env.sitemap_templates
    -- return "여긴 아직 공사중";
end

return module;