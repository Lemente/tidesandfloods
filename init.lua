local modpath = minetest.get_modpath("tidesandfloods")

tidesandfloods = {sealevel = 1}
local sealevel = tidesandfloods.sealevel

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
--  if param >= -2 and param <=2 then -- this gives a nil error
        tidesandfloods.sealevel = tonumber(param)
        minetest.chat_send_all(type(sealevel))
        if not sealevel then
            return false, "Missing or incorrect parameter?"
        end
        return true , "sealevel height = " .. sealevel
--    end
  end,
})