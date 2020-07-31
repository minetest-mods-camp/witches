witches.magic = {}
local wsc = witches.sheep_colors

local magic_texture = "bubble.png"
local magic_animation = nil
local fireflies = false
if minetest.registered_nodes["fireflies:firefly"] then
  fireflies = true
  magic_texture = "fireflies_firefly_animated.png"
  magic_animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1.5
  }
else
  magic_texture = "bubble.png"
  magic_animation = nil
end

local function pos_to_vol(pos,vol)
  local pv1 = {}
  local pv2 = {}

    pv1 = vector.subtract(pos,vector.divide(vol,2))
    pv2 = vector.add(pv1,vol)
    local rvol = {pv1,pv2}
  return rvol
end

function witches.magic.effect_area01(pos1,pos2,density)
  density = density or 100
minetest.add_particlespawner({
  amount=density,
  time=.1,
  minpos= pos1,
  maxpos= pos2,
  minvel={x=0, y=0, z=0},
  maxvel={x=0, y=1, z=0},
  minacc={x=0, y=0, z=0},
  maxacc={x=0, y=1, z=0},
  minexptime=.01,
  maxexptime=.5,
  minsize=1,
  maxsize=2,
  collisiondetection=false,
  texture= magic_texture,
  animation = magic_animation,
  glow = 10,
  --player = target:get_player_name()
})
end

function witches.magic.effect_line01(pos1,pos2,density)
  pos1 = vector.round(pos1)
  pos2 = vector.round(pos2)
  density = density or 10
  local dv = vector.direction(pos1, pos2)
  local vd = math.floor(vector.distance(pos1, pos2))
  local v_pos1 = pos1
  local v_pos2 = pos1

  for i=1,vd do
    v_pos2 = vector.add(v_pos1,dv)

      minetest.add_particlespawner({
        amount=density,
        time=.1,
        minpos= v_pos1,
        maxpos= v_pos2,
        minvel={x=0, y=0, z=0},
        maxvel={x=0, y=1, z=0},
        minacc={x=0, y=0, z=0},
        maxacc={x=0, y=1, z=0},
        minexptime=.01,
        maxexptime=.5,
        minsize=1,
        maxsize=2,
        collisiondetection=false,
        texture= magic_texture,
        animation = magic_animation,
        glow = 10,
        --player = target:get_player_name()
      })
    v_pos1 = v_pos2
  end
end

function witches.magic.teleport(self,target,strength,height)
  local description = "Yeet!" --thanks to ctate for naming this so accurately!
  local caster_pos = self.object:get_pos()
  local target_pos = {}
  strength = strength or 8
  height = height or 5
  if target then

    if target:is_player() then

      target_pos = target:get_pos()

    elseif target:get_luaentity() then
      --same for now...
      target_pos = target:get_pos()
    else
      return
    end
    --witches.stop_and_face(self,target_pos)

      local new_target_pos = vector.add(target_pos, vector.multiply(vector.direction(caster_pos, target_pos),strength))
    new_target_pos.y = target_pos.y + height

    --print(minetest.pos_to_string(target_pos))
    --print(minetest.pos_to_string(caster_pos))
    --print(minetest.pos_to_string(new_target_pos))

    target:set_pos(new_target_pos)
    witches.magic.effect_line01(caster_pos,new_target_pos,50)

    local vol =  pos_to_vol(caster_pos,{x=2,y=2,z=2})

    --print(minetest.pos_to_string(caster_pos))
    --print(minetest.pos_to_string(vol[1]))
    --print(minetest.pos_to_string(vol[2]))

    witches.magic.effect_area01(vol[1],vol[2],100)

    --witches.stop_and_face(self,new_target_pos)
  end

end

function witches.magic.polymorph(self, target, mob, duration)
  duration = duration or 0
  local colors = {}
  for _, col in ipairs(wsc) do
    table.insert(colors,col[1])
  end
  local r_sheep = "witches:sheep_"..colors[math.random(#colors)]
  mob = mob or r_sheep
  local caster_pos = self.object:get_pos()
  local ent = target:get_luaentity()
  local ent_pos = ent.object:get_pos()

  --local ent_props = ent.object:get_properties()
  --local ent_name = ent.name
  --print(dump(ent_props))

  witches.magic.effect_line01(caster_pos,ent_pos,50)
  ent.object:remove()
  local vol_ent =  pos_to_vol(ent_pos,{x=2,y=2,z=2})

  --print(minetest.pos_to_string(caster_pos))
  --print(minetest.pos_to_string(vol[1]))
  --print(minetest.pos_to_string(vol[2]))

  witches.magic.effect_area01(vol_ent[1],vol_ent[2],200)

  local new_obj = minetest.add_entity(ent_pos, mob)
  --local new_ent = new_obj:get_luaentity()
  --new_ent.old_mob_name = ent.name

end