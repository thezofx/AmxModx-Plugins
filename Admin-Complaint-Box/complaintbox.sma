#include < amxmodx >
#include < amxmisc >
#include < nvault >

#pragma semicolon	1

const ONE_HOUR = 1;
const TWENTY_FOUR_HOUR = 24;

new const PLUGIN[ ] = "Complaint Box";
new const VERSION[ ]= "0.1";
new const AUTHOR[ ] = "ZOF 'X";

new const PREFIX[ ] = "[AMXX]";

new iVault;
new iVaultName[ ] = "ComplaintDetails";

new gLogFilePath[ 64 ];

new gReportedAdminID[ MAX_PLAYERS + 1];
new iComplaintCounts[ MAX_PLAYERS + 1 ];
new szAuthID[ MAX_PLAYERS + 1 ][ 35 ];
new szName[ MAX_PLAYERS + 1 ][ 32 ];
new iTimeStamp[ MAX_PLAYERS + 1 ];

public plugin_init( ) {
	
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_clcmd( "say /complaint", "cmdComplaint" );
	register_clcmd( "say .complaint", "cmdComplaint" );
	register_clcmd( "say /complain", "cmdComplaint" );
	register_clcmd( "say .complain", "cmdComplaint" );
	
	register_clcmd( "say_team .complaint", "cmdComplaint" );
	register_clcmd( "say_team /complain", "cmdComplaint" );
	register_clcmd( "say_team .complain", "cmdComplaint" );
	register_clcmd( "say_team /complaint", "cmdComplaint" );
	
	register_cvar( "zofx_complaint_box", AUTHOR, FCVAR_SERVER );
	
	register_clcmd( "_ComplaintText", "Func_ComplaintText" );
	
	get_datadir( gLogFilePath, sizeof( gLogFilePath ) - 1 );
	add( gLogFilePath, sizeof( gLogFilePath ) - 1, "/admin_complaint_box" );
	
	if( !dir_exists( gLogFilePath ) ) mkdir( gLogFilePath );
	
}

public plugin_cfg( ) {
	
	iVault = nvault_open( iVaultName );
	
	if( iVault == INVALID_HANDLE ) set_fail_state( "Error Opening Vault" );
}

public client_putinserver( index ) {
	
	get_user_authid( index, szAuthID[ index ], sizeof( szAuthID ) - 1 );
	get_user_name( index, szName[ index ], sizeof( szName ) - 1 );
}


public client_disconnected( index ) {
	
	remove_task( index );
}

public cmdComplaint( index ) {
	
	get_user_authid( index, szAuthID[ index ], sizeof( szAuthID[ ] ) - 1 );
	
	static szData[ 15 ], iDummyTimeStamp;
	
	if( nvault_lookup( iVault, szAuthID[ index ], szData, sizeof( szData ) - 1, iDummyTimeStamp ) ) {
		
		iComplaintCounts[ index ] = str_to_num( szData[ 0 ] );
		iTimeStamp[ index ] = ( str_to_num( szData[ 2 ] ) );
		
		new iElapsedHours = ( ( get_systime( ) - iTimeStamp[ index ] ) / ( 60 * 60 ) );
		
		switch( iComplaintCounts[ index ] ) {
			
			case 1 : {
				
				if( iElapsedHours >= ONE_HOUR ) {
					
					ShowMenu( index );
				} else {
					
					client_print_color( index, index, "^4%s ^1You have to wait for %d minutes.!", PREFIX, ( ( ( iTimeStamp[ index ] + 3600 ) - ( get_systime( ) ) ) / 60 ) );
				}
			}
			
			case 2 : {
				
				if( iElapsedHours >= TWENTY_FOUR_HOUR ) {
					
					ShowMenu( index );
				} else {
					
					client_print_color( index, index, "^4%s ^1You have to wait for %d hours.!", PREFIX, ( ( ( iTimeStamp[ index ] + 86400 ) - ( get_systime( ) ) ) / 60 ) );
				}
			}
		}
	}
	else {
		
		ShowMenu( index );
	}
}

public ShowMenu( index ) {
	
	new gMenu = menu_create( "Select Admin :", "menu_handler" );
	
	static Players[ MAX_PLAYERS ], iNum, id;
	get_players( Players, iNum );
	
	static szUserID[ 35 ], iAdminCount;
	
	for( new i; i < iNum; i++ ) {
		
		id = Players[ i ];
		
		if( is_user_admin( id ) ) {
			
			formatex( szUserID, sizeof( szUserID ) - 1, "%d", get_user_userid( id ) );

			menu_additem( gMenu, szName[ id ], szUserID );
			
			iAdminCount++;
		}
	}
	
	if( iAdminCount ) {
		
		iAdminCount = 0;
		menu_display( index, gMenu, 0 );
	} else {
		
		client_print_color( index, index, "^4%s ^1Sorry no admin was found found online.!", PREFIX );
	}

}

public menu_handler( id, menu, item ) {
	
	if( item == MENU_EXIT ) {
		
		menu_destroy( menu );
		
		return PLUGIN_HANDLED;
	}
	
	static szUserID[ MAX_PLAYERS ], szName[ MAX_PLAYERS ], iPlayer, iAccess, iCallBack;
	
	menu_item_getinfo( menu, item, iAccess, szUserID, sizeof( szUserID ) - 1, szName, sizeof( szName ) - 1, iCallBack );
	
	if( ( iPlayer = find_player( "k", str_to_num( szUserID ) ) ) ) {
		
		set_hudmessage( 200, 000, _, _, _, 1 );
		show_hudmessage( iPlayer, "Warning.! Someone has registered Complaint about you.!" );
		
		gReportedAdminID[ id ] = iPlayer;
		client_cmd( id, "messagemode _ComplaintText" );
		
	} else {
		
		client_print( id, print_chat, "%s complaint Failed.! %s has been disconnected.!", szName, PREFIX );
	}
	
	menu_destroy( menu );
	
	return PLUGIN_HANDLED;
}

public Func_ComplaintText( index ) {
	
	static szComplaint[ 128 ];
	read_args( szComplaint, sizeof( szComplaint ) - 1 );
	remove_quotes( szComplaint );
	
	if( equal( szComplaint, " " ) || strlen( szComplaint ) < 1 ) {
		
		client_print_color( index, index, "^4%s ^1Please enter your complaint text!" );
		client_cmd( index, "messagemode _ComplaintText" );
	}
	
	static iDate[ 12 ], gLogFile[ 256 ];
	
	get_time( "%d-%m-%Y", iDate, sizeof( iDate ) - 1 );
	formatex( gLogFile, sizeof( gLogFile ) - 1, "%s/%s.txt", gLogFilePath, iDate );
	
	static iAdminIndex, iTime[ 12 ];
	
	iAdminIndex = gReportedAdminID[ index ];
	
	if( iAdminIndex ) {
		
		static tFile[ 256 ];
		
		get_time( "%H:%M:%S", iTime, sizeof( iTime ) - 1 );
		
		formatex( tFile, sizeof( tFile ) - 1, "[ TIME ]: %s ^n[ NAME ]: %s ^n[ AUTHID ]: %s ^n[ ADMIN NAME ]: %s ^n[ ADMIN AUTHID ]: %s ^n[ COMPLAINT ]: %s ^n^n", iTime, szName[ index ], szAuthID[ index ], szName[ iAdminIndex ], szAuthID[ iAdminIndex ], szComplaint );
		
		set_task( 5.0, "TASK_SHOW_INFO", index );
		set_task( 10.0, "TASK_SHOW_WARNING", iAdminIndex );
		
		SaveData( index );
		
		write_file( gLogFile, tFile );
	}
}

public TASK_SHOW_WARNING( index ) {
	
	ShowMotd( index, "[ WARNING ]", "Someone has reported complaint against you.! <br>Please contact your head-admin for more details about complaint." );
}

public TASK_SHOW_INFO( index ) {
	
	ShowMotd( index, "Thank You.!", "Your complaint has been successfully registered. <br> Our head-admin will review it as soon as possible." );
}

SaveData( index ) {
	
	static szTemp[ 20 ];
	
	switch( iComplaintCounts[ index ] ) {
		
		case 0 : {
			
			formatex( szTemp, sizeof( szTemp ) - 1, "1|%d", get_systime( ) );
		}
		
		case 1 : {
			
			formatex( szTemp, sizeof( szTemp ) - 1, "2|%d", iTimeStamp[ index ] );
		}
		
		case 2 : {
			
			formatex( szTemp, sizeof( szTemp ) - 1, "1|%d", get_systime( ) );
		}
	}
	
	nvault_set( iVault, szAuthID[ index ], szTemp );
	
	iComplaintCounts[ index ]++;
	
}

ShowMotd( index, szMessage[ ], szInfo[ ] ) {
	
	static szBuffer[ 1024 ], iLen;
	
	iLen = formatex( szBuffer, sizeof( szBuffer ) - 1, "<body bgcolor=white style=^"width=100%;height=100%;text-align:center;^"><body>" );
	iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<h1><font size=6 color=red>%s</font></h1>", szMessage );
	iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<h1><font size=3 color=black>%s</font></h1>", szInfo );
	iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<br>" );
	if( equal( szMessage, "[ WARNING ]") )
		iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<h1><font size=3 color=black>Dont Misuse your power of administrator</font></h1>" );
	iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<br>" );
	iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<h1><font size=2 color=black>This is Complaint Box Plugin made by Rohit Panchal ( zofx )</font></h1>" );
	szBuffer[ iLen ] = EOS;
	
	show_motd( index, szBuffer, "Complaint Box" );
}

public plugin_end( ) {
	
	nvault_close( iVault );
}