RegisterNetEvent('tss-blipcreator:client:OpenMenu',function()
    local options = {
        {
            header = "Create Marker",
            txt = "Create a custom marker for your map",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:CreateBlipForm',nil,false)
            end
        },
        {
            header = "My Markers",
            txt = "Manage Your Markers",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:ManageMarkersMenu')
            end
        },
    }
    openMenu(options, {
        header = "Custom Map Markers",
        headertxt = "",
        canClose = true,
    })
end)

RegisterNetEvent('tss-blipcreator:client:CreateBlipForm', function(ID, edit)
    if edit and not ID then debugPrint("No Id sent with edit form") return end
    -- checks if you require a item to make blip and if you dont have it then cancels
    if not edit and Config.Options.BlipCreationRequiresThisItem and Items[Config.Options.BlipCreationRequiresThisItem] ~= nil and not hasItem(Config.Options.BlipCreationRequiresThisItem, 1) then
        triggerNotify("Item Needed", "You Need a "..Items[Config.Options.BlipCreationRequiresThisItem].label, 'error')
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
            type = "text", 
            label = "Label", 
            icon = 'fas fa-tag',
            text = "Name of Marker",
            name = "label",       
            isRequired = true,
            default = defaultlabel,
        })

        for k, _ in pairs(Config.BlipOptions.Sprites) do
            table.insert(Sprites, { label = k, value = k })
        end
        table.insert(columns, {
            type = "select",
            label = "Sprite", 
            icon = 'fas fa-location-dot',
            text = "Blip Icon",  
            name = "sprite",      
            options = Sprites,
            isRequired = true,
            default = defaultsprite,
        })

        for k, _ in pairs(Config.BlipOptions.Colours) do
            table.insert(Colours, { label = k, value = k })
        end
        table.insert(columns, {
            type = "select",
            label = "Colour", 
            icon = 'fas fa-palette',
            text = "Colour of Icon",   
            name = "colour",
            options = Colours,  
            isRequired = true,
            default = defaultcolour,
        })

        for k, _ in pairs(Config.BlipOptions.Scales) do
            table.insert(Scales, { label = k, value = k })
        end
        table.insert(columns, {
            type = "select",
            label = "Scale",   
            icon = 'fas fa-ruler',
            text = "Scale of Icon", 
            name = "scale",    
            options = Scales,  
            isRequired = true,
            default = defaultscale,
        })

        local delmenu = createInput(MenuTitle, columns)
        if delmenu == nil then debugPrint("Returned Nil") return end

        if edit then
            debugPrint("Updating Blip")
            TriggerServerEvent('tss-blipcreator:server:UpdateBlip', ID, delmenu[1], delmenu[2], delmenu[3], delmenu[4])
        else
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('tss-blipcreator:server:RegisterBlip', delmenu[1], delmenu[2], delmenu[3], delmenu[4], PlayerCoords, nil)
        end
    end

    -- Only use callback if editing
    if edit then
        local blipData = triggerCallback('tss-blipcreator:server:GetBlipData', ID)
        if not blipData then
            debugPrint("Could not load blip data for ID: " .. tostring(ID))
            return
        end
        OpenBlipForm(blipData)

    else

        OpenBlipForm(nil)
    end

end)


RegisterNetEvent('tss-blipcreator:client:ManageMarkersMenu',function()
    local columns = {
        {
            header = "< Back",
            txt = "Go Back To Main Menu",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:OpenMenu')
            end
        },
        {
            header = "Toggle Marker Visibility",
            txt = "Show/Hide all my custom markers",
            onSelect = function()
                ToggleBlipsVisibility()
            end
        },
    }
    local result = triggerCallback('tss-blipcreator:server:GetMyBlips')
    if result then
        debugPrint("got a result")
        for k,v in pairs(result) do
            debugPrint("K = "..k)
            local item = {}
            item.header = v.label
            item.onSelect = function()
                TriggerEvent('tss-blipcreator:client:ManageABlip',k, v.label)
            end
            table.insert(columns, item)
        end 
        openMenu(columns, {
            header = "Manage Markers",
            headertxt = "",
            canClose = true,
        })
    else
        debugPrint("return was nil")
        triggerNotify("Markers", "You Do Not Have Any Active Markers", 'error')
    end
end)

RegisterNetEvent('tss-blipcreator:client:ManageABlip',function(ID, blip_name)
    local columns = {}

    if Config.Options.AllowPinging then
        table.insert(columns, {
            header = "Ping Marker",
            txt = "Set a temporary flash on this marker",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:CreateBlipPing',ID)
            end
        })
    end

    if Config.Options.AllowSharing then
        table.insert(columns, {
            header = "Share Marker",
            txt = "Share with a nearby friend",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:ShareMarkerMenu',ID)
            end
        })
    end

    if Config.Options.AllowFastTravel then
        table.insert(columns, {
            header = "Travel To",
            txt = "Fast travel to this marker",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:FastTravelTo',ID)
            end
        })
    end

    if Config.Options.AllowSetGPS then
        table.insert(columns, {
            header = "Set GPS",
            txt = "Add a GPS Route To This Marker",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:SetGPSTo',ID)
            end
        })
    end

    table.insert(columns, {
        header = "Update Marker",
        txt = "Update a specific attribute of this marker",
        onSelect = function()
            TriggerEvent('tss-blipcreator:client:CreateBlipForm',ID,true)
        end
    })

    table.insert(columns, {
        header = "Delete Marker",
        txt = "Delete this marker",
        onSelect = function()
            TriggerServerEvent('tss-blipcreator:server:DeleteBlip',ID)
        end
    })

    openMenu(columns, {
        header = "Marker: "..blip_name,
        headertxt = " id: "..tostring(ID),
        canClose = true,
    })
end)

RegisterNetEvent('tss-blipcreator:client:ShareMarkerMenu',function(blip_id)
    local columns = {}
    local result = triggerCallback('tss-blipcreator:server:GetNearbyPlayers')
    if result then
        local nearbyList = {}
        for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), Config.Options.SharingDistance)) do
            local dist = #(GetEntityCoords(GetPlayerPed(player)) - GetEntityCoords(PlayerPedId()))
            for i = 1, #result do
                if result[i].nearbySource == GetPlayerServerId(player) then
                    if player ~= PlayerId() or debugMode then
                        nearbyList[#nearbyList+1] = {
                            nearbySource = result[i].nearbySource, 
                            name = result[i].name, 
                        }
                    end
                end
            end
        end
        if nearbyList[1] == nil then
            triggerNotify("Nobody Nearby", "There isnt anybody here to share with", 'error')
            return
        end
        for _,v in pairs(nearbyList) do
            local nearbySource = v.nearbySource
            local item = {}
            item.header = "Share with "..v.name
            item.onSelect = function()
                TriggerServerEvent('tss-blipcreator:server:ShareBlipWith',blip_id, nearbySource)
            end
            table.insert(columns, item)
        end 
        openMenu(columns, {
            header = "Share Marker With...",
            headertxt = "",
            canClose = true,
        })
    else
        triggerNotify("Markers", "cant retrieve players", 'error')
    end
end)

RegisterNetEvent('tss-blipcreator:client:ReceiveBlip',function(new_data, sender_info)
    local options = {
        {
            header = "Accept Marker",
            txt = "Receive Marker",
            onSelect = function()
                TriggerServerEvent('tss-blipcreator:server:RegisterBlip',new_data.label, new_data.sprite, new_data.colour, new_data.scale, new_data.coords, sender_info.senderSource)
            end
        },
        {
            header = "Decline Marker",
            txt = "Do Not Receive Marker",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:ShareMarkerMenu',ID)
            end
        },
    }
    openMenu(options, {
        header = "Received Marker ["..new_data.label.."] from ["..sender_info.name.."], Accept?",
        headertxt = "",
        canClose = true,
    })
end)