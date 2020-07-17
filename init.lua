--Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
--The MIT License (MIT)

--local mod_name = "witches"
local path = minetest.get_modpath("witches")
witches = {}

witches.version = "20200716"
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
dofile(path .. "/items.lua")
print("enter the witches! version: "..witches.version)

local variance = witches.variance
local rnd_color = witches.rnd_color
local rnd_colors = witches.rnd_colors
local hair_colors = witches.hair_colors

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
    witches.quests(self,clicker)
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
  --print("speed mod: "..self.speed_mod)
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
      self.secret_name = witches.generate_name(witches.name_parts_female)
    end
    if not self.secret_title then
      self.secret_title =  witches.generate_name(witches.words_desc, {"titles"})
    end
    if not self.secret_locale then
      self.secret_locale = witches.generate_name(witches.name_parts_female, {"syllablesStart","syllablesEnd"})
    end
   
    self.item_request =  witches.generate_name(witches.quest_dialogs, {"item_request"}) 

    

    --print(self.secret_name.." has spawned")
    --print("self: "..dump(self.follow))
   -- print("self properties "..dump(self.object:get_properties()))
    witches.looking_for(self)


  end,
    
  spawning = spawning.generic,

  after_activate = function(self)
--maddest hatter <|%\D
    witches.attach_hat(self,"witches:witch_hat")
    witches.attach_tool(self,"witches:witch_tool")
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