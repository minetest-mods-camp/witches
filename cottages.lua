--this file is copyright (c) 2020 Francisco Athens licensed under the terms of the MIT license

local witches_dungeon_cellar_chance = tonumber(minetest.settings:get("witches_dungeon_cellar_chance")) or .50
local witches_dungeon_cellar_depth = tonumber(minetest.settings:get("witches_dungeon_cellar_depth")) or -5

local function mts(table)
  local output = minetest.serialize(table) 
  return output
end

local function mtpts(table)
  local output = minetest.pos_to_string(table) 
  return output
end

--lets see if any dungeons are near
minetest.set_gen_notify("dungeon")
local dungeon_cellar = {
									 chance = tonumber(witches_dungeon_cellar_chance), -- chance to try putting cottage over dungeon instead of anywhere else
									 max_depth = tonumber(witches_dungeon_cellar_depth) -- deepest dungeon depth to check
}

local dungeon_list ={}

minetest.register_on_generated(function(minp, maxp, blockseed)
  local dg = minetest.get_mapgen_object("gennotify")
	if dg and dg.dungeon and #dg.dungeon > 2 then
		 for i=1,#dg.dungeon do
      if dg.dungeon[i].y >= dungeon_cellar.max_depth then
			--print("dungeon found: "..minetest.pos_to_string(dg.dungeon[i]))

			table.insert(dungeon_list, dg.dungeon[i])
			end
		 end
	end
end)

--local vol_vec = {x=5,y=5,z=5}
function witches.grounding(self,vol_vec,required_list,exception_list,replacement_node)
  local r_tweak = math.random(-1,1)
  local area = vol_vec or {x=math.random(5+r_tweak,9),y=1,z=math.random(5-r_tweak,9)}
  local pos = vector.round(self.object:get_pos())
    --drop checks below sea level
    if pos.y < 0 then return end
  --local yaw = self.object:get_yaw()
  --print(mts(self.object:get_yaw()))

  local pos1 = {x= pos.x-(area.x/2),y=pos.y-area.y ,z= pos.z-(area.z/2)}
  local pos2 = {x= pos.x+(area.x/2),y=pos.y, z= pos.z+(area.z/2)}

  --print("pos = ".. mtpts(pos))
  --print("pos1 = ".. mtpts(pos1))
  --print("pos2 = ".. mtpts(pos2))

  --test if area is suitable (no air or water)
  local rlist = required_list or {"group:soil","group:crumbly"}
  local elist = exception_list or {}
  local minichunk = minetest.find_nodes_in_area(pos1, pos2,rlist)
  
  for i=1, #minichunk do
    for n=1, #elist do
      if minetest.get_node(minichunk[i].name) == elist[n] then
        table.remove(minichunk,i)
      end
    end
  end
  --print(mts(minichunk))
  --see that lowest nodes all exist at pos1.y or die
  local count = 0
  
  if #minichunk >= (area.x * area.z*1.4)  then
    print("SUCCESS!".."pos1 = ".. mtpts(pos1).."pos2 = ".. mtpts(pos2).." count = "..#minichunk)
    if replacement_node then
      minetest.bulk_set_node(minichunk,{name = replacement_node})
    end
    local volume = {pos1,pos2}
    return volume
  else
    --print("insufficient count = "..#minichunk)
  end
 
end

local cottage_id = nil
local default_params = {
  --plan_size =  {x=9, y=7 ,z=9}, --general size not including roof
  foundation_nodes = {"default:mossycobble"},
  foundation_depth = 3, 
  porch_nodes =         {"default:tree","default:pine_tree","default:acacia_tree"},
  porch_size = 2,
  first_floor_nodes =   {"default:cobble","default:wood","default:pine_wood","default:acacia_wood","default:junglewood"},
  second_floor_nodes =  {"default:wood","default:pine_wood","default:acacia_wood","default:junglewood"},
  gable_nodes =         {"default:wood","default:junglewood"},
  roof_nodes =          {"stairs:stair_wood","stairs:stair_junglewood"},
  roof_slabs =          {"stairs:slab_wood","stairs:slab_junglewood"},
  wall_nodes =          {"default:tree","default:pine_tree","default:acacia_tree"},
  wall_nodes_ftype = {"wall_wdir"}, --wall_dir, wall_fdir, wall_wdir 
  wall_height = 3,
  window_nodes = {"default:fence_wood","default:fence_pine_wood","default:fence_acacia_wood","default:fence_junglewood"},
  window_dimensions = {1,1,1,2}, --width,height min; width,height max
  orient_materials = true,
  door_bottom = "doors:door_wood_witch_a";
  door_top    = "doors:hidden";
}

function witches.generate_cottage(pos1,pos2,params)
  local working_parameters = params or default_params -- if there is nothing then initialize with defs
  pos1 = vector.round(pos1)
  pos2 = vector.round(pos2)
  local wp = working_parameters
  if params then --get defaults for any missing params
    for k,v in default_params do
     if not params[k] then 
      wp[k] = table.copy(default_params[k])
     end
    end
  else wp = table.copy(default_params)
  
  end
  
  --start with basement
  --local od = vector.subtract(pos2,pos1)
  
  local lower_corner_nodes = {
     pos1,
     {x= pos1.x, y = pos1.y, z = pos2.z},
     {x= pos2.x, y = pos1.y, z = pos2.z},
     {x= pos2.x, y = pos1.y, z = pos1.z},
  }
  local upper_corner_nodes = {
    
    {x= pos1.x, y = pos2.y, z = pos1.z},
    {x= pos1.x, y = pos2.y, z = pos2.z},
    pos2,
    {x= pos2.x, y = pos2.y, z = pos1.z},
  }
  local ucn = upper_corner_nodes
  for h=1, wp.foundation_depth do
   for i=1, #ucn do
    local pos = {x=ucn[i].x, y=ucn[i].y-h+1,z=ucn[i].z}
    minetest.set_node(pos,{name=wp.foundation_nodes[math.random(#wp.foundation_nodes)]})
   end
  end


  local ps = wp.porch_size or math.random(2)

 -- clear the area 
 local cpos1 = {x = pos1.x-ps, y=pos2.y+5 ,z=pos1.z-ps}
 local cpos2 = {x = pos2.x+ps, y=pos2.y+13, z=pos2.z+ps}
 local carea = vector.subtract(cpos2,cpos1)
 for h=1,carea.y+2 do
   for i=1, carea.z+1 do
     for j=1, carea.x+1 do

           local pos = {x=cpos1.x+j-1, y=cpos1.y, z=cpos1.z+i-1}
           minetest.set_node(pos,{
             name="air"
           })

     end
   end
 end

  -- porch
  local prnodes = wp.porch_nodes[math.random(#wp.porch_nodes)]
  

  local ppos1 = {x = pos1.x-ps, y=pos2.y ,z=pos1.z-ps}
  local ppos2 = {x = pos2.x+ps, y=pos2.y, z=pos2.z+ps} 
  local parea = vector.subtract(ppos2,ppos1)
  for i=1, parea.z+1 do
    for j=1, parea.x+1 do

          local pos = {x=ppos1.x+j-1, y=ppos1.y, z=ppos1.z+i-1}
          minetest.set_node(pos,{
            name=prnodes,
            paramtype2="facedir",
            param2=5
          })

    end
  end


  --first floor!
  local ffnodes = wp.first_floor_nodes[math.random(#wp.first_floor_nodes)]
  local ffpos1 = {x = pos1.x, y=pos2.y ,z=pos1.z}
  local ffpos2 = {x = pos2.x, y=pos2.y, z=pos2.z} 
  local area = vector.subtract(pos2,pos1)

  for i=1, area.z+1 do
    for j=1, area.x+1 do

          local pos = {x=ffpos1.x+j-1, y=ffpos1.y, z=ffpos1.z+i-1}
          minetest.set_node(pos,{
            name=ffnodes,
            paramtype2="facedir",
            param2=5
          })

    end
  end

  local wlnodes = wp.wall_nodes[math.random(#wp.wall_nodes)]
  if math.random() < 0.9 then
    --wall corners wood
    for h=1, wp.wall_height do
      for i=1, #ucn do
        if  h % 2 == 0 then
          local pos = {x=ucn[i].x, y=ucn[i].y+h,z=ucn[i].z}
          minetest.set_node(pos,{
                                  name=wlnodes,
                                  paramtype2="facedir",
                                  param2=5
                                })
        else
          local pos = {x=ucn[i].x, y=ucn[i].y+h,z=ucn[i].z}
          minetest.set_node(pos,{
                                  name=wlnodes,
                                  paramtype2="facedir",
                                  param2=13
                                })
        end
      end
    end
  else
    --wall corners stone
    for h=1, wp.wall_height do
      for i=1, #ucn do
        local pos = {x=ucn[i].x, y=ucn[i].y+h,z=ucn[i].z}
        minetest.set_node(pos,{name=wp.foundation_nodes[math.random(#wp.foundation_nodes)]})
      end
    end
  end

  --create first floor wall plan!
  local wall_plan ={}

  for i=1,area.z-1 do --west wall
    local pos = {x=ffpos1.x, y=ffpos1.y+1, z=ffpos1.z+i}
    local fpos = {x=ffpos1.x, y=ffpos1.y+1, z=ffpos1.z-1}
    local dir = vector.direction(fpos,pos)        -- the raw dir we can manipulate later
    local facedir = minetest.dir_to_facedir(dir)  --this facedir 
                                                  --walldir is for placing tree nodes in wall direction
    table.insert(wall_plan, {
                  pos = pos, dir = dir, facedir = facedir, walldir = 5
    })

  end

  for i=1,area.x-1 do --north wall
    local pos = {x=ffpos1.x+i, y=ffpos1.y+1, z=ffpos1.z}
    local fpos = {x=ffpos1.x-1, y=ffpos1.y+1, z=ffpos1.z}
    local dir = vector.direction(fpos,pos)
    local facedir = minetest.dir_to_facedir(dir)
    table.insert(wall_plan, {
      pos = pos, dir = dir, facedir = facedir, walldir = 13
    })
  end

  for i=1,area.z-1 do --east wall
    local pos = {x=ffpos1.x+area.x, y=ffpos1.y+1, z=ffpos1.z+i}
    local fpos = {x=ffpos1.x+area.x, y=ffpos1.y+1, z=ffpos1.z-1}
    local dir = vector.direction(fpos,pos)
    local facedir = minetest.dir_to_facedir(dir)
    table.insert(wall_plan, {
      pos = pos, dir = dir, facedir = facedir, walldir = 5
    })
  end

  for i=1,area.x-1 do --south wall
    local pos = {x=ffpos1.x+i, y=ffpos1.y+1, z=ffpos1.z+area.z}
    local fpos = {x=ffpos1.x-1, y=ffpos1.y+1, z=ffpos1.z+area.z}
    local dir = vector.direction(fpos,pos)
    local facedir = minetest.dir_to_facedir(dir)
    table.insert(wall_plan, {
      pos = pos, dir = dir, facedir = facedir, walldir = 13
    })
  end

 
  
  for h=1, wp.wall_height do
     for i=1, #wall_plan do
       minetest.set_node(wall_plan[i].pos,{
        
        name=wlnodes,
        paramtype2 = "facedir",
        param2 = wall_plan[i].walldir
      })
    end
    for i=1, #wall_plan do
      wall_plan[i].pos.y = wall_plan[i].pos.y+1
    end
  end
--possible door locations, extra offset data 
  local p_door_pos = {
                    w = {x = ffpos1.x, z = ffpos1.z+math.random(2,area.z-2), y = ffpos1.y+1, p ="z", fp={"x",-1}},
                    n = {x = ffpos1.x+math.random(2,area.x-2), z = ffpos2.z, y = ffpos1.y+1, p ="x", fp={"z",1}},
                    e = {x = ffpos2.x, z = ffpos1.z+math.random(2,area.z-2), y = ffpos1.y+1, p ="z", fp={"x",1}},
                    s = {x = ffpos1.x+math.random(2,area.x-2), z = ffpos1.z, y = ffpos1.y+1, p ="x", fp={"z",-1}}
  }
 
  local door_pos = {}
  local test = 4
  for k,v in pairs(p_door_pos) do
    if test >= 1 and math.random(test) == 1 then
      door_pos[k]=v
      test = 0 
    else
      test = test - 1
    end

  end

  
--local door_pos= p_door_pos

  print("door: "..mts(door_pos))
  for k,v in pairs(door_pos) do
    
    print(mts(v))
    local f_pos1 = vector.new(v)
    --get the offsets
    f_pos1[v.fp[1] ] = f_pos1[v.fp[1] ] + v.fp[2] 
      
    local dir=vector.direction(f_pos1,door_pos[k])
    local f_facedir = minetest.dir_to_facedir(dir)

    minetest.set_node(v,{
      name=wp.door_bottom,
      paramtype2 = "facedir",
      param2 = f_facedir
    })

    local door_pos_t = vector.new(v)
  
    door_pos_t.y = door_pos_t.y+1
    minetest.set_node(door_pos_t,{
      name=wp.door_top,
      paramtype2 = "facedir",
      param2 = f_facedir
    })

    --set some torch-like outside the door
    local t_pos1 = vector.new(v)
    --use fp to get outside
    t_pos1[v.fp[1] ]= t_pos1[v.fp[1] ] + (v.fp[2])
    --get wallmount param2
    local t_dir = vector.direction(t_pos1,v)
    local t_wm = minetest.dir_to_wallmounted(t_dir)
    
    t_pos1.y = t_pos1.y + 1
    --offset from door
    local t_pos2 = vector.new(t_pos1)
    t_pos1[v.p] = t_pos1[v.p] - 1

    t_pos2[v.p] = t_pos2[v.p] + 1
    minetest.bulk_set_node({t_pos1, t_pos2},{
      name="default:torch_wall",
      --paramtype2 = "facedir",
      param2 = t_wm
    })


  end
--set windows
  local window_pos = {}
  window_pos = {
                    w = {x = ffpos1.x, z = ffpos1.z+math.random(2,area.z-2), y = ffpos1.y+2, p= "z", fp = {"x", 1} },
                    n = {x = ffpos1.x+math.random(2,area.x-2), z = ffpos2.z, y = ffpos1.y+2, p= "x", fp = {"z", -1} },
                    e = {x = ffpos2.x, z = ffpos1.z+math.random(2,area.z-2), y = ffpos1.y+2, p= "z", fp = {"x", -1} },
                    s = {x = ffpos1.x+math.random(2,area.x-2), z = ffpos1.z, y = ffpos1.y+2, p= "x", fp = {"z", 1} }
  }

  for k,v in pairs(door_pos) do

    for i=v[v.p]+1,v[v.p]-1,-1 do
    
      if window_pos[k] and i == window_pos[k][v.p] then 
        window_pos[k] = nil
      end
    
    end

  end

  if window_pos then
    for _,v in pairs(window_pos) do
      
        print("window set: "..mtpts(v))
        minetest.set_node(v,{
          name="default:fence_wood"
        })
        local window_pos_t = v
      --[[
        window_pos_t.y = window_pos_t.y+1
        minetest.set_node(window_pos_t,{
          name="default:fence_wood"
        })
    --]]
    end
  end

      --set some torch-like inside near window
  if window_pos then
    for _,v in pairs(window_pos) do

      local t_pos1 = vector.new(v)
      --use fp to get inside
      t_pos1[v.fp[1] ]= t_pos1[v.fp[1] ] + (v.fp[2])
      --get wallmount param2
      local t_dir = vector.direction(t_pos1,v)
      local t_wm = minetest.dir_to_wallmounted(t_dir)
      
      --t_pos1.y = t_pos1.y + 1
      --offset from window
      
      local t_pos2 = vector.new(t_pos1)
      t_pos1[v.p] = t_pos1[v.p] - 1
  
      t_pos2[v.p] = t_pos2[v.p] + 1
      if math.random() < .5 then
        minetest.set_node(t_pos1,{
          name="default:torch_wall",
          --paramtype2 = "facedir",
          param2 = t_wm
        })
      else
        minetest.set_node(t_pos2,{
          name="default:torch_wall",
          --paramtype2 = "facedir",
          param2 = t_wm
        })
      end
    end
  end
  local furnace_pos = {} --gonna need this later!
  --place some furniture
  if window_pos then
    local furniture = {"default:bookshelf","default:chest","beds:bed","default:furnace"}
    local f_pos1 ={}
    for k,v in pairs(window_pos) do
      if furniture then
        f_pos1 = vector.new(v)
        f_pos1[v.fp[1] ] = f_pos1[v.fp[1] ]+v.fp[2]
        f_pos1.y = f_pos1.y-1
        
        print("window:"..mtpts(window_pos[k]))
        print("furniture:"..mtpts(f_pos1))

        local dir1=vector.direction(f_pos1,v)
        local dir2=vector.direction(v,f_pos1)
        local f_facedir1 = minetest.dir_to_facedir(dir1)
        local f_facedir2 = minetest.dir_to_facedir(dir2)
        local f_num = math.random(#furniture)
        local f_name = furniture[f_num]
 
        if f_name == "beds:bed" then
          minetest.set_node(f_pos1,{
            name=f_name,
            paramtype2 = "facedir",
            param2 = f_facedir2
          })

          print("bed1:"..mtpts(f_pos1))
          local f_pos2 = vector.new(f_pos1)
          
          f_pos2[v.fp[1] ] = f_pos2[v.fp[1] ]+v.fp[2]

          print("bed2:"..mtpts(f_pos2))
          minetest.set_node(f_pos2,{
            name=f_name,
            paramtype2 = "facedir",
            param2 = f_facedir1
          })
        
        elseif f_name == "default:furnace" then
          f_pos1[v.fp[1] ] = f_pos1[v.fp[1] ]-v.fp[2]
          minetest.set_node(f_pos1,{
            name=f_name,
            paramtype2 = "facedir",
            param2 = f_facedir1
          })
          furnace_pos = vector.new(f_pos1)
        
        elseif f_name ~="beds:bed"  then
          minetest.set_node(f_pos1,{
            name=f_name,
            paramtype2 = "facedir",
            param2 = f_facedir1
          })
        end

        table.remove(furniture, f_num)
      end
    end
  end
  
  -- second_floor!
  local sfnodes = wp.second_floor_nodes[math.random(#wp.second_floor_nodes)]

  local sfpos1 = {x = ffpos1.x, y=ffpos2.y+wp.wall_height,z=ffpos1.z}
  local sfpos2 = {x = ffpos2.x, y=ffpos2.y+wp.wall_height, z=ffpos2.z} 
  local sfarea = vector.subtract(sfpos2,sfpos1)
--
  for i=1, sfarea.z+1 do
    for j=1, sfarea.x+1 do

          local pos = {x=sfpos1.x+j-1, y=sfpos1.y+1, z=sfpos1.z+i-1}
          minetest.set_node(pos,{
            name=sfnodes,
            paramtype2="facedir",
            param2=5
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
  
--gable and roof
  --orientation
  local rfnum = math.random(#wp.roof_nodes)
  local rfnodes = wp.roof_nodes[rfnum]
  local rfslabs = wp.roof_slabs[rfnum]
  local gbnodes = wp.gable_nodes[rfnum]
  local orientations = {{"x","z"},{"z","x"}}
  local o = orientations[math.random(#orientations)]
  local gbpos1 = vector.new({x = sfpos1.x, y=sfpos2.y+1, z=sfpos1.z})
  local gbpos2 = vector.new({x = sfpos2.x, y=sfpos2.y+1, z=sfpos2.z}) --this is going to change while building
  local rfpos1 = vector.new({x = sfpos1.x-1, y=sfpos2.y, z=sfpos1.z-1})
  local rfpos2 = vector.new({x = sfpos2.x+1, y=sfpos2.y, z=sfpos2.z+1}) --this is going to change while building

  local rfarea = vector.subtract(rfpos2,rfpos1)
  local gbarea = vector.subtract(gbpos2,gbpos1)
  local l_pos = {}

  if math.random() < 0.5 then

    local midpoint = (rfarea.z+1)/2
    local gmp = rfarea.z-1
    for i=1, midpoint do
      for j=1, rfarea.x+1 do
        local pos = {x=rfpos1.x+j-1, y=rfpos2.y+1, z=rfpos1.z+i-1}
        minetest.set_node(pos,{
          name=rfnodes,
          paramtype2="facedir",
          param2=0
        })
        --print("mp "..midpoint)
        --both gables are made at the same time
        for g=1, gmp do
          
          local gpos = {x=gbpos1.x, y=rfpos2.y+2, z=gbpos1.z+gmp-g} 
          local gpos2 = {x=gbpos1.x+gbarea.x, y=rfpos2.y+2, z=gbpos1.z+gmp-g}
          minetest.bulk_set_node({gpos,gpos2},{
            name=gbnodes,
            paramtype2="facedir",
            param2=0
          })
          
        end
  
      end
      --transform coords for each step from outer dimension toward midpoint
      gmp = gmp -2
      gbpos1.z = gbpos1.z+1 
      rfpos2.y = rfpos2.y+1
    end
    
    rfpos2 = vector.new({x = sfpos2.x+1, y=sfpos2.y, z=sfpos2.z+1})--reset rfpos2 for other side of roof
    rfarea = vector.subtract(rfpos2,rfpos1)

    local rfamid = math.floor((rfarea.z+1)/2)
    for i=rfarea.z+1,rfamid+1,-1 do
      for j=1, rfarea.x+1 do
        local pos = {x=rfpos1.x+j-1, y=rfpos2.y+1, z=rfpos1.z+i-1}
        minetest.set_node(pos,{
          name=rfnodes,
          paramtype2="facedir",
          param2=2
        })
      end
        
      rfpos2.y=rfpos2.y+1
      
    end
    
    if rfarea.z % 2 == 0 then
      for j=1, rfarea.x+1 do
        local pos = {x=rfpos1.x+j-1, y=rfpos2.y, z=rfpos1.z+(rfarea.z/2)}
        minetest.set_node(pos,{
          name=rfslabs
        })
       end
       -- p is positional axis along which it is made
       -- fp is the facing axis and direction inward
       local wpos1 = {x=rfpos1.x+1, y=rfpos2.y-2, z=rfpos1.z+(rfarea.z/2), p="z", fp={"x",1}} 
       table.insert(l_pos,wpos1)
       local wpos2 = {x=rfpos1.x+rfarea.x-1, y=rfpos2.y-2, z=rfpos1.z+(rfarea.z/2), p="z", fp={"x",-1}}
       table.insert(l_pos,wpos2)
       minetest.bulk_set_node({wpos1,wpos2},{
        name=wp.window_nodes[1]
      })
    else
      local wpos1 = {x=rfpos1.x+1, y=rfpos2.y-2, z=rfpos1.z+(rfarea.z/2)-1, p="z", fp={"x",1}}
      table.insert(l_pos,wpos1)
      local wpos2 = {x=rfpos1.x+1, y=rfpos2.y-2, z=rfpos1.z+(rfarea.z/2), p="z", fp={"x",1}}
      table.insert(l_pos,wpos2)
      local wpos3 = {x=rfpos1.x+rfarea.x-1, y=rfpos2.y-2, z=rfpos1.z+(rfarea.z/2)-1, p="z", fp={"x",-1}}
      table.insert(l_pos,wpos3)
      local wpos4 = {x=rfpos1.x+rfarea.x-1, y=rfpos2.y-2, z=rfpos1.z+(rfarea.z/2), p="z", fp={"x",-1}}
      table.insert(l_pos,wpos4)
      minetest.bulk_set_node({wpos1,wpos2,wpos3,wpos4},{
        name=wp.window_nodes[1]
      })
    end

  else --------------------------------------------
    
    local gmp = rfarea.x-1

    for j=1, (rfarea.x+1)/2 do
      for i=1, rfarea.z+1 do
         
        local pos = {x=rfpos1.x+j-1, y=rfpos2.y+1, z=rfpos1.z+i-1}
        minetest.set_node(pos,{
          name=rfnodes,
          paramtype2="facedir",
          param2=1
        })
      end

      for g=1, gmp do
          
        local gpos = {x=gbpos1.x+gmp-g, y=rfpos2.y+2, z=gbpos1.z} 
        local gpos2 = {x=gbpos1.x+gmp-g, y=rfpos2.y+2, z=gbpos1.z+gbarea.z}
        minetest.bulk_set_node({gpos,gpos2},{
          name=gbnodes,
          paramtype2="facedir",
          param2=0
        })
        
      end
      gmp = gmp -2
      gbpos1.x = gbpos1.x+1 
      rfpos2.y=rfpos2.y+1
    end


    rfpos2 = vector.new({x = sfpos2.x+1, y=sfpos2.y, z=sfpos2.z+1})--reset rfpos2 for other side of roof
    rfarea = vector.subtract(rfpos2,rfpos1)

    local rfamid = math.floor((rfarea.x+1)/2)
    for j=rfarea.x+1, rfamid+1,-1 do
      for i=1,rfarea.z+1 do
        local pos = {x=rfpos1.x+j-1, y=rfpos2.y+1, z=rfpos1.z+i-1}
        minetest.set_node(pos,{
          name=rfnodes,
          paramtype2="facedir",
          param2=3
        })
      end
        
      rfpos2.y=rfpos2.y+1
    end
    
    if rfarea.x % 2 == 0 then
      for i=1,rfarea.z+1 do
        local pos = {x=rfpos1.x+(rfarea.x/2), y=rfpos2.y, z=rfpos1.z+i-1}
        minetest.set_node(pos,{
                                name=rfslabs
      })
      end
      local wpos1 = {x=rfpos1.x+(rfarea.x/2), y=rfpos2.y-2, z=rfpos1.z+1, p="x", fp={"z",1}}
      table.insert(l_pos,wpos1)
      local wpos2 = {x=rfpos1.x+(rfarea.x/2), y=rfpos2.y-2, z=rfpos1.z+rfarea.z-1, p="x", fp={"z",-1}}
      table.insert(l_pos,wpos2)
      minetest.bulk_set_node({wpos1,wpos2},{
        name=wp.window_nodes[1]
      })
    else
      local wpos1 = {x=rfpos1.x+(rfarea.x/2), y=rfpos2.y-2, z=rfpos1.z+1, p="x", fp={"z",1}}
      table.insert(l_pos,wpos1)
      local wpos2 = {x=rfpos1.x+(rfarea.x/2)-1, y=rfpos2.y-2, z=rfpos1.z+1, p="x", fp={"z",1}}
      table.insert(l_pos,wpos2)
      local wpos3 = {x=rfpos1.x+(rfarea.x/2), y=rfpos2.y-2, z=rfpos1.z+rfarea.z-1, p="x", fp={"z",-1}}
      table.insert(l_pos,wpos3)
      local wpos4 = {x=rfpos1.x+(rfarea.x/2)-1, y=rfpos2.y-2, z=rfpos1.z+rfarea.z-1, p="x", fp={"z",-1}}
      table.insert(l_pos,wpos4)
      minetest.bulk_set_node({wpos1,wpos2,wpos3,wpos4},{
        name=wp.window_nodes[1]
      })
    end
    
  end
  print("ladder l_pos: "..mts(l_pos))
  --extend the stovepipe
  if furnace_pos and furnace_pos.x then 
    --print("furnace pos: "..mtpts(furnace_pos))
    local stovepipe = (rfpos2.y - furnace_pos.y) + 1
    --print(rfpos2.y.." "..furnace_pos.y.." "..stovepipe)
    local stovepipe_pos = vector.new(furnace_pos)
    for i=1, stovepipe do
      stovepipe_pos.y = stovepipe_pos.y + 1
      minetest.set_node(stovepipe_pos,{
        name="default:cobble"
      })
    end
  end

  --drop a ladder from the center of the gable, avoiding any doors or windows
  print("door: ".. mts(door_pos))
  if door_pos and l_pos then
    for _,d in pairs(door_pos) do
      for k,l in pairs(l_pos) do
        if l.x == d.x and  l.z == d.z then
          l_pos[k]= nil
        end
      end
    end
  end

  if window_pos and l_pos  then
    for _,w in pairs(window_pos) do
      for k,l in pairs(l_pos) do
        print("possible window before check: ".. mtpts(w))
        print("possible ladder before check: ".. mtpts(l))
        if math.ceil(l.x) == w.x and  math.ceil(l.z) == w.z then
          print("removing".. mtpts(l_pos[k]))
          table.remove(l_pos,k)
        
        end
      end
    end
  end
  
  print("possible ladder: ".. mts(l_pos))
  if l_pos and #l_pos >= 1 then
     local lpn =  math.random(#l_pos)
     local lpc = l_pos[lpn]

    local ladder_length = lpc.y - 1 - ffpos1.y 
    local fpos = vector.new(lpc)

    fpos[ lpc.fp[1] ]  = fpos[ lpc.fp[1] ] + lpc.fp[2]

    --print("ladder:   "..mtpts(l_pos))
    --print("ladder f: "..mtpts(fpos))

    local dir1=vector.direction(fpos,lpc)
    local dir1_wm = minetest.dir_to_wallmounted(dir1)
    print("ladder chosen: ".. mts(lpc))
    lpc[ lpc.fp[1] ] = lpc[ lpc.fp[1] ] + lpc.fp[2]
    --l_pos.y = l_pos.y-1

    for i=1, ladder_length do
      lpc.y = lpc.y-1
      minetest.set_node(lpc,{
        name= "default:ladder_wood",
        param2 = dir1_wm
      })
      
      
    end
    print("ladder: "..mtpts(lpc))
  else 
    local loftpos1 = {x= sfpos1.x+2, y = sfpos1.y+1, z=sfpos1.z+1} 
    local loftpos2 = {x= sfpos2.x-2, y = sfpos1.y+1, z=sfpos2.z-1} 
    local loftarea = vector.subtract(loftpos2,loftpos1)
    print(dump(loftpos1))
    print(dump(loftpos2))
    print(dump(loftarea))
    for i=1, loftarea.z+1 do
      for j=1, loftarea.x+1 do 
        local pos = {x= loftpos1.x-1 + j, y = loftpos1.y, z = loftpos1.z-1 + i}
        print(mts(pos))
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


local cottage_dimensions = {ppos1,rfpos2}
print("porch above ground = "..mtpts(ppos1))
print("           rooftop = "..mtpts(rfpos2))
return cottage_dimensions
end


---  build the cottage in a defined area
local function place_cottage(cottage_id, pos1,pos2)
  if not cottage_id then 
    return
  end  

end 