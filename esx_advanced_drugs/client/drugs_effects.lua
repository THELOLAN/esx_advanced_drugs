-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
local allEffects = {}
local activeEffects = {}

allEffects.pink_visual = function(duration)
    if(not activeEffects["visual_color"]) then
        activeEffects["visual_color"] = duration

        local timer = 0

        while timer <= activeEffects["visual_color"] do
            if(GetTimecycleModifierIndex() == -1) then
                SetTimecycleModifier("drug_flying_02")
            end
            
            Citizen.Wait(1000)
            timer = timer + 1000
        end

        ClearTimecycleModifier()
        activeEffects["visual_color"] = false
    else
        activeEffects["visual_color"] = activeEffects["visual_color"] + duration
    end
end

allEffects.visual_shaking = function(duration) 
    if(not activeEffects["visual_shaking"]) then
        activeEffects["visual_shaking"] = duration

        local timer = 0

        while timer <= activeEffects["visual_shaking"] do
            if(not IsGameplayCamShaking()) then
                ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0.6)
            end

            Citizen.Wait(1000)
            timer = timer + 1000
        end

        StopGameplayCamShaking()
        activeEffects["visual_shaking"] = false
    else
        activeEffects["visual_shaking"] = activeEffects["visual_shaking"] + duration
    end
end

allEffects.drunk_walk = function(duration) 
    if(not activeEffects["drunk_walk"]) then
        activeEffects["drunk_walk"] = duration

        local plyPed = PlayerPedId()

        local timer = 0

        local animSet = "move_m@drunk@moderatedrunk"

        RequestAnimSet(animSet)

        while not HasAnimSetLoaded(animSet) do
            Citizen.Wait(0)
        end
        
        while timer <= activeEffects["drunk_walk"] do
            SetPedMovementClipset(plyPed, animSet, 5.0)

            Citizen.Wait(1000)
            timer = timer + 1000
        end

        ResetPedMovementClipset(plyPed, 5.0)
        activeEffects["drunk_walk"] = false
    else
        activeEffects["drunk_walk"] = activeEffects["drunk_walk"] + duration
    end
end

allEffects.green_visual = function(duration)
    if(not activeEffects["visual_color"]) then
        activeEffects["visual_color"] = duration

        local timer = 0

        while timer <= activeEffects["visual_color"] do
            if(GetTimecycleModifierIndex() == -1) then
                SetTimecycleModifier("stoned")
                SetTimecycleModifierStrength(0.54)
            end
            
            Citizen.Wait(1000)
            timer = timer + 1000
        end

        ClearTimecycleModifier()
        activeEffects["visual_color"] = false
    else
        activeEffects["visual_color"] = activeEffects["visual_color"] + duration
    end
end

allEffects.confused_visual = function(duration)
    if(not activeEffects["visual_color"]) then
        activeEffects["visual_color"] = duration

        local timer = 0

        while timer <= activeEffects["visual_color"] do
            if(GetTimecycleModifierIndex() == -1) then
                SetTimecycleModifier("drug_wobbly")
                SetTimecycleModifierStrength(1.0)
            end
            
            Citizen.Wait(1000)
            timer = timer + 1000
        end

        ClearTimecycleModifier()
        activeEffects["visual_color"] = false
    else
        activeEffects["visual_color"] = activeEffects["visual_color"] + duration
    end
end

local function assumeDrug(type)
    local plyPed = PlayerPedId()

    if(type == "pill") then
        local animDict = "mp_suicide"
        local anim = "pill"

        RequestAnimDict(animDict)

        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(0)
        end

        local animDuration = 3200

        TaskPlayAnim(plyPed, animDict, anim, 4.0, 4.0, animDuration, 0, 0.0, 0, 0, 0)

        Citizen.Wait(animDuration)
    elseif(type == "drink") then
        TaskStartScenarioInPlace(plyPed, "world_human_drinking", 0, true)

        Citizen.Wait(10000)

        ClearPedTasks(plyPed)
    elseif(type == "smoke") then
        TaskStartScenarioInPlace(plyPed, "world_human_aa_smoke", 0, true)

        Citizen.Wait(10000)

        ClearPedTasks(plyPed)
    end
end

local function drugEffects(type, effects, duration)
    assumeDrug(type)
    
    duration = duration * 1000
    for k, effect in pairs(effects) do
        Citizen.CreateThread(function() 
            allEffects[effect](duration)
        end)
    end
end

RegisterNetEvent('esx_advanced_drugs:drugEffects', drugEffects)