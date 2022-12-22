-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
local pedCustomers = {}
local canSellToNpcs = false

local function canPedBeUsedToSell(ped, distance)
    local notAllowedPedTypes = {
        [6] = true, -- Cops
        [28] = true, -- Animals
    }

    return 
        (not IsPedAPlayer(ped)) 
            and 
        (not pedCustomers[ped]) 
            and 
        (distance < 3.0) 
            and 
        (not IsPedDeadOrDying(ped, 1)) 
            and 
        (not IsPedInMeleeCombat(ped)) 
            and 
        (not IsPedFleeing(ped))
            and
        (not notAllowedPedTypes[GetPedType(ped)])
            and
        (not IsPedRagdoll(ped))
            and
        (not GetPedConfigFlag(ped, 17))
end

local function getClosestPed()
    local plyPed = PlayerPedId()

    local plyCoords = GetEntityCoords(plyPed)
    local closestPed, distance = ESX.Game.GetClosestPed(plyCoords)

    if(closestPed == plyPed) then
        closestPed, distance = ESX.Game.GetClosestPed(plyCoords, {plyPed})
    end

    return closestPed, distance
end

Citizen.CreateThread(function()
    if(not config.enableNPCSell) then return end

    while true do
        if(canSellToNpcs) then
            local ply = PlayerId()
            local plyPed = PlayerPedId()

            local plyPedCoords = GetEntityCoords(plyPed)
            local closestPed, distance = getClosestPed()

            Citizen.CreateThread(function() 
                while canPedBeUsedToSell(closestPed, distance) do
                    Citizen.Wait(500)

                    local plyPedCoords = GetEntityCoords(plyPed)
                    closestPed, distance = getClosestPed()

                    SetPedCanRagdollFromPlayerImpact(closestPed, false)
                    SetPedCanBeTargetted(closestPed, false)
                end

                SetPedCanRagdollFromPlayerImpact(closestPed, true)
                SetPedCanBeTargetted(closestPed, true)
            end)

            while canPedBeUsedToSell(closestPed, distance) do
                Citizen.Wait(0)

                local pedCoords = GetEntityCoords(closestPed)

                pedCoords = pedCoords + vector3(0.0, 0.0, 1.0)
                
                ESX.Game.Utils.DrawText3D(pedCoords, getLocalizedText("press_to_sell"), 0.5)

                if(IsControlJustReleased(0, 38)) then
                    pedCustomers[closestPed] = true
                    ClearPedTasks(closestPed)

                    SetPedPrimaryLookat(closestPed, plyPed)
                    TaskGoToEntity(closestPed, plyPed, 2000, 1.0, 100, 1073741824, 0)

                    local timeout = GetGameTimer() + 2000

                    while distance > 1.0 and timeout > GetGameTimer() do
                        Citizen.Wait(100)
                    end

                    if(distance < 3.0) then
                        local animDict = "mp_common"
                        local animName = "givetake1_b"

                        while not HasAnimDictLoaded(animDict) do
                            Citizen.Wait(0)
                            RequestAnimDict(animDict)
                        end

                        ESX.TriggerServerCallback('esx_advanced_drugs:sellToNpc', function(sold)
                            if(sold) then
                                local animDuration = GetAnimDuration(animDict, animName)

                                TaskPlayAnim(closestPed, animDict, animName, 4.0, -4.0, -1, 1, 0.0, false, false, false)

                                Citizen.Wait(math.random(200, 500))

                                TaskPlayAnim(plyPed, animDict, animName, 4.0, -4.0, -1, 1, 0.0, false, false, false)

                                Citizen.Wait(config.sellToNPCTime * 1000)

                                ClearPedTasks(closestPed)
                                ClearPedTasks(plyPed)
                            else
                                TaskReactAndFleePed(closestPed, plyPed)
                            end                       
                        end)
                    end
                end
            end
        end
        
        Citizen.Wait(2000)
    end
end)

RegisterNetEvent('esx_advanced_drugs:canSellToNPCs')
AddEventHandler('esx_advanced_drugs:canSellToNPCs', function(canSellToNpcsResult) 
    canSellToNpcs = canSellToNpcsResult
end)

RegisterNetEvent('esx_advanced_drugs:npcCalledPolice')
AddEventHandler('esx_advanced_drugs:npcCalledPolice', function(coords)
    local blip = AddBlipForRadius(coords, 50.0)

    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 150)

    local streetName = GetStreetNameAtCoord(coords.x, coords.y, coords.z)

    local streetLabel = GetStreetNameFromHashKey(streetName)

    ESX.ShowNotification(getLocalizedText("someone_tried_to_sell_drugs", streetLabel))

    SetTimeout(config.blipTimeAfterNPCCallPolice * 1000, function() 
        if(DoesBlipExist(blip)) then
            RemoveBlip(blip)
        end
    end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    TriggerServerEvent('esx_advanced_drugs:NPCCheckDrugsOnJoin')
end)