local QBCore = exports['qb-core']:GetCoreObject()

local Blips = {}
local DefaultBlips = {}
local PingingBlips = {}
local ShowMyBlips = true

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('sayer-blipcreator:PlayerLoaded')
    TriggerEvent('sayer-blipcreator:CreateDefaultBlips')
end)

AddEventHandler('onResourceStart', function(resource) 
    if GetCurrentResourceName() ~= resource then return end
    TriggerServerEvent('sayer-blipcreator:PlayerLoaded')
    TriggerEvent('sayer-blipcreator:CreateDefaultBlips')
end)

if Config.BlipCommand then
    RegisterCommand(Config.BlipCommand,function()
        TriggerEvent('sayer-blipcreator:client:OpenMenu')
    end)
end

local function HasJob(jobcode)
    local PlayerJob = QBCore.Functions.GetPlayerData().job.name
    if PlayerJob == jobcode then
        return true
    else
        return false
    end
end

local function DebugCode(msg)
    if Config.DebugCode then
        print(msg)
    end
end

RegisterNetEvent('sayer-blipcreator:CreateDefaultBlips',function()
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

function CreateNewBlip(data, code)
    DebugCode("Finalising Blip")
    if Blips[code] ~= nil then
        RemoveBlip(Blips[code])
    end
    local settings = data[code]
    Blips[code] = AddBlipForCoord(vector3(settings.coords.x, settings.coords.y, settings.coords.z))
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
    DebugCode("Blip Fully Created")
end

RegisterNetEvent('sayer-blipcreator:client:CreateBlips',function(data)
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

RegisterNetEvent('sayer-blipcreator:client:UpdateBlip',function(data, code)
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

RegisterNetEvent('sayer-blipcreator:client:CreateBlipPing',function(code)
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

function ToggleBlipsVisibility()
    ShowMyBlips = not ShowMyBlips
    for _,v in pairs(Blips) do
        if DoesBlipExist(v) then
            if ShowMyBlips then
                SetBlipDisplay(v, 2)
            else
                SetBlipDisplay(v, 0)
            end
        end
    end
end

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


RegisterNetEvent('sayer-blipcreator:client:RemoveBlip',function(id)
    if Blips[id] ~= nil then 
        RemoveBlip(Blips[id])
    end
end)

RegisterNetEvent('sayer-blipcreator:client:NewBlipRegistered',function(data, code)
    if data ~= nil and code ~= nil then
        DebugCode("data and code not nil")
        CreateNewBlip(data,code)
    else
        DebugCode("NewBlip Data or code is nil")
    end
end)

RegisterNetEvent('sayer-blipcreator:client:OpenMenu',function()
    lib.registerContext({
        id = 'sayerBlipsMenuOne',
        title = "Custom Map Markers",
        options = {
            {
                title = "Create Marker",
                description = "Create a custom marker for your map",
                onSelect = function()
                    TriggerEvent('sayer-blipcreator:client:CreateBlipForm',nil,false)
                end
            },
            {
                title = "My Markers",
                description = "Manage Your Markers",
                onSelect = function()
                    TriggerEvent('sayer-blipcreator:client:ManageMarkersMenu')
                end
            },
        }
    })
    lib.showContext('sayerBlipsMenuOne')
end)

RegisterNetEvent('sayer-blipcreator:client:CreateBlipForm', function(ID, edit)
    if edit and not ID then DebugCode("No Id sent with edit form") return end
    -- checks if you require a item to make blip and if you dont have it then cancels
    if not edit and Config.BlipCreationRequiresThisItem and QBCore.Shared.Items[Config.BlipCreationRequiresThisItem] ~= nil and not QBCore.Functions.HasItem(Config.BlipCreationRequiresThisItem) then
        SendNotify("Item Needed", "You Need a "..QBCore.Shared.Items[Config.BlipCreationRequiresThisItem].label, 'error', 5000)
        return
    end

    local function OpenBlipForm(blipData)
        local MenuTitle = edit and "Updating Map Marker" or "Custom Map Marker"
        local SubmitButtonText = edit and "Update!" or "Create!"

        local defaultsprite = blipData and blipData.sprite or "Race Flag"
        local defaultcolour = blipData and blipData.colour or "White"
        local defaultlabel  = blipData and blipData.label  or "Blip"
        local defaultscale  = blipData and blipData.scale  or "Regular"

        local columns = {}
        local Sprites, Colours, Scales = {}, {}, {}

        table.insert(columns, {
            type = "input", 
            label = "Label", 
            icon = 'fas fa-tag',
            description = "Name of Marker",
            name = "label",       
            required = true,
            default = defaultlabel,
        })

        for k, _ in pairs(Config.Sprites) do
            table.insert(Sprites, { label = k, value = k })
        end
        table.insert(columns, {
            type = "select",
            label = "Sprite", 
            icon = 'fas fa-location-dot',
            description = "Blip Icon",  
            name = "sprite",      
            options = Sprites,
            required = true,
            default = defaultsprite,
        })

        for k, _ in pairs(Config.Colours) do
            table.insert(Colours, { label = k, value = k })
        end
        table.insert(columns, {
            type = "select",
            label = "Colour", 
            icon = 'fas fa-palette',
            description = "Colour of Icon",   
            name = "colour",
            options = Colours,  
            required = true,
            default = defaultcolour,
        })

        for k, _ in pairs(Config.Scales) do
            table.insert(Scales, { label = k, value = k })
        end
        table.insert(columns, {
            type = "select",
            label = "Scale",   
            icon = 'fas fa-ruler',
            description = "Scale of Icon", 
            name = "scale",    
            options = Scales,  
            required = true,
            default = defaultscale,
        })

        local delmenu = lib.inputDialog(MenuTitle, columns)
        if delmenu == nil then DebugCode("Returned Nil") return end

        if edit then
            DebugCode("Updating Blip")
            TriggerServerEvent('sayer-blipcreator:server:UpdateBlip', ID, delmenu[1], delmenu[2], delmenu[3], delmenu[4])
        else
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('sayer-blipcreator:server:RegisterBlip', delmenu[1], delmenu[2], delmenu[3], delmenu[4], PlayerCoords, nil)
        end
    end

    -- Only use callback if editing
    if edit then
        QBCore.Functions.TriggerCallback('sayer-blipcreator:server:GetBlipData', function(blipData)
            if not blipData then
                DebugCode("Could not load blip data for ID: " .. tostring(ID))
                return
            end
            OpenBlipForm(blipData)
        end, ID)
    else
        OpenBlipForm(nil)
    end
end)


RegisterNetEvent('sayer-blipcreator:client:ManageMarkersMenu',function()
    local columns = {
        {
            title = "< Back",
            description = "Go Back To Main Menu",
            onSelect = function()
                TriggerEvent('sayer-blipcreator:client:OpenMenu')
            end
        },
        {
            title = "Toggle Marker Visibility",
            description = "Show/Hide all my custom markers",
            onSelect = function()
                ToggleBlipsVisibility()
            end
        },
    }
    QBCore.Functions.TriggerCallback('sayer-blipcreator:server:GetMyBlips',function(result)
        if result then
            for k,v in pairs(result) do
                DebugCode("K = "..k)
                local item = {}
                item.title = v.label
                item.onSelect = function()
                    id = k
                    TriggerEvent('sayer-blipcreator:client:ManageABlip',id, v.label)
                end
                table.insert(columns, item)
            end 
            lib.registerContext({
                id = 'sayerBlipsMenuTwo',
                title = "Manage Markers",
                options = columns,
            })  
            lib.showContext('sayerBlipsMenuTwo') 
        else
           SendNotify(nil, "You Do Not Have Any Active Markers", 'error', 5000)
        end
    end)
end)

RegisterNetEvent('sayer-blipcreator:client:ManageABlip',function(ID, blip_name)
    local columns = {}

    if Config.AllowPinging then
        table.insert(columns, {
            title = "Ping Marker",
            description = "Set a temporary flash on this marker",
            onSelect = function()
                TriggerEvent('sayer-blipcreator:client:CreateBlipPing',ID)
            end
        })
    end

    if Config.AllowSharing then
        table.insert(columns, {
            title = "Share Marker",
            description = "Share with a nearby friend",
            onSelect = function()
                TriggerEvent('sayer-blipcreator:client:ShareMarkerMenu',ID)
            end
        })
    end

    if Config.AllowFastTravel then
        table.insert(columns, {
            title = "Travel To",
            description = "Fast travel to this marker",
            onSelect = function()
                TriggerEvent('sayer-blipcreator:client:FastTravelTo',ID)
            end
        })
    end

    table.insert(columns, {
        title = "Update Marker",
        description = "Update a specific attribute of this marker",
        onSelect = function()
            TriggerEvent('sayer-blipcreator:client:CreateBlipForm',ID,true)
        end
    })

    table.insert(columns, {
        title = "Delete Marker",
        description = "Delete this marker",
        onSelect = function()
            TriggerServerEvent('sayer-blipcreator:server:DeleteBlip',ID)
        end
    })

    lib.registerContext({
        id = 'sayerBlipsMenuThree',
        title = "Marker: "..blip_name,
        options = columns
    })
    lib.showContext('sayerBlipsMenuThree')
end)

RegisterNetEvent('sayer-blipcreator:client:ShareMarkerMenu',function(blip_id)
    local columns = {}
    QBCore.Functions.TriggerCallback('sayer-blipcreator:server:GetNearbyPlayers',function(result)
        if result then
            local nearbyList = {}
            for _, player in pairs(QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), Config.SharingDistance)) do
                local dist = #(GetEntityCoords(GetPlayerPed(player)) - GetEntityCoords(PlayerPedId()))
                for i = 1, #result do
                    if result[i].nearbySource == GetPlayerServerId(player) then
                        if player ~= PlayerId() or Config.DebugCode then
                            nearbyList[#nearbyList+1] = {
                                nearbySource = result[i].nearbySource, 
                                name = result[i].name, 
                            }
                        end
                    end
                end
            end
            if nearbyList[1] == nil then
                SendNotify("Nobody Nearby", "There isnt anybody here to share with", 'error', 5000)
                return
            end
            for _,v in pairs(nearbyList) do
                local nearbySource = v.nearbySource
                local item = {}
                item.title = "Share with "..v.name
                item.onSelect = function()
                    TriggerServerEvent('sayer-blipcreator:server:ShareBlipWith',id, nearbySource)
                end
                table.insert(columns, item)
            end 
            lib.registerContext({
                id = 'sayerBlipsMenusharing',
                title = "Share Marker With...",
                options = columns,
            })  
            lib.showContext('sayerBlipsMenusharing') 
        else
            SendNotify(nil, "cant retrieve players", 'error', 5000)
        end
    end)
end)

RegisterNetEvent('sayer-blipcreator:client:ReceiveBlip',function(new_data, sender_info)
    lib.registerContext({
        id = 'sayerblipsreceiveblip',
        title = "Received Marker ["..new_data.label.."] from ["..sender_info.name.."], Accept?",
        options = {
            {
                title = "Accept Marker",
                description = "Receive Marker",
                onSelect = function()
                    TriggerServerEvent('sayer-blipcreator:server:RegisterBlip',new_data.label, new_data.sprite, new_data.colour, new_data.scale, new_data.coords, sender_info.senderSource)
                end
            },
            {
                title = "Decline Marker",
                description = "Do Not Receive Marker",
                onSelect = function()
                    TriggerEvent('sayer-blipcreator:client:ShareMarkerMenu',ID)
                end
            },
        }
    })
    lib.showContext('sayerblipsreceiveblip')
end)

RegisterNetEvent('sayer-blipcreator:client:FastTravelTo',function(blip_id)
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

-- RADIAL MENU

RegisterNetEvent('sayer-blipcreator:client:CreateBlipForm_radial',function()
    TriggerEvent('sayer-blipcreator:client:CreateBlipForm', nil, false)
end)

if Config.AddToRadialMenu then
    if Config.RadialMenu == 'qb' then
        exports['qb-radialmenu']:AddOption({
            id = 'blip_creator',
            title = "Create Marker",
            icon = 'location-dot',
            type = 'client',
            event = 'sayer-blipcreator:client:CreateBlipForm_radial',
            shouldClose = true
        })
        exports['qb-radialmenu']:AddOption({
            id = 'blip_creator2',
            title = "My Markers",
            icon = 'pen',
            type = 'client',
            event = 'sayer-blipcreator:client:ManageMarkersMenu',
            shouldClose = true
        })
    elseif Config.RadialMenu == 'ox' then
        lib.registerRadial({
            id = 'blip_creator',
            items = {
              {
                label = 'Create Marker',
                icon = 'location-dot',
                onSelect = function()
                    TriggerEvent('sayer-blipcreator:client:CreateBlipForm',nil,false)
                end
              },
              {
                label = 'My Markers',
                icon = 'pen',
                onSelect = function()
                    TriggerEvent('sayer-blipcreator:client:ManageMarkersMenu')
                end
              }
            }
        })
    
        lib.addRadialItem({
            {
              id = 'blip_manage',
              label = 'Blips',
              icon = 'location-dot',
              menu = 'blip_creator'
            },
        })
    else
        print("error no valid radial found")
    end
end

function SendNotify(Title, Msg, Type, Time)
    if Config.Notify == nil then DebugCode("Sayer Blips: Config.Notify Not Set!") return end
    if not Title then Title = "Markers" end
    if not Time then Time = 5000 end
    if not Type then Type = 'success' end
    if not Msg then DebugCode("SendNotify Client Triggered With No Message") return end

    if Config.Notify == 'qb' then
        QBCore.Functions.Notify(Msg,Type,Time)
    elseif Config.Notify == 'okok' then
        exports['okokNotify']:Alert(Title, Msg, Time, Type, false)
    elseif Config.Notify == 'qs' then
        exports['qs-notify']:Alert(Msg, Time, Type)
    elseif Config.Notify == 'ox' then
        lib.notify({
            title = Title,
            description = Msg,
            type = Type
        })
    elseif Config.Notify == 'other' then
        -- add your notify here
        exports['yournotifyscript']:Notify(Msg,Time,Type)
    end
end