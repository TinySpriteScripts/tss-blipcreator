fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'tss-blipcreator'
version '1.1.1'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}