TSS = exports.tss_bridge:GetModules({ 'Player', 'Inventory', 'Callbacks', 'Notify', 'Debug', 'UI', 'Blips' }, Config.TSS)

function MarkerNotify(title, message, kind)
    TSS.Notify.Send({ title = title, message = message, type = kind })
end

function MarkerMenu(options, heading)
    local items = {}
    for i, option in ipairs(options) do
        items[i] = { label = option.header, description = option.txt, icon = option.icon, value = i }
    end
    TSS.UI.Menu({ title = heading.header, subtitle = heading.headertxt, options = items }, function(result)
        local option = result and options[tonumber(result.value)]
        if option and option.onSelect then
            CreateThread(option.onSelect)
        end
    end)
end

function MarkerItemLabel(item)
    local definition = (TSS.Inventory.Items() or {})[item]
    return definition and definition.label or item
end

-- Preview assets belong to this script and can be replaced alongside custom map textures.
function MarkerSpriteIcon(sprite)
    local id = Config.BlipOptions.Sprites[sprite] or tonumber(sprite)
    if not id then return 'fas fa-map-marker-alt' end
    return {
        type = 'image',
        src = ('https://cfx-nui-%s/images/blips/%d.png'):format(GetCurrentResourceName(), id),
    }
end
