#include < amxmodx >
#include < amxmisc >
#include < colorchat >
#include < engine >
#include < fun >

#define MAX_PLAYER 	32
#pragma semicolon 	1

new const PLUGIN[ ] = "AMXX PRAY PLUGIN";
new const VERSION[ ] = "0.1";
new const AUTHOR[ ] = "ZOF 'X";

new const PREFIX[ ] = "[AMXX]";

new iAdvNum = 0;
new const iChatAdvertise[ ][ ] = {
	
	"^4%s ^1Say ^4^".pray^" ^1or ^4^"/pray^" ^1or ^4bind ^"p^" ^"pray^" ^1to Pray for players after Dead!",
	"^4%s ^1Praying Gives ^4+%dHP ^1to player you are Spectating.!"
};

enum _:Modes {
	
	NONE,
	LOCKED,
	FREE,
	ROAMING,
	IN_EYE,
	MAP_FREE,
	MAP_CHASE
	
};

enum {
	
	PRAYING = 0,
	PRAYED
	
};

const TASK_ID = 1586;

new bool:gPray[ MAX_PLAYER + 1 ][ 2 ];
new gName[ MAX_PLAYER + 1 ][ 32 ];
new pCvarHideCmd;
new pCvarMaxHealth;
new pCvarPrayHealth;

public plugin_init( ) {
	
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_clcmd( "say /pray", "cmdPray" );
	register_clcmd( "say_team /pray", "cmdPray" );
	
	register_clcmd( "say .pray", "cmdPray" );
	register_clcmd( "say_team .pray", "cmdPray" );
	
	register_clcmd( "pray", "cmdPray" );
	register_clcmd( "/pray", "cmdPray" );
	
	register_event( "HLTV", "EventNewRound", "a", "1=0", "2=0" );
	
	pCvarHideCmd = register_cvar( "amx_pray_showcmd", "0" );
	pCvarPrayHealth = register_cvar( "amx_pray_health", "20" );
	pCvarMaxHealth = register_cvar( "amx_pray_max_health", "100" );
	
}

public client_putinserver( index ) {
	
	gPray[ index ][ PRAYING ] = false;
	gPray[ index ][ PRAYED ] = false;
	
	get_user_info( index, "name", gName[ index ], sizeof( gName[ ] ) - 1 );
	
}

public client_disconnect( index ) {

	remove_task( index + TASK_ID );
}

public client_death( iKiller, iVictim ) {
	
	if( iVictim ) {
		
		if( iAdvNum >= sizeof( iChatAdvertise ) ) iAdvNum = 0;
		ColorChat( iVictim, TEAM_COLOR, iChatAdvertise[ iAdvNum ], PREFIX, get_pcvar_num( pCvarPrayHealth ) );
		iAdvNum++;
	}
}

public EventNewRound( ) {
	
	static Players[ MAX_PLAYER ], iNum, index;
	get_players( Players, iNum );
	
	while( --iNum >= 0 ) {
		
		index = Players[ iNum ];
		
		gPray[ index ][ PRAYING ] = false;
		gPray[ index ][ PRAYED ] = false;
	}
}

public cmdPray( index ) {
	
	static iSpecUser;
	iSpecUser = GetSpecID( index );
	
	if( gPray[ index ][ PRAYED ] ) {
		
		ColorChat( index, GREEN, "%s ^1You had already ^4Prayed ^1these round.!", PREFIX );
		
		return( !get_pcvar_num( pCvarHideCmd ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN );
	}
	
	else if( gPray[ index ][ PRAYING ] ) {
		
		ColorChat( index, GREEN, "%s ^1Please wait until your ^4Prayer ^1complete.!", PREFIX );		
		
		return( !get_pcvar_num( pCvarHideCmd ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN );
	}
	
	else if ( is_user_alive( index ) ) {
		
		ColorChat( index, GREEN, "%s ^1You can't use ^4Pray ^1while you are alive.!", PREFIX );
		
		return( !get_pcvar_num( pCvarHideCmd ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN );
	}
	
	else if( !iSpecUser ) {
		
		ColorChat( index, GREEN, "%s ^1You are not ^4Spectating ^1a player.!", PREFIX );
		
		return( !get_pcvar_num( pCvarHideCmd ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN );
	}
	
	else {
		
		static tParam[ 1 ];
		
		tParam[ 0 ] = iSpecUser;
		gPray[ index ][ PRAYING ] = true;
		
		set_task( 10.0, "TASK_PRAY", ( index + TASK_ID ), tParam, sizeof( tParam ) );
		ColorChat( 0, TEAM_COLOR, "^4%s ^3%s ^1has just ^4Prayed ^1for ^3%s", PREFIX, gName[ index ], gName[ iSpecUser ] );
	}
	
	
	return( !get_pcvar_num( pCvarHideCmd ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED_MAIN );
}

public TASK_PRAY( param[ ], index ) {
	
	index -= TASK_ID;
	
	static tHealth;
	tHealth = get_user_health( param[ 0 ] );
	
	if( !is_user_alive( param[ 0 ] ) ) {
		
		gPray[ index ][ PRAYING ] = true;
		gPray[ index ][ PRAYED ] = true;
		
		ColorChat( index, TEAM_COLOR, "^4%s ^3%s ^1Just Died before your ^4Prayer ^1complete.!", PREFIX, gName[ param[ 0 ] ] );
		return PLUGIN_CONTINUE;
	}
	
	else if( tHealth >= get_pcvar_num( pCvarMaxHealth ) ) {
		
		gPray[ index ][ PRAYING ] = false;
		
		ColorChat( index, TEAM_COLOR, "^4%s ^1Praying failed.! ^3%s ^1is already Healthy", PREFIX, gName[ param[ 0 ] ] );
		return PLUGIN_CONTINUE;
	}
	
	else {
		
		gPray[ index ][ PRAYING ] = false;
		gPray[ index ][ PRAYED ] = true;
		
		ColorChat( param[ 0 ], GREEN, "%s ^1You just got^4+%d HP ^1for bonus Enjoy :D", PREFIX, get_pcvar_num( pCvarPrayHealth ) );
		ColorChat( index, GREEN, "%s ^1Your Prayer for ^3%s ^1has been completed.!", PREFIX, gName[ param[ 0 ] ] );
		
		set_user_health( param[ 0 ], min( ( tHealth + get_pcvar_num( pCvarPrayHealth ) ), get_pcvar_num( pCvarMaxHealth ) ) );
	}
	
	return PLUGIN_CONTINUE;
	
}

GetSpecID( index, &view = 0 ) {
	
	view = entity_get_int( index, EV_INT_iuser1 );
	
	const iValidModes = ( 1 << LOCKED ) | ( 1 << FREE ) | ( 1 << IN_EYE ) | ( 1 << MAP_CHASE );
	
	if( iValidModes & ( 1 << view ) ) {
		
		static tPlayer;
		tPlayer = entity_get_int( index, EV_INT_iuser2 );
		
		if( tPlayer && is_user_alive( tPlayer ) ) {
			
			return( tPlayer );
		}
	}
	
	return( 0 );
}