core.register_craftitem("lamps:lamp", {
    description = "My Special Item",
    inventory_image = "lamp.png"
})
-- Function to update lamp brightness based on power
local function update_lamp_brightness(pos, power)
    local node = core.get_node(pos)
    local light_level = math.min(math.floor(power / 10), 14)  -- Scale power to Minetest's 0-14 light range
    local meta = core.get_meta(pos)
    meta:set_int("light_level", light_level)
    core.swap_node(pos, {name = node.name, param1 = light_level})  -- Update light level dynamically
end

-- Lamp Node off
core.register_node("voltz:lamp", {
    description = "Electric Lamp",
    tiles = {"lamp_off.png"},
    light_source = 0,  -- Default off
    groups = {cracky=2, oddly_breakable_by_hand=1},

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 0)
        update_lamp_brightness(pos, 0)
    end,
})

-- Lamp Node dim
core.register_node("voltz:lampdim", {
    description = "Electric Lamp",
    tiles = {"lamp_dim.png"},
    light_source = 5,  -- dim
    groups = {cracky=2, oddly_breakable_by_hand=1},

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 5)
        update_lamp_brightness(pos, 0)
    end,
})

-- Lamp Node bright
core.register_node("voltz:lampbright", {
    description = "Electric Lamp",
    tiles = {"lamp_bright.png"},
    light_source = 15,  -- bright
    groups = {cracky=2, oddly_breakable_by_hand=1},

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 14)
        update_lamp_brightness(pos, 0)
    end,
})




