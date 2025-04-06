#include <amxmodx>

#define VERSION	"0.1.3"

#define MAX_PLAYERS 32
#define IsPlayer(%1)	( 1 <= %1 <= g_iMaxPlayers )

enum _:Colors {
	DontChange,
	Red,
	Blue,
	Grey
}

new const g_szTeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new gmsgSayText, gmsgTeamInfo, g_iMaxPlayers

new g_bConnected[MAX_PLAYERS+1]
new g_bBot[MAX_PLAYERS+1]
new g_iPlayerTeamColor[MAX_PLAYERS+1]

new Array:g_aStoreML

public plugin_init() 
{
	register_plugin("ColorChat", VERSION, "ConnorMcLeod")

	register_event("TeamInfo", "Event_TeamInfo", "a")

	gmsgTeamInfo = get_user_msgid("TeamInfo")
	gmsgSayText = get_user_msgid("SayText")
	g_iMaxPlayers = get_maxplayers()
	g_aStoreML = ArrayCreate(1, 10) // assume we won't have more that 10 LANG_PLAYER args, so don't reserve more
}

public plugin_end()
{
	// just in case...
	ArrayDestroy(g_aStoreML)
}

public plugin_natives()
{
	register_library("chatcolor")
	register_native("client_print_color", "client_print_color")
}

public client_putinserver(id)
{
	// Little tip so we won't alter HLTV TeamInfo, dunno what would result
	g_bConnected[id] = !is_user_hltv(id)

	// So we won't send useless msgs to bots
	g_bBot[id] = is_user_bot(id)
}

public client_disconnect(id)
{
	g_bConnected[id] = false
}

public Event_TeamInfo()
{
	// Store the TeamInfo msg sent by game so if we alter that player TeamInfo
	// we can restore is w/o retrieving his team
	static szTeamInfo[2]
	read_data(2, szTeamInfo, charsmax(szTeamInfo))
	switch( szTeamInfo[0] )
	{
		case 'T': g_iPlayerTeamColor[ read_data(1) ] = Red
		case 'C': g_iPlayerTeamColor[ read_data(1) ] = Blue
		default : g_iPlayerTeamColor[ read_data(1) ] = Grey
	}
}

public client_print_color(iPlugin, iParams) // client_print_color(id, iColor=DontChange, const szMsg[], any:...)
{
	new id = get_param(1)

	// check if id is different from 0
	if( id )
	{
		// check player range and ingame player
		if( !IsPlayer(id) || !g_bConnected[id] || g_bBot[id] )
		{
			return
		}
	}

	new iColor = get_param(2)
	if( iColor > Grey )
	{
		iColor = DontChange
	}

	new szMessage[256], iPlayerTeamColor
	if( iColor > DontChange )
	{
		// if color specified, set 1st color to team color
		szMessage[0] = 0x03
	}
	else
	{
		// if no color passed, set 1st color to green
		szMessage[0] = 0x04
	}

	// Specific player code
	if(id)
	{
		if( iParams == 3 )
		{
			// if only 3 args are passed, no need to format the string, just retrieve it
			get_string(3, szMessage[1], charsmax(szMessage)-1)
		}
		else
		{
			// else format the string
			vdformat(szMessage[1], charsmax(szMessage)-1, 3, 4)
		}

		// convert !g, !t, and !n flags
		Set_String_Color(szMessage, charsmax(szMessage))

		// cut the string at its 192th character to prevent a bug
		// that would prevent players from joining the server
		szMessage[192] = 0

		// if color specified
		iPlayerTeamColor = g_iPlayerTeamColor[id]
		if( iColor && iPlayerTeamColor != iColor )
		{
			// set id TeamInfo in consequence
			// so SayText msg gonna show the right color
			Send_TeamInfo(id, id, MSG_ONE_UNRELIABLE, g_szTeamName[iColor])

			// Send the message
			Send_SayText(id, id, MSG_ONE_UNRELIABLE, szMessage)

			// restore TeamInfo
			Send_TeamInfo(id, id, MSG_ONE_UNRELIABLE, g_szTeamName[iPlayerTeamColor])
		}
		else
		{
			Send_SayText(id, id, MSG_ONE_UNRELIABLE, szMessage)
		}
	} 

	// Send message to all players
	else
	{
		// Figure out if at least 1 player is connected
		// so we don't send useless message if not
		// and we gonna use that player as team reference (aka SayText message sender) for color change
		new iPlayerFound = FindPlayer()
		if( !iPlayerFound )
		{
			return
		}

		new j

		// Use that array to store LANG_PLAYER args indexes, and szTemp to store ML keys
		new iArraySize, szTemp[64]

		for(j=4; j<iParams-1; j++)
		{
			// retrieve original param value and check if it's LANG_PLAYER value
			if( get_param_byref(j) == LANG_PLAYER )
			{
				// as LANG_PLAYER == -1, check if next parm string is a registered language translation
				get_string(j+1, szTemp, charsmax(szTemp))
				if( GetLangTransKey(szTemp) )
				{
					// Store that arg as LANG_PLAYER so we can alter it later
					ArrayPushCell(g_aStoreML, j)

					// Update ML array saire so we'll know 1st if ML is used,
					// 2nd how many args we have to alterate
					iArraySize++

					j++
				}
			}
		}

		// If arraysize == 0, ML is not used
		// we can only send 1 MSG_BROADCAST message
		if( !iArraySize )
		{
			if( iParams == 3 )
			{
				get_string(3, szMessage[1], charsmax(szMessage)-1)
			}
			else
			{
				vdformat(szMessage[1], charsmax(szMessage)-1, 3, 4)
			}

			Set_String_Color(szMessage, charsmax(szMessage))
			szMessage[192] = 0

			iPlayerTeamColor = g_iPlayerTeamColor[iPlayerFound]
			if( iColor && iPlayerTeamColor != iColor )
			{
				Send_TeamInfo(0, iPlayerFound, MSG_BROADCAST, g_szTeamName[iColor])
				Send_SayText(0, iPlayerFound, MSG_BROADCAST, szMessage)
				Send_TeamInfo(0, iPlayerFound, MSG_BROADCAST, g_szTeamName[iPlayerTeamColor])
			}
			else
			{
				Send_SayText(0, iPlayerFound, MSG_BROADCAST, szMessage)
			}
		}

		// ML is used, we need to loop through all players,
		// format text and send a MSG_ONE_UNRELIABLE SayText message
		else
		{
			iPlayerTeamColor = g_iPlayerTeamColor[iPlayerFound]
			new bColorChange = ( iColor && iPlayerTeamColor != iColor )
			new szNewColor[10], szPreviousColor[10]
			if( bColorChange )
			{
				copy(szNewColor, charsmax(szNewColor), g_szTeamName[iColor])
				copy(szPreviousColor, charsmax(szPreviousColor), g_szTeamName[iPlayerTeamColor])
			}

			for( new i = 1; i <= g_iMaxPlayers; i++ )
			{
				if( g_bConnected[i] && !g_bBot[i] )
				{
					for(j=0; j<iArraySize; j++)
					{
						// Set all LANG_PLAYER args to player id ( = i )
						// so we can format the text for that specific player
						set_param_byref(ArrayGetCell(g_aStoreML, j), i)
					}

					// format string for player i
					vdformat(szMessage[1], charsmax(szMessage)-1, 3, 4)

					Set_String_Color(szMessage, charsmax(szMessage))
					szMessage[192] = 0

					if( bColorChange )
					{
						Send_TeamInfo(i, iPlayerFound, MSG_ONE_UNRELIABLE, szNewColor)
						Send_SayText(i, iPlayerFound, MSG_ONE_UNRELIABLE, szMessage)
						Send_TeamInfo(i, iPlayerFound, MSG_ONE_UNRELIABLE, szPreviousColor)
					}
					else
					{
						Send_SayText(i, iPlayerFound, MSG_ONE_UNRELIABLE, szMessage)
					}
				}
			}
			// clear the array so next ML message we don't need to figure out
			// if should use PushArray or SetArray
			ArrayClear(g_aStoreML)
		}
	}
}

// convert !g, !t, and !n flags
Set_String_Color( szString[] , iLen )
{
	while( replace(szString, iLen, "!g", "^4") )
	{
	}
	while( replace(szString, iLen, "!t", "^3") )
	{
	}
	while( replace(szString, iLen, "!n", "^1") )
	{
	}
}

Send_TeamInfo(iReceiver, iPlayerId, MSG_DEST, szTeam[])
{
	message_begin(MSG_DEST, gmsgTeamInfo, _, iReceiver)
	write_byte(iPlayerId)
	write_string(szTeam)
	message_end()
}

Send_SayText(iReceiver, iPlayerId, MSG_DEST, szMessage[])
{
	message_begin(MSG_DEST, gmsgSayText, _, iReceiver)
	write_byte(iPlayerId)
	write_string(szMessage)
	message_end()
}

FindPlayer()
{
	for(new id=1; id<=g_iMaxPlayers; id++)
	{
		if(g_bConnected[id])
		{
			return id
		}
	}
	return 0
}
/*
* С уважением, Wildness Team (с) 2012
*/