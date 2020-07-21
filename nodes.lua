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
  random_level=0,
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
  random_level=1,
  trunk_type="single",
  thin_branches=true,
  fruit_chance=5,
  fruit="default:apple"
}
