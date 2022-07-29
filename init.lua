local modpath = minetest.get_modpath("tidesandfloods")


tidesandfloods = {sealevel = 1}

storage = minetest.get_mod_storage()
tidesandfloods.sealevel = tonumber(storage:get_int("sealevel"))

--if tidesandfloods.sealevel == nil then
--	storage:set_string("sealevel", 1)
--end

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