--Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
--The MIT License (MIT)
local function print_s(input)
  print(witches.strip_escapes(input))
end

local S = minetest.get_translator("witches")

witches.find_item_quest = {}
witches.found_item_quest = {}
--local item_request = witches.generate_name(witches.quest_dialogs, {"item_request"})


function witches.find_item_quest.get_formspec(self,name)
    -- retrieve the thing
    --local quest_item = witches.looking_for(self)
    local text = "" 
    if self.item_request.text and type(self.item_request.text) == "table" then
        local intro = self.item_request.text.intro
        local request = "\n"..self.item_request.text.request     
        text = S("@1 @2",intro,request)
    --print(text)

    else
      text = "hey, "..name..", I am error!"
    end
    
    if self.dev_mode == name and self.hair_style and self.hat_style then
      text = text .."\nhair: ".. self.hair_style..",hat: "..self.hat_style
    end
    
    local formspec = {
        "formspec_version[3]",
        "size[6,3.5,true]",
        "position[0.5,0.7]",
        "anchor[0.5,0.5]",
        --"bgcolor[red]",
        "textarea[0.25,0.25;5.75,2.0;;;", minetest.formspec_escape(text), "]",
        "item_image[2.5,2;1,1;"..self.item_request.item.name.. "]"

    }
    -- 
    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")

end

function witches.found_item_quest.get_formspec(self,name)
  local display_item = ""
  -- retrieve the thing
  local quest_item = self.item_request.item

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
      
  }

  -- table.concat is faster than string concatenation - `..`
  return table.concat(formspec, "")
end

function witches.find_item_quest.show_to(self,name)
  minetest.show_formspec(name, "witches.find_item_quest:game", witches.find_item_quest.get_formspec(self,name))
  self.item_request.text = nil
  self.dev_mode = nil
end

function witches.found_item_quest.show_to(self,clicker)
  local name = clicker:get_player_name()
  minetest.show_formspec(name, "witches.found_item_quest:game", witches.found_item_quest.get_formspec(self,name))
  self.players[name].reward_item = nil
  self.players[name].reward_text = nil
end