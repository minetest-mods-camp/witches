local function print_s(input)
  print(witches.strip_escapes(input))
end

local S = minetest.get_translator("witches")
witches.guessing = {}

function witches.guessing.get_formspec(self,name)
    -- TODO: display whether the last guess was higher or lower
    local quest_item = witches.looking_for(self)

    local text = S("My name is @1 and I'm looking for:\n@2",self.secret_name,quest_item.desc)

    local formspec = {
        "formspec_version[3]",
        "size[7,3]",
        "label[0.375,0.5;", minetest.formspec_escape(text), "]",
        "item_image[3,0.75;1,1;"..quest_item.name.. "]"
    --[[
        "field[0.375,1.25;5.25,0.8;number;Number;]",
        "button[1.5,2.3;3,0.8;guess;Guess]"
            --]]
    }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")

end

function witches.guessing.show_to(self,name)
  minetest.show_formspec(name, "witches.guessing:game", witches.guessing.get_formspec(self,name))
end