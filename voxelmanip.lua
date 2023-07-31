--VOXELMANIP.lua

local c_water_or_air = {
	[minetest.get_content_id("air")] = true,
	[minetest.get_content_id("default:water_source")] = true,
	[minetest.get_content_id("default:water_flowing")] = true,
	--[minetest.get_content_id("default:river_water_source")] = true,
	[minetest.get_content_id("default:river_water_flowing")] = true,
	[minetest.get_content_id("tides:offshore_water")] = true,
	[minetest.get_content_id("tides:wave_offshorewater")] = true,
	[minetest.get_content_id("tides:seawater")] = true,
	[minetest.get_content_id("tides:wave")] = true,
	[minetest.get_content_id("tides:shorewater")] = true,
	[minetest.get_content_id("tides:wave_shorewater")] = true,
	[minetest.get_content_id("ignore")] = true --/!\--
}


minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local c_air = minetest.CONTENT_AIR
	local c_water = minetest.get_content_id("mapgen_water_source") --minetest.get_content_id("default:water_source")
	local c_offshorewater = minetest.get_content_id("tides:offshore_water")
	local c_shorewater = minetest.get_content_id("tides:shorewater")
	local c_tidewater = minetest.get_content_id("tides:seawater")
	local area = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax
	}

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			local vi = area:index(minp.x, y, z)
			for x = minp.x, maxp.x do


				if data[vi] == c_water then
					local check_node = {
							["east"] = data[area:index(x+1, y, z)],
							["west"] = data[area:index(x-1, y, z)],
							["up"]   = data[area:index(x, y+1, z)],
							--	["down"] = data[area:index({x=pos.x, y=pos.y-1, z=pos.z})],
							["north"] = data[area:index(x, y, z+1)],
							["south"] = data[area:index(x, y, z-1)]
						}
					local cardinal = {"north", "south", "east", "west"}
					--first turn any water into tidewater
					data[vi] = c_tidewater
					if check_node["up"] == c_air then
						-- then if node corner of mapblock, become shorewater
						if (x % 16 == 0 or x % 16 == 15) and (z % 16 == 0 or z % 16 == 15) then
							data[vi] = c_offshorewater
						end
						--if next to a node that's neither air or water, become shorewater
						for i = 1,4 do
							if c_water_or_air[check_node[cardinal[i]]] == nil then
								data[vi] = c_shorewater
								break
							end
						end
					end
				end


			vi = vi + 1
			end
		end
	end
	vm:set_data(data)
    vm:write_to_map(true)
end
)