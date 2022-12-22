-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
isLabOpen = false
currentLabId = nil
local labPos = nil
local isWorking = false

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(800)
        for labId, drugPos in pairs(config.Labs) do
            if (#(GetEntityCoords(PlayerPedId()) - drugPos) ) < 3 then
                labPos = drugPos
                currentLabId = labId
            else
                if isLabOpen and drugPos == labPos then
                    ESX.UI.Menu.CloseAll()
                    labPos = false
                    isLabOpen = false
                elseif(isWorking and drugPos == labPos) then
                    isWorking = false
                    labPos = false
                    ESX.ShowNotification(getLocalizedText('too_far'))
                    TriggerServerEvent('esx_advanced_drugs:stopWorking')
                else
                    if drugPos == labPos then
                        labPos = false
                    end
                end
            end
        end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        
        if labPos and not isLabOpen and not isWorking then
            ESX.ShowHelpNotification(getLocalizedText("open_lab"), true, false, 0)
            if IsControlJustReleased(0, 38) then
                isLabOpen = true
                openMenu()
            end
        else
            Citizen.Wait(1000)
        end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        
        if isWorking then
            ESX.ShowHelpNotification(getLocalizedText("press_to_stop"), true, false, 0)
            if IsControlJustReleased(0, 38) then
                isWorking = false
                TriggerServerEvent('esx_advanced_drugs:stopWorking')
                ESX.ShowNotification(getLocalizedText("stopped"))
            end

            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0,21,true)
            DisableControlAction(0,24,true)
            DisableControlAction(0,25,true)
            DisableControlAction(0,47,true)
            DisableControlAction(0,58,true)
            DisableControlAction(0,263,true)
            DisableControlAction(0,264,true)
            DisableControlAction(0,257,true)
            DisableControlAction(0,140,true)
            DisableControlAction(0,141,true)
            DisableControlAction(0,142,true)
            DisableControlAction(0,143,true)
            DisableControlAction(0,75,true)
            DisableControlAction(27,75,true)

        else
            Citizen.Wait(1000)
        end
	end
end)

RegisterNetEvent('esx_advanced_drugs:isWorking')
AddEventHandler('esx_advanced_drugs:isWorking', function(bool) 
    isWorking = bool
end)

AddEventHandler('esx_advanced_drugs:correctIngredients', function(drugName, drugLabel)
    -- Example progressbar (you should download a progressbar script and use the export or the event here)
    -- To get drug creation time,  you can use config.drugsCreationTime[drugName]
    -- TriggerEvent('pogressBar:drawBar', config.drugsCreationTime[drugName], getLocalizedText('crafting_drug', drugLabel))
end)