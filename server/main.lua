local QBCore = exports['qb-core']:GetCoreObject()

if Config.BlipItem then
    QBCore.Functions.CreateUseableItem(Config.BlipItem , function(source, item)
        TriggerClientEvent('sayer-blipcreator:client:OpenMenu', source)
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


RegisterNetEvent('sayer-blipcreator:PlayerLoaded',function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local FormattedData = {}
    MySQL.rawExecute('SELECT * FROM player_blips WHERE citizenid = ?', { cid }, function(result)
        if result[1] then
            local BlipData = json.decode(result[1].blips)
            TriggerClientEvent('sayer-blipcreator:client:CreateBlips',src, BlipData)
        end
    end)
end)

RegisterNetEvent('sayer-blipcreator:server:RegisterBlip', function(label, sprite, colour, scale, coords)
    DebugCode("RegisterBlip Reached Server")
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local blipcount = 0

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
                    TriggerClientEvent('sayer-blipcreator:client:NewBlipRegistered', src, BlipData, NewBlipCode)
                else
                    TriggerClientEvent('QBCore:Notify', src, "Cannot Place More Markers", 'error', 5000)
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
                TriggerClientEvent('sayer-blipcreator:client:NewBlipRegistered', src, BlipData, NewBlipCode)
            end
        end)
    end)
end)

RegisterNetEvent('sayer-blipcreator:server:UpdateBlip', function(id, label, sprite, colour, scale)
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
                TriggerClientEvent('sayer-blipcreator:client:UpdateBlip', src, BlipData, id)
            else
                DebugCode("Cannot Find Blip With Matching ID")
            end
        else
            DebugCode("No Existing BlipData / should not have reached this point")
        end
    end)
end)

RegisterNetEvent('sayer-blipcreator:server:DeleteBlip', function(ID)
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
                TriggerClientEvent('sayer-blipcreator:client:RemoveBlip',src, id)
            else
                DebugCode("Error Finding Blip Data for Citizenid: "..citizenid.." with blip ID: "..tostring(id))
            end
        else
            DebugCode("No Blip Data For Citizenid: "..citizenid)
            TriggerClientEvent('sayer-blipcreator:client:RemoveBlip',src, id)
        end
    end)
end)

QBCore.Functions.CreateCallback('sayer-blipcreator:server:GetMyBlips', function(source, cb)
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

function DebugCode(msg)
    if Config.DebugCode then
        print(msg)
    end
end