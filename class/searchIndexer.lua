local logger = require("deps.logger")
local myXml = require("deps.myXml")
local json = require("json")

local concat = table.concat
local insert = table.insert
local function scan(body,result)
    if type(body) == "string" then
        local current = result[#result]
        local child = current and current.child
        if not child then
            insert(result,{text = body})
            return
        end
        if type(child[#child]) == "string" then
            child[#child] = concat{child[#child]," ",body}:gsub(" +"," "):gsub(" +$","")
        else
            local str = body:gsub(" +"," "):gsub(" +$","")
            insert(child,str)
        end
        return
    end
    if body.tag and body.tag:match("^h%d+$") then
        local title = {}
        for _,str in ipairs(body) do
            if type(str) == "string" then
                insert(title,str)
            end
        end
        title = concat(title," "):gsub(" +"," "):gsub(" +$","")
        -- insert(result,{title = body.__parent[body.__pindex+1],child = {},plink="#"..body.option.id})
    end
    for _,child in ipairs(body) do
        scan(child,result)
    end
end

local function makeIndex(htmlContent,path,title)
    local body = myXml.xmlToItem(htmlContent:gsub("\n+",""):gsub("<br>",""):gsub("<!%-%-.-%-%->",""):gsub("&[#]?%w*;",""))
    local result = {content = {},title = title or "이름없는 글",path = path}
    scan(body,result.content)
    require"fs".writeFileSync("test",myXml.itemToXml(body,"    "))
    return json.encode(result)
end

return {
    makeIndex = makeIndex;
}
