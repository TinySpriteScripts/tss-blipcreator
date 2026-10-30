local function validOptions(label, sprite, colour, scale)
    return type(label) == 'string' and #label <= 100 and label:match('%S')
        and type(sprite) == 'string' and Config.BlipOptions.Sprites[sprite] ~= nil
        and type(colour) == 'string' and Config.BlipOptions.Colours[colour] ~= nil
        and type(scale) == 'string' and Config.BlipOptions.Scales[scale] ~= nil
end

function GenerateBlipCode(citizenid, callback)
    local UniqueFound = false
    local NewBlipCode = 0
    print("generating new code")
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            local BlipData = json.decode(result[1].blips)
            while not UniqueFound do
                local random = math.random(1, 99999999)
                NewBlipCode = tostring(random)
                if BlipData[NewBlipCode] == nil then
                    UniqueFound = true
                    TSS.Debug.Print("Found Unique Code")
                end
            end
            callback(tostring(NewBlipCode))
        else
            local random = math.random(1, 99999999)
            NewBlipCode = tostring(random)
            TSS.Debug.Print("No BlipData / Making new code")
            callback(tostring(NewBlipCode))
        end
    end)
end


RegisterNetEvent('tss-blipcreator:PlayerLoaded',function()
    local src = source
    if not src then return end
    local cid = TSS.Player.Identifier(src)
    if not cid then return end
    print("inside player loaded server")


    print("player citizenid: "..tostring(cid))
    local FormattedData = {}
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { cid }, function(result)
        if result[1] then
            local BlipData = json.decode(result[1].blips)
            local DiscoveredBlips = result[1].blip_discovery and json.decode(result[1].blip_discovery) or {}
            TriggerClientEvent('tss-blipcreator:client:CreateBlips',src, BlipData, DiscoveredBlips)
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:RegisterBlip', function(label, sprite, colour, scale, coords, senderSource)
    if not validOptions(label, sprite, colour, scale) then return end
    if type(coords) ~= "table" and type(coords) ~= "vector3" then return end
    for _, axis in ipairs({ "x", "y", "z" }) do
        local value = coords[axis]
        if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return end
    end
    TSS.Debug.Print("RegisterBlip Reached Server")
    local src = source
    local citizenid = TSS.Player.Identifier(src)
    if not citizenid then return end
    local blipcount = 0

    if not senderSource and Config.Options.BlipCreationRequiresThisItem and not TSS.Inventory.Has(src, Config.Options.BlipCreationRequiresThisItem, 1) then
        MarkerNotify("Item Needed", "You Need a "..MarkerItemLabel(Config.Options.BlipCreationRequiresThisItem), 'error', src)
        return
    end


    GenerateBlipCode(citizenid, function(NewBlipCode)
        TSS.Debug.Print("New Blip Code Returned")
        MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
            if result[1] then
                TSS.Debug.Print("Found Existing BlipData")
                local BlipData = json.decode(result[1].blips)
                for k,v in pairs(BlipData) do
                    blipcount = blipcount + 1
                end
                if blipcount < Config.Options.MaxBlips then
                    BlipData[NewBlipCode] = {
                        coords = coords,
                        label = label,
                        sprite = sprite,
                        colour = colour,
                        scale = scale,
                    }
                    local FormattedData = json.encode(BlipData)
                    MySQL.update('UPDATE player_blips SET blips = ? WHERE citizenid = ?', { FormattedData, citizenid })
                    TriggerClientEvent('tss-blipcreator:client:NewBlipRegistered', src, BlipData, NewBlipCode)
                    if senderSource ~= nil then
                        MarkerNotify("Share Accepted", "Your Share Was Accepted", 'success', senderSource)
                    end
                else
                    MarkerNotify("Marker Limit Reached", "Cannot Place More Markers", 'error', src)
                end
            else
                TSS.Debug.Print("No Existing BlipData / Creating New")
                local BlipData = {}
                BlipData[NewBlipCode] = {
                    coords = coords,
                    label = label,
                    sprite = sprite,
                    colour = colour,
                    scale = scale,
                }
                MySQL.insert('INSERT INTO player_blips (citizenid, blips) VALUES (?, ?)', {
                    citizenid,
                    json.encode(BlipData),
                })
                TSS.Debug.Print("New BlipData Inserted/ creating new blip")
                TriggerClientEvent('tss-blipcreator:client:NewBlipRegistered', src, BlipData, NewBlipCode)
                if senderSource ~= nil then
                    MarkerNotify("Share Accepted", "Your Share Was Accepted", 'success', senderSource)
                end
            end
        end)
    end)
end)

RegisterNetEvent('tss-blipcreator:server:UpdateBlip', function(id, label, sprite, colour, scale)
    if not validOptions(label, sprite, colour, scale) then return end
    TSS.Debug.Print("UpadteBlip Reached Server")
    local src = source
    local citizenid = TSS.Player.Identifier(src)
    if not citizenid then return end

    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            TSS.Debug.Print("Found Existing BlipData")
            local BlipData = json.decode(result[1].blips)
            if BlipData[id] ~= nil then
                BlipData[id].label = label
                BlipData[id].sprite = sprite
                BlipData[id].colour = colour
                BlipData[id].scale = scale
                local FormattedData = json.encode(BlipData)
                MySQL.update('UPDATE player_blips SET blips = ? WHERE citizenid = ?', { FormattedData, citizenid })
                TriggerClientEvent('tss-blipcreator:client:UpdateBlip', src, BlipData, id)
                TriggerClientEvent('tss-blipcreator:client:ManageMarkersMenu', src)
            else
                TSS.Debug.Print("Cannot Find Blip With Matching ID")
            end
        else
            TSS.Debug.Print("No Existing BlipData / should not have reached this point")
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:DeleteBlip', function(ID)
    local id = ID
    local src = source
    local citizenid = TSS.Player.Identifier(src)
    if not citizenid then return end
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            local BlipData = json.decode(result[1].blips)
            if BlipData[id] ~= nil then
                BlipData[id] = nil
                local FormattedData = json.encode(BlipData)
                MySQL.update('UPDATE player_blips SET blips = ? WHERE citizenid = ?', { FormattedData, citizenid })
                TriggerClientEvent('tss-blipcreator:client:RemoveBlip',src, id)
                TriggerClientEvent('tss-blipcreator:client:ManageMarkersMenu', src)
            else
                TSS.Debug.Print("Error Finding Blip Data for Citizenid: "..citizenid.." with blip ID: "..tostring(id))
            end
        else
            TSS.Debug.Print("No Blip Data For Citizenid: "..citizenid)
            TriggerClientEvent('tss-blipcreator:client:RemoveBlip',src, id)
            TriggerClientEvent('tss-blipcreator:client:ManageMarkersMenu', src)
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:ShareBlipWith', function(blip_id, target_source)
    TSS.Debug.Print("ShareBlip Reached Server")
    local src = source
    target_source = tonumber(target_source)
    local citizenid = TSS.Player.Identifier(src)
    if not Config.Options.AllowSharing or not citizenid or not target_source or not TSS.Player.Identifier(target_source) then return end
    local senderPed, targetPed = GetPlayerPed(src), GetPlayerPed(target_source)
    if senderPed == 0 or targetPed == 0 then return end
    if #(GetEntityCoords(senderPed) - GetEntityCoords(targetPed)) > Config.Options.SharingDistance then return end
    local sender_info = { senderSource = src, name = TSS.Player.Name(src) or GetPlayerName(src) }
    local target_blipcount = 0
    local BlipData = {}

    TSS.Debug.Print("ShareBlipWith: server: blip_id: "..tostring(blip_id))

    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            TSS.Debug.Print("Found Existing BlipData to share")
            BlipData = json.decode(result[1].blips)
            if BlipData[blip_id] ~= nil then
                TriggerClientEvent('tss-blipcreator:client:ReceiveBlip', target_source, BlipData[blip_id], sender_info)
            else
                TSS.Debug.Print("Cannot Find Blip With Matching ID")
            end
        else
            TSS.Debug.Print("No Existing BlipData / should not have reached this point")
        end
    end)
end)

TSS.Callbacks.Register("tss-blipcreator:server:GetBlipData", function(source, blip_id)
	if not source then return end
    local citizenid = TSS.Player.Identifier(source)
    if not citizenid then return end
    TSS.Debug.Print("getting blip data: id: "..tostring(blip_id).." for cid: "..tostring(citizenid))
    local p = promise.new()

    local BlipData = {}
    MySQL.query('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        local retval = nil
        if result[1] then
            BlipData = json.decode(result[1].blips)
            if BlipData[blip_id] ~= nil then
                retval = BlipData[blip_id]
            end
        end
        p:resolve(retval)
    end)
    return Citizen.Await(p)
end)

TSS.Callbacks.Register('tss-blipcreator:server:GetMyBlips', function(source, cb)
    if not source then return end
    local citizenid = TSS.Player.Identifier(source)
    if not citizenid then return end
    TSS.Debug.Print("getting my blips: cid: "..tostring(citizenid))
    local p = promise.new()

    local BlipData = {}
    MySQL.query('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        local retval = nil
        if result[1] then
            local BlipData = json.decode(result[1].blips)
            if BlipData ~= nil then
                retval = BlipData
            end
        end
        p:resolve(retval)
    end)
    return Citizen.Await(p)
end)

TSS.Callbacks.Register('tss-blipcreator:server:GetNearbyPlayers', function(source)
    local nearbyPlayers = {}
    local ped = GetPlayerPed(source)
    if ped == 0 then return nearbyPlayers end
    local coords = GetEntityCoords(ped)
    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        local targetPed = GetPlayerPed(target)
        if target ~= source and targetPed ~= 0 and TSS.Player.Identifier(target)
            and #(GetEntityCoords(targetPed) - coords) <= Config.Options.SharingDistance then
            nearbyPlayers[#nearbyPlayers + 1] = {
                nearbySource = target,
                name = TSS.Player.Name(target) or GetPlayerName(target),
            }
        end
    end
    return nearbyPlayers
end)
