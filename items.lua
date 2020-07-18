--Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
--The MIT License (MIT)
local variance = witches.variance

local rnd_color = witches.rnd_color
local rnd_colors = witches.rnd_colors

witches.witch_hat_styles = {"a", "b", "c", "d"}

local hat_bling = {"band","feather","veil"}

local witch_hats = {}
for _,v in pairs(witches.witch_hat_styles) do 
  witch_hats[v] = {
    initial_properties = {
        --physical = true,
        pointable = false,
        collisionbox = {0,0,0,0,0,0},
        visual = "mesh",
        mesh = "witches_witch-hat_"..v..".b3d",
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
end


for i,v in pairs(witches.witch_hat_styles) do
  minetest.register_entity("witches:witch_hat_"..v,witch_hats[v])
end

--minetest.register_entity("witches:witch_hat",witch_hat)


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

  on_step =  function(self)
    if not self.owner or not self.owner:get_luaentity() then
      self.object:remove()
    end
  end 
}




minetest.register_entity("witches:witch_tool",witch_tool)

function witches.attach_hat(self,item)
  self.head_bone = "Head"
  local item = item or "witches:witch_hat"
  local hat = minetest.add_entity(self.object:get_pos(), item) 
  hat:set_attach(self.object, "Head", vector.new(0,4.5,0), vector.new(0,180,0))
  local hat_ent = hat:get_luaentity()
  hat_ent.owner = self.object
  --print("HAT: "..dump(hat_ent))
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
  --print("hat_mods: "..self.hat_mods)
  if self.color_mod ~= "none" then
    hat_ent.object:set_texture_mod("^[colorize:"..self.color_mod..":60"..self.hat_mods)
  else
    if self.hat_mods then hat_ent.object:set_texture_mod(self.hat_mods) end
  end
  he_props.visual_size.y = hat_size
  --print("he props: "..dump(he_props))
  hat_ent.object:set_properties(he_props)
end

function witches.attach_tool(self,item)
  item = item or "witches:witch_tool"
  local tool = minetest.add_entity(self.object:get_pos(), item) 
  tool:set_attach(self.object, "Arm_Right", {x=0.3, y=4.0, z=2}, {x=-100, y=225, z=90})
  tool:get_luaentity().owner = self.object
end