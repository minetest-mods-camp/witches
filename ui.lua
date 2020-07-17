--Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
--The MIT License (MIT)
local function print_s(input)
  print(witches.strip_escapes(input))
end

local S = minetest.get_translator("witches")

witches.find_item_quest = {}
witches.found_item_quest = {}
local item_request = witches.generate_name(witches.quest_dialogs, {"item_request"})

function witches.find_item_quest.get_formspec(self,name)
    -- retrieve the thing
    local quest_item = witches.looking_for(self)
    witches.item_quest(self)
    local text = S("My name is @1, @2 of @3. @4 @5?",self.secret_name,self.secret_title,self.secret_locale,self.item_request,quest_item.desc)
    self.item_request = nil
    local formspec = {
        "formspec_version[3]",
        "size[6,3,true]",
        "position[0.5,0.7]",
        "anchor[0.5,0.5]",
        --"bgcolor[red]",
        "textarea[0.25,0.25;5.5,1.25;;;", minetest.formspec_escape(text), "]",
        "item_image[2.5,1.5;1,1;"..quest_item.name.. "]"
    --[[
        "field[0.375,1.25;5.25,0.8;number;Number;]",
        "button[1.5,2.3;3,0.8;guess;Guess]"
            --]]
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")

end

function witches.found_item_quest.get_formspec(self,name)
  local display_item = ""
  -- retrieve the thing
  local quest_item = witches.looking_for(self)

  local text = S("Thank you @1, for finding @2!",name,quest_item.desc)
  --print(dump(self.players[name].reward_text))
  if self.players[name].reward_text then
    text = text.."\n("..self.players[name].reward_text .. "!)"
  end
  if self.players[name].reward_item then
    display_item = self.players[name].reward_item
  else
    display_item = quest_item.name
  end
  local formspec = {
      "formspec_version[3]",
      "size[6,3.5,true]",
      "position[0.5,0.7]",
      "anchor[0.5,0.5]",
      "textarea[0.25,0.25;5.5,2;;;", minetest.formspec_escape(text), "]",
      "item_image[2.5,2.25;1,1;"..display_item.. "]"
  --[[
      "field[0.375,1.25;5.25,0.8;number;Number;]",
      "button[1.5,2.3;3,0.8;guess;Guess]"
          --]]
  }

  -- table.concat is faster than string concatenation - `..`
  return table.concat(formspec, "")
end

function witches.find_item_quest.show_to(self,name)
  minetest.show_formspec(name, "witches.find_item_quest:game", witches.find_item_quest.get_formspec(self,name))
end

function witches.found_item_quest.show_to(self,clicker)
  local name = clicker:get_player_name()
  minetest.show_formspec(name, "witches.found_item_quest:game", witches.found_item_quest.get_formspec(self,name))
  self.players[name].reward_item = nil
  self.players[name].reward_text = nil
end