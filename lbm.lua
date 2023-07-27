local get_node = minetest.get_node

-- a list of nodes that should not be considered land/shore
local water_or_air = {
	["air"] = true,
	["default:water_source"] = true,
	["default:water_flowing"] = true,
	--		["default:river_water_source"] = true,
	["default:river_water_flowing"] = true,
	["tides:water"] = true,
	["tides:air"] = true,
	["tides:wave"] = true,
	["tides:surface"] = true,
	["tides:offshore_water"] = true,
	["tides:seawater"] = true,
	["tides:shorewater"] = true,
	["ignore"] = true --/!\--
}

-- To DO : target every airlike node?
--[[
local air_and_friends = {
	["air"] = true,
	["default:water_flowing"] = true,
	["default:river_water_flowing"] = true,
	--		["tides:wave"] = true,
	["ignore"] = true --/!\--
}]]

local water_and_friends = {
	["default:water_source"] = true,
	["default:water_flowing"] = true,
	--		["default:river_water_source"] = true,
	["default:river_water_flowing"] = true,
	["tides:water"] = true,
	["tides:air"] = true,
	["tides:wave"] = true,
	["tides:offshore_water"] = true,
	["tides:seawater"] = true,
	["tides:shorewater"] = true,
	["ignore"] = true --/!\--
}


-- REPLACE SEA WATER AT GENERATION with tides:seawater; tides:offshore_water (surface only); tides:waves (surface only)

if minetest.settings:get_bool("fixwater_generated_mapblocks") then
minetest.register_lbm({
	name="tidesandfloods:water_source_lbm",
	nodenames = {"default:water_source"},
	run_at_every_load=true,
	action = function(pos)
	local check_node = {
		["east"] = get_node({x=pos.x+1, y=pos.y, z=pos.z}).name,
		["west"] = get_node({x=pos.x-1, y=pos.y, z=pos.z}).name,
		["up"]   = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name,
		["down"] = get_node({x=pos.x, y=pos.y-1, z=pos.z}).name,
		["north"] = get_node({x=pos.x, y=pos.y, z=pos.z+1}).name,
		["south"] = get_node({x=pos.x, y=pos.y, z=pos.z-1}).name
	}
	local cardinal = {"north", "south", "east", "west"}
	if check_node["up"] == "air" then
		for i = 1,4 do
			if water_or_air[check_node[cardinal[i] ] ] == nil then --if cardinal node name not in list, then
				minetest.set_node(pos,{name="tides:shorewater"})
				do return end
				break
			end
		end
		local edge_x = pos.x % 16
		local edge_z = pos.z % 16
		if (edge_x == 0 or edge_x == 15) and (edge_z == 0 or edge_z == 15) then -- if node border mapblock
			minetest.set_node(pos,{name="tides:offshore_water"})
			do return end
		end
	end
	minetest.set_node(pos,{name="tides:seawater"})-- turn every other node into seawater
end
})
end

-- SEAWATER LBM
minetest.register_lbm({
	name="tidesandfloods:seawater_lbm",
	nodenames = {"tides:seawater"},
	run_at_every_load=true,
	action = function(pos)
	local cardinal_down_pos =  {
		{x=pos.x+1, y=pos.y-1, z=pos.z},
		{x=pos.x-1, y=pos.y-1, z=pos.z},
		{x=pos.x, y=pos.y-1, z=pos.z+1},
		{x=pos.x, y=pos.y-1, z=pos.z-1}
	}

	local cardinal_down_node = {
		get_node(cardinal_down_pos[1]).name,
		get_node(cardinal_down_pos[2]).name,
		get_node(cardinal_down_pos[3]).name,
		get_node(cardinal_down_pos[4]).name
	}
--	local edge_x = pos.x % 16
--	local edge_z = pos.z % 16
	if pos.y > tidesandfloods.sealevel then
		--			minetest.after(1, function()
		minetest.remove_node(pos)
		minetest.set_node(pos,{name="air"})
		--			end)
		-- CHANGE NODES BELOW
		if pos.y == tidesandfloods.sealevel + 1 then
			if get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "tides:seawater" then -- make node below wave or mapblock edge
				if (pos.x % 16 == 0 or pos.x % 16 == 15) and (pos.z % 16 == 0 or pos.z % 16 == 15) then -- if node border mapblock
					minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:offshore_water"})
					do return end
				end
				for i = 1,4 do
					if water_or_air[cardinal_down_node[i]] == nil then
						minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:shorewater"})
						do return end
						break
					end
				end
			end
			do return end
		end
	end
	if get_node(pos:offset(0, 1, 0)).name ~= "ignore" then
		local node_above = get_node(pos:offset(0, 1, 0)).name
		local drawtype = minetest.registered_nodes[node_above].drawtype
		if drawtype == "airlike" or drawtype == "flowingliquid" then
			if pos.y > tidesandfloods.sealevel then
				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="air"})
			elseif pos.y < tidesandfloods.sealevel then
				local tide_diff = tidesandfloods.sealevel-pos.y
				for i = 1,tide_diff do
					local node_above_i = get_node({x=pos.x, y=pos.y+i, z=pos.z}).name
					local drawtype = minetest.registered_nodes[node_above_i].drawtype
					if drawtype == "airlike" or drawtype == "flowing_liquid" then
						minetest.set_node({x=pos.x, y=pos.y+i, z=pos.z},{name="tides:seawater"})
					end
				end
			end
		end
	end
end
})

-- SHOREWATER LBM
minetest.register_lbm({
	name="tidesandfloods:shorewater_lbm",
	nodenames = {"tides:shorewater"},
	run_at_every_load=true,
	action = function(pos,node)
	local cardinal_down_pos =  {
		{x=pos.x+1, y=pos.y-1, z=pos.z},
		{x=pos.x-1, y=pos.y-1, z=pos.z},
		{x=pos.x, y=pos.y-1, z=pos.z+1},
		{x=pos.x, y=pos.y-1, z=pos.z-1}
	}
	local cardinal_down_node = {
		get_node(cardinal_down_pos[1]).name,
		get_node(cardinal_down_pos[2]).name,
		get_node(cardinal_down_pos[3]).name,
		get_node(cardinal_down_pos[4]).name
	}
	if pos.y > tidesandfloods.sealevel then
		minetest.remove_node(pos)
		if pos.y == tidesandfloods.sealevel + 1 and water_and_friends[get_node({x=pos.x, y=pos.y-1, z=pos.z}).name] then
			for i = 1,4 do
				if water_or_air[cardinal_down_node[i]] == nil then
					minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:wave"})
					break
				else
					minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:seawater"})
				end
				--					do return end
			end
		end
	end
	local node_above = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
	local drawtype = minetest.registered_nodes[node_above].drawtype
	if drawtype == "airlike" or drawtype == "flowing_liquid" then
		--			if pos.y > tidesandfloods.sealevel then
			--				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="air"})
			if pos.y < tidesandfloods.sealevel then
				local tide_diff = tidesandfloods.sealevel-pos.y
				for i = 1,tide_diff do
					local node_above_i = get_node({x=pos.x, y=pos.y+i, z=pos.z}).name
					local drawtype = minetest.registered_nodes[node_above_i].drawtype
					if drawtype == "airlike" or drawtype == "flowing_liquid" then
						minetest.set_node({x=pos.x, y=pos.y+i, z=pos.z},{name="tides:shorewater"})
					end
				end
			end
		end
	end
})

-- OFFSHORE_WATER LBM
minetest.register_lbm({
	name="tidesandfloods:offshore_water_lbm",
	nodenames = {"tides:offshore_water"},
	run_at_every_load=true,
	action = function(pos)
	if pos.y > tidesandfloods.sealevel then
		minetest.remove_node(pos)
		if pos.y == tidesandfloods.sealevel + 1 and water_and_friends[get_node({x=pos.x, y=pos.y-1, z=pos.z}).name] then
			minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:offshore_water"})
			do return end
		end
	end
	local node_above = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
	local drawtype = minetest.registered_nodes[node_above].drawtype
	--if air_and_friends[node_above] then
	if drawtype == "airlike" or drawtype == "flowing_liquid" then
		--			if pos.y > tidesandfloods.sealevel then
			--				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="air"})
			if pos.y < tidesandfloods.sealevel then
				local tide_diff = tidesandfloods.sealevel-pos.y
				for i = 1,tide_diff do
					local node_above_i = get_node({x=pos.x, y=pos.y+i, z=pos.z}).name
					if can_it_flood(node_above_i) then
						minetest.set_node({x=pos.x, y=pos.y+i, z=pos.z},{name="tides:offshore_water"})
					end
				end
			end
		end
	end
})



-- WAVE LBM
minetest.register_lbm({
	name="tidesandfloods:wave_lbm",
	nodenames = {"tides:wave"},
	run_at_every_load=true,
	action = function(pos)
	if pos.y > tidesandfloods.sealevel then
		minetest.remove_node(pos)
		if pos.y == tidesandfloods.sealevel + 1 and water_and_friends[get_node({x=pos.x, y=pos.y-1, z=pos.z}).name] then
			minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:seawater"})
			do return end
		end
	end
	local node_above = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
	local drawtype = minetest.registered_nodes[node_above].drawtype
	if drawtype == "airlike" or drawtype == "flowing_liquid" then
			if pos.y < tidesandfloods.sealevel then
				minetest.set_node(pos,{name="tides:seawater"})
				local tide_diff = tidesandfloods.sealevel-pos.y
				for i = 1,tide_diff do
					local node_above_i = get_node({x=pos.x, y=pos.y+i, z=pos.z}).name
					if can_it_flood(node_above_i) then
						minetest.set_node({x=pos.x, y=pos.y+i, z=pos.z},{name="tides:seawater"})
					end
				end
			end
		end
	end
})