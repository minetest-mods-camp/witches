-- Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
-- The MIT License (MIT)
local function print_s(input) print(witches.strip_escapes(input)) end

local S = minetest.get_translator("witches")

-- taken from https://github.com/LukeMS/lua-namegen/blob/master/data/creatures.cfg
witches.name_parts_male = {
    syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",
    syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",
    syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",
    syllablesTown = "mar, ton, veil,  Loch, del,  Pass,  Hillock,  shire, nia, ing"
}

witches.name_parts_female = {
    syllablesStart = "Ad, Aer, Ar, Bel, Bet, Beth, Ce'N, Cyr, Eilin, El, Em, Emel, G, Gl, Glor, Is, Isl, Iv, Lay, Lis, May, Ner, Pol, Por, Sal, Sil, Vel, Vor, X, Xan, Xer, Yv, Zub",
    syllablesMiddle = "bre, da, dhe, ga, lda, le, lra, mi, ra, ri, ria, re, se, ya",
    syllablesEnd = "ba, beth, da, kira, laith, lle, ma, mina, mira, na, nn, nne, nor, ra, rin, ssra, ta, th, tha, thra, tira, tta, vea, vena, we, wen, wyn",
    syllablesTown = "maer, tine, veila,  Loch, dael,  Pass,  Hillock, shire, mia, aeng"
}

witches.words_desc = {
    tool_adj = S(
        "shiny, polished, favorite, beloved, cherished, sharpened, enhanced"),
    titles = S(
        "artificer, librarian, logician, sorcerant, thaumaturgist, polymorphist, elementalist, hedge, herbologist, arcanologist, tutor, historian, mendicant, restorationist")
}

local function quest_dialogs(self)
    local thing = self.item_request.item.desc
    local thing_l = string.lower(self.item_request.item.desc)
    local dialogs = {
        intro = {
            S("Hello, @1, I am @2, @3 of @4! ", self.speaking_to,
              self.secret_name, self.secret_title, self.secret_locale),
            S("Just one minute, @1! @2, @3 of @4 seeks your assistance! ",
              self.speaking_to, self.secret_name, self.secret_title,
              self.secret_locale), S(
                "If you are indeed @1, perhaps you and I, @2, @3 of @4 can help each other! ",
                self.speaking_to, self.secret_name, self.secret_title,
                self.secret_locale),
            S(
                "Being a long way from @1, can be confusing. I'm known as @2 the @3! ",
                self.secret_locale, self.secret_name, self.secret_title), S(
                "You look as though you could be from @1, but I'm sure we have not yet met. I am @2 the @3! ",
                self.secret_locale, self.secret_name, self.secret_title)
        },
        having_met = {
            S("Well, @1, I have yet to return to @2. Can you help me? ",
              self.speaking_to, self.secret_locale),
            S("@1, do you have any intention of helping me? ", self.speaking_to),
            S("There are some matters that still need my attention, @1. ",
              self.speaking_to),
            S("I have been so busy in my search for materials, @1. ",
              self.speaking_to),
            S("It's just that the @1 is so difficult to procure, @2! ", thing_l,
              self.speaking_to),
            S("Great @1!, Where could that be found, @2?!? ", thing_l,
              self.speaking_to)

        },
        item_request = {
            S("A @1, just one will do! ", thing_l),
            S("I've been looking all over for the @1! ", thing_l),
            S("I seem to have misplaced the @1! ", thing_l),
            S("Would you happen to have some number of @1? ", thing_l),
            S("Would you kindly retrieve for me the @1? ", thing_l),
            S("Might you please return with the @1? ", thing_l),
            S("Do you know I seek only the @1? ", thing_l),
            S("Have you but some number of @1? ", thing_l),
            S("Why must my task require the @1? ", thing_l),
            S("Is it so difficult to find the @1? ", thing_l),
            S("Wherefor about this land art the @1? ", thing_l),
            S("Must not there be but a few of the @1 about? ", thing_l),
            S("Could I trouble you for some kind of @1? ", thing_l),
            S("The @1 would make my collection complete! ", thing_l),
            S("I sense the @1 are not far away...", thing_l),
            S("Certainly the @1 is not as rare as a blood moon! ", thing_l),
            S("You look like you know where to find the @1! ", thing_l)
        }
    }
    -- print(dump(dialogs))
    return dialogs
end

function witches.generate_text(name_parts, rules, separator)
    -- print_s("generating name")
    local name_arrays = {}
    local r_parts = {}
    local generated_name = {}
    for k, v in pairs(name_parts) do
        --  name_arrays.k = mysplit(v)
        if separator then
            name_arrays.k = string.split(v, separator)
        else
            name_arrays.k = string.split(v, ", ")
        end
        -- print_s(dump(name_arrays.k))
        r_parts[k] = k
        r_parts[k] = name_arrays.k[math.random(1, #name_arrays.k)]
    end
    -- local r_parts.k = name_arrays.k[math.random(1,#name_arrays.k)] did not work
    -- print_s(name_a)
    if r_parts.list_opt and math.random() <= 0.5 then r_parts.list_opt = "" end
    -- print_s(r_parts.list_a..r_parts.list_b..r_parts.list_opt)
    if rules then
        -- print_s(dump(rules))
        local gen_name = ""
        for i, v in ipairs(rules) do
            if v == "-" then
                gen_name = gen_name .. "-"
            elseif v == "\'" then
                gen_name = gen_name .. "\'"
            else
                gen_name = gen_name .. r_parts[v]
            end
        end
        generated_name = gen_name
        -- print_s(dump(generated_name))
        return generated_name
    else
        generated_name = r_parts.syllablesStart .. r_parts.syllablesMiddle ..
                             r_parts.syllablesEnd
        return generated_name
    end
end

witches.rnd_colors = {
    "none", "red", "green", "blue", "orange", "yellow", "violet", "cyan",
    "pink", "black", "magenta", "grey"
}

witches.hair_colors = {
    "black", "brown", "blonde", "gray", "red", "blue", "green"
}

local rnd_color = witches.rnd_color
local rnd_colors = witches.rnd_colors

function witches.rnd_color(rnd_colors)
    local color = rnd_colors[math.random(1, #rnd_colors)]
    return color
end

function witches.color_mod_string()
    local str = "^[colorize:\"" .. rnd_color(rnd_colors) .. ":50\""
    return str
end

-- for rng of small floats
function witches.variance(min, max)
    local target = math.random(min, max) / 100
    -- print(target)
    return target
end

--- Drops a special personlized item
function witches.special_gifts(self, pname, drop_chance, max_drops)
    if pname then
        if self.drops then
            if not drop_chance then drop_chance = 1000 end
            if not max_drops then max_drops = 1 end
            local rares = {}
            for k, v in pairs(self.drops) do
                -- print_s(dump(v.name).." and "..dump(v.chance))
                if v.chance >= drop_chance then
                    table.insert(rares, v.name)
                end
            end
            if #rares > 0 then
                -- print_s("rares = "..dump(rares))
                local pos = self.object:get_pos()
                pos.y = pos.y + 0.5
                -- witches.mixitup(pos)
                if #rares > max_drops then
                    rares = rares[math.random(max_drops, #rares)]
                    if type(rares) ~= table then
                        rares = {rares}
                    end --
                end
                for k, v in pairs(rares) do
                    --[[
          minetest.sound_play("goblins_goblin_cackle", {
            pos = pos,
            gain = 1.0,
            max_hear_distance = self.sounds.distance or 10
          })
          --]]
                    local item_wear = math.random(8000, 10000)
                    local stack = ItemStack({name = v, wear = item_wear})
                    local org_desc = minetest.registered_items[v].description
                    local meta = stack:get_meta()
                    -- boost the stats!
                    local capabilities = stack:get_tool_capabilities()

                    local bonuses = {}
                    for x, y in pairs(capabilities) do
                        if x == "groupcaps" then
                            for a, b in pairs(y) do
                                -- print(dump(a).." is "..dump(b).."\n---")
                                if b and b.uses then
                                    -- print("original uses: "..capabilities.groupcaps[a].uses)

                                    capabilities.groupcaps[a].uses = b.uses + 10
                                    -- print("boosted uses: "..capabilities.groupcaps[a].uses)

                                    -- print(dump(a).." is now "..dump(b))
                                end
                                if b and b.times then
                                    for i, v in pairs(b.times) do
                                        if v > 0.3 then
                                            -- print("original time:".. v )
                                            local v_rnd = math.random(1, 3) / 10
                                            v = v - v_rnd
                                            -- print("boosted time:".. v )
                                        end
                                        capabilities.groupcaps[a].times[i] = v
                                    end
                                end
                            end
                        elseif x == "damage_groups" then
                            for a, b in pairs(y) do
                                -- print(dump(a.." = "..capabilities.damage_groups[a]))
                                capabilities.damage_groups[a] = b +
                                                                    math.random(
                                                                        0, 1)
                                -- print(dump(capabilities.damage_groups[a]))
                            end
                        end
                    end
                    meta:set_tool_capabilities(capabilities)
                    -- print (dump(capabilities))
                    local tool_adj = witches.generate_text(witches.words_desc,
                                                           {"tool_adj"})
                    -- special thanks here to rubenwardy for showing me how translation works!
                    meta:set_string("description", S("@1's @2 @3",
                                                     self.secret_name, tool_adj,
                                                     org_desc))
                    -- minetest.chat_send_player()
                    local inv = minetest.get_inventory({
                        type = "player",
                        name = pname
                    })
                    local reward_text = {}
                    local reward = {}
                    for i, _ in pairs(inv:get_lists()) do
                        -- print(i.." = "..dump(v))
                        if i == "main" and stack and inv:room_for_item(i, stack) then
                            reward_text =
                                S("You are rewarded with @1",
                                  meta:get_string("description"))
                            -- print("generated text: "..reward_text)
                            local reward_item = stack:get_name()
                            -- print("generated:"..stack:get_name())
                            reward = {
                                r_text = reward_text,
                                r_item = reward_item
                            }
                            inv:add_item(i, stack)
                            return reward
                        end
                    end
                    reward_text = S(
                                      "You are rewarded with @1, but you cannot carry it",
                                      meta:get_string("description"))
                    -- print("generated text: "..reward_text)
                    local reward_item = stack:get_name()
                    -- print("generated:"..stack:get_name())
                    reward = {r_text = reward_text, r_item = reward_item}
                    minetest.add_item(pos, stack)
                    -- print("generated text: "..reward_text)
                    return reward
                end
            end
        end
    end
end

function witches.gift(self, pname, drop_chance_min, drop_chance_max, item_wear)
    if not pname then
        witches.debug("no player defined!")
        return
    end
    if not self.drops then
        witches.debug("no droplist defined in this mob!")
        return
    end
    local list = {}
    local reward_text = {}
    local reward_item = {}
    local reward = {}
    local inv = minetest.get_inventory({type = "player", name = pname})
    local pos = self.object:get_pos()
    pos.y = pos.y + 0.5

    drop_chance_min = drop_chance_min or 0
    drop_chance_max = drop_chance_max or 100

    for i = 1, #self.drops do
        if self.drops[i].chance <= drop_chance_max and self.drops[i].chance >=
            drop_chance_min then table.insert(list, self.drops[i]) end
    end

    local item_name = list[math.random(#list)].name
    item_wear = item_wear or math.random(8000, 10000)
    local stack = ItemStack({name = item_name, wear = item_wear})
    local org_desc = minetest.registered_items[item_name].description
    local meta = stack:get_meta()
    meta:set_string("description", S("@1's @2", self.secret_name, org_desc))
    -- print("stack meta "..dump(meta))
    -- print(dump(inv:get_lists()))
    for i, _ in pairs(inv:get_lists()) do
        -- print(i.." = "..dump(v))
        if i == "main" and stack and inv:room_for_item(i, stack) then
            reward_text = S("You are rewarded with @1",
                            meta:get_string("description"))
            -- print("generated text: "..reward_text)
            reward_item = stack:get_name()
            -- print("generated:"..stack:get_name())
            reward = {r_text = reward_text, r_item = reward_item}
            inv:add_item(i, stack)
            return reward
        else
        end
    end

    reward_text = S("You are rewarded with @1, but you cannot carry it",
                    meta:get_string("description"))
    -- print("generated text: "..reward_text)
    reward_item = stack:get_name()
    -- print("generated:"..stack:get_name())
    reward = {r_text = reward_text, r_item = reward_item}
    minetest.add_item(pos, stack)
    -- print("generated text: "..reward_text)
    return reward

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

function witches.stop_and_face(self, pos)
    mobs:yaw_to_pos(self, pos)
    self.state = "stand"
    self:set_velocity(0)
    self:set_animation("stand")
    self.attack = nil
    self.v_start = false
    self.timer = -5
    self.pause_timer = .25
    self.blinktimer = 0
    self.path.way = nil
end

local function stop_and_face(self, pos) witches.stop_and_face(self, pos) end

function witches.award_witches_chest(self, player)
    if player and self.witches_chest and self.witches_chest_owner ==
        self.secret_name then
        local pname = ""
        local meta = minetest.get_meta(self.witches_chest_pos)

        if player:is_player() then pname = player:get_player_name() end

        meta:set_string("owner", pname)
        local sname = meta:get_string("secret_name")
        local info = {self.secret_name, sname, self.witches_chest_pos, pname}
        local pos_string = minetest.pos_to_string(info[3])
        local reward_text = S(
                                "You receive permission from @1 to access the magic chest of @2!\n(@3)",
                                info[1], info[2], pos_string)
        local reward = {r_text = reward_text, r_item = "default:chest"}
        meta:set_string("infotext", S("@1's chest of @2", info[1], info[2]))
        self.witches_chest_owner = pname
        return reward
    end
end

function witches.claim_witches_chest(self)
    local pos = self.object:get_pos()
    pos.min = vector.subtract(pos, 10)
    pos.max = vector.add(pos, 10)
    local meta_table = minetest.find_nodes_with_meta(pos.min, pos.max)
    -- if meta_table then print(dump(meta_table)) end
    for i = 1, #meta_table do
        local meta = minetest.get_meta(meta_table[i])
        if meta:get_string("secret_type") == "witches_chest" then
            local sn = meta:get_string("secret_name")
            -- if sn then print(sn) end
            local o = meta:get_string("owner")
            if o and sn and sn == o then
                witches.debug("unbound chest: " .. sn)
                meta:set_string("owner", self.secret_name)
                meta:set_string("infotext",
                                self.secret_name .. "'s sealed chest")

                self.witches_chest = sn
                self.witches_chest_owner = self.secret_name
                self.witches_chest_pos = meta_table[i]
            end
        end
    end
end

function witches.firefly_mod(self)
    if minetest.registered_tools["fireflies:bug_net"] then
        local check = 0
        for i = 1, #self.drops do
            if self.drops[i].name == "fireflies:bug_net" then
                check = check + 1
            end
        end

        if check < 1 then
            table.insert(self.drops, 1, {
                name = "fireflies:bug_net",
                chance = 1000,
                min = 0,
                max = 1
            })
            table.insert(self.drops, {
                name = "fireflies:firefly_bottle",
                chance = 100,
                min = 0,
                max = 2
            })
        end
    end
end

function witches.item_list_check(list)
    witches.debug("checking list: " .. minetest.serialize(list))
    for i, v in ipairs(list) do
        if not minetest.registered_items[v] then
            witches.debug(i .. ". " .. v .. " not found and removing from list")
            list[i] = nil
        end
    end
    witches.debug("new list: " .. minetest.serialize(list))
    return list
end

function witches.item_request(self, name)
    self.speaking_to = name
    if not self.item_request then self.item_request = {} end
    if not self.item_request.item then
        -- we'd be in trouble if we dont have it already!
        self.item_request.item = witches.looking_for(self)
    end
    if not self.item_request.text then
        -- we need text for the quest!
        -- print("generating")
        local dialog_list = quest_dialogs(self)
        if not self.players then self.players = {} end
        if not self.players[name] then
            self.players[name] = {}
            -- if not self.players.met or #self.players.met < 1 or type(self.players.met) == string then

            -- table.insert(self.players_met, self.secret_name)
        end
        local intro_text = ""

        if not self.players[name].met then
            -- print(dump(self.players[name]))
            -- print( "We don't know "..name.."!")
            local dli_num = math.random(1, #dialog_list.intro)
            intro_text = dialog_list.intro[dli_num]

            self.players[name] = {met = math.floor(os.time())}

        else
            -- print(dump(self.players.met))
            -- print( "We first met "..name.." ".. os.time() - self.players[name].met.." seconds ago")
            local dli_num = math.random(1, #dialog_list.having_met)
            intro_text = dialog_list.having_met[dli_num]
        end

        -- print(intro_text)
        local quest_item = self.item_request.item.desc
        local dlr_num = math.random(1, #dialog_list.item_request)
        local request_text = dialog_list.item_request[dlr_num]
        -- print(request_text)
        self.item_request.text = {intro = intro_text, request = request_text}
        -- print(dump(self.item_request.text))
        return self.item_request.text
    end
end

function witches.found_item(self, clicker)
    local item = clicker:get_wielded_item()

    if item and item:get_name() == self.item_request.item.name then
        local pname = clicker:get_player_name()
        if not minetest.settings:get_bool("creative_mode") then
            item:take_item()
            clicker:set_wielded_item(item)
        end

        if not self.players then
            self.players = {}
            -- print("no records")
        end

        if not self.players[pname] then
            self.players[pname] = {}
            -- print("no records 2")
        end
        -- print(dump(self.players))
        if not self.players[pname].favors then
            self.players[pname] = {favors = 0}
        end

        self.players[pname].favors = self.players[pname].favors + 1
        local reward = {}
        -- print(self.secret_name.." has now received 2 favors"..self.players[pname].favors.." from " ..pname)

        if self.players[pname].favors >= 3 and
            math.fmod(18, self.players[pname].favors) == 0 then
            if self.witches_chest and self.witches_chest_owner ==
                self.secret_name then
                reward = witches.award_witches_chest(self, clicker)
            else
                reward = witches.special_gifts(self, pname)

            end
        else
            reward = witches.gift(self, pname)

            -- print(reward_text)
        end
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
        -- change the requested item
        if self.special_follow then
            self.follow = {}
            witches.item_list_check(self.special_follow)
            self.follow = {
                self.special_follow[math.random(#self.special_follow)]
            }
        end
        return item
    end

end

-- call this to set the self.item_request.item from the witches follow list!
function witches.looking_for(self)
    if not self.item_request then self.item_request = {} end

    if not self.item_request.item then

        if not self.follow or #self.follow < 1 then
            witches.item_list_check(self.special_follow)
            witches.debug(
                "looking for somethine but no self.follow so picking one of these: " ..
                    minetest.serialize(self.special_follow))
            self.follow = {}
            self.follow = {
                self.special_follow[math.random(#self.special_follow)]
            }
            witches.debug(minetest.serialize(self.follow) .. " picked")
        end

        if self.follow and #self.follow >= 1 then
            -- print("testing: "..type(self.follow).." "..#self.follow.." "..dump(self.follow).." "..math.random(1,#self.follow))
            witches.debug(self.secret_name .. "'s self.follow" ..
                              minetest.serialize(self.follow))
            local item = self.follow[math.random(1, #self.follow)]
            -- local stack = ItemStack({name = item})
            witches.debug(self.secret_name .. "'s chosen follow item: " .. item)

            local find = {
                name = minetest.registered_items[item].name,
                desc = minetest.registered_items[item].description,
                icon = minetest.registered_items[item].inventory_image
            }
            -- local meta = item:get_meta()
            -- print_s(S(dump(desc)))
            -- print(dump(find))
            self.item_request.item = find
            return self.item_request
        end
    else
        return self.item_request
    end
end

-- first thing on right click
function witches.quests(self, clicker)
    local pname = clicker:get_player_name()
    -- print(pname.."  clicked on a witch!")
    local item = clicker:get_wielded_item()
    local pos = clicker:get_pos()
    stop_and_face(self, pos)

    -- make sure we are looking for an item
    witches.looking_for(self)

    local var1 = item:get_name()
    local var2 = self.name
    -- print(var1.."  "..var2)

    if var1 == var2 then
        self.dev_mode = pname
        witches.debug("dev mode active for: " .. pname)
    end

    -- print("we are holding a "..dump(item:get_name()))
    if item:get_name() ~= self.item_request.item.name then
        -- create the dialog
        witches.item_request(self, pname)
        -- we can now show the quest!
        witches.find_item_quest.show_to(self, pname)
        -- now that we said what we had to say, we clean up!

        self.item_request.text = nil
        self.dev_mode = nil

        -- print(self.secret_name.." wants a ".. self.item_quest.name)
    elseif self.item_request and self.item_request.item and item and
        item:get_name() == self.item_request.item.name then
        -- print(self.item_quest.name.." and "..item:get_name())
        witches.found_item(self, clicker)
    end

end

