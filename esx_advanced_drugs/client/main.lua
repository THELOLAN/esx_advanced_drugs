-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	if(config.enableIngredientsBlips) then
		-- Blips
		for ingredient, coord in pairs(config.ingredientsCoords) do
			ESX.TriggerServerCallback('esx_advanced_drugs:getItemLabel', function(ingredientLabel)
				local blip = AddBlipForCoord(coord.x, coord.y, coord.z)
				SetBlipSprite(blip, 51)
				SetBlipDisplay(blip,  3)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(ingredientLabel)
				EndTextCommandSetBlipName(blip)

				SetBlipScale(blip, 0.8)
			end, ingredient)
		end
	end

	if(config.enableLabsBlips) then
		for _, coord in pairs(config.Labs) do
			local blip = AddBlipForCoord(coord.x, coord.y, coord.z)
			SetBlipSprite(blip, 270)
			SetBlipDisplay(blip,  3)
			
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Laboratory")
			EndTextCommandSetBlipName(blip)

			SetBlipScale(blip, 0.8)
		end
	end
end)

local function sparks()
	local plyCoords = GetEntityCoords(PlayerPedId())

	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Citizen.Wait(0)
		end
	end

	Citizen.CreateThread(function() 
		for i=1, 2 do
			SetPtfxAssetNextCall("core")

			StartNetworkedParticleFxNonLoopedAtCoord("sp_foundry_sparks", plyCoords, -0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
			Citizen.Wait(500)
		end
	end)

	local animDict = "anim@heists@ornate_bank@thermal_charge"
	local anim = "cover_eyes_loop"

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(0)
		RequestAnimDict(animDict)
	end

	TaskPlayAnim(PlayerPedId(), animDict, anim, 3.0, -1.0, 2000, 1, 1.0, 0, 0, 0)

    if(config.enableFireOnError) then
        StartScriptFire(plyCoords - vector3(0.0, 0.0, 1.0), 4, false)
    end
end

RegisterNetEvent('esx_advanced_drugs:wrongIngredients')
AddEventHandler('esx_advanced_drugs:wrongIngredients', function()
	sparks()
end)

function correctIngredients(drugName)
	local plyCoords = GetEntityCoords(PlayerPedId())

	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Citizen.Wait(0)
		end
	end

	SetPtfxAssetNextCall("core")
	local r = math.random(0, 255) + 0.0
	local g = math.random(0, 255) + 0.0
	local b = math.random(0, 255) + 0.0
	SetParticleFxNonLoopedColour(r, g, b, 0)

	local particle = StartNetworkedParticleFxNonLoopedAtCoord("veh_respray_smoke", plyCoords, 0.0, 0.0, 0.0, 0.40, false, false, false, false)

	local animDict = "missmechanic"
	local anim = "work2_in"

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(0)
		RequestAnimDict(animDict)
	end

	local initialAnimationTime = 2000

	TaskPlayAnim(PlayerPedId(), animDict, anim, 3.0, -1.0, initialAnimationTime, 1, 1.0, 0, 0, 0)
	Citizen.Wait(initialAnimationTime)
	local anim2 = "work2_base"

    local drugCreationTime = config.drugsCreationTime[drugName] or 1000

	TaskPlayAnim(PlayerPedId(), animDict, anim2, 3.0, -1.0, drugCreationTime - initialAnimationTime, 1, 1.0, 0, 0, 0)
end

RegisterNetEvent('esx_advanced_drugs:correctIngredients')
AddEventHandler('esx_advanced_drugs:correctIngredients', function(drugName, drugLabel)
	correctIngredients(drugName)
end)


local function isInSellingArea(method)
    local plyPed = PlayerPedId()

    if(config.sellUseWholeOcean[method]) then
        return IsEntityInZone(plyPed, "OCEANA")
    else
        local plyCoords = GetEntityCoords(plyPed)
        local distance = GetDistanceBetweenCoords(plyCoords, config.sellArea[method].x, config.sellArea[method].y, config.sellArea[method].z, false)

        local canSell = distance < config.sellArea[method].radius

        if(config.showRadiusWhileSelling) then
            if(canSell and not areaBlip) then
                areaBlip = AddBlipForRadius(config.sellArea[method].x, config.sellArea[method].y, config.sellArea[method].z, config.sellArea[method].radius)
                SetBlipDisplay(areaBlip, 8)
                SetBlipColour(areaBlip, 1)
                SetBlipAlpha(areaBlip, 50)
            elseif(not canSell) then
                if(DoesBlipExist(areaBlip)) then
                    RemoveBlip(areaBlip)
                    areaBlip = nil
                end
            end
        end

        return canSell
    end
end

local function height() 
    if config.enableAirplaneSell then
        Citizen.CreateThread(function() 
            while(isInSellingArea("plane") and IsPedInAnyPlane(PlayerPedId()) ) do
                local color = "~r~"
                Citizen.Wait(0)
                local z = GetEntityCoords(PlayerPedId()).z
                z = math.floor(z)

                if(z > config.heightToSell) then
                    color = "~g~"
                end

                ESX.ShowHelpNotification(getLocalizedText('height', color, z), false, false, 100)
            end
        end)
    end
end

local areaBlip = nil

local function plane() 
    Citizen.CreateThread(function()
        local showingHeight = false
        local isSelling = false
        
        while(true) do
            if(not isSelling) then
                if(IsPedInAnyPlane(PlayerPedId())) then
                    if(isInSellingArea("plane")) then
                        ESX.TriggerServerCallback('esx_advanced_drugs:hasAnyDrug', function(hasAnyDrug) 
                            if(hasAnyDrug) then
                                if(not showingHeight) then
                                    height()
                                    showingHeight = true
                                end
                                
                                local z = GetEntityCoords(PlayerPedId()).z
                                if(isInSellingArea("plane") and z > config.heightToSell) then
                                    isSelling = true
                                    
                                    if(config.alarmPoliceInPlane) then
                                        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                                        TriggerServerEvent("esx_advanced_drugs:alarmPolice", true, veh, true, GetEntityCoords(PlayerPedId()))

                                        Citizen.CreateThread(function() 
                                            while isSelling do
                                                Citizen.Wait(10000)
                                                TriggerServerEvent("esx_advanced_drugs:alarmPolice", true, veh, false, GetEntityCoords(PlayerPedId()))
                                            end
                                        end)
                                    end

                                    ESX.ShowNotification(getLocalizedText("remain_to_sell", config.timeToSellInPlane/1000))
            
                                    local timer = config.timeToSellInPlane
                                    while timer > 0 and isInSellingArea("plane") and z > config.heightToSell and IsPedInAnyPlane(PlayerPedId()) do
                                        z = GetEntityCoords(PlayerPedId()).z

                                        timer = timer - 1000
                                        Citizen.Wait(1000)
                                    end
            
                                    if(IsPedInAnyPlane(PlayerPedId()) and isInSellingArea("plane") and z > config.heightToSell) then
                                        TriggerServerEvent('esx_advanced_drugs:sell', player)
                                    else
                                        ESX.ShowNotification(getLocalizedText("minimum_altitude"))
                                    end

                                    isSelling = false
                                    
                                    if(showingHeight) then
                                        showingHeight = false 
                                    end
                                end
                            else
                                if(showingHeight) then
                                    showingHeight = false 
                                end
                            end
                        end)
                    else
                        if(showingHeight) then
                            showingHeight = false 
                        end
                    end
        
                    Citizen.Wait(5000)
                else
                    Citizen.Wait(10000)
                end
            else
                Citizen.Wait(5000)
            end
        end
    end)
end

local function showTimer() 
    Citizen.CreateThread(function() 
        local timer = config.timeToSellInBoat

        Citizen.CreateThread(function() 
            while timer > 0 and isInSellingArea("boat") and IsPedInAnyBoat(PlayerPedId()) do
                Citizen.Wait(0)
                ESX.ShowHelpNotification(getLocalizedText('timer', timer/1000), false, false, 1)
            end
        end)

        local isSelling = true

        if(config.alarmPoliceInBoat) then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            TriggerServerEvent("esx_advanced_drugs:alarmPolice", false, veh, true, GetEntityCoords(PlayerPedId()))

            Citizen.CreateThread(function() 
                while isSelling do
                    Citizen.Wait(10000)
                    TriggerServerEvent("esx_advanced_drugs:alarmPolice", false, veh, false, GetEntityCoords(PlayerPedId()))
                end
            end)
        end

        while timer > 0 and isInSellingArea("boat") and IsPedInAnyBoat(PlayerPedId()) do
            timer = timer - 1000
            Citizen.Wait(1000)
        end

        if(IsPedInAnyBoat(PlayerPedId()) and isInSellingArea("boat")) then
            TriggerServerEvent('esx_advanced_drugs:sell', player)
        end

        isSelling = false
        showingTimer = false
    end)
end

local function boat()
    Citizen.CreateThread(function() 
        while(true) do
            if(IsPedInAnyBoat(PlayerPedId())) then
                if(isInSellingArea("boat")) then
                    ESX.TriggerServerCallback('esx_advanced_drugs:hasAnyDrug', function(hasAnyDrug) 
                        if(hasAnyDrug and (not showingTimer)) then
                            showingTimer = true
                            showTimer()
                        end
                    end)
                end

                Citizen.Wait(5000)
            else
                Citizen.Wait(10000)
            end

            Citizen.Wait(0)
        end
    end)
end

local function sell()
    if config.enableAirplaneSell then
        plane()
    end
    
    if config.enableBoatSell then
        boat()
    end
end

Citizen.CreateThread(function() 
    Citizen.Wait(2000)
    sell()
end)

function openMenu()
    ESX.UI.Menu.CloseAll()
    ESX.TriggerServerCallback('esx_advanced_drugs:getDrugsElements', function(drugsElements)
        
        if(next(drugsElements) == nil) then
            ESX.ShowNotification(getLocalizedText("nothing_useful"))
            isLabOpen = false
            return
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_crafting', {
            title = getLocalizedText('lab'),
            align = 'bottom-right',
            elements = drugsElements
        },
            function(data, menu)
                local ingredientsToUse = {}

                for k, v in pairs(data.elements) do
                    if(v.value > 0) then
                        ingredientsToUse[v.id] = v.value
                    end
                end

                TriggerServerEvent('esx_advanced_drugs:useDrugsIngredients', ingredientsToUse, currentLabId)
                isLabOpen = false
                menu.close()
            end,
            function(data, menu)
                isLabOpen = false
                menu.close()
            end
        )
    end)
end

Citizen.CreateThread(function() 
    local blips = {}
    local blipsTimers = {}

    RegisterNetEvent('esx_advanced_drugs:addAlertBlip')
    AddEventHandler('esx_advanced_drugs:addAlertBlip', function(veh, coords) 
        if(not blips[veh]) then
            blips[veh] = AddBlipForRadius(coords, 400.0)
            SetBlipDisplay(blips[veh], 8)
            SetBlipColour(blips[veh], 1)
            SetBlipAlpha(blips[veh], 50)
            
            Citizen.CreateThread(function()
                local currentBlip = blips[veh]
                blipsTimers[currentBlip] = 0
                while blipsTimers[currentBlip] < 12000 do
                    Citizen.Wait(1000)
                    blipsTimers[currentBlip] = blipsTimers[currentBlip] + 1000
                end

                if(DoesBlipExist(currentBlip)) then
                    RemoveBlip(currentBlip)
                end
            end)
        else
            coords = coords + vector3(math.random(-200, 200), math.random(-200, 200), 0)
            SetBlipCoords(blips[veh], coords)
            local currentBlip = blips[veh]
            blipsTimers[currentBlip] = 0
        end
    end)
end)