local electricity = {
    voltz = 0,  -- default energy state
    capacity = 100  -- Max capacity
}

-- Function to generate the formspec with an always-full electricity bar
function electricity.get_formspec()
    return table.concat({
        "formspec_version[4]",
        "size[6,4]",
        "label[2.3,0.5;Electricity Status]",
        "image[1.5,1.5;3,0.5;gui_progress_bg.png]",  -- Background bar
        "image[1.5,1.5;3,0.5;gui_progress_bar.png]",  -- Always fully filled bar
        "button[1.5,3;3,0.8;close;Close]"
    }, "")
end

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
