function CreateNewBlip(data, code)
    debugPrint("Finalising Blip")
    if Blips[code] ~= nil then
        RemoveBlip(Blips[code])
    end
    local settings = data[code]
    Blips[code] = AddBlipForCoord(vector3(settings.coords.x, settings.coords.y, settings.coords.z))
    SetBlipSprite(Blips[code], Config.BlipOptions.Sprites[settings.sprite])
    SetBlipScale(Blips[code], Config.BlipOptions.Scales[settings.scale])
    SetBlipColour(Blips[code], Config.BlipOptions.Colours[settings.colour])
    SetBlipAsShortRange(Blips[code], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(settings.label)
    EndTextCommandSetBlipName(Blips[code])
    if ShowMyBlips then
        SetBlipDisplay(Blips[code], 2)
    else
        SetBlipDisplay(Blips[code], 0)
    end
    debugPrint("Blip Fully Created")
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

function HasJob(jobcode)
    local Player = getPlayer()
    if Player.job == jobcode then
        return true
    else
        return false
    end
end

-- RADIAL MENU

RegisterNetEvent('tss-blipcreator:client:CreateBlipForm_radial',function()
    TriggerEvent('tss-blipcreator:client:CreateBlipForm', nil, false)
end)