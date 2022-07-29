local modpath = minetest.get_modpath("tidesandfloods")

tidesandfloods = {sealevel = 1}
--local sealevel = tidesandfloods.sealevel

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
    if tonumber(param) == nil then
    return false, "Current sealevel is " .. tostring(tidesandfloods.sealevel)--"Missing or incorrect parameter?"
    else
    tidesandfloods.sealevel = tonumber(param)
    return true , "sealevel height = " .. tostring(tidesandfloods.sealevel)
    end
  end
})