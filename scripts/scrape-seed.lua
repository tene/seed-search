crawl_require('dlua/explorer.lua')

function item_data_helper(attrs, name, item)
    val = item[name]
    if val ~= nil then
        if type(val) == "function" then
            val = val(item)
            if val ~= nil then attrs[name] = val end
        else
            attrs[name] = val
        end
    end
end

function item_artprops(item)
    if props["Brand"] ~= nil then end
    return props
end

function item_data(item)
    local attrs = {}
    -- item_data_helper(attrs, "branded", item)
    item_data_helper(attrs, "artefact", item)
    item_data_helper(attrs, "name", item)
    item_data_helper(attrs, "ac", item)
    item_data_helper(attrs, "accuracy", item)
    item_data_helper(attrs, "damage", item)
    item_data_helper(attrs, "delay", item)
    item_data_helper(attrs, "encumbrance", item)
    item_data_helper(attrs, "plus", item)
    item_data_helper(attrs, "spells", item)
    item_data_helper(attrs, "weap_skill", item)
    item_data_helper(attrs, "class", item)
    item_data_helper(attrs, "ego", item)
    item_data_helper(attrs, "subtype", item)
    if item.artefact and attrs["class"] ~= "Books" then
        -- crawl.stderr(serialize_data_json(attrs))
        local brands = {
            "flaming", "freezing", "holy wrath", "electrocution", "orc slaying",
            "dragon slaying", "venom", "protection", "draining", "speed",
            "vorpality", "flame", "frost", "vampirism", "pain", "antimagic",
            "distortion", "reaching", "returning", "chaos", "evasion",
            "confusion", "penetration", "reaping", "spectralizing", "vorpal",
            "acid", "confusion"
        }
        local props = item.artprops
        local brand_id = props["Brand"]
        if brand_id ~= nil and brand_id > 0 then
            props["Brand"] = nil
            attrs["ego"] = brands[brand_id]
        end
        attrs["artprops"] = props
    end
    return attrs
end

function serialize_data_json(data)
    local quoted = {}
    for name, val in pairs(data) do
        if val ~= nil then
            local val_s
            if type(val) == "table" then
                val_s = serialize_data_json(val)
            elseif type(val) == "number" then
                val_s = tostring(val)
            else
                val_s = '"' .. tostring(val):gsub("\"", "\\\"") .. '"'
            end
            quoted[#quoted + 1] = '"' .. name .. '": ' .. val_s
        end
    end
    return "{" .. util.join(", ", quoted) .. "}"
end

function scrape_items(pos, items)
    local stack = dgn.items_at(pos.x, pos.y)
    if #stack > 0 then
        for _, item in ipairs(stack) do
            items[#items + 1] = item_data(item)
        end
    end
end

function scrape_shop_items(pos, items)
    local stack = dgn.shop_inventory_at(pos.x, pos.y)
    if stack ~= nil and #stack > 0 then
        for _, item in ipairs(stack) do
            local data = item_data(item[1])
            data["price"] = item[2]
            items[#items + 1] = data
        end
    end
end

function scrape_mon_items(pos, items)
    local mons = dgn.mons_at(pos.x, pos.y)
    if mons then
        local stack = mons.get_inventory()
        if #stack > 0 then
            for _, item in ipairs(stack) do
                items[#items + 1] = item_data(item)
            end
        end
    end
end

function scrape_current_place(lvl, to_show, hide_empty)
    wiz.identify_all_items()
    -- crawl.stderr(lvl)
    local items = {}
    local gxm, gym = dgn.max_bounds()
    for pos in iter.rect_iterator(dgn.point(1, 1), dgn.point(gxm - 2, gym - 2)) do
        scrape_items(pos, items)
        scrape_shop_items(pos, items)
        scrape_mon_items(pos, items)
    end
    for _, item in ipairs(items) do
        item["level"] = lvl
        crawl.stderr(serialize_data_json(item))
    end
    return true
end

local seed = crawl.script_args()[1]
local depth = #explorer.generation_order
local cats = {"items", "monsters"}
-- local cats = explorer.available_categories
local show_level = function(l) return true end
local describe_cat = function(seed) return "" end

wiz.identify_all_items()

explorer.mons_notable = function(m) return false end
explorer.mons_feat_filter =
    function(f) return f:find("item:") == 1 and f or nil end
explorer.item_notable = function(x) return true end

explorer.catalog_current_place = scrape_current_place

explorer.catalog_seed(seed, depth, cats, show_level, describe_cat)
