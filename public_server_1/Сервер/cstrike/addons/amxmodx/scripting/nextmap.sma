#include <amxmodx>
#include <chatcolor>

// WARNING: If you comment this line make sure
// that in your mapcycle file maps don't repeat.
// However the same map in a row is still valid.
#define OBEY_MAPCYCLE

new g_nextMap[32]
new g_mapCycle[32]
new g_pos

public plugin_init()
{
	register_plugin("NextMap", AMXX_VERSION_STR, "AMXX Dev Team & Wildness Team")
	register_dictionary("nextmap.txt")
	register_event("30", "changeMap", "a")
	register_clcmd("say nextmap", "sayNextMap", 0, "- displays nextmap")
	register_clcmd("say currentmap", "sayCurrentMap", 0, "- display current map")
	register_clcmd("say ff", "sayFFStatus", 0, "- display friendly fire status")
	register_cvar("amx_nextmap", "", FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_SPONLY)

	new szString[32], szString2[32], szString3[8]
	
	get_localinfo("lastmapcycle", szString, 31)
	parse(szString, szString2, 31, szString3, 7)
	g_pos = str_to_num(szString3)
	get_cvar_string("mapcyclefile", g_mapCycle, 31)

	if (!equal(g_mapCycle, szString2))
		g_pos = 0	// mapcyclefile has been changed - go from first

	readMapCycle(g_mapCycle, g_nextMap, 31)
	set_cvar_string("amx_nextmap", g_nextMap)
	format(szString3, 31, "%s %d", g_mapCycle, g_pos)	// save lastmapcycle settings
	set_localinfo("lastmapcycle", szString3)
}

getNextMapName(szArg[], iMax)
{
	new len = get_cvar_string("amx_nextmap", szArg, iMax)
	
	if (ValidMap(szArg)) return len
	len = copy(szArg, iMax, g_nextMap)
	set_cvar_string("amx_nextmap", g_nextMap)
	
	return len
}

public sayNextMap()
{
	new name[32]
	
	getNextMapName(name, 31)
	client_print_color(0, DontChange, "^01%L: ^04%s", LANG_PLAYER, "NEXT_MAP", name)
}

public sayCurrentMap()
{
	new mapname[32]

	get_mapname(mapname, 31)
	client_print_color(0, DontChange, "^01%L: ^04%s", LANG_PLAYER, "PLAYED_MAP", mapname)
}

public sayFFStatus()
{
	client_print_color(0, DontChange, "^01%L: ^04%L", LANG_PLAYER, "FRIEND_FIRE", LANG_PLAYER, get_cvar_num("mp_friendlyfire") ? "ON" : "OFF")
}

public delayedChange(param[])
{
	set_cvar_float("mp_chattime", get_cvar_float("mp_chattime") - 2.0)
	server_cmd("changelevel %s", param)
}

public changeMap()
{
	new string[32]
	new Float:chattime = get_cvar_float("mp_chattime")
	
	set_cvar_float("mp_chattime", chattime + 2.0)		// make sure mp_chattime is long
	new len = getNextMapName(string, 31) + 1
	set_task(chattime, "delayedChange", 0, string, len)	// change with 1.5 sec. delay
}

new g_warning[] = "WARNING: Couldn't find a valid map or the file doesn't exist (file ^"%s^")"

stock bool:ValidMap(mapname[])
{
	if ( is_map_valid(mapname) )
	{
		return true;
	}
	// If the is_map_valid check failed, check the end of the string
	new len = strlen(mapname) - 4;
	
	// The mapname was too short to possibly house the .bsp extension
	if (len < 0)
	{
		return false;
	}
	if ( equali(mapname[len], ".bsp") )
	{
		// If the ending was .bsp, then cut it off.
		// the string is byref'ed, so this copies back to the loaded text.
		mapname[len] = '^0';
		
		// recheck
		if ( is_map_valid(mapname) )
		{
			return true;
		}
	}
	
	return false;
}

#if defined OBEY_MAPCYCLE
readMapCycle(szFileName[], szNext[], iNext)
{
	new b, i = 0, iMaps = 0
	new szBuffer[32], szFirst[32]

	if (file_exists(szFileName))
	{
		while (read_file(szFileName, i++, szBuffer, 31, b))
		{
			if (!isalnum(szBuffer[0]) || !ValidMap(szBuffer)) continue
			
			if (!iMaps)
				copy(szFirst, 31, szBuffer)
			
			if (++iMaps > g_pos)
			{
				copy(szNext, iNext, szBuffer)
				g_pos = iMaps
				return
			}
		}
	}

	if (!iMaps)
	{
		log_amx(g_warning, szFileName)
		get_mapname(szFirst, 31)
	}

	copy(szNext, iNext, szFirst)
	g_pos = 1
}

#else

readMapCycle(szFileName[], szNext[], iNext)
{
	new b, i = 0, iMaps = 0
	new szBuffer[32], szFirst[32], szCurrent[32]
	
	get_mapname(szCurrent, 31)
	
	new a = g_pos

	if (file_exists(szFileName))
	{
		while (read_file(szFileName, i++, szBuffer, 31, b))
		{
			if (!isalnum(szBuffer[0]) || !ValidMap(szBuffer)) continue
			
			if (!iMaps)
			{
				iMaps = 1
				copy(szFirst, 31, szBuffer)
			}
			
			if (iMaps == 1)
			{
				if (equali(szCurrent, szBuffer))
				{
					if (a-- == 0)
						iMaps = 2
				}
			} else {
				if (equali(szCurrent, szBuffer))
					++g_pos
				else
					g_pos = 0
				
				copy(szNext, iNext, szBuffer)
				return
			}
		}
	}
	
	if (!iMaps)
	{
		log_amx(g_warning, szFileName)
		copy(szNext, iNext, szCurrent)
	}
	else
		copy(szNext, iNext, szFirst)
	
	g_pos = 0
}
#endif
/*
* С уважением, Wildnees Team (с) 2012
*/
