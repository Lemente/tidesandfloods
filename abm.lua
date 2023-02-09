-- changes how often (in seconds) water detect a change in sealevel
-- increase for performance
local abm_long_delay = 10

-- changes how fast (in seconds) water spread or recess
-- water will travel 1 node every x seconds
-- increase for slower water and better performance
-- is capped by "abm_interval" in minetest.conf, often at 1 seconds
local abm_short_delay = 0.2 --

local get_node = minetest.get_node

-- a list of nodes that should not be considered land/shore
local water_or_air = {
	["air"] = true,
	["default:water_source"] = true,
	["default:water_flowing"] = true,
	--["default:river_water_source"] = true,
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
	--["tides:wave"] = true,
	["ignore"] = true --/!\--
}]]

local water_and_friends = {
	["default:water_source"] = true,
	["default:water_flowing"] = true,
	--["default:river_water_source"] = true,
	["default:river_water_flowing"] = true,
	["tides:water"] = true,
	["tides:air"] = true,
	["tides:wave"] = true,
	["tides:offshore_water"] = true,
	["tides:seawater"] = true,
	["tides:shorewater"] = true,
	["ignore"] = true --/!\--
}

-- SHOREWATER ABM
minetest.register_abm({
	name="tidesandfloods:shorewater_abm",
	nodenames={"tides:shorewater"},
	interval = abm_long_delay,
	chance = 1,
	catch_up = false,
	action=function(pos)
	local cardinal_pos =  {
		{x=pos.x+1, y=pos.y, z=pos.z},
		{x=pos.x-1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z+1},
		{x=pos.x, y=pos.y, z=pos.z-1}
	}

	local cardinal_node = {
		get_node(cardinal_pos[1]).name,
		get_node(cardinal_pos[2]).name,
		get_node(cardinal_pos[3]).name,
		get_node(cardinal_pos[4]).name
	}
	-- trigger receding tide
	if pos.y > tidesandfloods.sealevel then
		minetest.set_node(pos,{name="tides:wave"})
	-- trigger rising tide
	elseif pos.y <= tidesandfloods.sealevel then
		local count_water = 0
		for i = 1,4 do
			if can_it_flood(cardinal_node[i]) then
				minetest.set_node(pos,{name="tides:seawater"})
				break
			end
			if water_and_friends[cardinal_node[i]] then
				count_water = count_water + 1
			end
		end
		if count_water == 4 then
			minetest.set_node(pos,{name="tides:seawater"})
		end
	end
end
})

-- OFFSHORE_WATER ABM
minetest.register_abm({
	name="tidesandfloods:offshore_water_abm",
	nodenames={"tides:offshore_water"},
	interval = abm_long_delay,
	chance = 1,
	catch_up = false,
	action=function(pos)
	local cardinal_pos ={
		{x=pos.x+1, y=pos.y, z=pos.z},
		{x=pos.x-1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z+1},
		{x=pos.x, y=pos.y, z=pos.z-1}
	}

	local cardinal_node = {
		get_node({x=pos.x+1, y=pos.y, z=pos.z}).name,
		get_node({x=pos.x-1, y=pos.y, z=pos.z}).name,
		get_node({x=pos.x, y=pos.y, z=pos.z+1}).name,
		get_node({x=pos.x, y=pos.y, z=pos.z-1}).name
	}
	-- if below sealevel then rise
	if pos.y < tidesandfloods.sealevel then
		minetest.set_node(pos,{name="tides:seawater"})
		for i = 1,4 do
			local status = "active"
			if minetest.compare_block_status(cardinal_pos[i], status) ~= true then
				--if cardinal_node[i] == ignore then
				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="tides:wave"})
				break
			end
		end
	end
	-- if at sealevel then spread
	if pos.y == tidesandfloods.sealevel then
		for i = 1,4 do
			if can_it_flood(cardinal_node[i]) then
					minetest.set_node(cardinal_pos[i],{name="tides:wave"})
			end
		end
	end
end
})

-- WAVE ABM
minetest.register_abm({
	name="tidesandfloods:wave_abm",
	nodenames={"tides:wave"},
	interval = abm_short_delay,
	chance = 1,
	catch_up = false,
	action=function(pos)
	local cardinal_pos =  {
		{x=pos.x+1, y=pos.y, z=pos.z},
		{x=pos.x-1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z+1},
		{x=pos.x, y=pos.y, z=pos.z-1}
	}

	local cardinal_node = {
		get_node(cardinal_pos[1]).name,
		get_node(cardinal_pos[2]).name,
		get_node(cardinal_pos[3]).name,
		get_node(cardinal_pos[4]).name
	}

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

	local edge_x = pos.x % 16
	local edge_z = pos.z % 16
	-- TIDE GOES DOWN
	if pos.y > tidesandfloods.sealevel then
		minetest.set_node(pos,{name="air"})
		minetest.after(0.1, function() -- to counter ABM directional bias
			for i = 1,4 do
				if water_and_friends[cardinal_node[i]] and cardinal_node[i] ~= "tides:wave" then
					minetest.set_node(cardinal_pos[i],{name="tides:wave"})
				end
			end
		end)
		-- CHANGE NODES BELOW
		if get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "tides:seawater" then
			if (pos.x % 16 == 0 or pos.x % 16 == 15) and (pos.z % 16 == 0 or pos.z % 16 == 15) then
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
	-- TIDE GOES UP
	elseif pos.y <= tidesandfloods.sealevel then
		-- look for air around, set wave there, become seawater
		for i = 1,4 do
			-- if node should be flooded
			if can_it_flood(cardinal_node[i]) then
				-- make things from float group rise with the tide
				local float = minetest.get_item_group(cardinal_node[i], "float")
				if float >= 1 then
					local cardinal_pos_up = vector.add(cardinal_pos[i],(vector.new(0,1,0)))
					local cardinal_node_up = get_node(cardinal_pos_up).name
					if can_it_flood(cardinal_node_up) then -- remove check for floating nodes?
						minetest.set_node(cardinal_pos[i], {name = tostring(cardinal_node_up)})
						minetest.set_node(cardinal_pos_up, {name = cardinal_node[i]})
					else break
					end
				end
				--
				minetest.after(0.1, function() -- to counter ABM directional bias
					minetest.set_node(cardinal_pos[i],{name="tides:wave"})
					if (edge_x == 0 or edge_x == 15) and (edge_z == 0 or edge_z == 15) then -- if in a mapblock corner/vertical edge
						minetest.set_node({x=pos.x, y=pos.y, z=pos.z},{name="tides:offshore_water"})
					else
						-- if touch shore then become shorewater
						local shore = false
						for  j = 1,4 do
							if water_or_air[cardinal_node[j]] == nil then
								minetest.set_node(pos,{name="tides:shorewater"})
								shore = true
								break
							end
						end
						--else become seawater
						if shore == false then
							minetest.set_node(pos,{name="tides:seawater"})
						end
					end
				end)
			end
		end
		for i = 1,4 do
			if water_or_air[cardinal_node[i]] == nil then
				minetest.set_node(pos,{name="tides:shorewater"})
			end
		end
		-- CLEAN BELOW THE SURFACE AS TIDE GOES
		local node_below = get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
		if  node_below ~= "tides:seawater" and water_and_friends[node_below] then
			minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:seawater"})
		end
		-- if surrounded by seawater, become seawater
		local seawater = 0
		for i = 1,4 do
			if water_and_friends[cardinal_node[i]] then
				seawater = seawater + 1
			end
		end
		if seawater == 4 then
			if (edge_x == 0 or edge_x == 15) and (edge_z == 0 or edge_z == 15) then -- if node border mapblock
				minetest.set_node({x=pos.x, y=pos.y, z=pos.z},{name="tides:offshore_water"})
			else
				minetest.set_node({x=pos.x, y=pos.y, z=pos.z},{name="tides:seawater"})
			end
		end
	end
end
})