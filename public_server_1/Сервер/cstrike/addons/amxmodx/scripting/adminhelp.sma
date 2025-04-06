#include <amxmodx>
#include <chatcolor>

#define DISPLAY_MSG		// Comment to disable message on join
#define HELPAMOUNT 10	// Number of commands per page

public plugin_init()
{
	register_plugin("Admin Help", AMXX_VERSION_STR, "AMXX Dev Team & Wildness Team")
	register_dictionary("adminhelp.txt")
	register_concmd("amx_help", "cmdHelp", 0, "<page> [nr of cmds (only for server)] - displays this help")
}

#if defined DISPLAY_MSG
public client_putinserver(id)
{
	if (is_user_bot(id))
		return
	
	set_task(15.0, "dispInfo", id)
}

public client_disconnect(id)
{
	remove_task(id)
}
#endif

public cmdHelp(id, level, cid)
{
	new arg1[8], flags = get_user_flags(id)
	new start = read_argv(1, arg1, 7) ? str_to_num(arg1) : 1
	new lHelpAmount = HELPAMOUNT
	
	// HACK: ADMIN_ADMIN is never set as a user's actual flags, so those types of commands never show
	if (flags > 0 && !(flags & ADMIN_USER))
	{
		flags |= ADMIN_ADMIN;
	}
	
	if (id == 0 && read_argc() == 3)
		lHelpAmount = read_argv(2, arg1, 7) ? str_to_num(arg1) : HELPAMOUNT

	if (--start < 0)
		start = 0

	new clcmdsnum = get_concmdsnum(flags, id)

	if (start >= clcmdsnum)
		start = clcmdsnum - 1

	console_print(id, "^n----- %L -----", id, "HELP_COMS")
	
	new info[128], cmd[32], eflags
	new end = start + lHelpAmount // HELPAMOUNT

	if (end > clcmdsnum)
		end = clcmdsnum

	for (new i = start; i < end; i++)
	{
		get_concmd(i, cmd, 31, eflags, info, 127, flags, id)
		console_print(id, "%3d: %s %s", i + 1, cmd, info)
	}
	
	console_print(id, "----- %L -----", id, "HELP_ENTRIES", start + 1, end, clcmdsnum)

	if (end < clcmdsnum)
		console_print(id, "----- %L -----", id, "HELP_USE_MORE", end + 1)
	else
		console_print(id, "----- %L -----", id, "HELP_USE_BEGIN")

	return PLUGIN_HANDLED
}

#if defined DISPLAY_MSG
public dispInfo(id)
{
	client_print_color(id, DontChange, "%L", id, "TYPE_HELP")
	
	new nextmap[32]
	get_cvar_string("amx_nextmap", nextmap, 31)
	
	if (get_cvar_float("mp_timelimit"))
	{
		new timeleft = get_timeleft()
		
		if (timeleft > 0)
		{
			client_print_color(id, DontChange, "%L", id, "TIME_INFO_1", timeleft / 60, timeleft % 60, nextmap)
		} else {
			client_print_color(id, DontChange, "%L", id, "TIME_INFO_2", nextmap)
		}
	}
}
#endif

/*
* С уважением, Wildness Team (с) 2012
*/
