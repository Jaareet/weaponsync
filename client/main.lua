local weaponHashToItem = {}
local ammoHashToItem = {}

local playerState = {
	data = nil,
	currentWeapon = nil,
	isShooting = false,
	ammoBefore = 0,
	inventoryDict = {}
}

local function InitializeHashes()
	for weaponName, weaponData in pairs(Config.Weapons) do
		weaponHashToItem[joaat(weaponName)] = weaponData
	end

	for ammoName, ammoData in pairs(Config.AmmoTypes) do
		ammoHashToItem[joaat(ammoName)] = ammoData
	end
end

local function UpdateInventoryDict()
	playerState.inventoryDict = {}
	for _, item in ipairs(playerState.data.inventory or {}) do
		playerState.inventoryDict[item.name] = item.count
	end
end

local function GetWeaponAmmoType(weaponHash)
	local weaponData = weaponHashToItem[weaponHash]
	return weaponData and weaponData.ammo
end

local function RebuildLoadout()
	playerState.data = ESX.GetPlayerData()
	UpdateInventoryDict()

	local playerPed = PlayerPedId()

	for weaponHash, weaponData in pairs(weaponHashToItem) do
		local hasWeapon = HasPedGotWeapon(playerPed, weaponHash, false)
		local itemCount = playerState.inventoryDict[weaponData.item] or 0

		if itemCount > 0 then
			local ammo = 0

			if weaponData.item == 'fireextinguisher' then
				ammo = 1000
			else
				local ammoTypeHash = GetPedAmmoTypeFromWeapon(playerPed, weaponHash)
				local ammoData = ammoHashToItem[ammoTypeHash]
				ammo = ammoData and (playerState.inventoryDict[ammoData.item] or 0)
			end

			if hasWeapon then
				if GetAmmoInPedWeapon(playerPed, weaponHash) ~= ammo then
					SetPedAmmo(playerPed, weaponHash, ammo)
				end
			else
				GiveWeaponToPed(playerPed, weaponHash, ammo or 0, false, false)
			end
		elseif hasWeapon then
			RemoveWeaponFromPed(playerPed, weaponHash)
		end
	end
end

local function HandleAmmoUsage()
	local playerPed = PlayerPedId()
	local currentAmmo = GetAmmoInPedWeapon(playerPed, playerState.currentWeapon)
	local ammoTypeHash = GetPedAmmoTypeFromWeapon(playerPed, playerState.currentWeapon)
	local ammoData = ammoHashToItem[ammoTypeHash]

	if ammoData and ammoData.item then
		local ammoUsed = playerState.ammoBefore - currentAmmo
		if ammoUsed > 0 then
			TriggerServerEvent('esx:discardInventoryItem', ammoData.item, ammoUsed)
		end
	end

	return currentAmmo
end

local function OnInventoryUpdate()
	Citizen.Wait(1)
	RebuildLoadout()

	if playerState.currentWeapon then
		playerState.ammoBefore = GetAmmoInPedWeapon(PlayerPedId(), playerState.currentWeapon)
	end
end

local function RegisterEvents()
	RegisterNetEvent('LWeapons:Sync', RebuildLoadout)

	local loadoutEvents = {
		'esx:playerLoaded',
		'esx:modelChanged',
		'playerSpawned',
		'skinchanger:modelLoaded'
	}

	for _, event in ipairs(loadoutEvents) do
		RegisterNetEvent(event, RebuildLoadout)
	end

	AddEventHandler('esx:addInventoryItem', OnInventoryUpdate)
	AddEventHandler('esx:removeInventoryItem', OnInventoryUpdate)
end

Citizen.CreateThread(function()
	InitializeHashes()
	RegisterEvents()

	while not ESX.PlayerLoaded do
		Citizen.Wait(100)
	end

	while ESX.PlayerLoaded do
		local waitTime = 500
		local playerPed = PlayerPedId()
		local selectedWeapon = GetSelectedPedWeapon(playerPed)

		if playerState.currentWeapon ~= selectedWeapon then
			playerState.isShooting = false
			HandleAmmoUsage()
			playerState.currentWeapon = selectedWeapon
			playerState.ammoBefore = GetAmmoInPedWeapon(playerPed, selectedWeapon)
			waitTime = 100
		end

		if IsPedShooting(playerPed) then
			if not playerState.isShooting then
				playerState.isShooting = true
			end
		elseif playerState.isShooting and IsControlJustReleased(0, 24) then
			playerState.isShooting = false
			playerState.ammoBefore = HandleAmmoUsage()
			waitTime = 100
		end

		Citizen.Wait(waitTime)
	end
end)
