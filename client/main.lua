local QBCore = exports['qb-core']:GetCoreObject()

Blips = {}
DefaultBlips = {}
PingingBlips = {}
ShowMyBlips = true
MyRouteBlip = nil

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('tss-blipcreator:PlayerLoaded')
    TriggerEvent('tss-blipcreator:CreateDefaultBlips')
end)

AddEventHandler('onResourceStart', function(resource) 
    if GetCurrentResourceName() ~= resource then return end
    TriggerServerEvent('tss-blipcreator:PlayerLoaded')
    TriggerEvent('tss-blipcreator:CreateDefaultBlips')
end)

RegisterNetEvent('tss-blipcreator:CreateDefaultBlips',function()
    for k,v in pairs(Config.DefaultBlips) do
        if v.JobLocked and not HasJob(v.JobLocked) then return end
        DefaultBlips[k] = AddBlipForCoord(v.vector)
        SetBlipSprite(DefaultBlips[k], v.sprite)
        SetBlipScale(DefaultBlips[k], v.scale)
        SetBlipColour(DefaultBlips[k], v.color)
        SetBlipAsShortRange(DefaultBlips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.text)
        EndTextCommandSetBlipName(DefaultBlips[k])
        SetBlipDisplay(DefaultBlips[k], v.view)
        SetBlipHiddenOnLegend(DefaultBlips[k], v.hiddenlegend)
    end
end)

RegisterNetEvent('tss-blipcreator:client:CreateBlips',function(data, discovered)
    for k,v in pairs(data) do
        if Blips[k] ~= nil then
            RemoveBlip(Blips[k])
        end
        Blips[k] = AddBlipForCoord(v.coords.x,v.coords.y,v.coords.z)
        SetBlipSprite(Blips[k], Config.Sprites[v.sprite])
        SetBlipScale(Blips[k], Config.Scales[v.scale])
        SetBlipColour(Blips[k], Config.Colours[v.colour])
        SetBlipAsShortRange(Blips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(Blips[k])
        if ShowMyBlips then
            SetBlipDisplay(Blips[k], 2)
        else
            SetBlipDisplay(Blips[k], 0)
        end
    end
end)

RegisterNetEvent('tss-blipcreator:client:UpdateBlip',function(data, code)
    if DoesBlipExist(Blips[code]) then
        DebugCode("Removing Old Blip")
        RemoveBlip(Blips[code])
    end
    local settings = data[code]
    Blips[code] = AddBlipForCoord(settings.coords.x,settings.coords.y,settings.coords.z)
    SetBlipSprite(Blips[code], Config.Sprites[settings.sprite])
    SetBlipScale(Blips[code], Config.Scales[settings.scale])
    SetBlipColour(Blips[code], Config.Colours[settings.colour])
    SetBlipAsShortRange(Blips[code], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(settings.label)
    EndTextCommandSetBlipName(Blips[code])
    if ShowMyBlips then
        SetBlipDisplay(Blips[code], 2)
    else
        SetBlipDisplay(Blips[code], 0)
    end
    DebugCode("Blip Fully Updated")
end)

RegisterNetEvent('tss-blipcreator:client:CreateBlipPing',function(code)
    if DoesBlipExist(Blips[code]) then
        if PingingBlips[code] ~= nil and PingingBlips[code].ID ~= nil then
            if DoesBlipExist(PingingBlips[code].ID) then
                RemoveBlip(PingingBlips[code].ID)
            end
        end

        local base_blip_coords = GetBlipCoords(Blips[code])
        local base_blip_colour = GetBlipColour(Blips[code])
        PingingBlips[code] = {}
        PingingBlips[code].ID = AddBlipForCoord(base_blip_coords)
        SetBlipSprite(PingingBlips[code].ID, Config.BlipPingSprite)
        SetBlipColour(PingingBlips[code].ID, base_blip_colour)
        PingingBlips[code].Timer = Config.PingBlipTimer
    end
end)

CreateThread(function()
    while true do
        Wait(1000) -- runs every second so the timer is accurate
        for code, pingData in pairs(PingingBlips) do
            if pingData.Timer and pingData.Timer > 0 then
                pingData.Timer = pingData.Timer - 1
                if pingData.Timer <= 0 then
                    if DoesBlipExist(pingData.ID) then
                        RemoveBlip(pingData.ID)
                    end
                    PingingBlips[code] = nil
                end
            end
        end
    end
end)


RegisterNetEvent('tss-blipcreator:client:RemoveBlip',function(id)
    if Blips[id] ~= nil then 
        RemoveBlip(Blips[id])
    end
end)

RegisterNetEvent('tss-blipcreator:client:NewBlipRegistered',function(data, code)
    if data ~= nil and code ~= nil then
        DebugCode("data and code not nil")
        CreateNewBlip(data,code)
    else
        DebugCode("NewBlip Data or code is nil")
    end
end)

RegisterNetEvent('tss-blipcreator:client:FastTravelTo',function(blip_id)
    if not Config.AllowFastTravel then return end

    if not Blips[blip_id] then return end
    local travel_to_coords = GetBlipCoords(Blips[blip_id])
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    Wait(1000)
    SetEntityCoords(PlayerPedId(), travel_to_coords.x, travel_to_coords.y, travel_to_coords.z, false, false, false, false)
    Wait(100)
    DoScreenFadeIn(1000)
end)

RegisterNetEvent('tss-blipcreator:client:SetGPSTo',function(blip_id)
    if not Config.AllowSetGPS then return end

    if not Blips[blip_id] then return end
    if MyRouteBlip ~= nil then
        if DoesBlipExist(MyRouteBlip) then
            RemoveBlip(MyRouteBlip)
        end
    end

    local route_colour = GetBlipColour(Blips[blip_id])
    local route_coords = GetBlipCoords(Blips[blip_id])

    MyRouteBlip = AddBlipForCoord(route_coords)
    SetBlipRoute(MyRouteBlip, true)
    SetBlipSprite(MyRouteBlip, 0)
    SetBlipRouteColour(MyRouteBlip, route_colour)
end)

CreateThread(function()
    while true do
        Wait(1000)
        if MyRouteBlip ~= nil then
            if DoesBlipExist(MyRouteBlip) then
                local blip_coords = GetBlipCoords(MyRouteBlip)
                if #(GetEntityCoords(PlayerPedId()) - blip_coords) < 25.0 then
                    RemoveBlip(MyRouteBlip)
                    MyRouteBlip = nil
                end
            end
        end
    end
end)