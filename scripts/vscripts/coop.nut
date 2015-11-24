printl("################################################")
printl("###                                          ###")
printl("###           Advanced Stats V 0.3           ###")
printl("###                                          ###")
printl("################################################")

/**
 * Plugin settings
 */
::ADV_STATS_LOG_LEVEL <- 2 				// 0 = no debug, 1 = info, 2 = debug
::ADV_STATS_DUMP <- true 				// Dump of data at start/end of map
::ADV_STATS_BOTS_DISPLAY <- false 		// Activate the display of the bots' stats
::ADV_STATS_FF_BOTS_ENABLED <- true 	// Activate FF done to bots

IncludeScript("logger.nut")
IncludeScript("hud.nut")
IncludeScript("events.nut")

::ADV_STATS_LOGGER <- Logger();
::AdvStats <- {cache = {}, hud_visible = false, finale_win = false}
::ADV_STATS_BOTS <- ["Coach", "Ellis", "Rochelle", "Nick", "Louis", "Bill", "Francis", "Zoey"]
::ADV_STATS_SI <- [
	"Boomer", "(1)Boomer", "(2)Boomer", "(3)Boomer",
	"Charger", "(1)Charger", "(2)Charger", "(3)Charger",
	"Hunter", "(1)Hunter", "(2)Hunter", "(3)Hunter",
	"Jockey", "(1)Jockey", "(2)Jockey", "(3)Jockey",
	"Smoker", "(1)Smoker", "(2)Smoker", "(3)Smoker",
	"Spitter", "(1)Spitter", "(2)Spitter", "(3)Spitter"
]

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
	return ::ADV_STATS_SI.find(sName) != null;
}

function AdvStats::isBot(sName)
{
	return ::ADV_STATS_BOTS.find(sName) != null;
}

/**
 * Init cache
 */
function AdvStats::init()
{
	::ADV_STATS_LOGGER.debug("Coop Init");

	::AdvStats.cache <- {};
}

/**
 * Init cache for a player
 */
function AdvStats::initPlayerCache(sPlayer)
{
	::ADV_STATS_LOGGER.debug("Coop InitPlayerCache");

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
	::ADV_STATS_LOGGER.debug("Coop Saving stats...");

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
	::ADV_STATS_LOGGER.debug("Coop Loading stats...");
	
	RestoreTable("_adv_stats", ::AdvStats.cache)
	if (::AdvStats.cache.len() == 0)
		::AdvStats.init()
}