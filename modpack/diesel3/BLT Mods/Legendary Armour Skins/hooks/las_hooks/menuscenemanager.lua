MenuSceneManager.go_away_masks = {}

MenuSceneManager.las_clbk_mask_unit_loaded = MenuSceneManager.las_clbk_mask_unit_loaded or MenuSceneManager.clbk_mask_unit_loaded
function MenuSceneManager:clbk_mask_unit_loaded(mask_data_param, status, asset_type, asset_name)
	local owner_key = mask_data_param.unit:key()

	if MenuSceneManager.go_away_masks[owner_key] then return end

	self:las_clbk_mask_unit_loaded(mask_data_param, status, asset_type, asset_name)
end

MenuSceneManager.las_set_character_mask = MenuSceneManager.las_set_character_mask or MenuSceneManager.set_character_mask
function MenuSceneManager:set_character_mask(mask_name_str, unit, peer_id_or_char, mask_id, ready_clbk)
	unit = unit or self._character_unit
	local owner_key = unit:key()

	if MenuSceneManager.go_away_masks[owner_key] then return end

	self:las_set_character_mask(mask_name_str, unit, peer_id_or_char, mask_id, ready_clbk)
end