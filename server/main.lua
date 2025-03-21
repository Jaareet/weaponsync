RegisterNetEvent('esx:discardInventoryItem', function(item, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, count)
end)

local ammoBoxConversions = {
	pistol_ammo_box = { ammo = 'pistol_ammo', amount = 24 },
	smg_ammo_box = { ammo = 'smg_ammo', amount = 30 },
	rifle_ammo_box = { ammo = 'rifle_ammo', amount = 30 },
	shotgun_ammo_box = { ammo = 'shotgun_ammo', amount = 16 }
}

for boxItem, data in pairs(ammoBoxConversions) do
	ESX.RegisterUsableItem(boxItem, function(source)
		local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeInventoryItem(boxItem, 1)
		xPlayer.addInventoryItem(data.ammo, data.amount)
	end)
end
