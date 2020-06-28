
--local mod_name = "witches"
local path = minetest.get_modpath("witches")
witches = {}

witches.version = "20200611"
print("this is Witches "..witches.version)

-- Strips any kind of escape codes (translation, colors) from a string
-- https://github.com/minetest/minetest/blob/53dd7819277c53954d1298dfffa5287c306db8d0/src/util/string.cpp#L777
function witches.strip_escapes(input)
  local s = function(idx) return input:sub(idx, idx) end
  local out = ""
  local i = 1
  while i <= #input do
    if s(i) == "\027" then -- escape sequence
      i = i + 1
      if s(i) == "(" then -- enclosed
        i = i + 1
        while i <= #input and s(i) ~= ")" do
          if s(i) == "\\" then
            i = i + 2
          else
            i = i + 1
          end
        end
      end
    else
      out = out .. s(i)
    end
    i = i + 1
  end
  --print(("%q -> %q"):format(input, out))
  return out
end

local function print_s(input)
  print(witches.strip_escapes(input))
end

local S = minetest.get_translator("witches")

local witches_version = witches.version
dofile(path .. "/utilities.lua")
dofile(path .. "/ui.lua")
print("enter the witches! version: "..witches.version)

local witch_hat = {}
witch_hat = {
  initial_properties = {
      --physical = true,
      pointable = false,
      collisionbox = {0,0,0,0,0,0},
      visual = "mesh",
      mesh = "witches_witch-hat.b3d",
      visual_size = {x = 1, y = 1, z = 1},
      textures = {"witches_witch_hat.png"},
  },
  message = "Default message",
  on_step =  function(self)
    if not self.owner or not self.owner:get_luaentity() then
      self.object:remove()
    else
      -- local owner_head_bone = self.owner:get_luaentity().head_bone
      --  local position,rotation = self.owner:get_bone_position(owner_head_bone)
      --  self.object:set_attach(self.owner, owner_head_bone, vector.new(0,0,0), rotation)
    end
  end 
  
}

minetest.register_entity("witches:witch_hat",witch_hat)

local witch_tool = {}
witch_tool = {
  initial_properties = {
      --physical = true,
      pointable = false,
      collisionbox = {0,0,0,0,0,0},
      visual = "wielditem",
      
      visual_size = {x = 0.3, y = 0.3},
      wield_item = "default:stick",
      --inventory_image = "default_tool_woodpick.png",
  },
  
  message = "Default message",
  on_step =  function(self)
    if not self.owner or not self.owner:get_luaentity() then
      self.object:remove()
    end
  end 
}

minetest.register_entity("witches:witch_tool",witch_tool)



local spawning = {
  generic = {
      nodes = {"group:stone"},
      neighbors = "air",
      min_light = 0,
      max_light = 15,
      interval = 30,
      chance = 1000,
      active_object_count = 2,
      min_height = 0,
      max_height = 200,
      day_toggle = nil,
      on_spawn = nil,
  },
}

local witch_types = {
  generic = {

  }
}


local rnd_colors = {"none", "red","green","blue","orange","yellow","violet","cyan"}
local hair_colors = {"black","brown","blonde","gray","red","blue","green"}
local hat_bling = {"band","feather","veil"}
local function rnd_color(rnd_colors)
  local color = rnd_colors[math.random(1,#rnd_colors)]
  return color
end
local function color_mod_string()
  local str = "^[colorize:\""..rnd_color(rnd_colors)..":50\""
  return str
end
--for rng of small floats
local function variance(min,max)
  local target = math.random(min,max) / 100
  print(target)
  return target
 end

local witch_template = {  --your average witch,
  description = "Basic Witch",
  lore = "This witch has a story yet to be...",
  type = "npc",
  passive = false,
  attack_type = "dogfight",
  attack_monsters = false,
  attack_npcs = false,
  attack_players = true,
  group_attack = true,
  runaway = true,
  damage = 1,
  reach = 2,
  knock_back = true,
  hp_min = 5,
  hp_max = 10,
  armor = 100,
  visual = "mesh",
  mesh = "witches_witch.b3d",
  textures = {
    "witches_clothes.png"
  },
  --blood_texture = "witches_blood.png",
  collisionbox = {-0.25, 0, -.25, 0.25, 2, 0.25},
  drawtype = "front",
  makes_footstep_sound = true,
  sounds = {
    random = "",
    war_cry = "",
    attack = "",
    damage = "",
    death = "",
    replace = "", gain = 0.05,
    distance = 15},
  walk_velocity = 2,
  run_velocity = 3,
  pathfinding = 1,
  jump = true,
  jump_height = 5,
  step_height = 1.5,
  fear_height = 4,
  water_damage = 0,
  lava_damage = 2,
  light_damage = 0,
  lifetimer = 360,
  view_range = 10,
  stay_near = "",
  order = "follow",

  animation = {
    stand_speed = 30,
    stand_start = 0,
    stand_end = 80,
    walk_speed = 30,
    walk_start = 168,
    walk_end = 187,
    run_speed = 45,
    run_start = 168,
    run_end = 187,
    punch_speed = 30,
    punch_start = 200,
    punch_end = 219,
  },
  drops = {
    {name = "default:pick_steel",
      chance = 1000, min = 0, max = 1},
    {name = "default:shovel_steel",
      chance = 1000, min = 0, max = 1},
    {name = "default:axe_steel",
      chance = 1000, min = 0, max = 1},
    {name = "default:axe_stone",
      chance = 5, min = 0, max = 1},
  },
  
  follow = {
  "default:diamond", "default:gold_lump", "default:apple",
  "default:blueberries", "default:torch", "default:stick",
  "flowers:mushroom_brown","flowers:mushroom_red"
  },
  on_rightclick = function(self,clicker)

    local pname = clicker:get_player_name()
    witches.guessing.show_to(self, pname)
  end,

  on_spawn = function(self)
    --make sure these are baseline on spawn
    --self.animation.walk_speed = 30
    --self.animation.run_speed = 45
    --self.walk_velocity = 2
    --self.run_velocity = 3
    --then set modifiers for each individual
    if not self.speed_mod then
      self.speed_mod = math.random(-1, 1)
      
    end
  print("speed mod: "..self.speed_mod)
--rng for testing variants
    if not self.size then
      self.size = {x = variance(90,100), y = variance(75,105), z = variance(90,100)}
    end
    
    if not self.skin then
      self.skin = math.random(1,5)
    end

    if not self.color_mod then
      self.color_mod = rnd_color(rnd_colors)
    end

    if not self.hair_color then
      self.hair_color= rnd_color(hair_colors)
    end
    
    local self_properties = self.object:get_properties()
    self_properties.visual_size = self.size
    self.object:set_properties(self_properties)

--initial speed modifications
    self.walk_velocity = self.walk_velocity + ( self.speed_mod / 10 )
    self.run_velocity = self.run_velocity + ( self.speed_mod / 10 )
    self.animation.walk_speed = self.animation.walk_speed + self.speed_mod
    self.animation.run_speed = self.animation.run_speed + self.speed_mod
    --no more speed mods!
    self.speed_mod = 0

    -- so many overlays!
    if self.color_mod ~="none" then
      self.object:set_texture_mod("^[colorize:"..self.color_mod..":60^witches_skin"..self.skin..".png^witches_accessories.png^witches_witch_hair_"..self.hair_color..".png")
    else
      self.object:set_texture_mod("^witches_skin"..self.skin..".png^witches_accessories.png^witches_witch_hair_"..self.hair_color..".png")
    end
    if not self.secret_name then
      self.secret_name = witches.generate_name(witches.name_parts_female).." the "..self.color_mod
    end
    print(self.secret_name.." has spawned")
    --print("self: "..dump(self.follow))
   -- print("self properties "..dump(self.object:get_properties()))
    witches.looking_for(self)


  end,
    
  spawning = spawning.generic,

  after_activate = function(self)
--maddest hatter <|%\D
  self.head_bone = "Head"
  local hat = minetest.add_entity(self.object:get_pos(), "witches:witch_hat") 
  hat:set_attach(self.object, "Head", vector.new(0,4,0), vector.new(0,180,0))
  local hat_ent = hat:get_luaentity()
  hat_ent.owner = self.object
  print("HAT: "..dump(hat_ent))
  local he_props = hat_ent.object:get_properties() 
  --print("he props: "..dump(he_props))
  local hat_size = variance(90, 120)
  local hat_mods = ""
  for i,v in pairs(hat_bling) do
    if v == "veil" and math.random() < 0.1 then 
      hat_mods = hat_mods.."^witches_witch_hat_"..v..".png"
    else
      if v ~= "veil" and math.random() < 0.5 then
        hat_mods = hat_mods.."^witches_witch_hat_"..v..".png"
      end
    end
  end
  self.hat_mods = hat_mods
  print("hat_mods: "..self.hat_mods)
  if self.color_mod ~= "none" then
     hat_ent.object:set_texture_mod("^[colorize:"..self.color_mod..":60"..self.hat_mods)
  else
    if self.hat_mods then hat_ent.object:set_texture_mod(self.hat_mods) end
  end
  he_props.visual_size.y = hat_size
  print("he props: "..dump(he_props))
  hat_ent.object:set_properties(he_props)

  local tool = minetest.add_entity(self.object:get_pos(), "witches:witch_tool") 
  tool:set_attach(self.object, "Arm_Right", {x=0.3, y=4.0, z=2}, {x=-100, y=225, z=90})
  tool:get_luaentity().owner = self.object
  
  end,

}




--- This can build all the mobs in our mod.
-- @witch_types is a table with the key used to build the subtype with values that are unique to that subtype
-- @witch_template is the table with all params that a mob type would have defined
function witches.generate(witch_types,witch_template)
  for k, v in pairs(witch_types) do
    -- we need to get a fresh template to modify for every type or we get some carryover values:-P
    local g_template = table.copy(witch_template)
    -- g_type should be different every time so no need to freshen
    local g_type = v
    for x, y in pairs(g_type) do
      -- print_s("found template modifiers " ..dump(x).." = "..dump(y))
      g_template[x] = g_type[x]
    end
    
    print_s("Assembling the "..g_template.description..":")
    if g_template.lore then print_s("  "..g_template.lore) end
    --print_s("resulting template: " ..dump(g_template))
    mobs:register_mob("witches:witch_"..k, g_template)
    mobs:register_egg("witches:witch_"..k, S("@1  Egg",g_template.description),"default_mossycobble.png", 1)
    g_template.spawning.name = "witches:witch_"..k --spawn in the name of the key!
    mobs:spawn(g_template.spawning)
    g_template = {}
  end
end

witches.generate(witch_types,witch_template)