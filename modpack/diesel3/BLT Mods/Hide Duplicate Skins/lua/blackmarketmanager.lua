--Set visible skins after Steam inventory is loaded.
--IOF blocking also suppresses this function but it's okay.
Hooks:PreHook(BlackMarketManager, "tradable_update", "HideDupeSkins-PreHook-BlackMarketManager:tradable_update", function(self, tradable_list, remove_missing)
	if tradable_list and remove_missing then
		self:hds_build_skin_db(tradable_list)
	end
end)

--Build database on first load, only happens once.
--Needed because init_finalize gets called before this.
Hooks:PostHook(BlackMarketManager, "load", "HideDupeSkins-PostHook-BlackMarketManager:load", function(self, ...)
	self:hds_build_skin_db()
end)

--Build database on reload. Needed because load is only called once.
Hooks:PostHook(BlackMarketManager, "init_finalize", "HideDupeSkins-PostHook-BlackMarketManager:init_finalize", function(self, ...)
	self:hds_build_skin_db()
end)

--Build a database of every unique skin you own
function BlackMarketManager:hds_build_skin_db(tradable_list)
	local function choose_instance(id_1, id_2)
		if tonumber(id_1) < tonumber(id_2) then
			return id_1
		else
			return id_2
		end
	end

	--If no list from Steam, simulate a list based using items in saved inventory
	--Don't update inventory in this case
	local update_inventory = tradable_list and true or false
	if not tradable_list then
		tradable_list = {}
		for instance_id, data in pairs(self._global.inventory_tradable) do
			if data.category == "weapon_skins" then
				local instance = {
					category = data.category,
					entry = data.entry,
					quality = data.quality,
					bonus = data.bonus,
					instance_id = instance_id,
				}
				table.insert(tradable_list, instance)
			end
		end
	end

	--Database with one instance_id for each skin quality/variant
	HideDupeSkins.db = {}
	for _, item in pairs(tradable_list) do
		if item.category == "weapon_skins" then
			local skin_id = item.entry
			local quality = item.quality
			local variant = item.bonus and "stat" or "norm"
			local k = quality.."_"..variant
			local instance_id = item.instance_id
			HideDupeSkins.db[skin_id] = HideDupeSkins.db[skin_id] or {}
			local old_instance = HideDupeSkins.db[skin_id][k]
			HideDupeSkins.db[skin_id][k] = old_instance and choose_instance(old_instance, instance_id) or instance_id
		end
	end

	--Database done, set visible items
	HideDupeSkins:set_visible_items()

	--Update instance_id in inventory
	if update_inventory then
		local crafted_list = self._global.crafted_items or {}
		for category, category_data in pairs(crafted_list) do
			if category == "primaries" or category == "secondaries" then
				for slot, weapon_data in pairs(category_data) do
					--Check if weapon has skin first
					if weapon_data.cosmetics and weapon_data.cosmetics.instance_id then
						local skin_id = weapon_data.cosmetics.id
						--Check if it is a skin you own
						if HideDupeSkins.db[skin_id] then
							local quality = weapon_data.cosmetics.quality
							local variant = weapon_data.cosmetics.bonus and "stat" or "norm"
							local instance_id = HideDupeSkins.db[skin_id][quality.."_"..variant]
							weapon_data.cosmetics.instance_id = instance_id or weapon_data.cosmetics.instance_id
						end
					end
				end
			end
		end
	end
end

--Only return skins in the show list
function BlackMarketManager:get_cosmetics_instances_by_weapon_id(weapon_id)
	local items = {}
	for skin_id, instance_id in pairs(HideDupeSkins.show or {}) do
		if self:weapon_cosmetics_type_check(weapon_id, skin_id) then
			table.insert(items, instance_id)
		end
	end

	return items
end
