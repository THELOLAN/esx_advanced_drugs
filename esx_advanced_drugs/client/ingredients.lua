-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(0)

        local plyPed = PlayerPedId()
        local pedCoords = GetEntityCoords(plyPed)

        for ingredientName, pos in pairs(config.ingredientsCoords) do
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, pedCoords, true)
            if(distance < pos.radius) then
                Citizen.CreateThread(function() 
                    while (distance < pos.radius) do
                        Citizen.Wait(2000)
                        pedCoords = GetEntityCoords(plyPed)
                        distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, pedCoords, true)
                    end
                end)

                while (distance < pos.radius) do
                    Citizen.Wait(0)
                    ESX.ShowHelpNotification(getLocalizedText('interact'), true, true, 0)
                    if(IsControlJustPressed(0, 38)) then
                        TriggerServerEvent('esx_advanced_drugs:takeItem', ingredientName)

                        local animDict = "random@mugging4"
                        local anim = "pickup_low"

                        while not HasAnimDictLoaded(animDict) do
                            Citizen.Wait(0)
                            RequestAnimDict(animDict)
                        end
                    
                        TaskPlayAnim(PlayerPedId(), animDict, anim, 1.0, -1.0, config.timeToPickup, 1, 1.0, 0, 0, 0)

                        Citizen.Wait(config.timeToPickup)
                    end
                end
            end
        end
        Citizen.Wait(7500) 
    end
end)

