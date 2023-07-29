local modpath = minetest.get_modpath("tidesandfloods")

tidesandfloods = {sealevel = 1}

storage = minetest.get_mod_storage()
if tonumber(storage:get_int("sealevel")) == nil then
    storage:set_string("sealevel", 1)
end
tidesandfloods.sealevel = tonumber(storage:get_int("sealevel"))

function set_sealevel(v)
    tidesandfloods.sealevel = tonumber(v)
    minetest.chat_send_all("tidesandfloods.sealevel = " .. tostring(v))
    return storage:set_int("sealevel", tonumber(v))-- , "sealevel height = " .. tostring(v)
end

dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/voxelmanip.lua")
dofile(modpath .. "/lbm.lua")
dofile(modpath .. "/abm.lua")
if minetest.get_modpath("flowers") ~= nil then
    dofile(modpath .. "/waterlily.lua")
end

--COMMAND: SEALEVEL
minetest.register_privilege("sealevel", "player can use /sealevel command")

minetest.register_chatcommand("sealevel", {
    params = "<height>",
    description = "choose sealevel height",
    privs = {sealevel=true},
    func = function(name, param)
    if tonumber(param) == nil then--or type(param) ~= number then
        return false, "Current sealevel is " .. tostring(tidesandfloods.sealevel) .. " ; type = " .. type(param)
    else
        set_sealevel(tonumber(param))
        return true
    end
  end
})

--COMMAND: COMPARE BLOCK STATUS
minetest.register_chatcommand("compare_block_status", {
    params = "<name> <X>,<Y>,<Z>",
    description = "compare_block_status",
    func = function(name, param)
        local p = {}
        local status
        status, p.x, p.y, p.z = param:match(
                "^([^ ]+) +([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
        p = vector.apply(p, tonumber)
        if status and p.x and p.y and p.z then
            return minetest.chat_send_all(
                tostring(status) .." at (" .. tostring(p.x) .. ", " .. tostring(p.y) .. ", " .. tostring(p.z) .. ") "
                .. " is " .. tostring(minetest.compare_block_status(p, tostring(status))))
        end
    end,
})


can_it_flood = function(node)
    --to not cause a loop (maybe move it outside of the function?)
    if node == "tides:wave" then return false end
    --check the node groups and parameters
    local def = minetest.registered_nodes[node] or {}
    local drawtype = def.drawtype
    local function part_of_any_group(itemname, ...) --move outside of the function only if I need it elsewhere?
        local groups = def.groups or {}
        for _, v in ipairs({...}) do
            if groups[v] and groups[v] > 0 then return true end
        end
    end
    if drawtype == "airlike" --start with the most common
        or drawtype == "flowingliquid" --continue with the other drawtype
        or def.floodable --does this require an extra check compared to checking a drawtype?
        or (drawtype == "plantlike" --end with the most complicated
            and part_of_any_group(node, "flora", "grass", "flowers", "saplings", "float","mushroom")
            )
    then
        return true
    else
        return false
    end
end