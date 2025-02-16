-- Register Voltbox Item (Fix: Added `groups = {}` for search visibility)
core.register_craftitem("voltz:voltbox", {
    description = "Infinite Energy Storage Box",
    inventory_image = "voltbox.png",
    groups = {energy_source = 1}  -- Allows it to appear in search results
})

-- Global Electricity Table (Removed duplicate declaration)
local electricity = {
    capacity = 100,  -- Max capacity (voltbox has infinite power)
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
                spread_power(neighbor_pos, power_level - 10)  -- Reduce power as it spreads
            end
        end
    end
end

-- Register Voltbox Node (Fix: Updated description & ensured proper placement)
core.register_node("voltz:voltbox", {
    description = "Infinite Energy Storage Box",
    tiles = {"voltbox.png"},
    is_ground_content = true,
    groups = {cracky = 3, stone = 1, energy_source = 1},  -- Ensures it appears in searches

    -- Always display full energy UI on right-click
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if clicker and clicker:is_player() then
            core.show_formspec(clicker:get_player_name(), "voltz:electricity_ui", electricity.get_formspec())
        end
    end,

    -- Initialize metadata when placed
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        if meta then
            meta:set_string("infotext", "Infinite Energy Box")
            spread_power(pos, electricity.capacity)
        end
    end,
})

-- Handle UI button actions
core.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "voltz:electricity_ui" and fields.close then
        return
    end
end)
