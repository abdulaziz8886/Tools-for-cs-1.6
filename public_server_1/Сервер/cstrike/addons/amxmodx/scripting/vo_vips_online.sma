/*
    Created Vip Online by VO Team for www.vse-ogon.ru
    Web Help - www.vse-ogon.ru

    +addon for menu
	
    All ingenious is simple - VO Team. Made in Russia.
*/

#include <amxmodx>
#include <cstrike>

new const PLUGIN[] = "Vip online"
new const VERSION[] = "1.0"
new const AUTHOR[] = "OneEyed/VO Team"

static const COLOR[] = "^x04", CONTACT[] = "^x03"
new maxplayers, gmsgSayText

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say", "handle_say")
	register_cvar("amx_contactinfo", CONTACT, FCVAR_SERVER)
	
	gmsgSayText = get_user_msgid("SayText")
	maxplayers = get_maxplayers()
}

public handle_say(id) 
{
	new said[192]
	read_args(said,192)
	if( ( containi(said, "who") != -1 && containi(said, "admin") != -1 ) || contain(said, "/vips") != -1 )
		set_task(0.1,"vo_vip_onliner",id)
	return PLUGIN_CONTINUE
}

public vo_vip_onliner(user) 
{
	new vipnames[33][32]
	new message[256]
	new contactinfo[256], contact[112]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) & ADMIN_LEVEL_H)
				get_user_name(id, vipnames[count++], 31)
	len = format(message, 255, "%s Vip online: ",COLOR)
	if(count > 0) 
	{
		for(x = 0 ; x < count ; x++) 
		{
			len += format(message[len], 255-len, "%s%s ", vipnames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) 
			{
				print_message(user, message)
				len = format(message, 255, "%s ",COLOR)
			}
		}
		print_message(user, message)
	}
	else 
	{
		len += format(message[len], 255-len, "Vip offline")
		print_message(user, message)
	}
	
	get_cvar_string("amx_contactinfo", contact, 63)
	if(contact[0])  
	{
		format(contactinfo, 111, "%s Используй команду /vip,для получения информации", CONTACT, contact)
		print_message(user, contactinfo)
	}
}

print_message(id, msg[]) 
{
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}