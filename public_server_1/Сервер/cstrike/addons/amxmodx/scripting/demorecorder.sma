#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Demo Recorder"
#define VERSION "1.6"
#define AUTHOR "Sho0ter"
#define PREFIX "[DEMO RECORDER]"
#define PREFIX_START "[DEMO RECORDER START]"
#define PREFIX_ERROR "[DEMO RECORDER ERROR]"
#define PREFIX_STOP "[DEMO RECORDER STOP]"

new demotime[64]
new demonick[64]
new demoip[64]
new demomap[64]
new demoname[64]
new demofolder[64]
new demosite[64]
new democonfigdir[64]
new democonfig[64]
new demodate[64]
new demolog[64]
new demomod[64]
new demofile[64]
new demohostname[64]
new demohostip[64]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("demorecorder.txt")
	register_cvar("amx_demo_recorder_name_mode", "4")
	register_cvar("amx_demo_recorder_auto_record", "1")
	register_cvar("amx_demo_recorder_auto_delay", "5.0")
	register_cvar("amx_demo_recorder_auto_cmd_stop", "0")
	register_cvar("amx_demo_recorder_auto_stop", "1")
	register_cvar("amx_demo_recorder_auto_stop_time", "60.0")
	register_cvar("amx_demo_recorder_cmd_record", "0")
	register_cvar("amx_demo_recorder_stop", "0")
	register_cvar("amx_demo_recorder_stop_time", "60.0")
	register_cvar("amx_demo_recorder_cmdinfo_delay", "20.0")
	register_cvar("amx_demo_recorder_name", "publicserver")
	register_cvar("amx_demo_recorder_folder", "")
	register_cvar("amx_demo_recorder_log", "1")
	register_cvar("amx_demo_recorder_site", "public-server.ru")
	register_cvar("amx_demo_recorder_chat", "1")
	register_cvar("amx_demo_recorder_hud", "1")
	register_cvar("amx_demo_recorder_hud_hold", "10.0")
	register_cvar("amx_demo_recorder_hud_color_r", "255")
	register_cvar("amx_demo_recorder_hud_color_g", "255")
	register_cvar("amx_demo_recorder_hud_color_b", "255")
	register_cvar("amx_demo_recorder_hud_position_x", "0.1")
	register_cvar("amx_demo_recorder_hud_position_y", "-1.0")
	register_clcmd("say /record", "cmdrecord", 0, " - start record demo")
	register_clcmd("say /demo", "cmdrecord", 0, " - start record demo")
	register_clcmd("say_team /record", "cmdrecord", 0, " - start record demo")
	register_clcmd("say_team /demo", "cmdrecord", 0, " - start record demo")
	register_clcmd("say /stop", "cmdstop", 0, " - stop record demo")
	register_clcmd("say_team /stop", "cmdstop", 0, " - stoprecord demo")
	return PLUGIN_CONTINUE
}

public plugin_cfg() 
{
	get_time("20%y.%m.%d", demodate, 63)
	get_configsdir(democonfigdir, 63)
	formatex(democonfig, 127, "%s/demorecorder.cfg", democonfigdir)
	formatex(demolog, 63, "demorecorder_%s.log", demodate)
	if(file_exists(democonfig))
	{
		server_cmd("exec %s", democonfig)
		server_print("%s Config file executed. Version: %s", PREFIX, VERSION)
	}
	else
	{
		server_print("%s Could not find config file!", PREFIX_ERROR)
		if(get_cvar_num("amx_demo_recorder_log") == 1)
		{
  			log_to_file(demolog, "%s [Could not find config file!]", PREFIX_ERROR)
  			log_to_file(demolog, "%s [You should put demorecorder.cfg in addons/amxmodx/configs/]", PREFIX_ERROR)
  			log_to_file(demolog, "%s [You should put demorecorder.cfg in addons/amxmodx/configs/]", PREFIX_ERROR)
		}
	}
	return PLUGIN_CONTINUE	
}

public client_putinserver(id)
{
	if(get_cvar_num("amx_demo_recorder_auto_record") == 1)
	{
		set_task(get_cvar_float("amx_demo_recorder_auto_delay"), "startrecord", id)
	}
	if(get_cvar_num("amx_demo_recorder_cmd_record") == 1)
	{
		set_task(get_cvar_float("amx_demo_recorder_cmdinfo_delay"), "showcmdinfo", id)
	}
	return PLUGIN_CONTINUE
}

public startrecord(id)
{
	client_cmd(id, "stop")
	get_cvar_string("amx_demo_recorder_folder", demofolder, 63)
	if(get_cvar_num("amx_demo_recorder_name_mode") == 1)
	{
		get_user_name(id, demonick, 63)
		get_user_ip(id, demoip, 63, 1)
		formatex(demoname, 63, "%s-%s", demonick, demoip)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 2)
	{
		get_user_name(0, demoname, 63)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 3)
	{
		get_time("%d-%m-20%y_%H-%M-%S", demoname, 63)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 4)
	{
		get_user_ip(0, demoname, 63)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 5)
	{
		get_cvar_string("amx_demo_recorder_name", demoname, 63)
	}
	replace_all(demoname, 63, ":", "_" )
	replace_all(demoname, 63, ".", "_" )
	replace_all(demoname, 63, "*", "_" )
	replace_all(demoname, 63, "/", "_" )
	replace_all(demoname, 63, "|", "_" )
	replace_all(demoname, 63, "\", "_" )
	replace_all(demoname, 63, "?", "_" )
	replace_all(demoname, 63, ">", "_" )
	replace_all(demoname, 63, "<", "_" )
	replace_all(demoname, 63, " ", "_" )
	client_cmd(id, "record %s/%s", demofolder, demoname)
	if(get_cvar_num("amx_demo_recorder_auto_stop") == 1)
	{
		set_task(get_cvar_float("amx_demo_recorder_auto_stop_time"), "cmdstop", id)
	}
	set_task(1.0, "showinfo", id)
	return PLUGIN_CONTINUE
}

public showinfo(id)
{
	get_time("%d.%m.20%y %H:%M:%S", demotime, 63)
	get_time("20%y.%m.%d", demodate, 63)
	get_user_name(id, demonick, 63)
	get_user_ip(id, demoip, 63, 1)
	get_mapname(demomap, 63)
	get_user_name(0, demohostname, 63)
	get_user_ip(0, demohostip, 63)
	get_cvar_string("amx_demo_recorder_site", demosite, 63)
	get_cvar_string("amx_demo_recorder_folder", demofolder, 63)
	if(get_cvar_num("amx_demo_recorder_name_mode") == 1)
	{
		get_user_name(id, demonick, 63)
		get_user_ip(id, demoip, 63, 1)
		formatex(demoname, 63, "%s-%s", demonick, demoip)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 2)
	{
		get_user_name(0, demoname, 63)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 3)
	{
		get_time("%d-%m-20%y_%H-%M-%S", demoname, 63)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 4)
	{
		get_user_ip(0, demoname, 63)
	}
	if(get_cvar_num("amx_demo_recorder_name_mode") == 5)
	{
		get_cvar_string("amx_demo_recorder_name", demoname, 63)
	}
	replace_all(demoname, 63, ":", "_" )
	replace_all(demoname, 63, ".", "_" )
	replace_all(demoname, 63, "*", "_" )
	replace_all(demoname, 63, "/", "_" )
	replace_all(demoname, 63, "|", "_" )
	replace_all(demoname, 63, "\", "_" )
	replace_all(demoname, 63, "?", "_" )
	replace_all(demoname, 63, ">", "_" )
	replace_all(demoname, 63, "<", "_" )
	replace_all(demoname, 63, " ", "_" )
	get_modname(demomod, 63)
	if (equali(demofolder,""))
	{
		formatex(demofile, 63, "%s/%s.dem", demomod, demoname)
	}
	else
	{
		formatex(demofile, 63, "%s/%s/%s.dem", demomod, demofolder, demoname)
	}
	formatex(demolog, 63, "demorecorder_%s.log", demodate)
	if(get_cvar_num("amx_demo_recorder_chat") == 1)
	{
		ColorChat(id, "%L", LANG_PLAYER, "DEMO_START")
		ColorChat(id, "%L", LANG_PLAYER, "DEMO_INFO_PLAYER", demonick, demoip, demotime, demomap)
		ColorChat(id, "%L", LANG_PLAYER, "DEMO_FILE", demofile)
		ColorChat(id, "%L", LANG_PLAYER, "DEMO_INFO", demosite)
	}
	if(get_cvar_num("amx_demo_recorder_hud") == 1)
	{
		set_hudmessage(get_cvar_num("amx_demo_recorder_hud_color_r") , get_cvar_num("amx_demo_recorder_hud_color_g"), get_cvar_num("amx_demo_recorder_hud_color_b"), get_cvar_float("amx_demo_recorder_hud_position_x"), get_cvar_float("amx_demo_recorder_hud_position_y"), 0, 6.0, get_cvar_float("amx_demo_recorder_hud_hold"), 0.5, 0.15, -1)
		show_hudmessage(id, "%s %L", PREFIX, LANG_PLAYER, "DEMO_HUD", demohostname, demohostip, demonick, demoip, demotime, demomap, demofile, demosite)
	}
	if(get_cvar_num("amx_demo_recorder_log") == 1)
	{
		log_to_file(demolog, "%s [Nick: %s] [IP: %s] [Time: %s] [Map: %s] [Command: record %s/%s]", PREFIX_START, demonick, demoip, demotime, demomap, demofolder, demoname)
	}
	return PLUGIN_CONTINUE
}

public showcmdinfo(id)
{
	if(get_cvar_num("amx_demo_recorder_chat") == 1)
	{
		client_print(id, print_chat, "%s %L", PREFIX, LANG_PLAYER, "DEMO_CMD_INFO")
	}
	if(get_cvar_num("amx_demo_recorder_hud") == 1)
	{
		set_hudmessage(get_cvar_num("amx_demo_recorder_hud_color_r") , get_cvar_num("amx_demo_recorder_hud_color_g"), get_cvar_num("amx_demo_recorder_hud_color_b"), get_cvar_float("amx_demo_recorder_hud_position_x"), get_cvar_float("amx_demo_recorder_hud_position_y"), 0, 6.0, get_cvar_float("amx_demo_recorder_hud_hold"), 0.5, 0.15, -1)
		show_hudmessage(id, "%s %L", PREFIX, LANG_PLAYER, "DEMO_CMD_INFO")
	}
	return PLUGIN_CONTINUE
}

public cmdrecord(id)
{
	if(get_cvar_num("amx_demo_recorder_cmd_record") == 1)
	{
		set_task(0.0, "startrecord", id)
		set_task(1.0, "infostop", id)
	}
	else
	{
		if(get_cvar_num("amx_demo_recorder_chat") == 1)
		{
			client_print(id, print_chat, "%s %L", PREFIX_ERROR, LANG_PLAYER, "DEMO_CMD_OFF")
		}
		if(get_cvar_num("amx_demo_recorder_hud") == 1)
		{
			set_hudmessage(get_cvar_num("amx_demo_recorder_hud_color_r") , get_cvar_num("amx_demo_recorder_hud_color_g"), get_cvar_num("amx_demo_recorder_hud_color_b"), get_cvar_float("amx_demo_recorder_hud_position_x"), get_cvar_float("amx_demo_recorder_hud_position_y"), 0, 6.0, get_cvar_float("amx_demo_recorder_hud_hold"), 0.5, 0.15, -1)
			show_hudmessage(id, "%s %L", PREFIX_ERROR, LANG_PLAYER, "DEMO_CMD_OFF")
		}
	}
	return PLUGIN_CONTINUE
}

public cmdstop(id)
{
	if(get_cvar_num("amx_demo_recorder_auto_cmd_stop") == 1)
	{
		client_cmd(id, "stop")
		if(get_cvar_num("amx_demo_recorder_chat") == 1)
		{
			client_print(id, print_chat, "%s %L", PREFIX_STOP, LANG_PLAYER, "DEMO_STOP")
		}
		if(get_cvar_num("amx_demo_recorder_hud") == 1)
		{
			set_hudmessage(get_cvar_num("amx_demo_recorder_hud_color_r") , get_cvar_num("amx_demo_recorder_hud_color_g"), get_cvar_num("amx_demo_recorder_hud_color_b"), get_cvar_float("amx_demo_recorder_hud_position_x"), get_cvar_float("amx_demo_recorder_hud_position_y"), 0, 6.0, get_cvar_float("amx_demo_recorder_hud_hold"), 0.5, 0.15, -1)
			show_hudmessage(id, "%s %L", PREFIX_STOP, LANG_PLAYER, "DEMO_STOP")
		}
	}
	else
	{
		if(get_cvar_num("amx_demo_recorder_cmd_record") == 0)
		{
			if(get_cvar_num("amx_demo_recorder_chat") == 1)
			{
				client_print(id, print_chat, "%s %L", PREFIX_ERROR, LANG_PLAYER, "DEMO_AUTO_NO_STOP")
			}
			if(get_cvar_num("amx_demo_recorder_hud") == 1)
			{
				set_hudmessage(get_cvar_num("amx_demo_recorder_hud_color_r") , get_cvar_num("amx_demo_recorder_hud_color_g"), get_cvar_num("amx_demo_recorder_hud_color_b"), get_cvar_float("amx_demo_recorder_hud_position_x"), get_cvar_float("amx_demo_recorder_hud_position_y"), 0, 6.0, get_cvar_float("amx_demo_recorder_hud_hold"), 0.5, 0.15, -1)
				show_hudmessage(id, "%s %L", PREFIX_ERROR, LANG_PLAYER, "DEMO_AUTO_NO_STOP")
			}
		}
		else
		{
			client_cmd(id, "stop")
			if(get_cvar_num("amx_demo_recorder_chat") == 1)
			{
				client_print(id, print_chat, "%s %L", PREFIX_STOP, LANG_PLAYER, "DEMO_STOP")
			}
			if(get_cvar_num("amx_demo_recorder_hud") == 1)
			{
				set_hudmessage(get_cvar_num("amx_demo_recorder_hud_color_r") , get_cvar_num("amx_demo_recorder_hud_color_g"), get_cvar_num("amx_demo_recorder_hud_color_b"), get_cvar_float("amx_demo_recorder_hud_position_x"), get_cvar_float("amx_demo_recorder_hud_position_y"), 0, 6.0, get_cvar_float("amx_demo_recorder_hud_hold"), 0.5, 0.15, -1)
				show_hudmessage(id, "%s %L", PREFIX_STOP, LANG_PLAYER, "DEMO_STOP")
			}
		}
	}
	return PLUGIN_CONTINUE
}

        stock ColorChat(const id, const input[], any:...)
        {
                new count = 1, players[32]
                static msg[191]
                vformat(msg, 190, input, 3)
               
                replace_all(msg, 190, "!g", "^4")
                replace_all(msg, 190, "!y", "^1")
                replace_all(msg, 190, "!team", "^3")
               
                if (id) players[0] = id; else get_players(players, count, "ch")
                {
                        for (new i = 0; i < count; i++)
                        {
                                if (is_user_connected(players[i]))
                                {
                                        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
                                        write_byte(players[i]);
                                        write_string(msg);
                                        message_end();
                                }
                        }
                }
        }

public infostop(id)
{
	if(get_cvar_num("amx_demo_recorder_chat") == 1)
	{
			client_print(id, print_chat, "%s %L", PREFIX, LANG_PLAYER, "DEMO_STOP_INFO")
	}
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	remove_task(id)
	return PLUGIN_CONTINUE
}