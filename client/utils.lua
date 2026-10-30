-- All personal-marker creation and editing shares one bridge call path.
function CreateNewBlip(data, code)
    local settings = data and data[code]
    if not settings then return end
    local options = {
        coords = settings.coords,
        sprite = Config.BlipOptions.Sprites[settings.sprite],
        scale = Config.BlipOptions.Scales[settings.scale],
        colour = Config.BlipOptions.Colours[settings.colour],
        label = settings.label,
        shortRange = true,
        display = ShowMyBlips and 2 or 0,
    }
    if TSS.Blips.Exists(Blips[code]) then
        TSS.Blips.Update(Blips[code], options)
    else
        Blips[code] = TSS.Blips.Create(options)
    end
end

function ToggleBlipsVisibility()
    ShowMyBlips = not ShowMyBlips
    for _, blip in pairs(Blips) do
        TSS.Blips.Update(blip, { display = ShowMyBlips and 2 or 0 })
    end
end

function HasJob(jobcode)
    local job = TSS.Player.Job()
    return job ~= nil and job.name == jobcode
end

-- RADIAL MENU

RegisterNetEvent('tss-blipcreator:client:CreateBlipForm_radial',function()
    TriggerEvent('tss-blipcreator:client:CreateBlipForm', nil, false)
end)
