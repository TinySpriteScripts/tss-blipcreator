local QBCore = exports['qb-core']:GetCoreObject()

local Blips = {}
local DefaultBlips = {}

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
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
    Blips[code] = AddBlipForCoord(settings.coords)
    SetBlipSprite(Blips[code], Config.Sprites[settings.sprite])
    SetBlipScale(Blips[code], Config.Scales[settings.scale])
    SetBlipColour(Blips[code], Config.Colours[settings.colour])
    SetBlipAsShortRange(Blips[code], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(settings.label)
    EndTextCommandSetBlipName(Blips[code])
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
    DebugCode("Blip Fully Updated")
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

RegisterNetEvent('sayer-blipcreator:client:CreateBlipForm',function(ID,edit)
    if edit and not ID then DebugCode("No Id sent with edit form") return end
    local MenuTitle = "Custom Map Marker"
    local SubmitButtonText = "Create!"
    if edit then
        MenuTitle = "Updating Map Marker"
        SubmitButtonText = "Update!"
    end
    local Sprites = {}
    local Colours = {}
    local Scales = {}
    for k,v in pairs(Config.Sprites) do
        local item = {}
        item.label = k 
        item.value = k 
        table.insert(Sprites, item)
    end
    for k,v in pairs(Config.Colours) do
        local item = {}
        item.label = k 
        item.value = k 
        table.insert(Colours, item)
    end
    for k,v in pairs(Config.Scales) do
        local item = {}
        item.label = k 
        item.value = k
        table.insert(Scales, item)
    end
    local delmenu = lib.inputDialog(
        MenuTitle,
        {
            {
                type = "input", 
                label = "Label", 
                icon = 'fas fa-tag',
                description = "Name of Marker",
                name = "label",       
                required = true,
            },
            {
                type = "select",
                label = "Sprite", 
                icon = 'fas fa-location-dot',
                description = "Blip Icon" ,  
                name = "sprite",      
                options = Sprites,
                required = true,
            },
            {
                type = "select",
                label = "Colour", 
                icon = 'fas fa-palette',
                description = "Colour of Icon",   
                name = "colour",
                options = Colours,  
                required = true,
            },
            {
                type = "select",
                label = "Scale",   
                icon = 'fas fa-ruler',
                description = "Scale of Icon", 
                name = "scale",    
                options = Scales,  
                required = true,
            }
        }
    )
    if delmenu == nil then DebugCode("Returned Nil") return end
    if edit then
        DebugCode("Updating Blip")
        TriggerServerEvent('sayer-blipcreator:server:UpdateBlip', ID, delmenu[1], delmenu[2], delmenu[3], delmenu[4])
    else
        local PlayerCoords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('sayer-blipcreator:server:RegisterBlip',delmenu[1], delmenu[2], delmenu[3], delmenu[4], PlayerCoords)
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
    }
    QBCore.Functions.TriggerCallback('sayer-blipcreator:server:GetMyBlips',function(result)
        if result then
            for k,v in pairs(result) do
                DebugCode("K = "..k)
                local item = {}
                item.title = "Manage: "..v.label
                item.onSelect = function()
                    id = k
                    TriggerEvent('sayer-blipcreator:client:ManageABlip',id)
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
            QBCore.Functions.Notify("You Do Not Have Any Active Markers", 'error', 5000)
        end
    end)
end)

RegisterNetEvent('sayer-blipcreator:client:ManageABlip',function(ID)
    lib.registerContext({
        id = 'sayerBlipsMenuThree',
        title = "Manage Markers",
        options = {
            {
                title = "Update Marker",
                description = "Update a specific attribute of this marker",
                onSelect = function()
                    TriggerEvent('sayer-blipcreator:client:CreateBlipForm',ID,true)
                end
            },
            {
                title = "Delete Marker",
                description = "Delete this marker",
                onSelect = function()
                    TriggerServerEvent('sayer-blipcreator:server:DeleteBlip',ID)
                end
            },
        }
    })
    lib.showContext('sayerBlipsMenuThree')
end)