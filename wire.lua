
-- Register Wire as a Craft Item
minetest.register_craftitem("voltz:wire", {
    description = "Electric Wire",
    inventory_image = "wire.obj",
    groups = {energy_cable = 1}  -- Ensures it appears in searches and works universally
})

-- Define electricity properties
local electricity = {
    max_capacity = 100,  -- Max voltage storage
    generation_rate = 10,  -- Power generated per second
}

-- Define wire types and their power loss rates
voltz.wire_types = {
    ["voltz:wire"] = { loss = 10 },       -- Standard wire
    ["voltz:wire_low"] = { loss = 15 },   -- Loses more power
    ["voltz:wire_high"] = { loss = 5 },   -- More efficient
}

-- Function to check if a node is a valid wire
local function is_wire(pos)
    local node = minetest.get_node(pos)
    return voltz.wire_types[node.name] ~= nil
end

-- Function to spread power through connected wires
local function spread_power(pos, power_level)
    local positions = {
        {x = pos.x + 1, y = pos.y, z = pos.z},  -- Right
        {x = pos.x - 1, y = pos.y, z = pos.z},  -- Left
        {x = pos.x, y = pos.y, z = pos.z + 1},  -- Front
        {x = pos.x, y = pos.y, z = pos.z - 1},  -- Back
    }

    for _, neighbor_pos in ipairs(positions) do
        local node = minetest.get_node(neighbor_pos)
        local wire_info = voltz.wire_types[node.name]

        if wire_info then
            local meta = minetest.get_meta(neighbor_pos)
            local current_power = meta:get_int("power") or 0
            if current_power < power_level then
                meta:set_int("power", power_level)
                spread_power(neighbor_pos, power_level - wire_info.loss)  -- Power weakens based on wire type
            end
        elseif minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].groups.energy_device then
            -- If a connected node is an energy-consuming device, send power to it
            local meta = minetest.get_meta(neighbor_pos)
            meta:set_int("power", power_level)
        end
    end
end

-- Function to generate power in the voltbox
local function generate_power(pos)
    local meta = minetest.get_meta(pos)
    local stored_power = meta:get_int("power") or 0
    stored_power = math.min(stored_power + electricity.generation_rate, electricity.max_capacity)
    meta:set_int("power", stored_power)
    spread_power(pos, stored_power)
    minetest.after(1, generate_power, pos)  -- Schedule next power generation
end

-- Register Standard Wire (Works Universally)
minetest.register_node("voltz:wire", {
    description = "Electric Wire",
    drawtype = "mesh",
    mesh = "wire.obj",
    tiles = {"wire.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_cable = 1},  -- Universal electricity cable

    -- Initialize power when placed
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("power", 0)
    end,

    -- Spread power when placed near energy sources
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        spread_power(pos, 90)
    end,
})

-- Register Low Voltage Wire (Loses More Power)
minetest.register_node("voltz:wire_low", {
    description = "Low Voltage Wire",
    tiles = {"wire_low.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_cable = 1},

    -- Initialize power when placed
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("power", 0)
    end,
})
    -- Spread power when placed
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        spread_power(pos, 90)
    end,

-- Register High Voltage Wire (Efficient Power Transfer)
minetest.register_node("voltz:wire_high",{
    description = "High Voltage Wire",
    tiles = {"wire_high.png"},
    groups = {cracky = 2, oddly_breakable_by_hand = 1, energy_cable = 1},

    -- Initialize power when placed
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_int("power", 0)

    -- Spread power when placed
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        spread_power(pos, 90)
    end
end
})
-- Make Wires Work with Any Luanti Energy Mod
minetest.register_on_mods_loaded(function()
    for name, def in pairs(minetest.registered_nodes) do
        if def.groups and def.groups.energy_device then
            voltz.wire_types[name] = { loss = 10 }  -- Automatically register any energy-consuming device
        end
    end
end)
