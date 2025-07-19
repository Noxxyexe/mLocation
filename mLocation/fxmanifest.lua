
fx_version('cerulean')
games({ 'gta5' })

shared_script('config.lua')

server_scripts({
    'server.lua'
});

client_scripts({
    'client.lua'
});

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/img/**'
}
