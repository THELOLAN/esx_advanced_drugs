-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
local function refreshPlayerId(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    for drugName, drugData in pairs(config.drugs) do
        local drugItem = xPlayer.getInventoryItem(drugName)
        
        if(drugItem and drugItem.count >= config.minNPCSellQuantity) then
            TriggerClientEvent('esx_advanced_drugs:canSellToNPCs', playerId, true)
            return
        end
    end

    TriggerClientEvent('esx_advanced_drugs:canSellToNPCs', playerId, false)
end

local function refreshAllPlayers()
    local playersIds = ESX.GetPlayers()

    for k, playerId in pairs(playersIds) do
        refreshPlayerId(playerId)
    end
end

Citizen.CreateThread(function() 
    while ESX == nil do
        Citizen.Wait(100)
    end

    Citizen.Wait(1000)

    refreshAllPlayers()
end)

ESX.RegisterServerCallback('esx_advanced_drugs:sellToNpc', function(playerId, cb)
    if(not isThereEnoughPoliceToSell()) then
        TriggerClientEvent('esx:showNotification', playerId, getLocalizedText('not_enough_police'))

        return
    end
    local acceptSell = math.random(1, 100) < config.sellToNPCChancesToAccept

    if(acceptSell) then
        local xPlayer = ESX.GetPlayerFromId(playerId)

        local playerDrugs = {}
        local hasAnyDrug = false

        for drugName, drugData in pairs(config.drugs) do
            local itemCount = xPlayer.getInventoryItem(drugName).count

            if(itemCount >= config.minNPCSellQuantity) then
                table.insert(playerDrugs, drugName)
                hasAnyDrug = true
            end
        end

        if(not hasAnyDrug) then
            cb(false)
            return
        end

        local randomDrugIndex = math.random(1, #playerDrugs)
        local randomDrug = playerDrugs[randomDrugIndex]

        local drugCount = xPlayer.getInventoryItem(randomDrug).count

        local maxSellable = drugCount < config.maxNPCSellQuantity and drugCount or config.maxNPCSellQuantity

        local randomQuantity = math.random(config.minNPCSellQuantity, maxSellable)
        local randomDrugPrice = config.drugs[randomDrug].price * randomQuantity



        if(xPlayer.getInventoryItem(randomDrug).count >= randomQuantity) then
            cb(true)

            Citizen.Wait(config.sellToNPCTime * 1000)

            if(xPlayer.getInventoryItem(randomDrug).count >= randomQuantity) then
                xPlayer.removeInventoryItem(randomDrug, randomQuantity)

                xPlayer.addAccountMoney(config.accountFromNPCSell, randomDrugPrice)

                TriggerClientEvent('esx:showNotification', playerId, getLocalizedText('sold_for', randomQuantity, ESX.GetItemLabel(randomDrug), ESX.Math.GroupDigits(randomDrugPrice)))
            end
        else
            cb(false)
        end
    else
        TriggerClientEvent('esx:showNotification', playerId, getLocalizedText('drug_not_wanted'))

        local plyPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(plyPed)

        for k, plyId in pairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(plyId)

            if(xPlayer.job.name == "police") then
                TriggerClientEvent('esx_advanced_drugs:npcCalledPolice', plyId, playerCoords)
            end
        end

        cb(false)
    end
end)

RegisterNetEvent('esx:onAddInventoryItem')
AddEventHandler('esx:onAddInventoryItem', function(playerId, itemName, itemCount)
    if(config.drugs[itemName]) then
        refreshPlayerId(playerId)
    end
end)

RegisterNetEvent('esx:onRemoveInventoryItem')
AddEventHandler('esx:onRemoveInventoryItem', function(playerId, itemName, itemCount)
    if(config.drugs[itemName]) then
        refreshPlayerId(playerId)
    end
end)

RegisterNetEvent('esx_advanced_drugs:NPCCheckDrugsOnJoin')
AddEventHandler('esx_advanced_drugs:NPCCheckDrugsOnJoin', function()
    local playerId = source

    refreshPlayerId(playerId)
end)