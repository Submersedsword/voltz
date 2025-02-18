-- Register Lamp as a Craft Item
minetest.register_craftitem("voltz:lamp_off", {
    description = "Electric Lamp",
    drawtype = "mesh",
    mesh = "lamp.obj",
    inventory_image = "lamp_off.png",
    groups = {energy_device = 1}  -- Ensures compatibility with other mods
})

-- Function to get power from the nearest wire and adjust brightness accordingly
local function get_adjacent_power(pos)
    local directions = {
        {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
        {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1},
        {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0}
    }

    local max_power = 0
    local wire_type_loss = nil  -- Store the type of wire connected

    for _, dir in ipairs(directions) do
        local neighbor_pos = vector.add(pos, dir)
        local neighbor_node = minetest.get_node(neighbor_pos).name

        -- Check if it's a wire
        if minetest.get_item_group(neighbor_node, "energy_cable") > 0 then
            local meta = minetest.get_meta(neighbor_pos)
            local power = meta:get_int("power") or 0

            -- Check the wire type and apply its loss
            local wire_info = voltz.wire_types[neighbor_node]
            if wire_info then
                local adjusted_power = power - wire_info.loss  -- Adjust power based on wire loss

                -- Ensure power never goes negative
                adjusted_power = math.max(adjusted_power, 0)

                -- Store the wire type loss (for debugging)
                wire_type_loss = wire_info.loss

                -- Track the highest adjusted power
                max_power = math.max(max_power, adjusted_power)
            end
        end
    end

    -- Debugging: Show detected power and wire loss in logs
    minetest.log("action", "[Voltz] Lamp at " .. minetest.pos_to_string(pos) ..
        " detecting power: " .. max_power .. " (Wire Loss: " .. tostring(wire_type_loss) .. ")")

    return max_power
end

-- Function to update lamp brightness based on power
local function update_lamp_brightness(pos)
    local meta = minetest.get_meta(pos)
    local power = get_adjacent_power(pos)

    if power > 0 then
        local light_level = math.min(math.floor(power / 10), 14)
        meta:set_int("light_level", light_level)

        if power >= 10 then
            minetest.swap_node(pos, {name = "voltz:lamp_bright"})
        elseif power >= 5 then
            minetest.swap_node(pos, {name = "voltz:lamp_dim"})
        else
            minetest.swap_node(pos, {name = "voltz:lamp_off"})
        end
    else
        minetest.swap_node(pos, {name = "voltz:lamp_off"})
    end
end

-- Run update when lamp is placed
local function on_construct(pos)
    minetest.after(0.1, function() update_lamp_brightness(pos) end)  -- Delayed update
end

-- Register Lamp Nodes
minetest.register_node("voltz:lamp_off", {
    description = "Electric Lamp (Off)",
    drawtype = "mesh",
    mesh = "lamp.obj",
    tiles = {"lamp_off.png"},
    light_source = 0,
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_device = 1},
    on_construct = on_construct
})

minetest.register_node("voltz:lamp_dim", {
    description = "Electric Lamp (Dim)",
    drawtype = "mesh",
    mesh = "lamp.obj",
    tiles = {"lamp_dim.png"},
    light_source = 5,
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_device = 1},
    on_construct = on_construct
})

minetest.register_node("voltz:lamp_bright", {
    description = "Electric Lamp (Bright)",
    drawtype = "mesh",
    mesh = "lamp.obj",
    tiles = {"lamp_bright.png"},
    light_source = 14,
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_device = 1},
    on_construct = on_construct
})

-- Ensure lamps update on power change
minetest.register_abm({
    nodenames = {"voltz:lamp_off", "voltz:lamp_dim", "voltz:lamp_bright"},
    interval = 2,  -- Reduced update frequency
    chance = 1,
    action = function(pos, node)
        minetest.after(0.1, function() update_lamp_brightness(pos) end)  -- Add slight delay
    end
})

-- Ensure lamps update when a wire is placed nearby
minetest.register_on_placenode(function(pos, newnode)
    if minetest.get_item_group(newnode.name, "energy_cable") > 0 then
        local directions = {
            {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
            {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1},
            {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0}
        }

        for _, dir in ipairs(directions) do
            local neighbor_pos = vector.add(pos, dir)
            local neighbor_node = minetest.get_node(neighbor_pos).name
            if minetest.get_item_group(neighbor_node, "energy_device") > 0 then
                minetest.after(0.1, function() update_lamp_brightness(neighbor_pos) end)
            end
        end
    end
end)
