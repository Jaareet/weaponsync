fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Lockser && Jaareet'
description 'WeaponSync resource for ESX'
version '2.0.0'
lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua',
}

server_scripts {
	'server/*.lua',
}

client_scripts {
	'client/*.lua',
}
