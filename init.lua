
local height = 1
local get_node = minetest.get_node
local abm_long_delay = 10
local abm_short_delay = 0.2

local water_or_air = {
		["air"] = true, -- a list of nodes that should not be considered land/shore
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

local air_and_friends = {
		["air"] = true, -- how to target every airlike node?
		["default:water_flowing"] = true,
		["default:river_water_flowing"] = true,
--		["tides:wave"] = true,
		["ignore"] = true --/!\--
		}

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

--TIDE ON COMMAND
minetest.register_privilege("tide", "player can use /tide command")

minetest.register_chatcommand("tide", {
    params = "<height>",
    description = "choose tide height",
    privs = {tide=true},
    func = function(name, param)
--  if param >= -2 and param <=2 then -- this gives a nil error
        height = tonumber(param)
        minetest.chat_send_all(type(height))
        if not height then
            return false, "Missing or incorrect parameter?"
        end
        return true , "tide height = " .. height
--    end
  end,
})

-- SEAWATER
minetest.register_node("tides:seawater", {
	description = ("tides:seawater : still water"),
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "default_water_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "default_water_source_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquid_range = 3,
	liquidtype = "source",
	liquid_alternative_flowing = "tides:wave",
	liquid_alternative_source = "tides:seawater",
	liquid_renewable = true,
	floodable = false,
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 30, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1},
	--sounds = default.node_sound_water_defaults(),
})

minetest.register_node("tides:wave", {
	description = ("tides:wave"),
	drawtype = "flowingliquid",
	waving = 3,
	tiles = {"default_water.png"},
	special_tiles = {
		{
			name = "default_water_flowing_animated.png^[colorize:#99f:100",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
		{
			name = "default_water_flowing_animated.png^[colorize:#99f:100",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.5,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "tides:wave",
	liquid_alternative_source = "tides:seawater",
	liquid_renewable = false,
	floodable = true,
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	groups = {water = 3, liquid = 3, not_in_creative_inventory = 0,
		cools_lava = 1},
	--sounds = default.node_sound_water_defaults(),
})

--SHOREWATER
minetest.register_node("tides:shorewater", {
	description = ("tides:shorewater : makes tides go down"),
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "default_water_source_animated.png^[colorize:#fff:100",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "default_water_source_animated.png^[colorize:#fff:100",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
--	liquid_range = 1,
	liquidtype = "none",--"source",
--	liquid_alternative_flowing = "tides:wave",
--	liquid_alternative_source = "tides:shorewater",
	liquid_renewable = false,
	floodable = false,
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 30, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1},
	--sounds = default.node_sound_water_defaults(),
})

-- OFFSHORE_WATER
minetest.register_node("tides:offshore_water", {
	description = ("tides:offshore_water : make tides rise"),
	drawtype = "liquid",
	waving = 3,
	tiles = {
		{
			name = "default_water_source_animated.png^[colorize:#000:100",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "default_water_source_animated.png^[colorize:#000:100",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = true,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
--	liquid_range = 3,
	liquidtype = "none",
--	liquid_alternative_flowing = "tides:wave",
--	liquid_alternative_source = "tides:offshore_water",
	liquid_renewable = false,
	floodable = false,
	liquid_viscosity = 1,
	post_effect_color = {a = 103, r = 30, g = 30, b = 90},
	groups = {water = 3, liquid = 3, cools_lava = 1},
	--sounds = default.node_sound_water_defaults(),
})

-- REPLACE SEA WATER AT GENERATION with tides:seawater; tides:offshore_water (surface only); tides:waves (surface only)
minetest.register_lbm({
	name="tides:water_source_lbm",
	nodenames = {"default:water_source"},
	--neighbors = {"air"},
	run_at_every_load=true,
	action = function(pos,node)
		--minetest.chat_send_all("LBM running")
		local check_node = {["east"] = get_node({x=pos.x+1, y=pos.y, z=pos.z}).name,
							["west"] = get_node({x=pos.x-1, y=pos.y, z=pos.z}).name,
							["up"]   = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name,
							["down"] = get_node({x=pos.x, y=pos.y-1, z=pos.z}).name,
							["north"] = get_node({x=pos.x, y=pos.y, z=pos.z+1}).name,
							["south"] = get_node({x=pos.x, y=pos.y, z=pos.z-1}).name}
		local cardinal = {"north", "south", "east", "west"}
		if check_node["up"] == "air" then
			for i = 1,4 do
				if water_or_air[check_node[cardinal[i]]] == nil then --if cardinal node name not in list, then
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

-- SEAWATER LBM
minetest.register_lbm({
	name="tides:seawater_lbm",
	nodenames = {"tides:seawater"},
	run_at_every_load=true,
	action = function(pos,node)

		local cardinal_pos =  {{x=pos.x+1, y=pos.y, z=pos.z},
							   {x=pos.x-1, y=pos.y, z=pos.z},
							   {x=pos.x, y=pos.y, z=pos.z+1},
							   {x=pos.x, y=pos.y, z=pos.z-1}}

		local cardinal_node = {get_node(cardinal_pos[1]).name,
							   get_node(cardinal_pos[2]).name,
							   get_node(cardinal_pos[3]).name,
							   get_node(cardinal_pos[4]).name}

		local cardinal_down_pos =  {{x=pos.x+1, y=pos.y-1, z=pos.z},
								    {x=pos.x-1, y=pos.y-1, z=pos.z},
								    {x=pos.x, y=pos.y-1, z=pos.z+1},
								    {x=pos.x, y=pos.y-1, z=pos.z-1}}

		local cardinal_down_node = {get_node(cardinal_down_pos[1]).name,
								    get_node(cardinal_down_pos[2]).name,
								    get_node(cardinal_down_pos[3]).name,
								    get_node(cardinal_down_pos[4]).name}
		local edge_x = pos.x % 16
		local edge_z = pos.z % 16

		if pos.y > height then
--			minetest.after(1, function()
			--minetest.chat_send_all("LBM : found tides:seawater above tide level")
			minetest.remove_node(pos)
			minetest.set_node(pos,{name="air"})
--			end)
			-- CHANGE NODES BELOW
		if pos.y == height + 1 then
				if get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "tides:seawater" then -- make node below wave or mapblock edge
					if (edge_x == 0 or edge_x == 15) and (edge_z == 0 or edge_z == 15) then -- if node border mapblock
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
		local node_above = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
		if air_and_friends[node_above] then
			if pos.y > height then
				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="air"})
			elseif pos.y < height then
				local tide_diff = height-pos.y
				for i = 1,tide_diff do
					local node_above_i = get_node({x=pos.x, y=pos.y+i, z=pos.z}).name
					if air_and_friends[node_above_i] then
						minetest.set_node({x=pos.x, y=pos.y+i, z=pos.z},{name="tides:seawater"})
					end
				end
			end
		end
	end
})

-- SHOREWATER LBM
minetest.register_lbm({
	name="tides:shorewater_lbm",
	nodenames = {"tides:shorewater"},
	run_at_every_load=true,
	action = function(pos,node)
		local cardinal_down_pos =  {{x=pos.x+1, y=pos.y-1, z=pos.z},
								    {x=pos.x-1, y=pos.y-1, z=pos.z},
								    {x=pos.x, y=pos.y-1, z=pos.z+1},
								    {x=pos.x, y=pos.y-1, z=pos.z-1}}

		local cardinal_down_node = {get_node(cardinal_down_pos[1]).name,
								    get_node(cardinal_down_pos[2]).name,
								    get_node(cardinal_down_pos[3]).name,
								    get_node(cardinal_down_pos[4]).name}
		if pos.y>height then
			minetest.remove_node(pos)
			if pos.y == height + 1 and water_and_friends[get_node({x=pos.x, y=pos.y-1, z=pos.z}).name] then
				for i = 1,4 do
					if water_or_air[cardinal_down_node[i]] == nil then
						minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:shorewater"})
						break
					else
						minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:seawater"})
					end
--					do return end
				end
			end
		end
		local node_above = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
		if air_and_friends[node_above] then
--			if pos.y > height then
--				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="air"})
			if pos.y < height then
				local tide_diff = height-pos.y
				for i = 1,tide_diff do
					local node_above_i = get_node({x=pos.x, y=pos.y+i, z=pos.z}).name
					if air_and_friends[node_above_i] then
						minetest.set_node({x=pos.x, y=pos.y+i, z=pos.z},{name="tides:shorewater"})
					end
				end
			end
		end
	end
})

-- OFFSHORE_WATER LBM
minetest.register_lbm({
	name="tides:offshore_water_lbm",
	nodenames = {"tides:offshore_water"},
	run_at_every_load=true,
	action = function(pos,node)
		if pos.y > height then
			minetest.remove_node(pos)
			if pos.y == height + 1 and water_and_friends[get_node({x=pos.x, y=pos.y-1, z=pos.z}).name] then
				minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:offshore_water"})
				do return end
			end
		end
		local node_above = get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
		if air_and_friends[node_above] then
--			if pos.y > height then
--				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="air"})
			if pos.y < height then
				local tide_diff = height-pos.y
				for i = 1,tide_diff do
					local node_above_i = get_node({x=pos.x, y=pos.y+i, z=pos.z}).name
					if air_and_friends[node_above_i] then
						minetest.set_node({x=pos.x, y=pos.y+i, z=pos.z},{name="tides:offshore_water"})
					end
				end
			end
		end
	end
})

-- OFFSHORE_WATER ABM
minetest.register_abm({
	name="tides:offshore_water_abm",
	nodenames={"tides:offshore_water"},
	interval = abm_long_delay, --increase for performance. No need to check for it every seconds
	chance = 1,
	catch_up = false,
	action=function(pos,node)
		if pos.y < height then
			local cardinal_node = {get_node({x=pos.x+1, y=pos.y, z=pos.z}).name,
								   get_node({x=pos.x-1, y=pos.y, z=pos.z}).name,
								   get_node({x=pos.x, y=pos.y, z=pos.z+1}).name,
								   get_node({x=pos.x, y=pos.y, z=pos.z-1}).name}
			for i = 1,4 do
--				minetest.chat_send_all(tostring(cardinal_node[i]))
				if cardinal_node[i] == ignore then
					minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z},{name="tides:offshore_water"})
					minetest.set_node(pos,{name="tides:seawater"})
				break
				end
			end
		end
	end
})

-- WAVE ABM
minetest.register_abm({
	name="tides:wave_abm",
	nodenames={"tides:wave"},
	interval = abm_short_delay,
	chance = 1,
	catch_up = false,
	action=function(pos,node)
		local cardinal_pos =  {{x=pos.x+1, y=pos.y, z=pos.z},
							   {x=pos.x-1, y=pos.y, z=pos.z},
							   {x=pos.x, y=pos.y, z=pos.z+1},
							   {x=pos.x, y=pos.y, z=pos.z-1}}

		local cardinal_node = {get_node(cardinal_pos[1]).name,
							   get_node(cardinal_pos[2]).name,
							   get_node(cardinal_pos[3]).name,
							   get_node(cardinal_pos[4]).name}

		local cardinal_down_pos =  {{x=pos.x+1, y=pos.y-1, z=pos.z},
								    {x=pos.x-1, y=pos.y-1, z=pos.z},
								    {x=pos.x, y=pos.y-1, z=pos.z+1},
								    {x=pos.x, y=pos.y-1, z=pos.z-1}}

		local cardinal_down_node = {get_node(cardinal_down_pos[1]).name,
								    get_node(cardinal_down_pos[2]).name,
								    get_node(cardinal_down_pos[3]).name,
								    get_node(cardinal_down_pos[4]).name}
		local edge_x = pos.x % 16
		local edge_z = pos.z % 16
		-- TIDE GOES DOWN
		if pos.y > height then
			minetest.set_node(pos,{name="air"})
			minetest.after(0.1, function()
				for i = 1,4 do
					--minetest.chat_send_all(tostring(cardinal_node[i]))
					if water_and_friends[cardinal_node[i]] and cardinal_node[i] ~= "tides:wave" then
						 minetest.set_node(cardinal_pos[i],{name="tides:wave"})
					end
				end
			end)
			-- CHANGE NODES BELOW
				if get_node({x=pos.x, y=pos.y-1, z=pos.z}).name == "tides:seawater" then -- make node below wave or mapblock edge
					if (edge_x == 0 or edge_x == 15) and (edge_z == 0 or edge_z == 15) then -- if node border mapblock
						minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:offshore_water"})
--						minetest.chat_send_all("mapblock corner found")
						do return end
					end

		--			minetest.chat_send_all("no mapblock corner found, add waves below")
					for i = 1,4 do
						if water_or_air[cardinal_down_node[i]] == nil then
							minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:shorewater"})
							do return end
							break
						end
					end
				end
			--minetest.set_node(pos,{name="air"})
		-- TIDE GOES UP
		elseif pos.y <= height then
			-- look for air around, set wave there, become seawater
			for i = 1,4 do
				if air_and_friends[cardinal_node[i]] then
					--minetest.chat_send_all("found air")
					minetest.after(0.1, function()
						minetest.set_node(cardinal_pos[i],{name="tides:wave"})
						if (edge_x == 0 or edge_x == 15) and (edge_z == 0 or edge_z == 15) then -- if node border mapblock
							--minetest.chat_send_all("become offshore_water")
							minetest.set_node({x=pos.x, y=pos.y, z=pos.z},{name="tides:offshore_water"})
						else
							--minetest.chat_send_all("don't become offshore_water")
							local shore = false
							for  j = 1,4 do --check for shore
								if water_or_air[cardinal_node[j]] == nil then
									--minetest.chat_send_all("become shorewater")
									minetest.set_node(pos,{name="tides:shorewater"})
									shore = true
									break
								end
							end
							if shore == false then --else become seawater
								--minetest.chat_send_all("become seawater" .. tostring(pos))
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
--			minetest.chat_send_all("node below is " .. tostring(get_node({x=pos.x, y=pos.y-1, z=pos.z}).name))
			local node_below = get_node({x=pos.x, y=pos.y-1, z=pos.z}).name
			if  node_below ~= "tides:seawater" and water_and_friends[node_below] then
--				minetest.chat_send_all("turning it to seawater ")
				minetest.set_node({x=pos.x, y=pos.y-1, z=pos.z},{name="tides:seawater"})
				--do return end -- we don't need to look further once it has been turned to seawater
			end
			--if surrounded by seawater, become seawater
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

-- SHOREWATER ABM
minetest.register_abm({
	name="tides:shorewater_abm",
	nodenames={"tides:shorewater"},
	interval = abm_long_delay,
	chance = 1,
	catch_up = false,
	action=function(pos,node)
		local cardinal_pos =  {{x=pos.x+1, y=pos.y, z=pos.z},
							   {x=pos.x-1, y=pos.y, z=pos.z},
							   {x=pos.x, y=pos.y, z=pos.z+1},
							   {x=pos.x, y=pos.y, z=pos.z-1}}

		local cardinal_node = {get_node(cardinal_pos[1]).name,
							   get_node(cardinal_pos[2]).name,
							   get_node(cardinal_pos[3]).name,
							   get_node(cardinal_pos[4]).name}

		local cardinal_down_pos =  {{x=pos.x+1, y=pos.y-1, z=pos.z},
								    {x=pos.x-1, y=pos.y-1, z=pos.z},
								    {x=pos.x, y=pos.y-1, z=pos.z+1},
								    {x=pos.x, y=pos.y-1, z=pos.z-1}}

		local cardinal_down_node = {get_node(cardinal_down_pos[1]).name,
								    get_node(cardinal_down_pos[2]).name,
								    get_node(cardinal_down_pos[3]).name,
								    get_node(cardinal_down_pos[4]).name}

		if pos.y > height then
			minetest.set_node(pos,{name="tides:wave"})
	elseif pos.y <= height then
			local count_water = 0
			for j = 1,4 do
				if air_and_friends[cardinal_node[j]] then
					minetest.set_node(pos,{name="tides:seawater"})
					break
				end
				if water_and_friends[cardinal_node[j]] then
					count_water = count_water + 1
				end
			end
			if count_water == 4 then
				minetest.set_node(pos,{name="tides:seawater"})
			end
		end
	end
})