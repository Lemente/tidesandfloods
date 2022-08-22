--local waterlily = {"flowers:waterlily","flowers:waterlily_waving"}
--minetest.chat_send_all("test")
--for i = 1,2 do
--	minetest.chat_send_all("do the waterlily")
--	if minetest.registered_nodes["flowers:waterlily_waving"] == true then
--minetest.chat_send_all(tostring("flowers:waterlily") .. " exist")
minetest.override_item("flowers:waterlily", {
	groups = {falling_node = 1, float = 1, bouncy = 1, waving = 3, snappy = 3, flower = 1, flammable = 1},
	floodable = false,
})

--minetest.chat_send_all(tostring("flowers:waterlily_waving") .. " exist")
minetest.override_item("flowers:waterlily_waving", {
	groups = {falling_node = 1, float = 1, bouncy = 1, waving = 3, snappy = 3, flower = 1, flammable = 1},
	floodable = false,
})

--[[		on_place = function(itemstack, placer, pointed_thing)
			local pos = pointed_thing.above
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, node, placer, itemstack,
						pointed_thing)
			end

			if def and (def.liquidtype == "source" or def.liquidtype == "none") and
					minetest.get_item_group(node.name, "water") > 0 then
--				local player_name = placer and placer:get_player_name() or ""
--				if not minetest.is_protected(pos, player_name) then
--					minetest.set_node(pos, {name = "flowers:waterlily" ..
--						(def.waving == 3 and "_waving" or ""),
--						param2 = math.random(0, 3)})
--					if not minetest.is_creative_enabled(player_name) then
--						itemstack:take_item()
--					end
--				else
--					minetest.chat_send_player(player_name, "Node is protected")
--					minetest.record_protection_violation(pos, player_name)
--				end
			end

			return itemstack
		end]]
--		})
--	else
--	minetest.chat_send_all(tostring(waterlily[i]) .. " doesn't exist")
--	end
--end