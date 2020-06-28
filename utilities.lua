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

--- Our mobs, territories, etc can have randomly generated names.
-- @name_parts is the name parts table: {list_a = "foo bar baz"}
-- @rules are the list table key names in order of how they will be chosen
-- "-" and "\'" are rules that can be used to add a hyphen or apostrophe respectively

function witches.attachment_check(self)
	if not self.owner or not self.owner:get_luaentity() then
		self.object:remove()
	else
		local owner_head_bone = self.owner:get_luaentity().head_bone
		-- local position,rotation = self.owner:get_bone_position(owner_head_bone)
		-- self.object:set_attach(self.owner, owner_head_bone, vector.new(0,0,0), rotation)
	end
end

function witches.looking_for(self)
  if self.follow then

    local item = self.follow[math.random(1,#self.follow)]
    --local stack = ItemStack({name = item})

    local find = {name = minetest.registered_items[item].name, desc = minetest.registered_items[item].description, icon = minetest.registered_items[item].inventory_image}
    --local meta = item:get_meta()
    print_s(S(dump(desc)))
    print(dump(find))
    return find
  end
end

function witches.generate_name(name_parts, rules)
  -- print_s("generating name")
  local name_arrays = {}
  local r_parts = {}
  local generated_name = {}
  for k,v in pairs(name_parts) do
    --  name_arrays.k = mysplit(v)
    name_arrays.k = string.split(v,", ")
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