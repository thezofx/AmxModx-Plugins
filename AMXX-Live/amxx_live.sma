#include < amxmodx >
#include < amxmisc >
#include < dhudmessage >

#pragma semicolon	1

const MAX_RESTART = 2;

new const PLUGIN[ ]		=	"Live Plugin";
new const VERSION[ ]		=	"1.0";
new const AUTHOR[ ]		=	"ZOF 'X";

new iXYPos;
new const Float:HUD_XY_POS[ ][ ] =
{
	{ -1.0, 0.98 },
	{ -1.0, 0.91 },
	{ -1.0, 0.84 },
	{ -1.0, 0.77 },
	{ -1.0, 0.70 },
	{ -1.0, 0.63 },
	{ -1.0, 0.56 },
	{ -1.0, 0.49 },
	{ -1.0, 0.42 },
	{ -1.0, 0.35 },
	{ -1.0, 0.28 },
	{ -1.0, 0.21 },
	{ -1.0, 0.14 },
	{ -1.0, 0.07 },
	{ -1.0, 0.00 }
};

new pCvar;
new iNumRounds, bool:GivenLive = false;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_event( "HLTV", "Event_NewRound", "a", "1=0", "2=0" );
	
	pCvar = register_cvar( "amx_auto_live", "1" );
	
	register_clcmd( "say /live", "cmd_live", ADMIN_KICK );
	register_clcmd( "say_team /live", "cmd_live", ADMIN_KICK );
	
	register_clcmd( "say .live", "cmd_live", ADMIN_KICK );
	register_clcmd( "say_team .live", "cmd_live", ADMIN_KICK );
}

public Event_NewRound( )
{
	if( !GivenLive ) iNumRounds++;
	if( get_pcvar_num( pCvar ) && iNumRounds > 1 && !GivenLive ) {
		set_task( 00.01, "NotifyGivingLive" );
		set_task( 03.00, "GiveRestartRound", _, _, _, "a", MAX_RESTART );
		set_task( 09.00, "ShowHUD_LiveLive" );
		set_task( 16.00, "GiveRestartRound" );
		set_task( 18.00, "NotifyThat_LIVE" );
		GivenLive = true;
	}
}

public NotifyGivingLive( )
{
	set_dhudmessage( 0, 160, 0, -1.0, 0.44, 0, 1.0, 3.0, 0.2, 0.3, false );
	show_dhudmessage( 0, "____________LIVE AFTER 3 RESTARTS____________" );
}

public NotifyThat_LIVE( )
{
	set_dhudmessage( 0, 160, 0, -1.0, 0.44, 0, 1.0, 3.0, 0.2, 0.3, false );
	show_dhudmessage( 0, "____________Its LIVE GO GO GO____________" );
}

public GiveRestartRound( )
{
	server_cmd( "sv_restartround ^"1^"" );
}

public ShowHUD_LiveLive( )
{
	set_task( 0.2, "HUD_LiveLive", _, _, _, "a", sizeof( HUD_XY_POS ) * 2 );
}

public HUD_LiveLive( index )
{
	if( iXYPos >= sizeof( HUD_XY_POS ) ) iXYPos = 0;
	set_dhudmessage( random_num( 0, 255 ), random_num( 0, 255 ), random_num( 0, 255 ), HUD_XY_POS[ iXYPos ][ 0 ], HUD_XY_POS[ iXYPos ][ 1 ], 0, 50.0, 0.3, 0.4, 0.4, false );
	show_dhudmessage( index, "[   L   I   V   E   ]          [   L   I   V   E   ]             [   L   I   V   E   ]" );
	iXYPos++;
}

public cmd_live( index, level, cid )
{
	if( !cmd_access( index, level, cid, 0 ) ) return PLUGIN_CONTINUE;
	
	iXYPos = 0; GivenLive = true;
	set_task( 00.01, "NotifyGivingLive" );
	set_task( 03.00, "GiveRestartRound", _, _, _, "a", MAX_RESTART );
	set_task( 09.00, "ShowHUD_LiveLive" );
	set_task( 16.00, "GiveRestartRound" );
	set_task( 18.00, "NotifyThat_LIVE" );
	GivenLive = true;
	
	return PLUGIN_CONTINUE;
}
