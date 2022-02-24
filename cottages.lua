-- this file is copyright (c) 2020 Francisco Athens licensed under the terms of the MIT license
local dungeon_cellar_chance = tonumber(minetest.settings:get(
                                           "witches_dungeon_cellar_chance")) or
                                  2

local dungeon_cellar_depth_min = tonumber(
                                     minetest.settings:get(
                                         "witches_dungeon_cellar_depth_min")) or
                                     2

local dungeon_cellar_depth_max = tonumber(
                                     minetest.settings:get(
                                         "witches_dungeon_cellar_depth")) or 5

local function mts(table)
    local output = minetest.serialize(table)
    return output
end

local function mtpts(table)
    local output = minetest.pos_to_string(table)
    return output
end

-- lets see if any dungeons are near
minetest.set_gen_notify("dungeon")

-- when we are notified check if dungeon is near surface

local dungeons = {}
local d_ladder_pos = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
    local dg = minetest.get_mapgen_object("gennotify")

    if dg and dg.dungeon and #dg.dungeon > 1 then
        local cur_dg = vector.new(dg.dungeon[#dg.dungeon])
        witches.debug("dungeon registered of size " .. #dg.dungeon .. " at " ..
                          vector.to_string(cur_dg))
        -- check depth 
        local mindd = dungeon_cellar_depth_min or 2
        local maxdd = dungeon_cellar_depth_max or 5 -- max dungeon depth
        local pos_ck = vector.new(vector.add(cur_dg, vector.new(0, maxdd, 0))) -- how close does the dungeon need to be?
        local pos_alt = vector.new(vector.add(pos_ck,
                                              vector.new(0, maxdd + 20, 0))) -- ensure we are measuring above ground
        local air_check = minetest.find_nodes_in_area(pos_ck, pos_alt, "air")
        if air_check then
            -- print(#air_check.." nodes of air found!")
        end
        if #dungeons < 1 then
            witches.debug("no last dungeon to compare!!")
            table.insert(dungeons, vector.new(cur_dg))
            -- print(#dungeons)
        end
        witches.debug("current: " .. vector.to_string(cur_dg))
        witches.debug("last: " .. vector.to_string(dungeons[#dungeons]))
        local distance = vector.distance(cur_dg, dungeons[#dungeons])
        if distance > 50 and air_check and #air_check >= 20 and #air_check - 20 >
            mindd then
            -- print("Distance: "..math.round(distance).." new surface dungeon (" ..#dungeons..") found at" ..(vector.to_string(cur_dg)))
            local surface = vector.new(vector.add(pos_ck, vector.new(0, 20 +
                                                                         maxdd -
                                                                         #air_check,
                                                                     0))) -- dropping the cottage on the surface

            witches.debug("new surface dungeons found: " .. #dungeons)

            d_ladder_pos = cur_dg

            if math.random(1, dungeon_cellar_chance) == 1 then
                witches.place_cottage(surface)
            end

            table.insert(dungeons, vector.new(cur_dg))
        end
    end
end)

-- @for use by notify events
function witches.place_cottage(pos)
    -- pos,vol_vec,required_list,exception_list

    local volume = witches.grounding(pos, nil, nil, {"default:lava_source"})
    if volume then
        volume[1].y = volume[1].y + 1
        volume[2].y = volume[2].y + 1
        witches.debug("witches.place_cottage - volume passed: " .. dump(volume))

        return witches.generate_cottage(volume[1], volume[2])
    end
end

-- @more checks for placement, especially by witches
function witches.grounding(pos, vol_vec, required_list, exception_list,
                           replacement_node)

    local r_tweak = math.random(-1, 1)
    local area = vol_vec or
                     {
            x = math.random(5 + r_tweak, 9),
            y = 1,
            z = math.random(5 - r_tweak, 9)
        }

    if not pos then
        print("error: grounding failed pos checks")
        return
    end

    pos = vector.round(pos)
    -- drop checks below sea level, undecided if this is necessary...
    -- if pos.y < 0 then return end
    -- local yaw = self.object:get_yaw()
    -- print(mts(self.object:get_yaw()))

    local pos1 = {
        x = pos.x - (area.x / 2),
        y = pos.y - area.y,
        z = pos.z - (area.z / 2)
    }
    local pos2 = {x = pos.x + (area.x / 2), y = pos.y, z = pos.z + (area.z / 2)}
    local ck_pos1 = vector.subtract(pos1, 4)
    local ck_pos2 = vector.add(pos2, 4)

    -- ck_pos2.y = ck_pos2.y + 12
    -- print("pos = ".. mtpts(pos))
    -- print("pos1 = ".. mtpts(pos1))
    -- print("pos2 = ".. mtpts(pos2))

    -- test if area is suitable (no air or water)
    local rlist = required_list or {"soil", "crumbly"}
    local elist = exception_list or
                      {
            "group:stone", "group:cracky", "group:wood", "group:tree"
        }
    local exceptions = minetest.find_nodes_in_area_under_air(ck_pos1, ck_pos2,
                                                             elist)
    local protected_area = minetest.is_area_protected(ck_pos1, ck_pos2, "", 2)

    if #exceptions and #exceptions >= 1 then
        witches.debug("exceptions count = " .. #exceptions)
        return
    elseif protected_area then
        witches.debug("protected area found at " .. mtpts(protected_area))
        return
    else
        witches.debug(
            "witches.grounding - SUCCESS!" .. "pos1 = " .. mtpts(pos1) ..
                "pos2 = " .. mtpts(pos2))

        local volume = {pos1, pos2}
        local ck_volume = {ck_pos1, ck_pos2}

        return volume, ck_volume
    end
end

-- @cottage layout and materials template
local default_params = {
    -- plan_size =  {x=9, y=7 ,z=9}, --general size not including roof
    foundation_nodes = {"default:mossycobble"},
    foundation_depth = 3,
    porch_nodes = {"default:tree", "default:pine_tree", "default:acacia_tree"},
    porch_size = 2,
    first_floor_nodes = {
        "default:cobble", "default:wood", "default:pine_wood",
        "default:acacia_wood", "default:junglewood"
    },
    second_floor_nodes = {
        "default:wood", "default:pine_wood", "default:acacia_wood",
        "default:junglewood"
    },
    gable_nodes = {"default:wood", "default:junglewood"},
    roof_nodes = {"stairs:stair_wood", "stairs:stair_junglewood"},
    roof_slabs = {"stairs:slab_wood", "stairs:slab_junglewood"},
    wall_nodes = {"default:tree", "default:pine_tree", "default:acacia_tree"},
    wall_nodes_ftype = {"wall_wdir"}, -- wall_dir, wall_fdir, wall_wdir
    wall_height = 3,
    wall_height_add = 2, -- randomly added height variation to first floor
    window_nodes = {
        "default:fence_wood", "default:fence_pine_wood",
        "default:fence_acacia_wood", "default:fence_junglewood"
    },
    window_height = {1, 2}, -- height min, height max
    orient_materials = true,
    door_bottom = "doors:door_wood_witch_a",
    door_top = "doors:hidden",
    root_nodes = {"witches:jungleroots"},
    tree_types = {witches.acacia_tree, witches.acacia_tree2},
    owner = "none"
}

function witches.generate_cottage(pos1, pos2, params, secret_name)
    local working_parameters = params or default_params -- if there is nothing then initialize with defs
    pos1 = vector.round(pos1)
    pos2 = vector.round(pos2)
    local wp = working_parameters

    if params then -- get defaults for any missing params
        -- print("default params: "..minetest.serialize(default_params))
        for k, v in pairs(default_params) do
            if not params[k] then
                wp[k] = table.copy(default_params[k])
            end
        end
    else
        wp = table.copy(default_params)

    end

    -- print(minetest.serialize(wp))

    local ps = wp.porch_size or math.random(2)
    local wall_node = wp.wall_nodes[math.random(#wp.wall_nodes)]
    local root_node = wp.root_nodes[math.random(#wp.root_nodes)]
    if not minetest.registered_nodes[root_node] then
        witches.debug("can't find root node: " .. root_node)
        root_node = "default:tree"
    end
    local window_node = wp.window_nodes[math.random(#wp.window_nodes)]
    local window_height = wp.window_height[math.random(#wp.window_height)]
    -- start with basement
    -- local od = vector.subtract(pos2,pos1)

    local lower_corner_nodes = {
        {x = pos1.x, y = pos1.y, z = pos1.z},
        {x = pos1.x, y = pos1.y, z = pos2.z},
        {x = pos2.x, y = pos1.y, z = pos2.z},
        {x = pos2.x, y = pos1.y, z = pos1.z}
    }
    local upper_corner_nodes = {
        {x = pos1.x, y = pos2.y, z = pos1.z},
        {x = pos1.x, y = pos2.y, z = pos2.z},
        {x = pos2.x, y = pos2.y, z = pos2.z},
        {x = pos2.x, y = pos2.y, z = pos1.z}
    }

    local ucn = upper_corner_nodes
    for h = 1, wp.foundation_depth do
        for i = 1, #ucn do
            local pos = {x = ucn[i].x, y = ucn[i].y - h + 1, z = ucn[i].z}
            minetest.set_node(pos, {
                name = wp.foundation_nodes[math.random(#wp.foundation_nodes)]
            })
        end
    end

    for h = 1, wp.foundation_depth do
        for i = 1, #ucn do
            local pos = {x = ucn[i].x, y = ucn[i].y - h + 1, z = ucn[i].z}
            -- minetest.set_node(pos, {name = wp.foundation_nodes[math.random(#wp.foundation_nodes)]})
            local pos_ck = vector.new(pos.x, pos.y - 10, pos.z)
            local pillars = minetest.find_nodes_in_area(pos, pos_ck,
                                                        {"group:liquid", "air"})
            minetest.bulk_set_node(pillars, {
                name = wp.foundation_nodes[math.random(#wp.foundation_nodes)]
            })
        end
    end

    -- clear the area
    local cpos1 = {x = pos1.x - ps, y = pos2.y, z = pos1.z - ps}
    local cpos2 = {x = pos2.x + ps, y = pos2.y + 13, z = pos2.z + ps}
    local carea = vector.subtract(cpos2, cpos1)
    for h = 1, carea.y + 2 do
        for i = 1, carea.z + 1 do
            for j = 1, carea.x + 1 do

                local pos = {
                    x = cpos1.x + j - 1,
                    y = cpos1.y + h,
                    z = cpos1.z + i - 1
                }
                minetest.set_node(pos, {name = "air"})

            end
        end
    end

    -- porch
    local prnodes = wp.porch_nodes[math.random(#wp.porch_nodes)]

    local ppos1 = {x = pos1.x - ps, y = pos2.y, z = pos1.z - ps}
    local ppos2 = {x = pos2.x + ps, y = pos2.y, z = pos2.z + ps}
    local parea = vector.subtract(ppos2, ppos1)
    for i = 1, parea.z + 1 do
        for j = 1, parea.x + 1 do

            local pos = {x = ppos1.x + j - 1, y = ppos1.y, z = ppos1.z + i - 1}
            minetest.set_node(pos, {
                name = prnodes,
                paramtype2 = "facedir",
                param2 = 5
            })

        end
    end

    local pcn = {

        {x = pos1.x - ps, y = pos2.y, z = pos1.z - ps},
        {x = pos1.x - ps, y = pos2.y, z = pos2.z + ps},
        {x = pos2.x + ps, y = pos2.y, z = pos2.z + ps},
        {x = pos2.x + ps, y = pos2.y, z = pos1.z - ps}
    }
    local pcn_height = wp.foundation_depth + 1

    for h = 1, pcn_height do
        for i = 1, #pcn do
            local pos = vector.new(pcn[i].x, pcn[i].y + 2 - h, pcn[i].z)
            -- minetest.set_node(pos, {name = wall_node})
            -- minetest.set_node({x = pos.x, y = pos.y - 1, z = pos.z}, {name = root_node})
            local pos_ck = vector.new(pos.x, pos.y - 10, pos.z)
            local pillars = minetest.find_nodes_in_area(pos, pos_ck,
                                                        {"group:liquid", "air"})
            minetest.bulk_set_node(pillars, {name = wall_node})

        end
    end

    local function mr(min, max)
        local v = math.random(min, max)
        return v
    end

    local treecn = {

        {
            x = pcn[1].x - ps + mr(-1, 1),
            y = pos2.y - 1,
            z = pcn[1].z - ps + mr(-1, 1)
        },
        {
            x = pcn[2].x - ps + mr(-1, 1),
            y = pos2.y - 1,
            z = pcn[2].z + ps + mr(-1, 1)
        },
        {
            x = pcn[3].x + ps + mr(-1, 1),
            y = pos2.y - 1,
            z = pcn[3].z + ps + mr(-1, 1)
        },
        {
            x = pcn[4].x + ps + mr(-1, 1),
            y = pos2.y - 1,
            z = pcn[4].z - ps + mr(-1, 1)
        }
    }
    if wp.tree_types and #wp.tree_types >= 1 then
        ---this check fails without "minetest" game, why!?
        local tree_pos = treecn[math.random(#treecn)]
        local root_pos = vector.new(tree_pos)
        local tree_var = wp.tree_types[math.random(#wp.tree_types)]

        -- print("spawning "..tree_var )
        root_pos.y = root_pos.y - 1
        minetest.spawn_tree(tree_pos, tree_var)
        -- minetest.set_node(root_pos, {name = root_node})
        local pos_ck = vector.new(tree_pos.x, tree_pos.y - 10, tree_pos.z)
        local roots = minetest.find_nodes_in_area(tree_pos, pos_ck,
                                                  {"group:liquid", "air"})
        minetest.bulk_set_node(roots, {name = root_node})
    end

    -- first floor!
    local ffnodes = wp.first_floor_nodes[math.random(#wp.first_floor_nodes)]
    local ffpos1 = {x = pos1.x, y = pos2.y, z = pos1.z}
    local ffpos2 = {x = pos2.x, y = pos2.y, z = pos2.z}
    local area = vector.subtract(pos2, pos1)

    for i = 1, area.z + 1 do
        for j = 1, area.x + 1 do

            local pos = {
                x = ffpos1.x + j - 1,
                y = ffpos1.y,
                z = ffpos1.z + i - 1
            }
            minetest.set_node(pos, {
                name = ffnodes,
                paramtype2 = "facedir",
                param2 = 5
            })

        end
    end
    wp.wall_height = wp.wall_height + math.random(0, wp.wall_height_add)
    -- local wall_node = wp.wall_nodes[math.random(#wp.wall_nodes)]
    if math.random() < 0.9 then
        -- wall corners wood
        for h = 1, wp.wall_height do
            for i = 1, #ucn do
                if h % 2 == 0 then
                    local pos = {x = ucn[i].x, y = ucn[i].y + h, z = ucn[i].z}
                    minetest.set_node(pos, {
                        name = wall_node,
                        paramtype2 = "facedir",
                        param2 = 5
                    })
                else
                    local pos = {x = ucn[i].x, y = ucn[i].y + h, z = ucn[i].z}
                    minetest.set_node(pos, {
                        name = wall_node,
                        paramtype2 = "facedir",
                        param2 = 13
                    })
                end
            end
        end
    else
        -- wall corners stone
        for h = 1, wp.wall_height do
            for i = 1, #ucn do
                local pos = {x = ucn[i].x, y = ucn[i].y + h, z = ucn[i].z}
                minetest.set_node(pos, {
                    name = wp.foundation_nodes[math.random(#wp.foundation_nodes)]
                })
            end
        end
    end

    -- create first floor wall plan!
    local wall_plan = {}
    for i = 1, area.z - 1 do -- west wall
        local pos = {x = ffpos1.x, y = ffpos1.y + 1, z = ffpos1.z + i}
        local fpos = {x = ffpos1.x, y = ffpos1.y + 1, z = ffpos1.z - 1}
        local dir = vector.direction(fpos, pos) -- the raw dir we can manipulate later
        local facedir = minetest.dir_to_facedir(dir) -- this facedir
        -- walldir is for placing tree nodes in wall direction
        table.insert(wall_plan,
                     {pos = pos, dir = dir, facedir = facedir, walldir = 5})

    end

    for i = 1, area.x - 1 do -- north wall
        local pos = {x = ffpos1.x + i, y = ffpos1.y + 1, z = ffpos1.z}
        local fpos = {x = ffpos1.x - 1, y = ffpos1.y + 1, z = ffpos1.z}
        local dir = vector.direction(fpos, pos)
        local facedir = minetest.dir_to_facedir(dir)
        table.insert(wall_plan,
                     {pos = pos, dir = dir, facedir = facedir, walldir = 13})
    end

    for i = 1, area.z - 1 do -- east wall
        local pos = {x = ffpos1.x + area.x, y = ffpos1.y + 1, z = ffpos1.z + i}
        local fpos = {x = ffpos1.x + area.x, y = ffpos1.y + 1, z = ffpos1.z - 1}
        local dir = vector.direction(fpos, pos)
        local facedir = minetest.dir_to_facedir(dir)
        table.insert(wall_plan,
                     {pos = pos, dir = dir, facedir = facedir, walldir = 5})
    end

    for i = 1, area.x - 1 do -- south wall
        local pos = {x = ffpos1.x + i, y = ffpos1.y + 1, z = ffpos1.z + area.z}
        local fpos = {x = ffpos1.x - 1, y = ffpos1.y + 1, z = ffpos1.z + area.z}
        local dir = vector.direction(fpos, pos)
        local facedir = minetest.dir_to_facedir(dir)
        table.insert(wall_plan,
                     {pos = pos, dir = dir, facedir = facedir, walldir = 13})
    end

    for h = 1, wp.wall_height do
        for i = 1, #wall_plan do
            minetest.set_node(wall_plan[i].pos, {

                name = wall_node,
                paramtype2 = "facedir",
                param2 = wall_plan[i].walldir
            })
        end
        for i = 1, #wall_plan do
            wall_plan[i].pos.y = wall_plan[i].pos.y + 1
        end
    end

    -- possible door locations, extra offset data
    local p_door_pos = {
        w = {
            x = ffpos1.x,
            z = ffpos1.z + math.random(2, area.z - 2),
            y = ffpos1.y + 1,
            p = "z",
            fp = {"x", -1}
        },
        n = {
            x = ffpos1.x + math.random(2, area.x - 2),
            z = ffpos2.z,
            y = ffpos1.y + 1,
            p = "x",
            fp = {"z", 1}
        },
        e = {
            x = ffpos2.x,
            z = ffpos1.z + math.random(2, area.z - 2),
            y = ffpos1.y + 1,
            p = "z",
            fp = {"x", 1}
        },
        s = {
            x = ffpos1.x + math.random(2, area.x - 2),
            z = ffpos1.z,
            y = ffpos1.y + 1,
            p = "x",
            fp = {"z", -1}
        }
    }

    local door_pos = {}
    local test = 4
    for k, v in pairs(p_door_pos) do
        if test >= 1 and math.random(test) == 1 then
            door_pos[k] = v
            test = 0
        else
            test = test - 1
        end

    end

    -- local door_pos= p_door_pos

    witches.debug("door: " .. mts(door_pos))
    for k, v in pairs(door_pos) do

        witches.debug(mts(v))
        local f_pos1 = vector.new(v)
        -- get the offsets
        f_pos1[v.fp[1]] = f_pos1[v.fp[1]] + v.fp[2]

        local dir = vector.direction(f_pos1, door_pos[k])
        local f_facedir = minetest.dir_to_facedir(dir)
        if not witches.doors then
            witches.debug("doors repalced with air")
            wp.door_bottom = "air"
            wp.door_top = "air"
        end
        minetest.set_node(v, {
            name = wp.door_bottom,
            paramtype2 = "facedir",
            param2 = f_facedir
        })

        local door_pos_t = vector.new(v)

        door_pos_t.y = door_pos_t.y + 1
        minetest.set_node(door_pos_t, {
            name = wp.door_top,
            paramtype2 = "facedir",
            param2 = f_facedir
        })

        -- set some torch-like outside the door
        local t_pos1 = vector.new(v)
        -- use fp to get outside
        t_pos1[v.fp[1]] = t_pos1[v.fp[1]] + (v.fp[2])
        -- get wallmount param2
        local t_dir = vector.direction(t_pos1, v)
        local t_wm = minetest.dir_to_wallmounted(t_dir)

        t_pos1.y = t_pos1.y + 1
        -- offset from door
        local t_pos2 = vector.new(t_pos1)
        t_pos1[v.p] = t_pos1[v.p] - 1

        t_pos2[v.p] = t_pos2[v.p] + 1
        minetest.bulk_set_node({t_pos1, t_pos2}, {
            name = "default:torch_wall",
            -- paramtype2 = "facedir",
            param2 = t_wm
        })

    end
    -- set windows

    local window_pos = {w = {}, n = {}, e = {}, s = {}}
    local az = math.floor((area.z - 2) / 2)
    local ax = math.floor((area.x - 2) / 2)
    witches.debug("az/ax= " .. az .. "  " .. ax)
    for i = 1, az do
        local wz = {
            x = ffpos1.x,
            z = ffpos1.z + math.random(2, area.z - 2),
            y = ffpos1.y + 2,
            p = "z",
            fp = {"x", 1}
        }
        table.insert(window_pos.w, wz)
        local ez = {
            x = ffpos2.x,
            z = ffpos1.z + math.random(2, area.z - 2),
            y = ffpos1.y + 2,
            p = "z",
            fp = {"x", -1}
        }
        table.insert(window_pos.e, ez)
    end
    for i = 1, ax do
        local nx = {
            x = ffpos1.x + math.random(2, area.x - 2),
            z = ffpos2.z,
            y = ffpos1.y + 2,
            p = "x",
            fp = {"z", -1}
        }
        table.insert(window_pos.n, nx)
        local sx = {
            x = ffpos1.x + math.random(2, area.x - 2),
            z = ffpos1.z,
            y = ffpos1.y + 2,
            p = "x",
            fp = {"z", 1}
        }
        table.insert(window_pos.s, sx)
    end
    witches.debug(mts(window_pos))

    for k, v in pairs(door_pos) do
        -- v is the door pos vector table
        for i = v[v.p] + 1, v[v.p] - 1, -1 do -- start with lateral axis (p) pos on either side of door
            witches.debug("doorpos " .. v.p .. " " .. i)
            for j, _ in ipairs(window_pos[k]) do -- we want the vector table value of each
                witches.debug("windowpos " .. mts(window_pos[k][j]) .. " vs " ..
                                  i)
                if window_pos[k][j] and i == window_pos[k][j][v.p] then
                    witches.debug("windowpos " .. window_pos[k][j][v.p] ..
                                      " vs " .. i)
                    witches.debug("removing window_pos[k][j][v.p] = " ..
                                      mtpts(window_pos[k][j]))
                    -- table.remove(window_pos[k],j)
                    window_pos[k][j] = nil
                end
            end
        end

    end

    if window_pos then
        for k, _ in pairs(window_pos) do
            for _, v in pairs(window_pos[k]) do

                for i = 1, window_height do

                    witches.debug("window set: " .. mtpts(v))
                    minetest.set_node({x = v.x, y = v.y - 1 + i, z = v.z},
                                      {name = window_node})

                end

            end
        end
    end

    -- set some torch-like inside near window
    if window_pos then

        for k, _ in pairs(window_pos) do
            for _, v in ipairs(window_pos[k]) do
                local t_pos1 = vector.new(v)
                -- use fp to get inside
                t_pos1[v.fp[1]] = t_pos1[v.fp[1]] + (v.fp[2])
                local t_pos2 = vector.new(t_pos1)

                -- get wallmount param2
                local t_dir = vector.direction(t_pos1, v)
                local t_wm = minetest.dir_to_wallmounted(t_dir)

                t_pos1[v.p] = t_pos1[v.p] - 1
                t_pos2[v.p] = t_pos2[v.p] + 1

                local ck_pos1 = vector.new(v)
                ck_pos1[v.p] = ck_pos1[v.p] - 1
                local ck_pos2 = vector.new(v)
                ck_pos2[v.p] = ck_pos1[v.p] + 1

                if math.random() < .5 then
                    local ck = minetest.get_node(ck_pos1)
                    witches.debug("ck: " .. ck.name)
                    if ck.name ~= window_node then
                        minetest.set_node(t_pos1, {
                            name = "default:torch_wall",
                            -- paramtype2 = "facedir",
                            param2 = t_wm

                        })
                    end
                else
                    local ck = minetest.get_node(ck_pos2)
                    witches.debug("ck: " .. ck.name)
                    if ck.name ~= window_node then
                        minetest.set_node(t_pos2, {
                            name = "default:torch_wall",
                            -- paramtype2 = "facedir",
                            param2 = t_wm
                        })
                    end
                end
            end
        end
    end
    local furnace_pos = {} -- gonna need this later!
    -- place some furniture
    if window_pos then
        local bed = ""
        if not beds then
            bed = "air"
        else
            bed = "beds:bed"
        end
        local furniture = {
            "default:bookshelf", "default:chest_locked", bed, "default:furnace"
        }

        local f_pos1 = {}
        for j in pairs(window_pos) do
            for k, v in ipairs(window_pos[j]) do
                if furniture and #furniture >= 1 then
                    f_pos1 = vector.new(v)
                    f_pos1[v.fp[1]] = f_pos1[v.fp[1]] + v.fp[2]
                    f_pos1.y = f_pos1.y - 1

                    witches.debug("window:" .. mtpts(v))
                    witches.debug("furniture:" .. mtpts(f_pos1))
                    local dir1 = vector.direction(f_pos1, v)
                    local dir2 = vector.direction(v, f_pos1)
                    local f_facedir1 = minetest.dir_to_facedir(dir1)
                    local f_facedir2 = minetest.dir_to_facedir(dir2)
                    local f_num = math.random(#furniture)
                    local f_name = furniture[f_num]

                    if f_name == "beds:bed" then
                        local f_pos2 = vector.new(f_pos1)
                        if math.random() < 0.001 then
                            f_pos2[v.fp[1]] = f_pos2[v.fp[1]] + v.fp[2]
                        else
                            f_pos2[v.p] = f_pos2[v.p] + v.fp[2] -- bed along wall_nodes
                            dir1 = vector.direction(f_pos2, f_pos1)
                            dir2 = vector.direction(f_pos1, f_pos2)
                            f_facedir1 = minetest.dir_to_facedir(dir1)
                            f_facedir2 = minetest.dir_to_facedir(dir2)
                        end

                        minetest.set_node(f_pos1, {
                            name = f_name,
                            paramtype2 = "facedir",
                            param2 = f_facedir2
                        })
                        witches.debug("bed1:" .. mtpts(f_pos1))
                        witches.debug("bed2:" .. mtpts(f_pos2))
                        minetest.set_node(f_pos2, {
                            name = f_name,
                            paramtype2 = "facedir",
                            param2 = f_facedir1
                        })

                    elseif f_name == "default:furnace" then
                        f_pos1[v.fp[1]] = f_pos1[v.fp[1]] - v.fp[2]
                        minetest.set_node(f_pos1, {
                            name = f_name,
                            paramtype2 = "facedir",
                            param2 = f_facedir1
                        })
                        furnace_pos = vector.new(f_pos1)
                    elseif f_name == "default:chest_locked" then

                        minetest.set_node(f_pos1, {
                            name = f_name,
                            paramtype2 = "facedir",
                            param2 = f_facedir1,
                            protected = 1
                        })

                        minetest.registered_nodes[f_name].on_construct(f_pos1);
                        local meta = minetest.get_meta(f_pos1);
                        local inv = meta:get_inventory();
                        meta:set_string("secret_type", "witches_chest")

                        if secret_name then
                            meta:set_string("secret_name", secret_name)
                            meta:set_string("owner", secret_name)
                            meta:set_string("infotext",
                                            "Sealed chest of " .. secret_name)
                        end

                        if minetest.get_modpath("fireflies") then
                            inv:add_item("main", {name = "fireflies:bug_net"})
                        end
                        inv:add_item("main", {name = "default:meselamp"})
                        if math.random() < 0.50 then
                            for i = 1, math.random(3) do
                                inv:add_item("main", {name = "default:diamond"})
                            end
                        end

                    elseif f_name ~= "beds:bed" then
                        minetest.set_node(f_pos1, {
                            name = f_name,
                            paramtype2 = "facedir",
                            param2 = f_facedir1
                        })
                    end

                    table.remove(furniture, f_num)
                end
            end
        end
    end

    -- second_floor!
    local sfnodes = wp.second_floor_nodes[math.random(#wp.second_floor_nodes)]

    local sfpos1 = {x = ffpos1.x, y = ffpos2.y + wp.wall_height, z = ffpos1.z}
    local sfpos2 = {x = ffpos2.x, y = ffpos2.y + wp.wall_height, z = ffpos2.z}
    local sfarea = vector.subtract(sfpos2, sfpos1)
    --
    for i = 1, sfarea.z + 1 do
        for j = 1, sfarea.x + 1 do

            local pos = {
                x = sfpos1.x + j - 1,
                y = sfpos1.y + 1,
                z = sfpos1.z + i - 1
            }
            minetest.set_node(pos, {
                name = sfnodes,
                paramtype2 = "facedir",
                param2 = 5
            })

        end
    end
    --
    --[[
  for h=1, wp.wall_height-1 do
    for i=1, #ucn do
      local pos = {x=ucn[i].x, y=ucn[i].y+h+1+wp.wall_height,z=ucn[i].z}
      minetest.set_node(pos,{name=wp.foundation_nodes[math.random(#wp.foundation_nodes)]})
    end
  end
--]]
    local stovepipe_pos = {}
    -- gable and roof
    -- orientation
    local rfnum = math.random(#wp.roof_nodes)
    local rf_nodes = wp.roof_nodes[rfnum]
    if not minetest.registered_nodes[rf_nodes] then
        witches.debug("can't find roof node: " .. rf_nodes)
        rf_nodes = "default:wood"
    end
    local rf_slabs = wp.roof_slabs[rfnum]
    if not minetest.registered_nodes[rf_slabs] then
        witches.debug("can't find roof slab node: " .. rf_slabs)
        rf_slabs = "default:wood"
    end
    local gbnodes = wp.gable_nodes[rfnum]
    local orientations = {{"x", "z"}, {"z", "x"}}
    local o = orientations[math.random(#orientations)]
    local gbpos1 = vector.new({x = sfpos1.x, y = sfpos2.y + 1, z = sfpos1.z})
    local gbpos2 = vector.new({x = sfpos2.x, y = sfpos2.y + 1, z = sfpos2.z}) -- this is going to change while building
    local rfpos1 =
        vector.new({x = sfpos1.x - 1, y = sfpos2.y, z = sfpos1.z - 1})
    local rfpos2 =
        vector.new({x = sfpos2.x + 1, y = sfpos2.y, z = sfpos2.z + 1}) -- this is going to change while building

    local rfarea = vector.subtract(rfpos2, rfpos1)
    local gbarea = vector.subtract(gbpos2, gbpos1)
    local l_pos = {}
    local rfaz = math.floor(rfarea.z / 2)
    local rfax = math.floor(rfarea.x / 2)
    if math.random() < 0.5 then

        local midpoint = (rfarea.z + 1) / 2
        local gmp = rfarea.z - 1
        for i = 1, midpoint do
            for j = 1, rfarea.x + 1 do
                local pos = {
                    x = rfpos1.x + j - 1,
                    y = rfpos2.y + 1,
                    z = rfpos1.z + i - 1
                }
                minetest.set_node(pos, {
                    name = rf_nodes,
                    paramtype2 = "facedir",
                    param2 = 0
                })
                -- print("mp "..midpoint)
                -- both gables are made at the same time
                for g = 1, gmp do

                    local gpos = {
                        x = gbpos1.x,
                        y = rfpos2.y + 2,
                        z = gbpos1.z + gmp - g
                    }
                    local gpos2 = {
                        x = gbpos1.x + gbarea.x,
                        y = rfpos2.y + 2,
                        z = gbpos1.z + gmp - g
                    }
                    minetest.bulk_set_node({gpos, gpos2}, {
                        name = gbnodes,
                        paramtype2 = "facedir",
                        param2 = 0
                    })

                end

            end
            -- transform coords for each step from outer dimension toward midpoint
            gmp = gmp - 2
            gbpos1.z = gbpos1.z + 1
            rfpos2.y = rfpos2.y + 1
        end

        rfpos2 = vector.new({x = sfpos2.x + 1, y = sfpos2.y, z = sfpos2.z + 1}) -- reset rfpos2 for other side of roof
        rfarea = vector.subtract(rfpos2, rfpos1)

        local rfamid = math.floor((rfarea.z + 1) / 2)
        for i = rfarea.z + 1, rfamid + 1, -1 do
            for j = 1, rfarea.x + 1 do
                local pos = {
                    x = rfpos1.x + j - 1,
                    y = rfpos2.y + 1,
                    z = rfpos1.z + i - 1
                }
                minetest.set_node(pos, {
                    name = rf_nodes,
                    paramtype2 = "facedir",
                    param2 = 2
                })
            end

            rfpos2.y = rfpos2.y + 1

        end

        if rfarea.z % 2 == 0 then
            for j = 1, rfarea.x + 1 do
                local pos = {
                    x = rfpos1.x + j - 1,
                    y = rfpos2.y,
                    z = rfpos1.z + (rfarea.z / 2)
                }
                minetest.set_node(pos, {name = rf_slabs})
            end
            -- p is positional axis along which it is made
            -- fp is the facing axis and direction inward

            local wpos1 = {
                x = rfpos1.x + 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + (rfaz),
                p = "z",
                fp = {"x", 1}
            }
            table.insert(l_pos, wpos1)
            local wpos2 = {
                x = rfpos1.x + rfarea.x - 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + (rfaz),
                p = "z",
                fp = {"x", -1}
            }
            table.insert(l_pos, wpos2)
            minetest.bulk_set_node({wpos1, wpos2}, {name = wp.window_nodes[1]})
        else
            local wpos1 = {
                x = rfpos1.x + 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + (rfaz) + 1,
                p = "z",
                fp = {"x", 1}
            }
            table.insert(l_pos, wpos1)
            local wpos2 = {
                x = rfpos1.x + 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + (rfaz),
                p = "z",
                fp = {"x", 1}
            }
            table.insert(l_pos, wpos2)
            local wpos3 = {
                x = rfpos1.x + rfarea.x - 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + (rfaz) + 1,
                p = "z",
                fp = {"x", -1}
            }
            table.insert(l_pos, wpos3)
            local wpos4 = {
                x = rfpos1.x + rfarea.x - 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + (rfaz),
                p = "z",
                fp = {"x", -1}
            }
            table.insert(l_pos, wpos4)
            minetest.bulk_set_node({wpos1, wpos2, wpos3, wpos4},
                                   {name = wp.window_nodes[1]})
        end

    else --------------------------------------------

        local gmp = rfarea.x - 1

        for j = 1, (rfarea.x + 1) / 2 do
            for i = 1, rfarea.z + 1 do

                local pos = {
                    x = rfpos1.x + j - 1,
                    y = rfpos2.y + 1,
                    z = rfpos1.z + i - 1
                }
                minetest.set_node(pos, {
                    name = rf_nodes,
                    paramtype2 = "facedir",
                    param2 = 1
                })
            end

            for g = 1, gmp do

                local gpos = {
                    x = gbpos1.x + gmp - g,
                    y = rfpos2.y + 2,
                    z = gbpos1.z
                }
                local gpos2 = {
                    x = gbpos1.x + gmp - g,
                    y = rfpos2.y + 2,
                    z = gbpos1.z + gbarea.z
                }
                minetest.bulk_set_node({gpos, gpos2}, {
                    name = gbnodes,
                    paramtype2 = "facedir",
                    param2 = 0
                })

            end
            gmp = gmp - 2
            gbpos1.x = gbpos1.x + 1
            rfpos2.y = rfpos2.y + 1
        end

        rfpos2 = vector.new({x = sfpos2.x + 1, y = sfpos2.y, z = sfpos2.z + 1}) -- reset rfpos2 for other side of roof
        rfarea = vector.subtract(rfpos2, rfpos1)

        local rfamid = math.floor((rfarea.x + 1) / 2)
        for j = rfarea.x + 1, rfamid + 1, -1 do
            for i = 1, rfarea.z + 1 do
                local pos = {
                    x = rfpos1.x + j - 1,
                    y = rfpos2.y + 1,
                    z = rfpos1.z + i - 1
                }
                minetest.set_node(pos, {
                    name = rf_nodes,
                    paramtype2 = "facedir",
                    param2 = 3
                })
            end

            rfpos2.y = rfpos2.y + 1
        end

        if rfarea.x % 2 == 0 then
            for i = 1, rfarea.z + 1 do
                local pos = {
                    x = rfpos1.x + (rfarea.x / 2),
                    y = rfpos2.y,
                    z = rfpos1.z + i - 1
                }
                minetest.set_node(pos, {name = rf_slabs})
            end
            local wpos1 = {
                x = rfpos1.x + (rfax),
                y = rfpos2.y - 2,
                z = rfpos1.z + 1,
                p = "x",
                fp = {"z", 1}
            }
            table.insert(l_pos, wpos1)
            local wpos2 = {
                x = rfpos1.x + (rfax),
                y = rfpos2.y - 2,
                z = rfpos1.z + rfarea.z - 1,
                p = "x",
                fp = {"z", -1}
            }
            table.insert(l_pos, wpos2)
            minetest.bulk_set_node({wpos1, wpos2}, {name = wp.window_nodes[1]})
        else
            local wpos1 = {
                x = rfpos1.x + (rfax),
                y = rfpos2.y - 2,
                z = rfpos1.z + 1,
                p = "x",
                fp = {"z", 1}
            }
            table.insert(l_pos, wpos1)
            local wpos2 = {
                x = rfpos1.x + (rfax) + 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + 1,
                p = "x",
                fp = {"z", 1}
            }
            table.insert(l_pos, wpos2)
            local wpos3 = {
                x = rfpos1.x + (rfax),
                y = rfpos2.y - 2,
                z = rfpos1.z + rfarea.z - 1,
                p = "x",
                fp = {"z", -1}
            }
            table.insert(l_pos, wpos3)
            local wpos4 = {
                x = rfpos1.x + (rfax) + 1,
                y = rfpos2.y - 2,
                z = rfpos1.z + rfarea.z - 1,
                p = "x",
                fp = {"z", -1}
            }
            table.insert(l_pos, wpos4)
            minetest.bulk_set_node({wpos1, wpos2, wpos3, wpos4},
                                   {name = wp.window_nodes[1]})
        end

    end
    witches.debug("ladder l_pos: " .. mts(l_pos))
    -- extend the stovepipe
    if furnace_pos and furnace_pos.x then
        -- print("furnace pos: "..mtpts(furnace_pos))
        local stovepipe = (rfpos2.y - furnace_pos.y) + 1
        -- print(rfpos2.y.." "..furnace_pos.y.." "..stovepipe)
        stovepipe_pos = vector.new(furnace_pos)
        for i = 1, stovepipe do
            stovepipe_pos.y = stovepipe_pos.y + 1
            minetest.set_node(stovepipe_pos, {name = "default:cobble"})
        end
    end

    -- drop a ladder from the center of the gable, avoiding any doors or windows
    witches.debug("door: " .. mts(door_pos))
    if door_pos and l_pos then
        for _, d in pairs(door_pos) do
            for k, l in pairs(l_pos) do
                if l.x == d.x and l.z == d.z then
                    table.remove(l_pos, k)
                end
            end
        end
    end

    if window_pos and l_pos then
        for v, _ in pairs(window_pos) do
            for _, w in ipairs(window_pos[v]) do
                for k, l in pairs(l_pos) do
                    witches.debug("possible window before check: " .. mtpts(w))
                    witches.debug("possible ladder before check: " .. mtpts(l))
                    if math.ceil(l.x) == w.x and math.ceil(l.z) == w.z then
                        witches.debug("removing" .. mtpts(l_pos[k]))
                        table.remove(l_pos, k)
                    end
                end
            end
        end
    end

    witches.debug("possible ladder: " .. mts(l_pos))
    if l_pos and #l_pos >= 1 then

        local lpn = math.random(#l_pos)
        local lpc = l_pos[lpn]
        local ladder_length = nil
        if d_ladder_pos and d_ladder_pos.y then
            ladder_length = lpc.y - 1 - d_ladder_pos.y
        else
            ladder_length = lpc.y - 1 - ffpos1.y
        end

        local fpos = vector.new(lpc)

        fpos[lpc.fp[1]] = fpos[lpc.fp[1]] + lpc.fp[2]

        -- print("ladder:   "..mtpts(l_pos))
        -- print("ladder f: "..mtpts(fpos))

        local dir1 = vector.direction(fpos, lpc)
        local dir1_wm = minetest.dir_to_wallmounted(dir1)
        witches.debug("ladder chosen: " .. mts(lpc))
        lpc[lpc.fp[1]] = lpc[lpc.fp[1]] + lpc.fp[2]
        -- l_pos.y = l_pos.y-1

        for i = 1, ladder_length do
            lpc.y = lpc.y - 1
            minetest.set_node(lpc,
                              {name = "default:ladder_wood", param2 = dir1_wm})

        end
        witches.debug("ladder: " .. mtpts(lpc))
    else
        local loftpos1 = {x = sfpos1.x + 2, y = sfpos1.y + 1, z = sfpos1.z + 1}
        local loftpos2 = {x = sfpos2.x - 2, y = sfpos1.y + 1, z = sfpos2.z - 1}
        local loftarea = vector.subtract(loftpos2, loftpos1)
        witches.debug(dump(loftpos1))
        witches.debug(dump(loftpos2))
        witches.debug(dump(loftarea))
        for i = 1, loftarea.z + 1 do
            for j = 1, loftarea.x + 1 do
                local pos = {
                    x = loftpos1.x - 1 + j,
                    y = loftpos1.y,
                    z = loftpos1.z - 1 + i
                }
                witches.debug(mts(pos))
                minetest.set_node(pos, {name = "air"})
            end
        end

    end

    --[[
  for i=1, sfarea.z+1 do
    for j=1, sfarea.x+1 do

          local pos = {x=sfpos1.x+j-1, y=sfpos1.y+1, z=sfpos1.z+i-1}
          minetest.set_node(pos,{
            name=wp.second_floor_nodes[math.random(#wp.second_floor_nodes)]
          })

    end
  end

  for h=1, wp.wall_height-1 do
    for i=1, #ucn do
      local pos = {x=ucn[i].x, y=ucn[i].y+h+1+wp.wall_height,z=ucn[i].z}
      minetest.set_node(pos,{name=wp.foundation_nodes[math.random(#wp.foundation_nodes)]})
    end
  end
--]]

    local c_area1 = vector.new(ppos1)
    local c_area2 = vector.new(ppos2)
    if stovepipe_pos and stovepipe_pos.y then
        c_area2.y = stovepipe_pos.y

    else
        c_area2.y = c_area2.y + 12
    end

    local cottage_area = {c_area1, c_area2}
    local cottage_va = VoxelArea:new{MinEdge = c_area1, MaxEdge = c_area2}
    -- print(mts(VoxelArea))

    return l_pos
end

