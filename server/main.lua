CreateThread(function()
    if Config.Options.BlipItem then
        createUseableItem(Config.Options.BlipItem, function(source)
            print("using item")
            TriggerClientEvent('tss-blipcreator:client:OpenMenu', source)
        end)
    end
end)

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
                    debugPrint("Found Unique Code")
                end
            end
            callback(tostring(NewBlipCode))
        else
            local random = math.random(1, 99999999)
            NewBlipCode = tostring(random)
            debugPrint("No BlipData / Making new code")
            callback(tostring(NewBlipCode))
        end
    end)
end


RegisterNetEvent('tss-blipcreator:PlayerLoaded',function()
    local src = source
    if not src then return end
    local Player = getPlayer(src)
    if not Player then return end
    print("inside player loaded server")

    local cid = Player.citizenId

    print("player citizenid: "..tostring(cid))
    local FormattedData = {}
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { cid }, function(result)
        if result[1] then
            local BlipData = json.decode(result[1].blips)
            local DiscoveredBlips = json.decode(result[1].blip_discovery)
            TriggerClientEvent('tss-blipcreator:client:CreateBlips',src, BlipData, DiscoveredBlips)
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:RegisterBlip', function(label, sprite, colour, scale, coords, senderSource)
    debugPrint("RegisterBlip Reached Server")
    local src = source
    local Player = getPlayer(src)
    local citizenid = Player.citizenId
    local blipcount = 0

    if not senderSource and Config.Options.BlipCreationRequiresThisItem and not hasItem(Config.Options.BlipCreationRequiresThisItem, 1, src) then
        triggerNotify("Item Needed", "You Need a "..Items[Config.Options.BlipCreationRequiresThisItem].label, 'error', src)
        return
    end

    
    GenerateBlipCode(citizenid, function(NewBlipCode)
        debugPrint("New Blip Code Returned")
        MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
            if result[1] then
                debugPrint("Found Existing BlipData")
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
                        triggerNotify("Share Accepted", "Your Share Was Accepted", 'success', senderSource)
                    end
                else
                    triggerNotify("Marker Limit Reached", "Cannot Place More Markers", 'error', src)
                end
            else
                debugPrint("No Existing BlipData / Creating New")
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
                debugPrint("New BlipData Inserted/ creating new blip")
                TriggerClientEvent('tss-blipcreator:client:NewBlipRegistered', src, BlipData, NewBlipCode)
                if senderSource ~= nil then
                    triggerNotify("Share Accepted", "Your Share Was Accepted", 'success', senderSource)
                end
            end
        end)
    end)
end)

RegisterNetEvent('tss-blipcreator:server:UpdateBlip', function(id, label, sprite, colour, scale)
    debugPrint("UpadteBlip Reached Server")
    local src = source
    local Player = getPlayer(src)
    local citizenid = Player.citizenId

    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            debugPrint("Found Existing BlipData")
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
                debugPrint("Cannot Find Blip With Matching ID")
            end
        else
            debugPrint("No Existing BlipData / should not have reached this point")
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:DeleteBlip', function(ID)
    local id = ID
    local src = source
    local Player = getPlayer(src)
    local citizenid = Player.citizenId
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
                debugPrint("Error Finding Blip Data for Citizenid: "..citizenid.." with blip ID: "..tostring(id))
            end
        else
            debugPrint("No Blip Data For Citizenid: "..citizenid)
            TriggerClientEvent('tss-blipcreator:client:RemoveBlip',src, id)
            TriggerClientEvent('tss-blipcreator:client:ManageMarkersMenu', src)
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:ShareBlipWith', function(blip_id, target_source)
    debugPrint("ShareBlip Reached Server")
    local src = source
    local Player = getPlayer(src)
    local Target = getPlayer(target_source)
    local citizenid = Player.citizenId
    local sender_name = Player.firstname.." "..Player.lastname
    local sender_info = {
        senderSource = src,
        name = sender_name,
    }
    local target_citizenid = Target.citizenId
    local target_blipcount = 0
    local BlipData = {}

    debugPrint("ShareBlipWith: server: blip_id: "..tostring(blip_id))

    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            debugPrint("Found Existing BlipData to share")
            BlipData = json.decode(result[1].blips)
            if BlipData[blip_id] ~= nil then
                TriggerClientEvent('tss-blipcreator:client:ReceiveBlip', target_source, BlipData[blip_id], sender_info)
            else
                debugPrint("Cannot Find Blip With Matching ID")
            end
        else
            debugPrint("No Existing BlipData / should not have reached this point")
        end
    end)
end)

createCallback("tss-blipcreator:server:GetBlipData", function(source, blip_id)
	if not source then return end
    local Player = getPlayer(source)
    if not Player then return end
    local citizenid = Player.citizenId
    debugPrint("getting blip data: id: "..tostring(blip_id).." for cid: "..tostring(citizenid))
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

createCallback('tss-blipcreator:server:GetMyBlips', function(source, cb)
    if not source then return end
    local Player = getPlayer(source)
    if not Player then return end
    local citizenid = Player.citizenId
    debugPrint("getting my blips: cid: "..tostring(citizenid))
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

createCallback('tss-blipcreator:server:GetNearbyPlayers', function(source)
	local nearbyPlayers = {}
	for _, v in pairs(GetActivePlayers()) do
		local Player = getPlayer(v)
		nearbyPlayers[#nearbyPlayers+1] = { 
            nearbySource = v,
            citizenid = Player.citizenId, 
            name = Player.firstname..' '..Player.lastname  
        }
	end
	return nearbyPlayers
end)