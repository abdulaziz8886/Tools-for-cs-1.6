#include <amxmodx>
#include <csx>
#include <ColorChat>

#define MAX_PLAYERS 32


new bool:g_RestartAttempt[MAX_PLAYERS+1]

new g_oldrank[MAX_PLAYERS+1]

#if defined DISABLED_BY_DEFAULT
new bool:disabled[MAX_PLAYERS+1] = {true, ...}
#else
new bool:disabled[MAX_PLAYERS+1]
#endif

new inforank

public plugin_init() {
	register_plugin("Info Rank", "0.1", "by CepeH9")
	register_dictionary("inforank.txt")

	inforank = register_cvar("amx_inforank", "1")

	register_event("TextMsg", "eRestartAttempt", "a", "2=#Game_will_restart_in")
	register_event("ResetHUD", "eResetHUD", "be")

	register_clcmd("say /inforank","switchCmd", 0, "- enable/disable info rank messages")
	register_clcmd("say_team /inforank","switchCmd", 0, "- enable/disable info rank messages")
	register_clcmd("fullupdate", "fullupdateCmd")
}

public fullupdateCmd() {
	return PLUGIN_HANDLED_MAIN
}

public eRestartAttempt() {
	if(!get_pcvar_num(inforank))
		return

	new players[MAX_PLAYERS], num
	get_players(players, num, "a")
	for (new i; i < num; ++i)
		g_RestartAttempt[players[i]] = true
}

public eResetHUD(id) {
	if (g_RestartAttempt[id]) {
		g_RestartAttempt[id] = false
		return
	}
	
	if(!get_pcvar_num(inforank))
		return

	if(disabled[id])
		return

	event_player_spawn(id)
}
 
public event_player_spawn(id) {

	new osef[8]
	new rank = get_user_stats(id, osef, osef)
	new maxrank = get_statsnum()
		
	if(g_oldrank[id] == 0)
		g_oldrank[id] = rank
	
	new diff = g_oldrank[id] - rank
	g_oldrank[id] = rank
	
	if(diff > 0) {		
		ColorChat(id, GREEN, "^1[^4Сервер^1] ^3Вы поднялись на ^4%i ^3позиций в статистике!", diff)
	}
	else if(diff < 0) {
		ColorChat(id, RED, "^1[^4Сервер^1] ^3Вы опустились на ^4%i ^3позиций в статистике!", abs(diff))
	}
	ColorChat(id, GREY, "^1[^4Сервер^1] ^1Вы занимаете ^4%i-е ^1место из ^4%i", rank, maxrank)
}

public switchCmd(id) {
	if(!get_pcvar_num(inforank))
		return PLUGIN_CONTINUE

	if(disabled[id]) {
		disabled[id] = false
		client_cmd(id, "setinfo _ir 1")
		ColorChat(id, GREEN, "^3[^4Сервер^3] ^4Сообщения включены")
	}
	else {
		disabled[id] = true
		client_cmd(id, "setinfo _ir 0")
		ColorChat(id, GREEN, "^3[^4Сервер^3] ^4Сообщения выключены")
	}
	return PLUGIN_CONTINUE
}

public client_authorized(id) {
	new osef[8]
	g_oldrank[id] = get_user_stats(id, osef, osef)

	new enable[2]
	get_user_info(id, "_ir", enable, 1)
	if(!enable[0])
		return

	if(enable[0]=='1')
		disabled[id] = false
	else
		disabled[id] = true
}

public client_disconnect(id) {
	g_oldrank[id] = 0

#if defined DISABLED_BY_DEFAULT
	disabled[id] = true
#else
	disabled[id] = false
#endif
}	