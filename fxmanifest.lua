fx_version 'cerulean'

use_experimental_fxv2_oal 'yes'

game 'gta5'

description 'nema safe zones'

version '1.0.0'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config_npcs.lua'

}

-- server_scripts {
--     '@es_extended/locale.lua',
--     '@oxmysql/lib/MySQL.lua',
--     'locales/*.lua',
--     'server/**/*'
-- }

client_scripts {
    'client/**/*'
}

-- files {
--     'locales/*.json'
-- }

-- ox_libs {
--     'locale',
--     'table',
-- }