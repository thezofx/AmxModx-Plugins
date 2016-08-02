#include < amxmodx >
#include < amxmisc >

#pragma semicolon	1
#define MAX_PLAYERS	32

new const PLUGIN[ ] = "Auto Admin ServerTagger";
new const VERSION[ ]= "0.1";
new const AUTHOR[ ] = "ZOF 'X";

new const ServerTag[ ] = "[TAG]";

public plugin_init( ) {
	
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_cvar( "zofx_", PLUGIN, FCVAR_SERVER );
	
}

public client_putinserver( index ) {
	
	if( get_user_flags( index ) & ADMIN_KICK ) {
		
		static szName[ MAX_PLAYERS ];
		get_user_name( index, szName, sizeof( szName ) - 1 );
		
		if( !equal( szName, ServerTag, sizeof( ServerTag ) - 1 ) ) {
			
			static szNewName[ 32 ];
			
			formatex( szNewName, sizeof( szNewName ) - 1, "%s %s", ServerTag, szName );
			
			set_user_info( index, "name", szNewName );
		}
	}
	
}

public client_infochanged( index ) {
	
	if( get_user_flags( index ) & ADMIN_KICK ) {
		
		static szName[ MAX_PLAYERS ];
		get_user_info( index, "name", szName, sizeof( szName ) - 1 );
		
		if( !equal( szName, ServerTag, sizeof( ServerTag ) - 1 ) ) {
			
			static szNewName[ 32 ];
			
			formatex( szNewName, sizeof( szNewName ) - 1, "%s %s", ServerTag, szName );
			
			set_user_info( index, "name", szNewName );
		}
	}
}