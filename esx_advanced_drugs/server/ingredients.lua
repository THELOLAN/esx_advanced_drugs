-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
local playersTakingIngredients = {}

RegisterNetEvent('esx_advanced_drugs:takeItem')
AddEventHandler('esx_advanced_drugs:takeItem', function(itemName)
    local _source = source

    pickUpItem(_source, itemName)
end)

function pickUpItem(playerId, itemName)
	if not playersTakingIngredients[playerId] then
		playersTakingIngredients[playerId] = ESX.SetTimeout(config.timeToPickup, function()
			local xPlayer = ESX.GetPlayerFromId(playerId)
            
			if(config.ingredientQuantityOnPickup[itemName]) then
				if(canPlayerCarry(playerId, itemName, config.ingredientQuantityOnPickup[itemName])) then
					xPlayer.addInventoryItem(itemName, config.ingredientQuantityOnPickup[itemName])
				else
					TriggerClientEvent('esx:showNotification', xPlayer.source, getLocalizedText('no_space'))
				end
			else
				printResourceMessage("player " .. GetPlayerName(playerId) .. " tried to pickup '" .. itemName .. "' with 'esx_advanced_drugs:takeItem' (probably cheater)", true)
			end

			playersTakingIngredients[playerId] = nil
		end)
	end
end

function CancelProcessing(playerId)
	if playersTakingIngredients[playerId] then
		ESX.ClearTimeout(playersTakingIngredients[playerId])
		playersTakingIngredients[playerId] = nil
	end
end

RegisterServerEvent('esx_advanced_drugs:cancelProcessing')
AddEventHandler('esx_advanced_drugs:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	CancelProcessing(playerId)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)