#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <dhudmessage>

#define adtime	 600.0 //Default of 10 minuites

new pcvar_Advertise
new pcvar_Display

public plugin_init()
{
	register_plugin("Reset Score", "0.2", "Silenttt / CepeH9")
	
	register_clcmd("say /rs", "reset_score")
	register_clcmd("say /resetscore", "reset_score")
	register_clcmd("say_team /rs", "reset_score")
	register_clcmd("say_team /resetscore", "reset_score")
	
	pcvar_Advertise = register_cvar("sv_rsadvertise", "1")
	pcvar_Display = register_cvar("sv_rsdisplay", "1")
	if(get_cvar_num("sv_rsadvertise") == 1)
	{
		set_task(adtime, "advertise", _, _, _, "b")
	}
	
	register_cvar("amx_rstune", "1")
}

public reset_score(id)
{
	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)
	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)
	
	if(get_pcvar_num(pcvar_Display) == 1)
	{
		new name[33]
		get_user_name(id, name, 32)

		ChatColor(id, "!n[!gИнформация!n] - !nВаш счет !tобнулен", name)
		if (get_cvar_num("amx_rstune") != 0)
	    { 
	     client_cmd(id,"spk buttons/bell1.wav")
	    }
	}
}

public advertise()
{
	set_dhudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.71, 2, 6.0, 3.0, 0.1, 1.5 );
	show_dhudmessage(0, "!n[!gИнформация!n] - !nПлохой счет,значит используй !t/rs");
}

public client_putinserver(id)
{
	if(get_pcvar_num(pcvar_Advertise) == 1)
	{
		set_task(10.0, "connectmessage", id, _, _, "a", 1)
	}
}

public connectmessage(id)
{
	if(is_user_connected(id))
	{
	ChatColor(id, "!t[!gСервер!t] !yНапишите в чате !g/rs !yдля обнуления вашего счёта")
	}
}

stock ChatColor(const id, const input[], any:...)
{
        new count = 1, players[32]
        static msg[191]
        vformat(msg, 190, input, 3)
    
        replace_all(msg, 190, "!g", "^4")
        replace_all(msg, 190, "!y", "^1")
        replace_all(msg, 190, "!t", "^3")
    
        if (id) players[0] = id; else get_players(players, count, "ch")
        {
                for (new i = 0; i < count; i++)
                {
                        if (is_user_connected(players[i]))
                        {
                                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);
                                write_byte(players[i]);
                                write_string(msg);
                                message_end();
                        }
                }
        }
} 
