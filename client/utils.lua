local QBCore = exports['qb-core']:GetCoreObject()

if Config.BlipCommand then
    RegisterCommand(Config.BlipCommand,function()
        TriggerEvent('tss-blipcreator:client:OpenMenu')
    end)
end

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

function HasJob(jobcode)
    local PlayerJob = QBCore.Functions.GetPlayerData().job.name
    if PlayerJob == jobcode then
        return true
    else
        return false
    end
end

function DebugCode(msg)
    if Config.DebugCode then
        print(msg)
    end
end

-- RADIAL MENU

RegisterNetEvent('tss-blipcreator:client:CreateBlipForm_radial',function()
    TriggerEvent('tss-blipcreator:client:CreateBlipForm', nil, false)
end)

if Config.AddToRadialMenu then
    if Config.RadialMenu == 'qb' then
        exports['qb-radialmenu']:AddOption({
            id = 'blip_creator',
            title = "Create Marker",
            icon = 'location-dot',
            type = 'client',
            event = 'tss-blipcreator:client:CreateBlipForm_radial',
            shouldClose = true
        })
        exports['qb-radialmenu']:AddOption({
            id = 'blip_creator2',
            title = "My Markers",
            icon = 'pen',
            type = 'client',
            event = 'tss-blipcreator:client:ManageMarkersMenu',
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
                    TriggerEvent('tss-blipcreator:client:CreateBlipForm',nil,false)
                end
              },
              {
                label = 'My Markers',
                icon = 'pen',
                onSelect = function()
                    TriggerEvent('tss-blipcreator:client:ManageMarkersMenu')
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