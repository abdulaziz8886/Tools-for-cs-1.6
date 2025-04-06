#include <amxmodx>
#if AMXX_VERSION_NUM < 183
	#include <colorchat>
#endif

#define ALL			// Показывать всем. Для показа только мервым и спектаторам закомментируйте
#define REPEAT_TIME 15.0	// Время между сообщениями

new adMessages[256][192];
new ad_count, iMessgCount;

public plugin_init()
{
	register_plugin("Advert Messages", "1.2", "neygomon");
	set_task(REPEAT_TIME, "advert", .flags="b");
}

public plugin_cfg()
{
	new configsdir[64], filename[64], file;
	get_localinfo("amxx_configsdir", configsdir,charsmax(configsdir));
	formatex(filename, charsmax(filename), "%s/adverts.ini",configsdir);

	file = fopen(filename,"r");

	if(file)
	{
		new string[512], message[192];
		while((ad_count < 256) && !feof(file))
		{
			fgets(file, string, charsmax(string));

			if((string[0] != ';') && (string[0] != '/') && parse(string, message, charsmax(message)))
			{
				format_color(message, charsmax(message));
				copy(adMessages[ad_count], 192, message);
				ad_count++;
			}
		}
		fclose(file);
	}
	else
		log_amx("File ^"%s^" not found", filename);
}

public advert()
{	
	if(!ad_count) return;
#if defined ALL
	client_print_color(0, 0, "%s", adMessages[iMessgCount == ad_count ? (iMessgCount = 0) : iMessgCount++]);
#else
	static players[32], pcount;
	get_players(players, pcount, "bch");
	for(new i; i < pcount; i++)
	{
		client_print_color(players[i], 0, "%s", adMessages[iMessgCount == ad_count ? (iMessgCount = 0) : iMessgCount++]);
	}
#endif	
}

stock format_color(message[], msglen)
{
	new string[256], len = charsmax(string);

	copy(string, len, message);

	replace_all(string, len, "!n", "^1");
	replace_all(string, len, "!t", "^3");
	replace_all(string, len, "!g", "^4");

	formatex(message, msglen, "^1%s", string);
}