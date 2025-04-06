#define DAMAGE_RECIEVED
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <colorchat>

static const COLOR[] = "^x04" //green
static const CONTACT[] = ""
new maxplayers
new gmsgSayText
new mpd, mkb, mhb
new g_MsgSync
new health_add
new health_hs_add
new health_max
new nKiller
new nKiller_hp
new nHp_add
new nHp_max
new g_awp_active
new g_menu_active
new round;
new bool:HasC4[33]
#define Keysrod (1<<0)|(1<<1)|(1<<9) // Keys: 1234567890
#if defined DAMAGE_RECIEVED
	new g_MsgSync2
#endif

public plugin_init()
{
	register_plugin("VIP Eng Version", "2.05", "Dunno")
	mpd = register_cvar("money_per_damage","3")
	mkb = register_cvar("money_kill_bonus","200")
	mhb = register_cvar("money_hs_bonus","500")
	health_add = register_cvar("amx_vip_hp", "15")
	health_hs_add = register_cvar("amx_vip_hp_hs", "30")
	health_max = register_cvar("amx_vip_max_hp", "100")
	g_awp_active = register_cvar("awp_active", "1")
	g_menu_active = register_cvar("menu_active", "1")
	register_event("Damage","Damage","b")
	register_event("DeathMsg","death_msg","a")
	register_menucmd(register_menuid("rod"), Keysrod, "Pressedrod")
	register_clcmd("awp","HandleCmd")
    	register_clcmd("sg550","HandleCmd")
    	register_clcmd("g3sg1","HandleCmd")
    	register_event("CurWeapon", "event_CurWeapon", "be", "1=1")
    	register_event("CurWeapon", "event_CurWeaponn", "be", "1=1")
    	register_event("CurWeapon", "event_CurWeaponnn", "be", "1=1")
	register_clcmd("say /buyvip","ShowMotd")
	maxplayers = get_maxplayers()
	gmsgSayText = get_user_msgid("SayText")
	register_clcmd("say", "handle_say")
	register_cvar("amx_contactinfo", CONTACT, FCVAR_SERVER)
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1) 
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0") 
	register_event("TextMsg","Event_RoundRestart","a","2&#Game_w")
	register_event("DeathMsg", "hook_death", "a", "1>0")
	register_event("Damage", "on_damage", "b", "2!0", "3=0", "4!0")
	g_MsgSync = CreateHudSyncObj()
#if defined DAMAGE_RECIEVED
	g_MsgSync2 = CreateHudSyncObj()
#endif	
}

public on_damage(id)
{
	new attacker = get_user_attacker(id)

#if defined DAMAGE_RECIEVED
	// id should be connected if this message is sent, but lets check anyway
	if ( is_user_connected(id) && is_user_connected(attacker) )
	if (get_user_flags(attacker) & ADMIN_LEVEL_H)
	{
		new damage = read_data(2)

		set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
		ShowSyncHudMsg(id, g_MsgSync2, "%i^n", damage)
#else
	if ( is_user_connected(attacker) && if (get_user_flags(attacker) & ADMIN_LEVEL_H) )
	{
		new damage = read_data(2)
#endif
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
		ShowSyncHudMsg(attacker, g_MsgSync, "%i^n", damage)
	}
}

public Damage(id)
{
	new weapon, hitpoint, attacker = get_user_attacker(id,weapon,hitpoint)
	if(attacker<=maxplayers && is_user_alive(attacker) && attacker!=id)
	if (get_user_flags(attacker) & ADMIN_LEVEL_H) 
	{
		new money = read_data(2) * get_pcvar_num(mpd)
		if(hitpoint==1) money += get_pcvar_num(mhb)
		cs_set_user_money(attacker,cs_get_user_money(attacker) + money)
	}
}

public death_msg()
{
	if(read_data(1)<=maxplayers && read_data(1) && read_data(1)!=read_data(2)) cs_set_user_money(read_data(1),cs_get_user_money(read_data(1)) + get_pcvar_num(mkb) - 300)
}


public fwHamPlayerSpawnPost() {

	new players[32], player, pnum;
	get_players(players, pnum, "a");
	for(new i = 0; i < pnum; i++)
	{
		player = players[i];
		if(is_user_alive(player) && get_user_flags(player) & ADMIN_LEVEL_H)
		{
		give_item(player, "weapon_hegrenade");
		give_item(player, "weapon_flashbang");
		give_item(player, "weapon_flashbang");
		give_item(player, "weapon_smokegrenade");
		give_item(player, "item_assaultsuit");
		give_item(player, "item_thighpack");
		}
	}
	return PLUGIN_HANDLED
}

public event_new_round() 
{
	round++;
	new players[32], player, pnum;
	get_players(players, pnum, "a");
	for(new i = 0; i < pnum; i++)
	{
		player = players[i];
		if(get_user_flags(player) & ADMIN_LEVEL_H)
		{
		if (!get_pcvar_num(g_menu_active))
			return PLUGIN_CONTINUE
		if(round > 2)
		{
			Showrod(player);
		}
		}
	}
	return PLUGIN_HANDLED
}

public Event_RoundRestart(id)
{
	round=0;
}

public hook_death()
{
   // Killer id
   nKiller = read_data(1)
   
   if ( (read_data(3) == 1) && (read_data(5) == 0) )
   {
      nHp_add = get_pcvar_num (health_hs_add)
   }
   else
      nHp_add = get_pcvar_num (health_add)
   nHp_max = get_pcvar_num (health_max)
   // Updating Killer HP
   if(!(get_user_flags(nKiller) & ADMIN_LEVEL_H))
   return;

   nKiller_hp = get_user_health(nKiller)
   nKiller_hp += nHp_add
   // Maximum HP check
   if (nKiller_hp > nHp_max) nKiller_hp = nHp_max
   set_user_health(nKiller, nKiller_hp)
   // Hud message "Healed +15/+30 hp"
   set_hudmessage(0, 255, 0, -1.0, 0.15, 0, 1.0, 1.0, 0.1, 0.1, -1)
   show_hudmessage(nKiller, "Healed +%d hp", nHp_add)
   // Screen fading
   message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, nKiller)
   write_short(1<<10)
   write_short(1<<10)
   write_short(0x0000)
   write_byte(0)
   write_byte(0)
   write_byte(200)
   write_byte(75)
   message_end()
 
}

public Showrod(id) {
	show_menu(id, Keysrod, "Бесплатные vip оружия^n\w1. Взять M4A1 и Deagle^n\w2. Взять AK47 и Deagle^n0. Выход^n", -1, "rod") // Display menu
}
public Pressedrod(id, key) {
	/* Меню:
	* Vip меню
	* 1. Взять M4A1 и Deagle
	* 2. Взять AK47 и Deagle
	* 0. выход
	*/
	switch (key) {
		case 0: { 
			if (user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
				HasC4[id] = true;
			else
				HasC4[id] = false;
            
			strip_user_weapons (id)
			give_item(id,"weapon_m4a1")
			give_item(id,"ammo_556nato")
			give_item(id,"ammo_556nato")
			give_item(id,"ammo_556nato")
			give_item(id,"weapon_deagle")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"weapon_knife")
			give_item(id,"weapon_hegrenade")
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_smokegrenade");
			give_item(id, "item_assaultsuit");
			give_item(id, "item_thighpack");
			client_print(id, print_center, "Ты взял M4A1 и Deagle!")
			
			if (HasC4[id])
			{
				give_item(id, "weapon_c4");
				cs_set_user_plant( id );
			}
			}
		case 1: { 
			if (user_has_weapon(id, CSW_C4) && get_user_team(id) == 1)
				HasC4[id] = true;
			else
				HasC4[id] = false;
            
			strip_user_weapons (id)
			give_item(id,"weapon_ak47")
			give_item(id,"ammo_762nato")
			give_item(id,"ammo_762nato")
			give_item(id,"ammo_762nato")
			give_item(id,"weapon_deagle")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"ammo_50ae")
			give_item(id,"weapon_knife")
			give_item(id,"weapon_hegrenade")
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_flashbang");
			give_item(id, "weapon_smokegrenade");
			give_item(id, "item_assaultsuit");
			give_item(id, "item_thighpack");
			client_print(id, print_center, "Ты взял AK47 и Deagle!")
			
			if (HasC4[id])
			{
				give_item(id, "weapon_c4");
				cs_set_user_plant( id );
			}
			}
		case 9: { 			
		}
	}
	return PLUGIN_CONTINUE
}

public HandleCmd(id){
	if (!get_pcvar_num(g_awp_active))
      return PLUGIN_CONTINUE
	if(get_user_flags(id) & ADMIN_LEVEL_H) 
		return PLUGIN_CONTINUE
	client_print(id, print_center, "AWP только для vip игроков.")
	return PLUGIN_HANDLED
}


public event_CurWeapon(id)
	{
	if(read_data(2) == CSW_AWP)
		{
		if(!(get_user_flags(id) & ADMIN_LEVEL_H))
			{
			client_print(id, print_center, "AWP только для vip игроков.")
			client_cmd(id, "drop")
			}
		}
	return PLUGIN_HANDLED
}

public event_CurWeaponn(id)
	{
	if(read_data(2) == CSW_SG550)
		{
		if(!(get_user_flags(id) & ADMIN_LEVEL_H))
			{
			client_print(id, print_center, "AWP только для vip игроков.")
			client_cmd(id, "drop")
			}
		}
	return PLUGIN_HANDLED
}

public event_CurWeaponnn(id)
	{
	if(read_data(2) == CSW_G3SG1)
		{
		if(!(get_user_flags(id) & ADMIN_LEVEL_H))
			{
			client_print(id, print_center, "AWP только для vip игроков.")
			client_cmd(id, "drop")
			}
		}
	return PLUGIN_HANDLED
}

public ShowMotd(id)
{
 show_motd(id, "vip.txt")
}
public client_authorized(id)
{
 set_task(30.0, "PrintText" ,id)
}
public PrintText(id)
{
 ColorChat(id, print_chat, "^x04[Public-Server.Ru] ^x03Контактная информация с ^x04администратором ^x04/buyvip.")
}
public handle_say(id) {
	new said[192]
	read_args(said,192)
	if( ( containi(said, "who") != -1 && containi(said, "admin") != -1 ) || contain(said, "/vips") != -1 )
		set_task(0.1,"print_adminlist",id)
	return PLUGIN_CONTINUE
}

public print_adminlist(user) 
{
	new adminnames[33][32]
	new message[256]
	new contactinfo[256], contact[112]
	new id, count, x, len
	
	for(id = 1 ; id <= maxplayers ; id++)
		if(is_user_connected(id))
			if(get_user_flags(id) & ADMIN_LEVEL_H)
				get_user_name(id, adminnames[count++], 31)

	len = format(message, 255, "%s Vip игроки online: ",COLOR)
	if(count > 0) {
		for(x = 0 ; x < count ; x++) {
			len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
			if(len > 96 ) {
				print_message(user, message)
				len = format(message, 255, "%s ",COLOR)
			}
		}
		print_message(user, message)
	}
	else {
		len += format(message[len], 255-len, "Vip игроки offline.")
		print_message(user, message)
	}
	
	get_cvar_string("amx_contactinfo", contact, 63)
	if(contact[0])  {
		format(contactinfo, 111, "%s Контакты администратора -- /buyvip", COLOR, contact)
		print_message(user, contactinfo)
	}
}

print_message(id, msg[]) {
	message_begin(MSG_ONE, gmsgSayText, {0,0,0}, id)
	write_byte(id)
	write_string(msg)
	message_end()
}

