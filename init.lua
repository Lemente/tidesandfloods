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
--dofile(modpath .. "/command.lua")
dofile(modpath .. "/lbm.lua")
dofile(modpath .. "/abm.lua")



--TIDE ON COMMAND
minetest.register_privilege("sealevel", "player can use /sealevel command")

minetest.register_chatcommand("sealevel", {
    params = "<height>",
    description = "choose sealevel height",
    privs = {sealevel=true},
    func = function(name, param)
    if tonumber(param) == nil then--or type(param) ~= number then
        return false, "Current sealevel is " .. tostring(tidesandfloods.sealevel) .. " ; type = " .. type(param)--"Missing or incorrect parameter?"
    else
        set_sealevel(tonumber(param))
        return true
    end
  end
})

--if minetest.compare_block_status(cardinal_pos[i], "active") ~= true then


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
                tostring(status) .." at (" .. tostring(p.x) .. ", " .. tostring(p.y) .. ", " .. tostring(p.z) .. ") " .. " is " .. tostring(minetest.compare_block_status(p, tostring(status))))
        end
    end,
})