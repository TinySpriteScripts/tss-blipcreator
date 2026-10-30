RegisterNetEvent('tss-blipcreator:client:OpenMenu',function()
    local options = {
        {
            header = "Create Marker",
            icon = "fas fa-map-marker-alt",
            txt = "Create a custom marker for your map",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:CreateBlipForm',nil,false)
            end
        },
        {
            header = "My Markers",
            icon = "fas fa-map",
            txt = "Manage Your Markers",
            onSelect = function()
                TriggerEvent('tss-blipcreator:client:ManageMarkersMenu')
            end
        },
    }
    MarkerMenu(options, {
        header = "Custom Map Markers",
        headertxt = "",
        canClose = true,
    })
end)

RegisterNetEvent('tss-blipcreator:client:CreateBlipForm', function(ID, edit)
    if edit and not ID then TSS.Debug.Print("No Id sent with edit form") return end
    -- checks if you require a item to make blip and if you dont have it then cancels
    if not edit and Config.Options.BlipCreationRequiresThisItem and not TSS.Inventory.Has(Config.Options.BlipCreationRequiresThisItem, 1) then
        MarkerNotify("Item Needed", "You Need a "..MarkerItemLabel(Config.Options.BlipCreationRequiresThisItem), 'error')
        return
    end

    local function OpenBlipForm(blipData)
        local MenuTitle = edit and "Updating Map Marker" or "Custom Map Marker"
        local SubmitButtonText = edit and "Update!" or "Create!"

        local defaultsprite = blipData and blipData.sprite or "Race Flag"
        local defaultcolour = blipData and blipData.colour or "White"
        local defaultlabel  = blipData and blipData.label  or "Blip"
        local defaultscale  = blipData and blipData.scale  or "Regular"

        local values = { label = defaultlabel, sprite = defaultsprite, colour = defaultcolour, scale = defaultscale }
        local showForm
        local function choose(field, choices)
            local options = {}
            local names = {}
            for name in pairs(choices) do names[#names + 1] = name end
            table.sort(names)
            for _, name in ipairs(names) do
                options[#options + 1] = { header = name, icon = field == 'sprite' and MarkerSpriteIcon(name) or nil, onSelect = function()
                    values[field] = name
                    showForm()
                end }
            end
            MarkerMenu(options, { header = 'Choose ' .. field })
        end
        showForm = function()
            MarkerMenu({
                { header = 'Label: ' .. values.label, onSelect = function()
                    TSS.UI.Input({ title = 'Marker label', fields = {
                        { name = 'label', label = 'Name of marker', value = values.label }
                    } }, function(result)
                        local label = result and result.values and result.values.label
                        if type(label) == 'string' and label:match('%S') then values.label = label end
                        showForm()
                    end)
                end },
                { header = 'Sprite: ' .. values.sprite, icon = MarkerSpriteIcon(values.sprite), onSelect = function() choose('sprite', Config.BlipOptions.Sprites) end },
                { header = 'Colour: ' .. values.colour, onSelect = function() choose('colour', Config.BlipOptions.Colours) end },
                { header = 'Scale: ' .. values.scale, onSelect = function() choose('scale', Config.BlipOptions.Scales) end },
                { header = SubmitButtonText, onSelect = function()
                    if edit then
                        TriggerServerEvent('tss-blipcreator:server:UpdateBlip', ID, values.label, values.sprite, values.colour, values.scale)
                    else
                        TriggerServerEvent('tss-blipcreator:server:RegisterBlip', values.label, values.sprite, values.colour, values.scale, GetEntityCoords(PlayerPedId()), nil)
                    end
                end },
            }, { header = MenuTitle })
        end
        showForm()
    end

    -- Only use callback if editing
    if edit then
        local blipData = TSS.Callbacks.Await('tss-blipcreator:server:GetBlipData', nil, ID)
        if not blipData then
            TSS.Debug.Print("Could not load blip data for ID: " .. tostring(ID))
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
    local result = TSS.Callbacks.Await('tss-blipcreator:server:GetMyBlips')
    if result then
        TSS.Debug.Print("got a result")
        for k,v in pairs(result) do
            TSS.Debug.Print("K = "..k)
            local item = {}
            item.header = v.label
            item.icon = MarkerSpriteIcon(v.sprite)
            item.onSelect = function()
                TriggerEvent('tss-blipcreator:client:ManageABlip',k, v.label)
            end
            table.insert(columns, item)
        end
        MarkerMenu(columns, {
            header = "Manage Markers",
            headertxt = "",
            canClose = true,
        })
    else
        TSS.Debug.Print("return was nil")
        MarkerNotify("Markers", "You Do Not Have Any Active Markers", 'error')
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

    MarkerMenu(columns, {
        header = "Marker: "..blip_name,
        headertxt = " id: "..tostring(ID),
        canClose = true,
    })
end)

RegisterNetEvent('tss-blipcreator:client:ShareMarkerMenu',function(blip_id)
    local columns = {}
    local result = TSS.Callbacks.Await('tss-blipcreator:server:GetNearbyPlayers')
    if result then
        local nearbyList = {}
        for _, player in ipairs(result) do
            if player.nearbySource ~= GetPlayerServerId(PlayerId()) then
                nearbyList[#nearbyList + 1] = player
            end
        end
        if nearbyList[1] == nil then
            MarkerNotify("Nobody Nearby", "There isnt anybody here to share with", 'error')
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
        MarkerMenu(columns, {
            header = "Share Marker With...",
            headertxt = "",
            canClose = true,
        })
    else
        MarkerNotify("Markers", "cant retrieve players", 'error')
    end
end)

RegisterNetEvent('tss-blipcreator:client:ReceiveBlip',function(new_data, sender_info)
    local options = {
        {
            header = "Accept Marker",
            icon = MarkerSpriteIcon(new_data.sprite),
            txt = "Receive Marker",
            onSelect = function()
                TriggerServerEvent('tss-blipcreator:server:RegisterBlip',new_data.label, new_data.sprite, new_data.colour, new_data.scale, new_data.coords, sender_info.senderSource)
            end
        },
        {
            header = "Decline Marker",
            txt = "Do Not Receive Marker",
            onSelect = function()
                TSS.UI.Close()
            end
        },
    }
    MarkerMenu(options, {
        header = "Received Marker ["..new_data.label.."] from ["..sender_info.name.."], Accept?",
        headertxt = "",
        canClose = true,
    })
end)
