-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj 

	for drugName, drugData in pairs(config.drugs) do
		ESX.RegisterUsableItem(drugName, function(playerId)
			local xPlayer = ESX.GetPlayerFromId(playerId)

			xPlayer.removeInventoryItem(drugName, 1)

			TriggerClientEvent('esx_advanced_drugs:drugEffects', playerId, drugData.drugType, drugData.drugEffects, drugData.effectsDuration)
		end)
	end
end)

local policeMembers = {}
local onlinePolice = 0

local function getAllDrugElements()
	local DrugElements = {}
	
    for drugName, drugData in pairs(config.drugs) do
		for ingrName, ingrDoses in pairs(drugData.recipe) do
			DrugElements[ingrName] = true
		end
	end

    return DrugElements
end

drugsElements = getAllDrugElements()

local function createDrug(plyId, drugToCreate, perfect) 
    Citizen.CreateThread(function()
		local drugCreationTime = config.drugsCreationTime[drugToCreate] or 1000
		Citizen.Wait(drugCreationTime)

        local xPlayer = ESX.GetPlayerFromId(plyId)
        if(xPlayer) then
            if not perfect then
                xPlayer.addInventoryItem(drugToCreate, config.drugs[drugToCreate].baseRecipeReward)
            else
                xPlayer.addInventoryItem(drugToCreate, config.drugs[drugToCreate].perfectRecipeReward)
            end
        end
	end)
end

function canPlayerCarry(ply, itemName, itemCount) 
    local canCarry = false
    local xPlayer = ESX.GetPlayerFromId(ply)
    
    if(xPlayer.canCarryItem) then
        canCarry = xPlayer.canCarryItem(itemName, itemCount)
    else
        local item = xPlayer.getInventoryItem(itemName)
        canCarry = (item.limit == -1) or ((item.count + itemCount) <= item.limit) 
    end

    return canCarry
end

local function checkDrugRecipes(ingrQuant, plyId, labId)
    local totalIngredientsNumber = 0

    for k, v in pairs(ingrQuant) do totalIngredientsNumber = totalIngredientsNumber + 1 end

    for drugName, drugData in pairs(config.drugs) do
		local canDoThisDrug = true
		local isRecipePerfect = true

        local playerUsedIngredientCount = 0

        for ingrName, ingrDoses in pairs(drugData.recipe) do
			if(ingrQuant[ingrName] == nil or ingrQuant[ingrName] == 0) then
				canDoThisDrug = false
				break
			elseif(ingrQuant[ingrName] < ingrDoses.min or ingrQuant[ingrName] > ingrDoses.max) then
				canDoThisDrug = false
				break
            else
                playerUsedIngredientCount = playerUsedIngredientCount + 1

				if(ingrQuant[ingrName] ~= ingrDoses.perfect) then
					if isRecipePerfect then
						isRecipePerfect = false
					end
				end
			end
        end
        
        if(canDoThisDrug and (playerUsedIngredientCount == totalIngredientsNumber) and drugData.allowedLabs[labId]) then
            if(canPlayerCarry(plyId, drugName, drugData.baseRecipeReward)) then
                createDrug(plyId, drugName, isRecipePerfect)

                local drugLabel = ESX.GetItemLabel(drugName)
                
                TriggerClientEvent('esx_advanced_drugs:correctIngredients', plyId, drugName, drugLabel)
    
                return drugName
            else
                TriggerClientEvent('esx:showNotification', plyId, getLocalizedText('no_space'))

                return false
            end
		end
	end


    if(next(ingrQuant) ~= nil) then
        TriggerClientEvent('esx_advanced_drugs:wrongIngredients', plyId)
    end

    return false
end

local function getAllDrugs()
    local allDrugs = {}
    for drugName, v in pairs(config.drugs) do
        allDrugs[drugName] = true
    end

    return allDrugs
end

local function hasPlayerAnyDrug(playerId) 
    local xPlayer = ESX.GetPlayerFromId(playerId)
	local playerInventory = xPlayer.getInventory()

	local allDrugs = getAllDrugs()

	for k, v in pairs(playerInventory) do
		if(allDrugs[v.name] and v.count > 0) then
            return true
		end
	end
end

ESX.RegisterServerCallback('esx_advanced_drugs:hasAnyDrug', function(playerId, cb)
	cb(hasPlayerAnyDrug(playerId) and isThereEnoughPoliceToSell())
end)

local function sellDrug(plyId, drug)
    local xPlayer = ESX.GetPlayerFromId(plyId)
    xPlayer.removeInventoryItem(drug.name, drug.count)
    xPlayer.addAccountMoney(config.account, config.drugs[drug.name].price * drug.count)
end

function playerHasDrugs(plyId) 
    local xPlayer = ESX.GetPlayerFromId(plyId)
    local plyInventory = xPlayer.getInventory()
    
    for k, item in pairs(plyInventory) do
        if(config.drugs[item.name] ~= nil and item.count > 0) then
            sellDrug(plyId, item)
            TriggerClientEvent('esx:showNotification', xPlayer.source, getLocalizedText('sold', item.count, item.label))
        end
    end
end

RegisterNetEvent('esx_advanced_drugs:alarmPolice')
AddEventHandler('esx_advanced_drugs:alarmPolice', function(isPlane, veh, justStarted, coords) 
    local message = isPlane and getLocalizedText("plane_spotted") or getLocalizedText("boat_spotted")
    
    local xPlayers = ESX.GetPlayers()
    
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

        if(xPlayer.job.name == "police") then
            if(justStarted) then
                TriggerClientEvent('esx:showNotification', xPlayer.source, message)
            end

            TriggerClientEvent('esx_advanced_drugs:addAlertBlip', xPlayer.source, veh, coords)
        end
    end
end)

ESX.RegisterServerCallback('esx_advanced_drugs:getDrugsElements', function(playerId, cb)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local playerInventory = xPlayer.getInventory()

	local drugsElements = drugsElements

	local elements = {}

	for k, v in pairs(playerInventory) do
		if(drugsElements[v.name] and v.count > 0) then
			table.insert(elements, {type = 'slider', value = 0, min = 0, max = v.count, id = v.name, label = v.label})
		end
	end

    cb(elements)
end)

local isWorking = {}

--[[ 
    Check if the player has the quantites of the items he wants to use, then it removes his items,
    and checks if exists a drug with that ingredients, in the right quantity.
    If the players tries random recipes, he's probably going to lose ingredients without creating anything.
]]
RegisterNetEvent('esx_advanced_drugs:useDrugsIngredients')
AddEventHandler('esx_advanced_drugs:useDrugsIngredients', function(ingredientsUsed, labId, plyId)
	if ingredientsUsed == nil  then return end

	local _source = tonumber(source)

	local xPlayer = nil

	if(_source and _source > 0) then
		xPlayer = ESX.GetPlayerFromId(_source)
	else
		xPlayer = ESX.GetPlayerFromId(plyId)
	end

	if(not xPlayer) then
		return
	end

	local playerHasItems = true

	-- Checks if the player actually has the items declared in the menu
	for actualIngredientName, actualIngredientCount in pairs(ingredientsUsed) do
		local item = xPlayer.getInventoryItem(actualIngredientName)
		if(item.count < actualIngredientCount) then
			TriggerClientEvent('esx:showNotification', xPlayer.source, getLocalizedText('not_enough', item.label))

			return
		end
	end
	
	-- Check if the recipe can be done/redone
	local drugName = checkDrugRecipes(ingredientsUsed, xPlayer.source, labId)

	-- Removes all used items from the inventory
	if(config.removeOnError or drugName) then
		for actualIngredientName, actualIngredientCount in pairs(ingredientsUsed) do
			if(config.drugs[drugName].recipe[actualIngredientName].loseOnUse) then
				xPlayer.removeInventoryItem(actualIngredientName, actualIngredientCount)
			end
		end
	end

	if drugName then
		if(not isWorking[xPlayer.source]) then
			isWorking[xPlayer.source] = true
			TriggerClientEvent('esx_advanced_drugs:isWorking', source, isWorking[xPlayer.source])
		end

		local drugCreationTime = config.drugsCreationTime[drugName] or 1000

		Citizen.Wait(drugCreationTime)

		if(isWorking[xPlayer.source]) then
			TriggerEvent('esx_advanced_drugs:useDrugsIngredients', ingredientsUsed, labId, xPlayer.source)
		else
			return
		end
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, getLocalizedText('wrong_items'))
	end
end)

RegisterNetEvent('esx_advanced_drugs:stopWorking')
AddEventHandler('esx_advanced_drugs:stopWorking', function()
	isWorking[source] = false
end)

ESX.RegisterServerCallback('esx_advanced_drugs:getItemLabel', function(playerId, cb, itemName)
	local itemLabel = ESX.GetItemLabel(itemName)
    cb(itemLabel)
end)

function isThereEnoughPoliceToSell()
	return onlinePolice >= config.minimumPoliceToSell
end

ESX.RegisterServerCallback('esx_advanced_drugs:isThereEnoughPoliceToSell', function()
	cb(isThereEnoughPoliceToSell())
end)

local function countPolice()
	policeMembers = {}
	onlinePolice = 0

	for k, playerId in pairs(ESX.GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(playerId)

		if(xPlayer.job.name == "police") then
			onlinePolice = onlinePolice + 1
			policeMembers[playerId] = true
		end
	end
end

local function addPoliceMember(playerId)
	onlinePolice = onlinePolice + 1
	policeMembers[playerId] = true
end

local function removePoliceMember(playerId)
	policeMembers[playerId] = nil
	onlinePolice = onlinePolice - 1
end

Citizen.CreateThread(function() 
	countPolice()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer) 
	if(xPlayer.job.name == "police") then
		addPoliceMember(playerId)
	end
end)

RegisterNetEvent('esx:playerDropped')
AddEventHandler('esx:playerDropped', function(playerId)
	if(policeMembers[playerId]) then
		removePoliceMember(playerId)
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(playerId, newJob, oldJob) 
	if(policeMembers[playerId]) then
		if(newJob.name ~= oldJob.name) then
			removePoliceMember(playerId)
		end
	elseif(newJob.name == "police") then
		addPoliceMember(playerId)
	end
end)