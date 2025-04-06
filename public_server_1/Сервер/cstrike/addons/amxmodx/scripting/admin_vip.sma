#define DAMAGE_RECIEVED
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#define VIP_FLAG ADMIN_LEVEL_H
new round_number
public plugin_init()
{
	register_plugin("Admin_vip", "1.0", "kent-4")
	register_clcmd("say /adminka", "adminka")
	register_event("ResetHUD", "ResetHUD", "be")
	register_clcmd("say /vip","ShowMotd")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_clcmd("say /dgl", "dgl")
	register_clcmd("say /m4a1", "m4a1")
	register_clcmd("say /ak47", "ak47")
	register_clcmd("say /awp", "awp")
}

public adminka(id)
{
 show_motd(id, "adminka.txt")
}
public PrintText(id)
{
 client_print(id, print_chat, "Введите /adminka для получении информации о правах администратора.")
}
public ResetHUD(id)
{
	set_task(0.5, "VIP", id + 6910)
}
public VIP(TaskID)
{
	new id = TaskID - 6910
	
	if (is_user_admin(id))
	{
		message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"))
		write_byte(id)
		write_byte(4)
		message_end()
		give_item(id,"weapon_hegrenade")
		give_item(id,"weapon_flashbang")
		give_item(id,"weapon_flashbang")
		give_item(id,"weapon_smokegrenade")
		give_item(id,"item_assaultsuit")	
	}
	
	return PLUGIN_HANDLED
}
public ShowMotd(id)
{
 show_motd(id, "vip.txt")
}
public PrintCenter(id)
{
 client_print(id, print_center, "Введите /vip для полуения информации о правах vip.")
}
public event_round_start ( ) 
	round_number++ 

public dgl ( id ) 
	{ 

	if ( ! ( get_user_flags ( id ) & VIP_FLAG )  ) 
	{
		ChatColor ( id , "!g[VIP]!y Только для !team[VIP] !y!" ); 
		return PLUGIN_HANDLED; 
	}


	if ( ! is_user_alive ( id ) ) 
	{
		ChatColor(id, "!g[VIP]!y Ты!team [Мертв] !y!"); 
		return PLUGIN_HANDLED; 
	}


	give_item( id, "weapon_deagle" ) 
	cs_set_user_bpammo( id , CSW_DEAGLE, 90 ) 
		
	return PLUGIN_CONTINUE;  
}


public m4a1 ( id )  

	{

	if ( ! ( get_user_flags ( id ) & VIP_FLAG )  )  
	{
		ChatColor ( id , "!g[VIP]!y Только для !team[VIP] !y!" ); 
		return PLUGIN_HANDLED; 
	}


	if ( ! is_user_alive ( id ) )  
	{
		ChatColor(id, "!g[VIP]!y Ты!team [Мертв] !y!"); 
		return PLUGIN_HANDLED; 
	}

	if ( round_number <= 3 ) 
	{
		ChatColor ( id , "!g[VIP]!y Доступно со 2  раунда !y!" ); 
		return PLUGIN_HANDLED; 
	}


	give_item( id, "weapon_m4a1" ) 
	cs_set_user_bpammo( id , CSW_M4A1, 90 ) 
		
	return PLUGIN_CONTINUE;  
}

public ak47 ( id )
	{

	if ( ! ( get_user_flags ( id ) & VIP_FLAG )  )
	{
		ChatColor ( id , "!g[VIP]!y Только для !team[VIP] !y!" ); 
		return PLUGIN_HANDLED; 
	}


	if ( ! is_user_alive ( id ) )  
	{
		ChatColor(id, "!g[VIP]!y Ты!team Мертв !y!"); 
		return PLUGIN_HANDLED; 
	}

	if ( round_number <= 3 )
	{
		ChatColor ( id , "!g[VIP]!y Доступно с 2 раунда !y!" );
		return PLUGIN_HANDLED; 
	}

	give_item( id, "weapon_ak47" ) 
	cs_set_user_bpammo( id , CSW_AK47, 90 )
		

	return PLUGIN_CONTINUE;
}

public awp ( id )
	{

	if ( ! ( get_user_flags ( id ) & VIP_FLAG )  )
	{
		ChatColor ( id , "!g[VIP]!y Только для !team[VIP] !y!" );
		return PLUGIN_HANDLED; 
	}


	if ( ! is_user_alive ( id ) )  
	{
		ChatColor(id, "!g[V]!y Ты!team мертв !y!");
		return PLUGIN_HANDLED; 
	}

	if ( round_number <= 4 )
	{
		ChatColor ( id , "!g[VIP]!y Доступно с 3 раунда !y!" ); 
		return PLUGIN_HANDLED;
	}


	give_item( id, "weapon_awp" )
	cs_set_user_bpammo( id , CSW_AWP, 30 )
		

	return PLUGIN_CONTINUE; 
}

stock ChatColor(const id, const input[], any:...) 
{
	new count = 1, players[32]
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4") // Green Color
	replace_all(msg, 190, "!y", "^1") // Default Color
	replace_all(msg, 190, "!team", "^3") // Team Color
	replace_all(msg, 190, "!team2", "^0") // Team2 Color
	
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