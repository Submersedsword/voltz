core.register_craftitem("voltz:wire", {
    description = "My Special Item",
    inventory_image = "wire.png"
})
-- Function to check if a position has a wire
local function is_wire(pos)
    local node = core.get_node(pos)
    return node.name == "voltz:wire"
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
        if is_wire(neighbor_pos) then
            local meta = core.get_meta(neighbor_pos)
            local current_power = meta:get_int("power") or 0
            if current_power < power_level then
                meta:set_int("power", power_level)
                spread_power(neighbor_pos, power_level - 10)  -- Reduce power as it spreads
            end
        end
    end
end

    -- Spread power when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "Infinite Energy Box")
        spread_power(pos, electricity.capacity)
    end
-- Wire Node (Connects Voltbox to other wires)
core.register_node("voltz:wire", {
    description = "Electric Wire",
    tiles = {"wire.png"},
    groups = {cracky=2, oddly_breakable_by_hand=1},
    -- Set wire power when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 0)  -- Default power level
    end,

    -- Update power when a wire is connected
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        spread_power(pos, 90)  -- Power spread from nearby sources
    end,
})
local electricity = {
    max_capacity = 100,  -- Max voltage storage
    generation_rate = 10,  -- Power generated per second
}

-- Function to check if a position has a wire
local function is_wire(pos)
    local node = core.get_node(pos)
    return node.name == "voltz:wire"
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
        if is_wire(neighbor_pos) then
            local meta = core.get_meta(neighbor_pos)
            local current_power = meta:get_int("power") or 0
            if current_power < power_level then
                meta:set_int("power", power_level)
                spread_power(neighbor_pos, power_level - 10)  -- Power decreases as it spreads
            end
        end
    end
end

-- Function to generate power in the voltbox
local function generate_power(pos)
    local meta = core.get_meta(pos)
    local stored_power = meta:get_int("power") or 0
    stored_power = math.min(stored_power + electricity.generation_rate, electricity.max_capacity)
    meta:set_int("power", stored_power)
    spread_power(pos, stored_power)
    minetest.after(1, generate_power, pos)  -- Schedule next power generation
end

    -- Initialize power generation when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "Power Generator")
        meta:set_int("power", 0)
        generate_power(pos)
    end
-- Wire Node (Connects Voltbox to other wires)
core.register_node("voltz:wire", {
    description = "Electric Wire",
    tiles = {"wire.png"},
    groups = {cracky=2, oddly_breakable_by_hand=1},

    -- Set wire power when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 0)  -- Default power level
    end,

    -- Update power when a wire is connected
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        spread_power(pos, 90)  -- Power spread from nearby sources
    end,
})
local electricity = {
    max_capacity = 100,  -- Max voltage storage
    generation_rate = 10,  -- Power generated per second
}

-- Wire types and their power loss rates
local wire_types = {
    ["voltz:wire_low"] = { loss = 15 },  -- Loses more energy
    ["voltz:wire_high"] = { loss = 5 },  -- More efficient
}

-- Function to check if a position contains a wire
local function is_wire(pos)
    local node = core.get_node(pos)
    return wire_types[node.name] ~= nil
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
        local node = core.get_node(neighbor_pos)
        local wire_info = wire_types[node.name]

        if wire_info then
            local meta = core.get_meta(neighbor_pos)
            local current_power = meta:get_int("power") or 0
            if current_power < power_level then
                meta:set_int("power", power_level)
                spread_power(neighbor_pos, power_level - wire_info.loss)  -- Reduce power based on wire type
            end
        end
    end
end

-- Function to generate power in the voltbox
local function generate_power(pos)
    local meta = core.get_meta(pos)
    local stored_power = meta:get_int("power") or 0
    stored_power = math.min(stored_power + electricity.generation_rate, electricity.max_capacity)
    meta:set_int("power", stored_power)
    spread_power(pos, stored_power)
    minetest.after(1, generate_power, pos)  -- Schedule next power generation
end

    -- Initialize power generation when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("infotext", "Power Generator")
        meta:set_int("power", 0)
        generate_power(pos)
    end

-- Low Voltage Wire (Loses more power)
core.register_node("voltz:wire_low", {
    description = "Low Voltage Wire",
    tiles = {"wire_low.png"},
    groups = {cracky=2, oddly_breakable_by_hand=1},

    -- Set wire power when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 0)
    end,

    -- Update power when a wire is placed
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        spread_power(pos, 90)  -- Spread power from nearby sources
    end,
})

-- High Voltage Wire (Transfers power efficiently)
core.register_node("voltz:wire_high", {
    description = "High Voltage Wire",
    tiles = {"wire_high.png"},
    groups = {cracky=2, oddly_breakable_by_hand=1},

    -- Set wire power when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 0)
    end,

    -- Update power when a wire is placed
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        spread_power(pos, 90)  -- Spread power from nearby sources
    end,
})
local electricity = {
    max_capacity = 100,  -- Max voltage storage
    generation_rate = 10,  -- Power generated per second
}

-- Wire types and their power loss rates
local wire_types = {
    ["voltz:wire_low"] = { loss = 15 },
    ["voltz:wire_high"] = { loss = 5 },
}

-- Function to check if a position has a wire
local function is_wire(pos)
    local node = core.get_node(pos)
    return wire_types[node.name] ~= nil
end

-- Function to spread power through connected wires
local function spread_power(pos, power_level)
    local positions = {
        {x = pos.x + 1, y = pos.y, z = pos.z},
        {x = pos.x - 1, y = pos.y, z = pos.z},
        {x = pos.x, y = pos.y, z = pos.z + 1},
        {x = pos.x, y = pos.y, z = pos.z - 1},
    }

    for _, neighbor_pos in ipairs(positions) do
        local node = core.get_node(neighbor_pos)
        local wire_info = wire_types[node.name]

        if wire_info then
            local meta = core.get_meta(neighbor_pos)
            local current_power = meta:get_int("power") or 0
            if current_power < power_level then
                meta:set_int("power", power_level)
                spread_power(neighbor_pos, power_level - wire_info.loss)
            end
        elseif node.name == "voltz:lamp" or node.name == "voltz:electric_furnace" then
            local meta = core.get_meta(neighbor_pos)
            meta:set_int("power", power_level)
            update_lamp_brightness(neighbor_pos, power_level)
            update_furnace_speed(neighbor_pos, power_level)
        end
    end
end

-- Function to generate power in the voltbox
local function generate_power(pos)
    local meta = core.get_meta(pos)
    local stored_power = meta:get_int("power") or 0
    stored_power = math.min(stored_power + electricity.generation_rate, electricity.max_capacity)
    meta:set_int("power", stored_power)
    spread_power(pos, stored_power)
    minetest.after(1, generate_power, pos)
end

-- Low Voltage Wire
core.register_node("voltz:wire_low", {
    description = "Low Voltage Wire",
    tiles = {"wire_low.png"},
    groups = {cracky=2, oddly_breakable_by_hand=1},

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 0)
    end,
})

-- High Voltage Wire
core.register_node("voltz:wire_high", {
    description = "High Voltage Wire",
    tiles = {"wire_high.png"},
    groups = {cracky=2, oddly_breakable_by_hand=1},

    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("power", 0)
    end,
})




