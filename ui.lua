-- Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
-- The MIT License (MIT)
local function print_s(input) print(witches.strip_escapes(input)) end

local S = minetest.get_translator("witches")

witches.find_item_quest = {}
witches.found_item_ask = {}
witches.found_item_quest = {}

-- local item_request = witches.generate_name(witches.quest_dialogs, {"item_request"})

local _contexts = {}
local function get_context(name)
    local context = _contexts[name] or {}
    _contexts[name] = context
    return context
end

minetest.register_on_leaveplayer(function(player)
    _contexts[player:get_player_name()] = nil
end)

function witches.find_item_quest.get_formspec(self, name)
    -- retrieve the thing
    -- local quest_item = witches.looking_for(self)
    local text = ""
    local item = self.item_request.item
    if self.item_request.text and type(self.item_request.text) == "table" then
        local intro = self.item_request.text.intro
        local request = "\n" .. self.item_request.text.request
        text = S("@1 @2", intro, request)
        -- print(text)

    else
        text = "hey, " .. name .. ", I am error!"
    end

    if self.dev_mode == name and self.hair_style and self.hat_style then
        text = text .. "\nhair: " .. self.hair_style .. ",hat: " ..
                   self.hat_style
    end

    --[[    meta = minetest.get_meta(self.pos)
    local inv = meta:get_inventory()
    inv:set_size("main", 1*1)
    --]]
    
    local formspec = {
        "formspec_version[3]", "size[6,3.5,true]", "position[0.5,0.5]",
        "anchor[0.5,0.5]", "style_type[label;font=bold;font_size=+4]",
        "textarea[0.25,0.25;5.50,2.0;;;", minetest.formspec_escape(text), "]",
        "item_image[2.5,2;1,1;", item.name, "]", "label[2.5,2.25;", item.count,
        "]"

    }
    -- 
    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")

end

function witches.found_item_ask.get_formspec(context, name)
    --print("SHOWING FORMSPEC!")
    local qi = context.target.item_request.item

    local witch = context.target.secret_name
    local text = S("I see you found some @1!\nDo you wish to give me @2 @3?",
                   qi.desc, qi.count, qi.desc)

    local display_item = qi.name

    local formspec = {
        "formspec_version[3]", "size[5,4,true]", "position[0.5,0.5]",
        "anchor[0.5,0.5]",
        "style_type[item_image_button;border=true;font=bold;font_size=+4;bgcolor_hovered=black]",
        "style_type[label;font=bold;font_size=+4]", 
        "textarea[0.1,0.5;5,2;;;", minetest.formspec_escape(text), "]",
         --"item_image[2,2;1,1;",display_item,"]",
        "item_image_button[1,2;1,1;", display_item, ";give_yes;]",
        "label[1.1,2.3;", qi.count, "]", "item_image_button[3,2;1,1;",
        display_item, ";give_no;]", "label[3.1,2.3;0]"
    }
    return table.concat(formspec, "")
end

function witches.found_item_quest.get_formspec(self, name)
    local display_item = "default:mese"
    -- retrieve the thing
    local qi = self.item_request.item

    local text = S("Thank you @1, for finding @2 @3!", name, qi.count, qi.desc)
    -- print(dump(self.players[name].reward_text))
    if self.players[name].reward_text then
        text = text .. "\n(" .. self.players[name].reward_text .. ")"
    end
    if self.players[name].reward_item then
        display_item = self.players[name].reward_item
    else
        display_item = qi.name
    end
    local formspec = {
      "formspec_version[3]", "size[6,4,true]", "position[0.5,0.5]",
      "anchor[0.5,0.5]", 
      "textarea[0.25,0.25;5.5,2;;;", minetest.formspec_escape(text), "]",
      "item_image[2.5,2;1,1;" .. display_item .. "]"
    }

    return table.concat(formspec, "")
end

function witches.find_item_quest.show_to(self, name)
    minetest.show_formspec(name, "witches:find_item_quest",
                           witches.find_item_quest.get_formspec(self, name))
    self.item_request.text = nil
    self.dev_mode = nil
end

function witches.found_item_ask.show_to(self, name)
    local context = get_context(name)
    context.target = self

    local fs = witches.found_item_ask.get_formspec(context, name)
    minetest.show_formspec(name, "witches:found_item_ask", fs)
    -- self.item_request.text = nil

end

function witches.found_item_quest.show_to(self, name)

    minetest.show_formspec(name, "witches:found_item_quest",
                           witches.found_item_quest.get_formspec(self, name))
    self.players[name].reward_item = nil
    self.players[name].reward_text = nil
end

minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname ~= "witches:found_item_ask" then return end

        if formname == "witches:found_item_ask" then
            local name = player:get_player_name()
            local context = get_context(name)
            local qi = context.target.item_request.item
            if fields.give_yes then

                witches.take_item(context.target, player)
                minetest.close_formspec(name, 'witches:found_item_ask')
            else
                minetest.close_formspec(name, 'witches:found_item_ask')
            end
        end
    end)
