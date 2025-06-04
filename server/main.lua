local QBCore = exports['qb-core']:GetCoreObject()

if Config.BlipItem then
    QBCore.Functions.CreateUseableItem(Config.BlipItem , function(source, item)
        TriggerClientEvent('tss-blipcreator:client:OpenMenu', source)
    end)
end

function GenerateBlipCode(citizenid, callback)
    local UniqueFound = false
    local NewBlipCode = 0
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            local BlipData = json.decode(result[1].blips)
            while not UniqueFound do
                local random = math.random(1, 99999999)
                NewBlipCode = tostring(random)
                if BlipData[NewBlipCode] == nil then
                    UniqueFound = true
                    DebugCode("Found Unique Code")
                end
            end
            callback(tostring(NewBlipCode))
        else
            local random = math.random(1, 99999999)
            NewBlipCode = tostring(random)
            DebugCode("No BlipData / Making new code")
            callback(tostring(NewBlipCode))
        end
    end)
end


RegisterNetEvent('tss-blipcreator:PlayerLoaded',function()
    local src = source
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
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
    DebugCode("RegisterBlip Reached Server")
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local blipcount = 0

    if not senderSource and Config.BlipCreationRequiresThisItem and not Player.Functions.RemoveItem(Config.BlipCreationRequiresThisItem, 1) then
        SendNotify(src, "Item Needed", "You Need a "..QBCore.Shared.Items[Config.BlipCreationRequiresThisItem].label, 'error', 5000)
        return
    end


    GenerateBlipCode(citizenid, function(NewBlipCode)
        DebugCode("New Blip Code Returned")
        MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
            if result[1] then
                DebugCode("Found Existing BlipData")
                local BlipData = json.decode(result[1].blips)
                for k,v in pairs(BlipData) do
                    blipcount = blipcount + 1
                end
                if blipcount < Config.MaxBlips then
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
                        SendNotify(senderSource, "Share Accepted", "Your Share Was Accepted", 'success', 5000)
                    end
                else
                    SendNotify(src, "Marker Limit Reached", "Cannot Place More Markers", 'error', 5000)
                end
            else
                DebugCode("No Existing BlipData / Creating New")
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
                DebugCode("New BlipData Inserted/ creating new blip")
                TriggerClientEvent('tss-blipcreator:client:NewBlipRegistered', src, BlipData, NewBlipCode)
                if senderSource ~= nil then
                    SendNotify(senderSource, "Share Accepted", "Your Share Was Accepted", 'success', 5000)
                end
            end
        end)
    end)
end)

RegisterNetEvent('tss-blipcreator:server:UpdateBlip', function(id, label, sprite, colour, scale)
    DebugCode("UpadteBlip Reached Server")
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            DebugCode("Found Existing BlipData")
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
                DebugCode("Cannot Find Blip With Matching ID")
            end
        else
            DebugCode("No Existing BlipData / should not have reached this point")
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:DeleteBlip', function(ID)
    local id = ID
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
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
                DebugCode("Error Finding Blip Data for Citizenid: "..citizenid.." with blip ID: "..tostring(id))
            end
        else
            DebugCode("No Blip Data For Citizenid: "..citizenid)
            TriggerClientEvent('tss-blipcreator:client:RemoveBlip',src, id)
            TriggerClientEvent('tss-blipcreator:client:ManageMarkersMenu', src)
        end
    end)
end)

RegisterNetEvent('tss-blipcreator:server:ShareBlipWith', function(blip_id, target_source)
    DebugCode("ShareBlip Reached Server")
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(target_source)
    local citizenid = Player.PlayerData.citizenid
    local sender_name = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
    local sender_info = {
        senderSource = src,
        name = sender_name,
    }
    local target_citizenid = Target.PlayerData.citizenid
    local target_blipcount = 0

    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            DebugCode("Found Existing BlipData to share")
            local BlipData = json.decode(result[1].blips)
            if BlipData[blip_id] ~= nil then
                TriggerClientEvent('tss-blipcreator:client:ReceiveBlip', target_source, BlipData[blip_id], sender_info)
            else
                DebugCode("Cannot Find Blip With Matching ID")
            end
        else
            DebugCode("No Existing BlipData / should not have reached this point")
        end
    end)
end)

QBCore.Functions.CreateCallback('tss-blipcreator:server:GetBlipData', function(source, cb, blip_id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    
    local BlipData = {}
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            BlipData = json.decode(result[1].blips)
            if BlipData[blip_id] then
                cb(BlipData[blip_id])
            else
                cb(nil)
            end
        else 
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('tss-blipcreator:server:GetMyBlips', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    
    local BlipData = {}
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            BlipData = json.decode(result[1].blips)
            if BlipData ~= nil then
                cb(BlipData)
            else
                cb(nil)
            end
        else 
            cb(nil)
        end
    end)
end)

QBCore.Functions.CreateCallback('tss-blipcreator:server:GetNearbyPlayers', function(source, cb)
	local nearbyPlayers = {}
	for _, v in pairs(QBCore.Functions.GetPlayers()) do
		local Player = QBCore.Functions.GetPlayer(v)
		nearbyPlayers[#nearbyPlayers+1] = { 
            nearbySource = v,
            citizenid = Player.PlayerData.citizenid, 
            name = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname  
        }
	end
	cb(nearbyPlayers)
end)

function DebugCode(msg)
    if Config.DebugCode then
        print(msg)
    end
end

function SendNotify(src, Title, Msg, Type, Time)
    if not Title then Title = "Markers" end
    if not Time then Time = 5000 end
    if not Type then Type = 'success' end
    if not Msg then DebugCode("SendNotify Server Triggered With No Message") return end
    if Config.Notify == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, Msg, Type, Time)
    elseif Config.Notify == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src, Title, Msg, Time, Type, false)
    elseif Config.Notify == 'qs' then
        TriggerClientEvent('qs-notify:Alert', src, Msg, Time, Type)
    elseif Config.Notify == 'ox' then
        local data = {
            id = 'sayerblips_notify',
            title = Title,
            description = Msg,
            type = Type 
        }
        TriggerClientEvent('ox_lib:notify', src, data)
    elseif Config.Notify == 'other' then
        --add your notify event here
    end
end