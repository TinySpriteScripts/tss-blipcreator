local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('tss-blipcreator:client:OpenMenu',function()
    lib.registerContext({
        id = 'sayerBlipsMenuOne',
        title = "Custom Map Markers",
        options = {
            {
                title = "Create Marker",
                description = "Create a custom marker for your map",
                onSelect = function()
                    TriggerEvent('tss-blipcreator:client:CreateBlipForm',nil,false)
                end
            },
            {
                title = "My Markers",
                description = "Manage Your Markers",
                onSelect = function()
                    TriggerEvent('tss-blipcreator:client:ManageMarkersMenu')
                end
            },
        }
    })
    lib.showContext('sayerBlipsMenuOne')
end)

RegisterNetEvent('tss-blipcreator:client:CreateBlipForm', function(ID, edit)
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
            TriggerServerEvent('tss-blipcreator:server:UpdateBlip', ID, delmenu[1], delmenu[2], delmenu[3], delmenu[4])
        else
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('tss-blipcreator:server:RegisterBlip', delmenu[1], delmenu[2], delmenu[3], delmenu[4], PlayerCoords, nil)
        end
    end

    -- Only use callback if editing
    if edit then
        QBCore.Functions.TriggerCallback('tss-blipcreator:server:GetBlipData', function(blipData)
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


RegisterNetEvent('tss-blipcreator:client:ManageMarkersMenu',function()
    local columns = {
        {
            title = "< Back",
            description = "Go Back To Main Menu",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:OpenMenu')
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
    QBCore.Functions.TriggerCallback('tss-blipcreator:server:GetMyBlips',function(result)
        if result then
            for k,v in pairs(result) do
                DebugCode("K = "..k)
                local item = {}
                item.title = v.label
                item.onSelect = function()
                    id = k
                    TriggerEvent('tss-blipcreator:client:ManageABlip',id, v.label)
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

RegisterNetEvent('tss-blipcreator:client:ManageABlip',function(ID, blip_name)
    local columns = {}

    if Config.AllowPinging then
        table.insert(columns, {
            title = "Ping Marker",
            description = "Set a temporary flash on this marker",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:CreateBlipPing',ID)
            end
        })
    end

    if Config.AllowSharing then
        table.insert(columns, {
            title = "Share Marker",
            description = "Share with a nearby friend",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:ShareMarkerMenu',ID)
            end
        })
    end

    if Config.AllowFastTravel then
        table.insert(columns, {
            title = "Travel To",
            description = "Fast travel to this marker",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:FastTravelTo',ID)
            end
        })
    end

    if Config.AllowSetGPS then
        table.insert(columns, {
            title = "Set GPS",
            description = "Add a GPS Route To This Marker",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:SetGPSTo',ID)
            end
        })
    end

    table.insert(columns, {
        title = "Update Marker",
        description = "Update a specific attribute of this marker",
        onSelect = function()
            TriggerEvent('tss-blipcreator:client:CreateBlipForm',ID,true)
        end
    })

    table.insert(columns, {
        title = "Delete Marker",
        description = "Delete this marker",
        onSelect = function()
            TriggerServerEvent('tss-blipcreator:server:DeleteBlip',ID)
        end
    })

    lib.registerContext({
        id = 'sayerBlipsMenuThree',
        title = "Marker: "..blip_name,
        options = columns
    })
    lib.showContext('sayerBlipsMenuThree')
end)

RegisterNetEvent('tss-blipcreator:client:ShareMarkerMenu',function(blip_id)
    local columns = {}
    QBCore.Functions.TriggerCallback('tss-blipcreator:server:GetNearbyPlayers',function(result)
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
                    TriggerServerEvent('tss-blipcreator:server:ShareBlipWith',id, nearbySource)
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

RegisterNetEvent('tss-blipcreator:client:ReceiveBlip',function(new_data, sender_info)
    lib.registerContext({
        id = 'sayerblipsreceiveblip',
        title = "Received Marker ["..new_data.label.."] from ["..sender_info.name.."], Accept?",
        options = {
            {
                title = "Accept Marker",
                description = "Receive Marker",
                onSelect = function()
                    TriggerServerEvent('tss-blipcreator:server:RegisterBlip',new_data.label, new_data.sprite, new_data.colour, new_data.scale, new_data.coords, sender_info.senderSource)
                end
            },
            {
                title = "Decline Marker",
                description = "Do Not Receive Marker",
                onSelect = function()
                    TriggerEvent('tss-blipcreator:client:ShareMarkerMenu',ID)
                end
            },
        }
    })
    lib.showContext('sayerblipsreceiveblip')
end)