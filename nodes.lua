local S = minetest.get_translator("witches")
if not doors then
  print("doors mod not found!")
  return
else
  print("doors active")
  doors.register("door_wood_witch", {
    tiles = {{ name = "doors_door_wood.png", backface_culling = true }},
    description = S("Wooden Door"),
    inventory_image = "doors_item_wood.png",
    groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
    --[[
    recipe = {
      {"group:wood", "group:wood"},
      {"group:wood", "group:wood"},
      {"group:wood", "group:wood"},
    }
    --]]
  })
end

-- the following are based on: https://dev.minetest.net/L-system_tree_examples

witches.acacia_tree={
  axiom="FFFFFFccccA",
  rules_a = "[B]//[B]//[B]//[B]",
  rules_b = "&TTTT&TT^^G&&----GGGGGG++GGG++"   -- line up with the "canvas" edge
        .."fffffRfGG++G++"               -- first layer, drawn in a zig-zag raster pattern
        .."Gffffffff--G--"
        .."ffffRfffG++G++"
        .."fffffffff--G--"
        .."fffffffff++G++"
        .."ffRffffff--G--"
        .."ffffffffG++G++"
        .."GffffRfff--G--"
        .."fffffffGG"
        .."^^G&&----GGGGGGG++GGGGGG++"      -- re-align to second layer canvas edge
        .."ffffGGG++G++"               -- second layer
        .."GGfffff--G--"
        .."ffRfffG++G++"
        .."fffffff--G--"
        .."ffffRfG++G++"
        .."GGfffff--G--"
        .."ffRfGGG",
  rules_c = "/",
  trunk="default:tree",
  leaves="default:leaves",
  angle=45,
  iterations=3,
  random_level=1,
  trunk_type="single",
  thin_branches=true,
  fruit_chance=5,
  fruit="default:apple"
}

witches.apple_tree={
  axiom="FFFFFAFFBF",
  rules_a="[&&&FFFFF&&FFFF][&&&++++FFFFF&&FFFF][&&&----FFFFF&&FFFF]",
  rules_b="[&&&++FFFFF&&FFFF][&&&--FFFFF&&FFFF][&&&------FFFFF&&FFFF]",
  trunk="default:tree",
  leaves="default:leaves",
	angle=30,
	iterations=2,
	random_level=0,
	trunk_type="single",
	thin_branches=true,
	fruit_chance=10,
  fruit="default:apple"
}

local flowers_types = {}
if flowers.datas then
  for i,v in pairs(flowers.datas) do
    flowers_types[i] = "flowers:" .. v[1]
    
  end
end

function witches.flower_patch(pos)
  if not pos then 
    print("no pos for flowers!")
    return
  end
  local fpos = pos
	if minetest.get_modpath("flowers") then

    --print(dump(flowers_types))
		local r_flower = flowers_types[math.random(#flowers_types)]
    local node = r_flower
    --print(r_flower)
    local check = minetest.get_node(pos)
    if string.find(check.name,"dirt") then
        minetest.place_node({x=fpos.x, y=fpos.y+1, z=fpos.z}, {name = r_flower})
        --flowers.flower_spread(fpos, {name = r_flower}) 
        return r_flower
    elseif string.find(check.name,"sand") then
        if math.random() < 0.20 then
          minetest.set_node({x=fpos.x, y=fpos.y+1, z=fpos.z}, {name = "default:large_cactus_seedling"})
        elseif minetest.get_modpath("farming") then
          minetest.set_node({x=fpos.x, y=fpos.y+1, z=fpos.z}, {name = "farming:cotton_wild"})
        else
          minetest.set_node({x=fpos.x, y=fpos.y+1, z=fpos.z}, {name = "default:dry_shrub"})
        end

    end
    
  
	end
end