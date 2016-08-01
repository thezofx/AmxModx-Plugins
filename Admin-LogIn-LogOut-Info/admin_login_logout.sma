#include < amxmodx >
#include < amxmisc >

#pragma semicolon	1
#define MAX_PLAYERS	32

new const PLUGIN[ ] = "ADMIN_LOG";
new const VERSION[ ]= "0.1";
new const AUTHOR[ ] = "ZOF 'X";

enum _:_ADMIN_DATA {
	
	NAME[ 32 ],
	AUTHID[ 35 ],
	LOGIN[ 32 ],
	LOGOUT[ 32 ]
};

new gLogFilePath[ 64 ];
new gAdminInfo[ MAX_PLAYERS + 1 ][ _ADMIN_DATA ];

public plugin_init( ) {
	
	register_plugin( PLUGIN, VERSION, AUTHOR );
	register_cvar( "zofx_admin_log", AUTHOR, FCVAR_SERVER );
	
	get_datadir( gLogFilePath, sizeof( gLogFilePath ) - 1 );
	add( gLogFilePath, sizeof( gLogFilePath ) - 1, "/admin_log_files" );

	if( !dir_exists( gLogFilePath ) ) mkdir( gLogFilePath );
	
}

public client_putinserver( index ) {
	
	if( is_user_admin( index ) ) {
		
		get_user_info( index, "name", gAdminInfo[ index ][ NAME ], sizeof( gAdminInfo[ ][ NAME ] ) - 1 );
		get_user_authid( index, gAdminInfo[ index ][ AUTHID ], sizeof( gAdminInfo[ ][ AUTHID ] ) - 1 );
		get_time( "%d/%m/%Y - %H:%M:%S", gAdminInfo[ index ][ LOGIN ], sizeof( gAdminInfo[ ][ LOGIN ] ) - 1 );
	}
	
}

public client_disconnect( index ) {
	
	
	if( is_user_admin( index ) ) {
		
		new tPlayedTime = ( get_user_time( index, 1) / 60 );
		get_time( "%d/%m/%Y - %H:%M:%S", gAdminInfo[ index ][ LOGOUT ], sizeof( gAdminInfo[ ][ LOGOUT ] ) - 1 );
		
		new iDate[ 64 ], gLogFile[ 64 ];
		
		get_time( "%d-%m-%Y", iDate, sizeof( iDate ) - 1 );
		formatex( gLogFile, sizeof( gLogFile ) - 1, "%s/%s.txt", gLogFilePath, iDate );
		
		static tFile[ 255 ];
		formatex( tFile, sizeof( tFile ) - 1, "[ NAME ]: %s ^n[ AUTHID ]: %s ^n[ LOGIN ]: %s ^n[ LOGOUT ]: %s ^n[ PLAYED TIME ]: %d Minute%s ^n^n", gAdminInfo[ index ][ NAME ], gAdminInfo[ index ][ AUTHID ], gAdminInfo[ index ][ LOGIN ], gAdminInfo[ index ][ LOGOUT ], tPlayedTime, tPlayedTime == 1 ? "" : "s" );
		
		write_file( gLogFile, tFile );
	}
}
