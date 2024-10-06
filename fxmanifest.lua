fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DFNZ'
description 'Marketplace by DFNZscript'
version '1.1.2'

shared_script {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    "shared/config.lua",
    "client/*.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "shared/config.lua",
    "server/*.lua"
}

dependencies {
    'oxmysql',
    'es_extended',
    'ox_lib',
    'ox_target',
    'DFNZ_LOGGER'
}
