fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'TinySprite Scripts'
description 'tss-blipcreator'
version '1.2.0'

shared_scripts {
    'shared/*.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/utils.lua',
    'client/main.lua',
    'client/menus.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge.lua',
    'server/main.lua',
}


dependencies { 'tss_bridge', 'oxmysql' }

files { 'images/blips/*.png' }
