#include < amxmodx >
#include < amxmisc >

const MAX_PLAYERS = 32

new const PLUGIN[ ] = "Amxx TagMe";
new const VERSION[ ] = "0.1";
new const AUTHOR[ ] = "ZOF 'X";
new const PREFIX[ ] = "[AMXX]";

new bool:iUsed[ MAX_PLAYERS + 1 ] = false;
new const TAG[ ] = "[AMXX]";

public plugin_init( ) {
	
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_clcmd( "say /tagme", "cmdTag" );
	register_clcmd( "say .tagme", "cmdTag" );
	register_clcmd( "say_team /tagme", "cmdTag" );
	register_clcmd( "say_tea .tagme", "cmdTag" );
	
}

public client_putinserver( index ) {
	
	iUsed[ index ] = false;
}

public cmdTag( index ) {
	
	static szName[ MAX_PLAYERS ];
	get_user_name( index, szName, sizeof( szName ) - 1 );
	
	if( !equal( szName, TAG, sizeof( TAG ) - 1 ) ) {
		
		static szNewName[ 32 ];
		
		formatex( szNewName, sizeof( szNewName ) - 1, "%s %s", TAG, szName );
		
		set_user_info( index, "name", szNewName );
		
		iUsed[ index ] = true;
		
	} else {
		
		client_print( index, print_chat, "%s You already have tag!", PREFIX );
	}
}

public client_infochanged( index ) {
	
	if( iUsed[ index ] ) {
		
		static szName[ MAX_PLAYERS ];
		get_user_info( index, "name", szName, sizeof( szName ) - 1 );
		
		if( !equal( szName, TAG, sizeof( TAG ) - 1 ) ) {
			
			static szNewName[ MAX_PLAYERS ];
			
			formatex( szNewName, sizeof( szNewName ) - 1, "%s %s", TAG, szName );
			
			set_user_info( index, "name", szNewName );
		}
	}
}