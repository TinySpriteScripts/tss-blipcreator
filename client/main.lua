Blips = {}
DefaultBlips = {}
PingingBlips = {}
ShowMyBlips = true
MyRouteBlip = nil
MyRouteCode = nil

-- Poll the bridge identifier to cover login, character switches and resource restarts.
CreateThread(function()
    local previousCharacter
    while true do
        local character = TSS.Player.Identifier()
        if character ~= previousCharacter then
            TSS.Blips.Clear()
            Blips, DefaultBlips, PingingBlips, MyRouteBlip, MyRouteCode = {}, {}, {}, nil, nil
            previousCharacter = character
            if character then
                TriggerServerEvent('tss-blipcreator:PlayerLoaded')
                TriggerEvent('tss-blipcreator:CreateDefaultBlips')
            end
        end
        Wait(1000)
    end
end)

-- The Blips module automatically removes this resource's handles when it stops.
RegisterNetEvent('tss-blipcreator:CreateDefaultBlips', function()
    for key, blip in pairs(DefaultBlips) do
        TSS.Blips.Remove(blip)
        DefaultBlips[key] = nil
    end
    for key, settings in pairs(Config.DefaultBlips) do
        if not settings.JobLocked or HasJob(settings.JobLocked) then
            DefaultBlips[key] = TSS.Blips.Create({
                coords = settings.vector,
                sprite = settings.sprite,
                scale = settings.scale,
                colour = settings.color,
                label = settings.text,
                shortRange = settings.rangeshort ~= false,
                display = settings.view,
                hiddenOnLegend = settings.hiddenlegend == true,
            })
        end
    end
end)

RegisterNetEvent('tss-blipcreator:client:CreateBlips', function(data)
    for code in pairs(data) do CreateNewBlip(data, code) end
end)

RegisterNetEvent('tss-blipcreator:client:UpdateBlip', function(data, code)
    CreateNewBlip(data, code)
    if MyRouteCode == code then
        TSS.Blips.Update(MyRouteBlip, {
            coords = TSS.Blips.Coords(Blips[code]),
            routeColor = TSS.Blips.Colour(Blips[code]),
        })
    end
end)

RegisterNetEvent('tss-blipcreator:client:CreateBlipPing', function(code)
    if not TSS.Blips.Exists(Blips[code]) then return end
    if PingingBlips[code] then TSS.Blips.Remove(PingingBlips[code].ID) end
    PingingBlips[code] = {
        ID = TSS.Blips.Create({
            coords = TSS.Blips.Coords(Blips[code]),
            colour = TSS.Blips.Colour(Blips[code]),
            sprite = Config.Options.BlipPingSprite,
            shortRange = false,
            scale = 1.0,
            display = 2,
        }),
        Timer = Config.Options.PingBlipTimer,
    }
end)

CreateThread(function()
    while true do
        Wait(1000) -- runs every second so the timer is accurate
        for code, pingData in pairs(PingingBlips) do
            if pingData.Timer and pingData.Timer > 0 then
                pingData.Timer = pingData.Timer - 1
                if pingData.Timer <= 0 then
                    if TSS.Blips.Exists(pingData.ID) then
                        TSS.Blips.Remove(pingData.ID)
                    end
                    PingingBlips[code] = nil
                end
            end
        end
    end
end)


RegisterNetEvent('tss-blipcreator:client:RemoveBlip', function(id)
    TSS.Blips.Remove(Blips[id])
    Blips[id] = nil
    if PingingBlips[id] then
        TSS.Blips.Remove(PingingBlips[id].ID)
        PingingBlips[id] = nil
    end
    if MyRouteCode == id then
        TSS.Blips.Remove(MyRouteBlip)
        MyRouteBlip, MyRouteCode = nil, nil
    end
end)

RegisterNetEvent('tss-blipcreator:client:NewBlipRegistered',function(data, code)
    if data ~= nil and code ~= nil then
        TSS.Debug.Print("data and code not nil")
        CreateNewBlip(data,code)
    else
        TSS.Debug.Print("NewBlip Data or code is nil")
    end
end)

RegisterNetEvent('tss-blipcreator:client:FastTravelTo',function(blip_id)
    if not Config.Options.AllowFastTravel then return end

    if not TSS.Blips.Exists(Blips[blip_id]) then return end
    local travel_to_coords = TSS.Blips.Coords(Blips[blip_id])
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(10)
    end
    Wait(1000)
    SetEntityCoords(PlayerPedId(), travel_to_coords.x, travel_to_coords.y, travel_to_coords.z, false, false, false, false)
    Wait(100)
    DoScreenFadeIn(1000)
end)

RegisterNetEvent('tss-blipcreator:client:SetGPSTo', function(blip_id)
    if not Config.Options.AllowSetGPS or not TSS.Blips.Exists(Blips[blip_id]) then return end
    TSS.Blips.Remove(MyRouteBlip)
    MyRouteBlip = TSS.Blips.Create({
        coords = TSS.Blips.Coords(Blips[blip_id]),
        sprite = 0,
        display = 2,
        shortRange = false,
        route = true,
        routeColor = TSS.Blips.Colour(Blips[blip_id]),
    })
    MyRouteCode = blip_id
end)

CreateThread(function()
    while true do
        Wait(1000)
        if MyRouteBlip ~= nil then
            if TSS.Blips.Exists(MyRouteBlip) then
                local blip_coords = TSS.Blips.Coords(MyRouteBlip)
                if #(GetEntityCoords(PlayerPedId()) - blip_coords) < 25.0 then
                    TSS.Blips.Remove(MyRouteBlip)
                    MyRouteBlip, MyRouteCode = nil, nil
                end
            end
        end
    end
end)
