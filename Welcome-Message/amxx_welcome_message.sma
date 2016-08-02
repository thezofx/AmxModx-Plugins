#include < amxmodx >
#include < amxmisc >
#include < dhudmessage >

#pragma semicolon	1

const MAX_PLAYERS = 32
const TASK_ID = 9468523

new const PLUGIN[ ]  =	"Welcome Message";
new const VERSION[ ] =	"0.1";
new const AUTHOR[ ]  =	"ZOF 'X";

new pCvar_Toggle;

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	pCvar_Toggle = register_cvar( "amx_welcome_message", "1" );
}

public client_putinserver( index )
{
	set_task( 5.0, "ShowWelcomeMsg", ( index + TASK_ID ) );
}

public ShowWelcomeMsg( index )
{
	index -= TASK_ID;
	
	if( get_pcvar_num( pCvar_Toggle ) )
	{
		new szName[ MAX_PLAYERS ];
		get_user_name( index, szName, sizeof( szName ) );
		
		set_dhudmessage( 000, 160, 000, -1.0, 0.33, 2, _, 12.0, _, _, false );
		show_dhudmessage( index, "Hey %s !! ^nWelcome to Server ^nWe hope you will Enjoy Fragging with Us :)", szName );
	}
}

public client_disconnect( index )
{
	remove_task( index + TASK_ID );
}
