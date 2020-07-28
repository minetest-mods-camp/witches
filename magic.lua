witches.magic = {}

local magic_texture = "bubble.png"
local magic_animation = nil

if minetest.registered_nodes["fireflies:firefly"] then
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


function witches.magic.teleport(self,target,strength,height)
  local mob_pos = self.object:get_pos()
  local player_pos = {}
  strength = strength or 8
  height = height or 5
  if target then

    if target:is_player() then
     
      player_pos = target:get_pos()

    else

    end
    --witches.stop_and_face(self,player_pos)

      local new_player_pos = vector.add(player_pos, vector.multiply(vector.direction(mob_pos, player_pos),strength))             
    new_player_pos.y = player_pos.y +5
    --print(minetest.pos_to_string(player_pos))
    --print(minetest.pos_to_string(mob_pos))
    --print(minetest.pos_to_string(new_player_pos))
    target:set_pos(new_player_pos)

    minetest.add_particlespawner({
                amount=50,
                time=.1,
                minpos= mob_pos,
                maxpos= new_player_pos,
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
                player = target:get_player_name()
    })

    --witches.stop_and_face(self,new_player_pos)
  end
  
end
