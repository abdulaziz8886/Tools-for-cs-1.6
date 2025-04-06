/*
*************************************************************************************************
* Что делает этот плагин?
* Ответ: данный плагин выводит информацию о сервере, при заходе на сервер, в чат
*************************************************************************************************
* Настройки:
* Отсутствуют
*************************************************************************************************
* Изменения версий:
* 0.1 -> выход на свет
* 0.2 -> счетчик раундов
* 0.3 -> карта
*************************************************************************************************
* Автор:
* smatlyun(smatJkee)
* Связь:
* ICQ: 981326
* SKYPE: smatlyun5130
*/

#include <amxmodx>
#include <colorchat>
#define PLUGIN "smat_info"
#define VERSION "0.3"
#define AUTHOR "smatJkee"
#define DATE "19 february 2012"
new number_round = 1

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_concmd("smat_info", "smatPLUGIN")
    register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
}

public smatPLUGIN(id)
{
    client_print(id, print_console, "Plugin: %s | Version: %s | Author: %s | Date: %s^nICQ: 981326^nSKYPE: smatlyun5130", PLUGIN, VERSION, AUTHOR, DATE)
}

public event_round_start()
{
number_round++
}

public client_putinserver(id)
{
    set_task(10.0, "msg")
}

public msg(id)
{
    new name[32]
    get_user_name(id, name, 31)
    new MapName[32]
    get_mapname(MapName,31)
    new players
    players = get_playersnum()
    ColorChat(0, GREEN, "Привет: ^1%s^4 спасибо что зашел. Раунд: ^1%d^4 | Карта: ^1%s^4 | Игроков: ^1%d", name, number_round, MapName, players)
}