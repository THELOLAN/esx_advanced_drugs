fx_version 'cerulean'
game 'gta5'

author 'jaksam1074'

version '2.1'

-- Leaked By: Leaking Hub | J. Snow | leakinghub.com

shared_scripts {
    'shared/shared.lua',
    'locales/en.lua',
}

client_scripts {
    'cl_config.lua',
    'sh_config.lua',
    'client/main.lua',
    'client/crafts.lua',
    'client/ingredients.lua',
    'client/sell.lua',
    'client/npcselling.lua',
    'client/drugs_effects.lua',
}

server_scripts{
    'sv_config.lua',
    'sh_config.lua',
    'customer_cfg.lua',
    'server/main.lua',
    'server/ingredients.lua',
    'server/sell.lua',
    'server/npcselling.lua',
}

dependencies {
    'es_extended'
}