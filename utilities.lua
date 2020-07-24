--Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
--The MIT License (MIT)
local function print_s(input)
  print(witches.strip_escapes(input))
end

local S = minetest.get_translator("witches")

--taken from https://github.com/LukeMS/lua-namegen/blob/master/data/creatures.cfg
witches.name_parts_male = {
  syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",
  syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",
  syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",
}

witches.name_parts_female = {
  syllablesStart = "Ad, Aer, Ar, Bel, Bet, Beth, Ce'N, Cyr, Eilin, El, Em, Emel, G, Gl, Glor, Is, Isl, Iv, Lay, Lis, May, Ner, Pol, Por, Sal, Sil, Vel, Vor, X, Xan, Xer, Yv, Zub",
  syllablesMiddle = "bre, da, dhe, ga, lda, le, lra, mi, ra, ri, ria, re, se, ya",
  syllablesEnd = "ba, beth, da, kira, laith, lle, ma, mina, mira, na, nn, nne, nor, ra, rin, ssra, ta, th, tha, thra, tira, tta, vea, vena, we, wen, wyn",
}

witches.words_desc = {
  tool_adj = S("shiny, polished, favorite, beloved, cherished, sharpened"),
  titles = S("artificer, librarian, logician, sorcerant, thaumaturgist, polymorphist, elementalist, hedge, herbologist, arcanologist, tutor, historian, mendicant, restorationist"),
}


local function quest_dialogs(self)
  local dialogs = {
    intro = {
      S("Hello, @1, I am @2, @3 of @4! ", self.speaking_to,self.secret_name,self.secret_title,self.secret_locale),
      S("Just one minute, @1! @2, @3 of @4 seeks your assistance! ", self.speaking_to,self.secret_name,self.secret_title,self.secret_locale),
      S("If you are indeed @1, perhaps you and I, @2, @3 of @4 can help each other! ", self.speaking_to,self.secret_name,self.secret_title,self.secret_locale),

    },
    item_request = {
      S("I've been looking all over for the @1! ",self.item_request.item.desc),
      S("I seem to have misplaced the @1! ",self.item_request.item.desc),
      S("Would you happen to have some number of @1? ",self.item_request.item.desc),
      S("Would you kindly retrieve for me the @1? ",self.item_request.item.desc),
      S("Might you please return with the @1? ",self.item_request.item.desc),
      S("Do you know I seek only the @1? ",self.item_request.item.desc),
      S("Have you but some number of @1? ",self.item_request.item.desc),
      S("Why must my task require the @1? ",self.item_request.item.desc),
      S("Is it so difficult to find the @1? ",self.item_request.item.desc),
      S("Wherefor about this land art the @1? ",self.item_request.item.desc),
      S("Must there be but a few of the @1 about? ",self.item_request.item.desc),
      S("Could I trouble you for some kind of @1? ",self.item_request.item.desc),
      S("The @1 would make my collection complete! ",self.item_request.item.desc),
      S("I sense the @1 are not far away...",self.item_request.item.desc),
      S("Certainly the @1 is not as rare as a blood moon! ",self.item_request.item.desc),
      S("You look like you know where to find the @1! ",self.item_request.item.desc)
    }
  }
  --print(dump(dialogs))
  return dialogs
end


function witches.generate_text(name_parts, rules, separator)
  -- print_s("generating name")
  local name_arrays = {}
  local r_parts = {}
  local generated_name = {}
  for k,v in pairs(name_parts) do
    --  name_arrays.k = mysplit(v)
    if separator then
      name_arrays.k = string.split(v,separator)
    else
      name_arrays.k = string.split(v,", ")
    end
    -- print_s(dump(name_arrays.k))
    r_parts[k] = k
    r_parts[k] = name_arrays.k[math.random(1,#name_arrays.k)]
  end
  --local r_parts.k = name_arrays.k[math.random(1,#name_arrays.k)] did not work
  --print_s(name_a)
  if r_parts.list_opt and math.random() <= 0.5 then r_parts.list_opt = "" end
  --print_s(r_parts.list_a..r_parts.list_b..r_parts.list_opt)
  if rules then
    --print_s(dump(rules))
    local gen_name = ""
    for i, v in ipairs(rules) do
      if v == "-" then
        gen_name = gen_name.."-"
      elseif v == "\'" then
        gen_name = gen_name.."\'"
      else
        gen_name = gen_name..r_parts[v]
      end
    end
    generated_name = gen_name
    --print_s(dump(generated_name))
    return generated_name
  else
    generated_name = r_parts.syllablesStart..r_parts.syllablesMiddle..r_parts.syllablesEnd
    return generated_name
  end
end

witches.rnd_colors = {"none", "red","green","blue","orange","yellow","violet","cyan","pink","black","magenta","grey"}

witches.hair_colors = {"black","brown","blonde","gray","red","blue","green"}


local rnd_color = witches.rnd_color
local rnd_colors = witches.rnd_colors

function witches.rnd_color(rnd_colors)
  local color = rnd_colors[math.random(1,#rnd_colors)]
  return color
end

function witches.color_mod_string()
  local str = "^[colorize:\""..rnd_color(rnd_colors)..":50\""
  return str
end

--for rng of small floats
function witches.variance(min,max)
  local target = math.random(min,max) / 100
  --print(target)
  return target
 end


--- Drops a special personlized item
function witches.special_gifts(self, pname, drop_chance, max_drops)
  if pname then
    if self.drops then
      if not drop_chance then drop_chance = 1000 end
      if not max_drops then max_drops = 1 end
      local rares = {}
      for k,v in pairs(self.drops) do
        --print_s(dump(v.name).." and "..dump(v.chance))
        if v.chance >= drop_chance then
          table.insert(rares,v.name)
        end
      end
      if #rares > 0 then
        --print_s("rares = "..dump(rares))
        local pos = self.object:getpos()
        pos.y = pos.y + 0.5
        --witches.mixitup(pos)
        if #rares > max_drops then
          rares = rares[math.random(max_drops, #rares)]
          if type(rares) ~= table then rares = {rares} end --
        end
        for k,v in pairs(rares) do
          --[[
          minetest.sound_play("goblins_goblin_cackle", {
            pos = pos,
            gain = 1.0,
            max_hear_distance = self.sounds.distance or 10
          })
          --]]
          local item_wear = math.random(8000,10000)
          local stack = ItemStack({name = v, wear = item_wear })
          local org_desc = minetest.registered_items[v].description
          local meta = stack:get_meta()
          --boost the stats!
          local capabilities = stack:get_tool_capabilities()
          
          local bonuses = {}
          for x,y in pairs(capabilities) do
            if x == "groupcaps" then
              for a,b in pairs(y) do
                --print(dump(a).." is "..dump(b).."\n---")
                if b and b.uses then
                   --print("original uses: "..capabilities.groupcaps[a].uses)
                   
                   capabilities.groupcaps[a].uses = b.uses + 10
                   --print("boosted uses: "..capabilities.groupcaps[a].uses)
                   
                  --print(dump(a).." is now "..dump(b))
                end
                if b and b.times then
                  for i,v in pairs(b.times) do
                    if v > 0.3 then
                       --print("original time:".. v )
                       local v_rnd = math.random(1,3) / 10
                       v = v - v_rnd
                      -- print("boosted time:".. v )
                    end
                    capabilities.groupcaps[a].times[i] = v
                  end  
                end
              end
            elseif x == "damage_groups" then
              for a,b in pairs(y) do
                --print(dump(a.." = "..capabilities.damage_groups[a]))
                capabilities.damage_groups[a] = b + math.random(0,1)
                --print(dump(capabilities.damage_groups[a]))
              end 
            end
          end
          meta:set_tool_capabilities(capabilities)
          --print (dump(capabilities))
          local tool_adj = witches.generate_text(witches.words_desc, {"tool_adj"})
          -- special thanks here to rubenwardy for showing me how translation works!
          meta:set_string(
            "description", S("@1's @2 @3", self.secret_name, tool_adj, org_desc)
          )
          --minetest.chat_send_player()
          local inv = minetest.get_inventory({ type="player", name= pname })     
          local reward_text = {}
          local reward = {}
          for i,_ in pairs(inv:get_lists()) do
            --print(i.." = "..dump(v))
            if i == "main" and stack and inv:room_for_item(i, stack) then
              reward_text = S("You are rewarded with @1",meta:get_string("description"))
              --print("generated text: "..reward_text)
              local reward_item = stack:get_name()
              --print("generated:"..stack:get_name())
               reward = {r_text = reward_text, r_item = reward_item}
              inv:add_item(i,stack)
              return reward
            end
          end
          reward_text = S("You are rewarded with @1, but you cannot carry it",meta:get_string("description"))
          --print("generated text: "..reward_text)
          local reward_item = stack:get_name()
          --print("generated:"..stack:get_name())
           reward = {r_text = reward_text, r_item = reward_item}
           minetest.add_item(pos, stack)
          --print("generated text: "..reward_text)
          return reward
        end
      end
    end
  end
end

function witches.attachment_check(self)
	if not self.owner or not self.owner:get_luaentity() then
		self.object:remove()
	else
		local owner_head_bone = self.owner:get_luaentity().head_bone
		-- local position,rotation = self.owner:get_bone_position(owner_head_bone)
		-- self.object:set_attach(self.owner, owner_head_bone, vector.new(0,0,0), rotation)
	end
end

local function stop_and_face(self,pos)
  mobs:yaw_to_pos(self, pos)
  self.state = "stand"
  self:set_velocity(0)
  self:set_animation("stand")
  self.attack = nil
  self.v_start = false
  self.timer = 0
  self.blinktimer = 0
  self.path.way = nil
end

function witches.item_request(self,name)
  self.speaking_to = name
  if not self.item_request then self.item_request = {} end
  if not self.item_request.item then
    --we'd be in trouble if we dont have it already!
    self.item_request.item = witches.looking_for(self)
  end
  if not self.item_request.text then
    --we need text for the quest!
   -- print("generating")
    local dialog_list = quest_dialogs(self)
    local dli_num = math.random(1,#dialog_list.intro)
    local intro_text = dialog_list.intro[dli_num]

    --print(intro_text)
    local quest_item = self.item_request.item.desc
    local dlr_num = math.random(1,#dialog_list.item_request)
    local request_text = dialog_list.item_request[dlr_num]
   -- print(request_text)
    self.item_request.text = { intro = intro_text, request = request_text }
    --print(dump(self.item_request.text))
   return self.item_request.text
  end
end

function witches.found_item(self,clicker)
  local item = clicker:get_wielded_item()
  
  if item and item:get_name() == self.item_request.item.name then
    local pname = clicker:get_player_name()
    if not minetest.settings:get_bool("creative_mode") then
      item:take_item()
      clicker:set_wielded_item(item)
    end

    if not self.players then 
      self.players = {} 
      --print("no records")
    end
    
    if not self.players[pname] then 
      self.players[pname] = {} 
      --print("no records 2")
    end
    --print(dump(self.players))
    if not self.players[pname].favors then 
      self.players[pname] = { favors = 0 }
    end

    self.players[pname].favors = self.players[pname].favors + 1
    local reward = {}
    --print(self.secret_name.." has now received 2 favors"..self.players[pname].favors.." from " ..pname)
    
    --if self.players[pname].favors >=3 and math.fmod(18, self.players[pname].favors) == 0 then
      reward = witches.special_gifts(self,pname)
    --print(reward_text)
      if reward and reward.r_text then
        self.players[pname].reward_text = reward.r_text
      end
      if reward and reward.r_item then
      -- print("reward: "..reward.r_item)
        self.players[pname].reward_item = reward.r_item
      end

   -- end
    witches.found_item_quest.show_to(self, clicker)

    self.item_request = nil
  return item
  end

end

--call this to set the self.item_request.item from the witches follow list!
function witches.looking_for(self)
  if not self.item_request then
    self.item_request = {}
  end
  if not self.item_request.item then
    if self.follow then

      local item = self.follow[math.random(1,#self.follow)]
      --local stack = ItemStack({name = item})

      local find = {name = minetest.registered_items[item].name, desc = minetest.registered_items[item].description, icon = minetest.registered_items[item].inventory_image}
      --local meta = item:get_meta()
      --print_s(S(dump(desc)))
      --print(dump(find))

      self.item_request.item = find
      return self.item_request
      
    end

  else
    return self.item_request
  end
end

--first thing on right click
function witches.quests(self, clicker)
  local pname = clicker:get_player_name()
  --print(pname.."  clicked on a witch!")
  local item = clicker:get_wielded_item()
  local pos = clicker:getpos() 
  stop_and_face(self,pos)

  --make sure we are looking for an item
  witches.looking_for(self)

  local var1 = item:get_name()
  local var2 = self.name
  --print(var1.."  "..var2)

  if var1 == var2 then
    self.dev_mode = pname
    print("dev mode active for: "..pname)
  end

  --print("we are holding a "..dump(item:get_name()))
  if item:get_name() ~= self.item_request.item.name then
   --create the dialog 
   witches.item_request(self,pname)
    --we can now show the quest!
   witches.find_item_quest.show_to(self, pname)
   -- now that we said what we had to say, we clean up!

    self.item_request.text = nil
    self.dev_mode = nil

   -- print(self.secret_name.." wants a ".. self.item_quest.name)
  elseif self.item_request and self.item_request.item and item and item:get_name() == self.item_request.item.name then
    --print(self.item_quest.name.." and "..item:get_name())
    witches.found_item(self,clicker)
  end

end


