fx_version('cerulean')
games({ 'gta5' })
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts({
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua'
});

client_scripts({
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/client.lua'
});