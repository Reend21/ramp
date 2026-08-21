local function expect_yes(self, params) params.yes_func() end -- This function was created by notwa, some code is created by ReaperTeh, rest of it done by Dribbleondo

-- Skills
MenuManager.show_confirm_skillpoints = expect_yes
MenuManager.show_confirm_respec_skilltree = expect_yes

-- Offshore contracts
MenuManager.show_confirm_buy_premium_contract = expect_yes

-- Leaving either the old or new Safehouse via laptop
MenuManager.show_leave_safehouse_dialog = expect_yes

-- Weapons
MenuManager.show_confirm_blackmarket_buy = expect_yes
MenuManager.show_confirm_blackmarket_sell = expect_yes
MenuManager.show_confirm_blackmarket_mod = expect_yes
MenuManager.show_confirm_blackmarket_weapon_mod_purchase = expect_yes -- This is for removing the popup for buying anything with Gage Coi...err I mean Continental Coins.
MenuManager.show_confirm_pay_casino_fee = expect_yes --This is for removing the dialog box for when you use the offshore payday thing.

-- Slots
MenuManager.show_confirm_blackmarket_buy_mask_slot = expect_yes
MenuManager.show_confirm_blackmarket_buy_weapon_slot = expect_yes
MenuManager.show_confirm_blackmarket_slot_item = expect_yes --We can make weapon skins on Linux Now =D

-- Masks
MenuManager.show_confirm_blackmarket_mask_sell = expect_yes
MenuManager.show_confirm_blackmarket_mask_remove = expect_yes
MenuManager.show_confirm_blackmarket_finalize = expect_yes
MenuManager.show_confirm_blackmarket_assemble = expect_yes

MenuManager.show_confirm_blackmarket_abort = expect_yes
-- MenuManager.show_confirm_blackmarket_abort = expect_yes --(This removes the dialog when you try to abort mask customization. As it's quite easy to do this by accident, this is commented out by default, but there's no problems with uncommenting it.)

-- Assets
MenuManager.show_confirm_mission_asset_buy = expect_yes
MenuManager.show_confirm_mission_asset_buy_all = expect_yes --Added in 199.6, you can now buy all the assets.

-- Infamy
MenuManager.show_confirm_become_infamous = expect_yes
MenuManager.show_confirm_infamypoints = expect_yes


-- MenuManager.show_confirm_blackmarket_sell_no_slot = expect_yes (Don't know what this does, but should be harmless to uncomment.)

-- Game States (mission restart)
MenuManager.show_restart_game_dialog = expect_yes
