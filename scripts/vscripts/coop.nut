printl("################################################")
printl("###                                          ###")
printl("###            Advanced Stats V 0.2          ###")
printl("###                                          ###")
printl("################################################")

IncludeScript("logger.nut")
::ADV_STATS_LOGGER <- Logger();

::ADV_STATS_LOG_LEVEL <- 2 // 0 = no debug, 1 = info, 2 = debug
::ADV_STATS_DUMP <- true // Dump of data at start/end of map
::AdvStats <- {cache = {}, hud_visible = false, finale_win = false}
::ADV_STATS_BOTS <- ["Coach", "Ellis", "Rochelle", "Nick", "Louis", "Bill", "Francis", "Zoey"]
::ADV_STATS_SI <- ["Boomer", "Spitter", "Hunter", "Jockey", "Smoker", "Charger"]

IncludeScript("hud.nut")
IncludeScript("events.nut")

function AdvStatsDebug()
{
	if (!::ADV_STATS_DUMP)
		return

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

function AdvStats::isSpecialInfected(sName)
{
    if (::ADV_STATS_SI.find(sName) != null)
		return true;

	// when a special infected spawn twice, the second name is prefixed by "(1)"
	return ::ADV_STATS_SI.find("(1)" + sName) != null
}

function AdvStats::isBot(sName)
{
	return ::ADV_STATS_BOTS.find(sName) != null
}

/**
 * Init cache
 */
function AdvStats::init()
{
	::ADV_STATS_LOGGER.debug("Init");

	::AdvStats.cache <- {};
}

/**
 * Init cache for a player
 */
function AdvStats::initPlayerCache(sPlayer)
{
	// We don't want to store stats for bots
	if (::AdvStats.isBot(sPlayer))
		return;

	// Already initialized
	if (::AdvStats.cache.rawin(sPlayer))
		return;
	
	::AdvStats.cache[sPlayer] <- {
		ff = { // Friendly fire stats
			dmg = {},
			incap = {},
			tk = {}
		},
		dmg = { // Damage dealt
			tanks = 0,
			witches = 0
		},
		hits = { // Hits received
			infected = 0,
			si_hits = 0,
			si_dmg = 0
		},
		specials = {
			dmg = 0,
			kills = 0,
			kills_hs = 0, // head shots
		}
	};
}

/**
 * Save data between maps
 */
function AdvStats::save()
{
	::ADV_STATS_LOGGER.debug("Saving stats...");

	if (::AdvStats.finale_win == true)
	{
		::ADV_STATS_LOGGER.debug("FINALE WIN!! Clearing stats...");
		::AdvStats.cache = {};
	}

	SaveTable("_adv_stats", ::AdvStats.cache)
}

/**
 * Load data after a map load
 */
function AdvStats::load()
{
	::ADV_STATS_LOGGER.debug("Loading stats...");
	
	RestoreTable("_adv_stats", ::AdvStats.cache)
	if (::AdvStats.cache.len() == 0)
		::AdvStats.init()
}