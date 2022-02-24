-- Witches is copyright 2020 Francisco Athens, Ramona Athens, Damon Athens and Simone Athens
-- The MIT License (MIT)
-- local mod_name = "witches"
local path = minetest.get_modpath("witches")
witches = {}

witches.version = "20220223"
print("This is Witches " .. witches.version .. "!")

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
    -- print(("%q -> %q"):format(input, out))
    return out
end

local function print_s(input) print(witches.strip_escapes(input)) end

local S = minetest.get_translator("witches")
local settings = minetest.settings

function witches.debug(input)
    local witches_debug = settings:get_bool("witches_debug")
    if witches_debug then print_s(input) end
end

local witches_version = witches.version

if mobs.version then
    if tonumber(mobs.version) >= tonumber(20200516) then
        print_s(S("Mobs Redo 20200516 or greater found! (" .. mobs.version ..
                      ")"))
    else
        print_s(S("You should find a more recent version of Mobs Redo!"))
        print_s(S("https://notabug.org/TenPlus1/mobs_redo"))
    end
else
    print_s(S("This mod requires Mobs Redo version 2020516 or greater!"))
    print_s(S("https://notabug.org/TenPlus1/mobs_redo"))
end

if not doors then
    witches.debug("doors mod not found")
    witches.doors = false
else
    witches.doors = true
    witches.debug("doors mod found")
end

dofile(path .. "/utilities.lua")
dofile(path .. "/ui.lua")
dofile(path .. "/items.lua")
dofile(path .. "/nodes.lua")

-- This gets the list of possible sheep that an enemy can be turned into
if minetest.get_modpath("animalia") then
    witches.sheep = {"animalia:sheep"}
elseif minetest.get_modpath("mobs_animal") then
    witches.sheep = {}
    for key, value in pairs(minetest.registered_entities) do
        if string.sub(key, 1, #("mobs_animal:sheep_")) == "mobs_animal:sheep_" then
            witches.sheep[#witches.sheep + 1] = key
        end
    end
else
    dofile(path .. "/sheep.lua")
    witches.sheep = {}
    for _, col in ipairs(witches.sheep_colors) do
        witches.sheep[#witches.sheep + 1] = "witches:sheep_" .. col[1]
    end
end

dofile(path .. "/magic.lua")
local witches_cottages = settings:get_bool("witches_cottages")

if witches_cottages then
    witches.cottages = true
    dofile(path .. "/cottages.lua")
    print_s(S("Witch cottages will be generated"))
else
    print_s(S("Witch cottages will NOT be generated"))
end

dofile(path .. "/witches.lua")

witches.debug("Generating witches! version: " .. witches.version)

--- This can build all the mobs in our mod.
-- @witch_types is a table with the key used to build the subtype with values that are unique to that subtype
-- @witch_template is the table with all params that a mob type would have defined
function witches.generate(witch_types, witch_template)
    for k, v in pairs(witch_types) do
        -- we need to get a fresh template to modify for every type or we get some carryover values:-P
        local g_template = table.copy(witch_template)
        -- g_type should be different every time so no need to freshen
        local g_type = v
        for x, y in pairs(g_type) do
            -- print_s("found template modifiers " ..dump(x).." = "..dump(y))
            g_template[x] = g_type[x]
        end

        witches.debug("Registering the " .. g_template.description ..
                          ": witches:witch_" .. k)
        if g_template.lore then print_s("  " .. g_template.lore) end
        -- print_s("resulting template: " ..dump(g_template))
        mobs:register_mob("witches:witch_" .. k, g_template)
        mobs:register_egg("witches:witch_" .. k,
                          S("@1  Egg", g_template.description),
                          "default_mossycobble.png", 1)
        g_template.spawning.name = "witches:witch_" .. k -- spawn in the name of the key!
        mobs:spawn(g_template.spawning)
        if g_template.additional_properties then
            for x, y in pairs(g_template.additional_properties) do
                minetest.registered_entities["witches:witch_" .. k][x] = y
            end
        end
        g_template = {}
    end
end

witches.generate(witches.witch_types, witches.witch_template)
