-- Register Lamp as a Craft Item
minetest.register_craftitem("voltz:lamp", {
    description = "Electric Lamp",
    inventory_image = "lamp.png",
    groups = {energy_device = 1}  -- Ensures compatibility with other mods
})

-- Function to check if there's a wire block adjacent to the lamp
local function is_wire_adjacent(pos)
    local directions = {
        {x = 1, y = 0, z = 0},  {x = -1, y = 0, z = 0},  -- Left/Right
        {x = 0, y = 0, z = 1},  {x = 0, y = 0, z = -1},  -- Front/Back
        {x = 0, y = 1, z = 0},  {x = 0, y = -1, z = 0}   -- Above/Below
    }
    
    for _, dir in ipairs(directions) do
        local neighbor_pos = vector.add(pos, dir)
        local neighbor_node = minetest.get_node(neighbor_pos).name
        if minetest.get_item_group(neighbor_node, "wire") > 0 then
            return true
        end
    end

    return false
end

-- Function to update lamp brightness dynamically
local function get_adjacent_power(pos)
    local directions = {
        {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},  -- Left/Right
        {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1},  -- Front/Back
        {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0}   -- Above/Below
    }
    local max_power = 0

    for _, dir in ipairs(directions) do
        local neighbor_pos = vector.add(pos, dir)
        local neighbor_node = minetest.get_node(neighbor_pos).name
        if minetest.get_item_group(neighbor_node, "energy_cable") > 0 then
            local meta = minetest.get_meta(neighbor_pos)
            local power = meta:get_int("power") or 0
            if power > max_power then
                max_power = power
            end
        end
    end
    return max_power
end

local function update_lamp_brightness(pos)
    local node = minetest.get_node(pos)
    local meta = minetest.get_meta(pos)
    local power = get_adjacent_power(pos)  -- Get power from connected wires

    -- Only light up if there's a wire nearby with power
    if not is_wire_adjacent(pos) or power <= 0 then
        minetest.swap_node(pos, {name = "voltz:lamp_off"})
        return
    end

    local light_level = math.min(math.floor(power / 10), 14)
    meta:set_int("light_level", light_level)

    if power >= 10 then
        minetest.swap_node(pos, {name = "voltz:lamp_bright", param1 = light_level})
    elseif power >= 5 then
        minetest.swap_node(pos, {name = "voltz:lamp_dim", param1 = light_level})
    else
        minetest.swap_node(pos, {name = "voltz:lamp_off", param1 = 0})
    end
end

-- Automatically Adjust Brightness When Power is Updated
minetest.register_abm({
    nodenames = {"voltz:lamp_off", "voltz:lamp_dim", "voltz:lamp_bright"},
    interval = 1,  -- Check every second
    chance = 1,  -- Always run

    action = function(pos, node)
        update_lamp_brightness(pos)
    end
})

-- Base Lamp Node (OFF)
minetest.register_node("voltz:lamp_off", {
    description = "Electric Lamp (Off)",
    tiles = {"lamp_off.png"},
    light_source = 0,  -- Default off
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_device = 1},  -- Works with power mods

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("power", 0)
        update_lamp_brightness(pos)
    end,
})

-- Dim Lamp Node
minetest.register_node("voltz:lamp_dim", {
    description = "Electric Lamp (Dim)",
    tiles = {"lamp_dim.png"},
    light_source = 5,  -- Dim light
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_device = 1},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("power", 5)
        update_lamp_brightness(pos)
    end,
})

-- Bright Lamp Node
minetest.register_node("voltz:lamp_bright", {
    description = "Electric Lamp (Bright)",
    tiles = {"lamp_bright.png"},
    light_source = 14,  -- Maximum brightness
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_device = 1},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("power", 14)
        update_lamp_brightness(pos)
    end,
})
