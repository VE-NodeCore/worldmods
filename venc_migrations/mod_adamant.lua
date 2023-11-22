-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, nodecore, string
    = ipairs, minetest, nodecore, string
local string_gsub
    = string.gsub
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function hardalias(oldname, newname)
	local newdef = minetest.registered_items[newname] or {}
	local olddef = nodecore.underride({drop = newdef.drop or newname}, newdef)

	minetest.register_node(":" .. oldname, olddef)

	local function check(pos)
		return minetest.set_node(pos, {
				name = newname,
				param2 = newdef.place_param2
			})
	end

	local label = modname .. ":hardalias_" .. string_gsub(oldname, "%W", "_")
	minetest.register_lbm({
			name = label,
			run_at_every_load = true,
			nodenames = {oldname},
			action = check
		})
	minetest.register_abm({
			label = label,
			interval = 1,
			chance = 1,
			nodenames = {oldname},
			action = check
		})
	nodecore.register_aism({
			label = label,
			interval = 1,
			chance = 1,
			itemnames = {oldname},
			action = function(stack)
				stack:set_name(newname)
				return stack
			end
		})

	return olddef
end

local function words(str) return ipairs(str:split(" ")) end

for _, name in words("cobble cobble_hot cobble_loose ore") do
	hardalias("nc_adamant:" .. name, "nc_lode:" .. name)
end
for _, temper in words("annealed hot tempered") do
	for _, name in words("block adze bar prill rake rod") do
		hardalias(
			"nc_adamant:" .. name .. "_" .. temper,
			"nc_lode:" .. name .. "_" .. temper
		)
	end
	for _, name in words("hatchet mallet mattock pick spade") do
		hardalias(
			"nc_adamant:tool_" .. name .. "_" .. temper,
			"nc_lux:tool_" .. name .. "_" .. temper
		)
		hardalias(
			"nc_adamant:toolhead_" .. name .. "_" .. temper,
			"nc_lode:toolhead_" .. name .. "_" .. temper
		)
	end
end

for k, v in pairs(minetest.registered_items) do
	if string.match(k, "wc_adamant:tool_") then
	  minetest.register_alias(k .. "_infused", k)
	end
  end
