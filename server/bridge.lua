TSS = exports.tss_bridge:GetModules({ 'Player', 'Inventory', 'Callbacks', 'Notify', 'Debug' }, Config.TSS)

function MarkerNotify(title, message, kind, source)
    TSS.Notify.Send(source, { title = title, message = message, type = kind })
end

function MarkerItemLabel(item)
    local definition = (TSS.Inventory.Items() or {})[item]
    return definition and definition.label or item
end

if Config.Options.BlipItem then
    local registered, err = TSS.Inventory.CreateUseableItem(Config.Options.BlipItem, function(source)
        TriggerClientEvent('tss-blipcreator:client:OpenMenu', source)
    end)
    if not registered then
        error(('[tss-blipcreator] Could not register GPS item: %s'):format(err or 'unknown error'))
    end
end
