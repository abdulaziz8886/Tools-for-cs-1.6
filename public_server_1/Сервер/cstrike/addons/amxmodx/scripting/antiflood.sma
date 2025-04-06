#include <amxmodx>
#include <chatcolor>

new Float:g_Flooding[33] = {0.0, ...}
new g_Flood[33] = {0, ...}

new amx_flood_time;

public plugin_init()
{
	register_plugin("Anti Flood", AMXX_VERSION_STR, "AMXX Dev Team & Wildness Team")
	register_dictionary("antiflood.txt")
	register_clcmd("say", "chkFlood")
	register_clcmd("say_team", "chkFlood")
	amx_flood_time=register_cvar("amx_flood_time", "0.75")
}

public chkFlood(id)
{
	new Float:maxChat = get_pcvar_float(amx_flood_time)

	if (maxChat)
	{
		new Float:nexTime = get_gametime()
		
		if (g_Flooding[id] > nexTime)
		{
			if (g_Flood[id] >= 3)
			{
				client_print_color(id, DontChange, "^04[AMXX] ^01%L ^n Наш сайт: [^03GM-Serv.Ru^01]", id, "STOP_FLOOD")
				g_Flooding[id] = nexTime + maxChat + 3.0
				return PLUGIN_HANDLED
			}
			g_Flood[id]++
		}
		else if (g_Flood[id])
		{
			g_Flood[id]--
		}
		
		g_Flooding[id] = nexTime + maxChat
	}

	return PLUGIN_CONTINUE
}
/*
* С уважением, Wildness Team (с) 2012
*/