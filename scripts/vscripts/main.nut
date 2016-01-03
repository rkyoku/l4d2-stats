/**
 * Settings
 */
::ADV_STATS_BOTS_DISPLAY <- true 		// Activate the display of bots stats
::ADV_STATS_FF_BOTS_ENABLED <- true 	// Activate FF done to bots
::ADV_STATS_EXTRA_STATS <- true			// Activate to display extra stats
::ADV_STATS_LOG_LEVEL <- 2 				// 0 = no debug, 1 = info level, 2 = debug level
::ADV_STATS_DUMP <- true 				// Dump of stats data at start/end of map

printl("################################################")
printl("###                                          ###")
printl("###           Advanced Stats V 0.6           ###")
printl("###                                          ###")
printl("################################################")

IncludeScript("logger.nut");
IncludeScript("hud.nut");
IncludeScript("events.nut");

::ADV_STATS_LOGGER <- Logger();
::AdvStats <- {
	cache = {},
	welcome_hud_visible = false,
	hud_visible = false,
	endgame_hud_triggered = false,
	finale_win = false,
	current_map = null
};
::ADV_STATS_BOTS <- {
	L4D1 = ["Louis", "Bill", "Francis", "Zoey"],
	L4D2 = ["Coach", "Ellis", "Rochelle", "Nick"]
};
::ADV_STATS_SI <- [
	"Boomer", "(1)Boomer", "(2)Boomer", "(3)Boomer",
	"Charger", "(1)Charger", "(2)Charger", "(3)Charger",
	"Hunter", "(1)Hunter", "(2)Hunter", "(3)Hunter",
	"Jockey", "(1)Jockey", "(2)Jockey", "(3)Jockey",
	"Smoker", "(1)Smoker", "(2)Smoker", "(3)Smoker",
	"Spitter", "(1)Spitter", "(2)Spitter", "(3)Spitter",
];
::ADV_STATS_MAP_PASSING_PORT <- "c6m3_port";
::ADV_STATS_HUD_MAX_PLAYERS <- 4;

createStatsHUD();

/**
 * Stats cache debug
 */
function AdvStatsDebug()
{
	if (!::ADV_STATS_DUMP)
		return;

	printl("")
	printl("################################################")
	printl("###                                          ###")
	printl("###          Advanced Stats - DUMP           ###")
	printl("###                                          ###")
	printl("################################################")
	DeepPrintTable(::AdvStats.cache)
	printl("################################################")
	printl("")
}

/**
 * Is the given name matching the name of a Special infected?
 */
function AdvStats::isSpecialInfected(sName)
{
	return ::ADV_STATS_SI.find(sName) != null;
}

/**
 * Is the given name matching the name of a bot?
 */
function AdvStats::isBot(sName)
{
	if (::ADV_STATS_BOTS.L4D1.find(sName) != null)
		return true;
	
	if (::ADV_STATS_BOTS.L4D2.find(sName) != null)
		return true;
	
	return false;
}

/**
 * Init stats data for a given player name
 */
function AdvStats::initPlayerCache(sPlayer)
{
	::ADV_STATS_LOGGER.debug("initPlayerCache");

	if (::AdvStats.cache.rawin(sPlayer))
		return;
	
	::AdvStats.cache[sPlayer] <- {
		ff = { 				// Friendly fire
			dmg = {},		// Damage dealt
			incap = {},		// Players incapacitated
			tk = {},		// Team kill
		},
		dmg = { 			// Damage dealt
			tanks = 0,		// Tanks
			witches = 0,	// Witches
		},
		hits = { 			// Hits/damage received
			infected = 0,	// By Common infected
			si_hits = 0,	// By Special infected hits
			si_dmg = 0,		// By Special infected damage
		},
		specials = {		// Special infected
			dmg = 0,		// Damage dealt
			kills = 0,		// Kills
			kills_hs = 0,	// Head shots
		}
	};
}

/**
 * Save stats data between maps
 */
function AdvStats::save()
{
	::ADV_STATS_LOGGER.debug("Saving stats...");

	if (::AdvStats.finale_win == true)
	{
		::ADV_STATS_LOGGER.debug("FINALE WIN!! Clearing stats...");
		::AdvStats.cache = {};
	}

	SaveTable("_adv_stats", ::AdvStats.cache);
}

/**
 * Load stats data after a map load
 */
function AdvStats::load()
{
	::ADV_STATS_LOGGER.debug("Loading stats...");
	
	RestoreTable("_adv_stats", ::AdvStats.cache);
	if (::AdvStats.cache.len() == 0)
		::AdvStats.cache <- {};
}