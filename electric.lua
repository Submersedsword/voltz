local electricity = {
    voltz = 0,  -- Default energy state
    capacity = 100,  -- Maximum storage capacity
    generation_rate = 10,  -- Energy produced per tick
    loss_rate = 5  -- Power loss per wire connection
}

-- Function to generate electricity (e.g., power plants, solar panels)
function electricity.generate(amount)
    electricity.voltz = math.min(electricity.voltz + amount, electricity.capacity)
end

-- Function to consume electricity (e.g., machines, furnaces)
function electricity.consume(amount)
    if electricity.voltz >= amount then
        electricity.voltz = electricity.voltz - amount
        return true  -- Successfully consumed power
    else
        return false  -- Not enough power
    end
end

-- Function to check if a position has a wire
local function is_wire(pos)
    local node = core.get_node(pos)
    return node.name == "voltz:wire_low" or node.name == "voltz:wire_high"
end

-- Function to spread power through connected wires
local function spread_power(pos, power_level)
    if power_level <= 0 then return end  -- Stop spreading if no power left

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
                spread_power(neighbor_pos, power_level - electricity.loss_rate)  -- Reduce power as it spreads
            end
        end
    end
end

-- Function to update power every second
local function update_electricity()
    electricity.generate(electricity.generation_rate)  -- Generate power per tick
    minetest.after(1, update_electricity)  -- Schedule next update
end

-- Start the electricity update loop
minetest.after(1, update_electricity)

-- Function to get electricity formspec
function minetest.get_formspec()
    local percent = (electricity.voltz / electricity.capacity) * 3  -- Scale for UI
    return table.concat({
        "formspec_version[4]",
        "size[6,4]",
        "label[2.3,0.5;Electricity Status]",
        "image[1.5,1.5;3,0.5;gui_progress_bg.png]",  -- Background bar
        "image[1.5,1.5;", percent, ",0.5;gui_progress_bar.png]",  -- Power bar
        "button[1.5,3;3,0.8;close;Close]"
    }, "")
end

return electricity  -- Export the electricity system for other mod files.


