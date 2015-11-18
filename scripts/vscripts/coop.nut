printl("################################################")
printl("###                                          ###")
printl("###            Advanced Stats V 0.1          ###")
printl("###                                          ###")
printl("################################################")
printl("Bugs:")
printl("    * Script's damage to Tanks does not match game-computed values")
printl("    * Sometimes the event 'incapacitated' happens after only 4 zombie hits (events) instead of five")
printl("    * Right after the finale_win event, it seems that the HUD is removed. Must find a way around that (event before finale_win?)")
printl("    * When using a 'Lee' mod (for Coach) the stats do not save for Lee...")


::ADV_STATS_DEBUG <- true // Debug info
::ADV_STATS_DEBUG_BUGS <- true // Debug info
::ADV_STATS_DEBUG_EVENTS <- true // Debug events
::ADV_STATS_DUMP <- true // Dump of data at start/end of map
::AdvStats <- {cache = {}, hud_visible = false, finale_win = false}
::ADV_STATS_BOTS <- ["Coach", "Ellis", "Rochelle", "Nick", "Louis", "Bill", "Francis", "Rochelle"]
::ADV_STATS_SI <- ["Boomer", "Spitter", "Hunter", "Jockey", "Smoker", "Charger"]



IncludeScript("hud.nut")


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
	return ::ADV_STATS_SI.find(sName) != null
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
	printl("+++++++ Init Stats");

	::AdvStats.cache <- {};
	
	/*
	::AdvStats.cache <- {
		Test1 = {
			ff = { // Friendly fire stats
				dmg = {
					Test2 = 14
				},
				incap = {
					Test2 = 2
				},
				tk = {
					Test2 = 1
				}
			},
			dmg = { // Damage dealt
				tanks = 1347,
				witches = 241
			},
			hits = { // Hits received
				infected = 5
			}
		},
		Test2 = {
			ff = { // Friendly fire stats
				dmg = {
					Test1 = 7
				},
				incap = {
					Test3 = 1
				},
				tk = {
				}
			},
			dmg = { // Damage dealt
				tanks = 456,
				witches = 12
			},
			hits = { // Hits received
				infected = 7
			}
		},
		Test3 = {
			ff = { // Friendly fire stats
				dmg = {
					Test3 = 54
				},
				incap = {
					Test4 = 1
				},
				tk = {
				}
			},
			dmg = { // Damage dealt
				tanks = 4235,
				witches = 10
			},
			hits = { // Hits received
				infected = 1
			}
		},
		Test4 = {
			ff = { // Friendly fire stats
				dmg = {
					Test1 = 25
				},
				incap = {
				},
				tk = {
				}
			},
			dmg = { // Damage dealt
				tanks = 752,
				witches = 3248
			},
			hits = { // Hits received
				infected = 16
			}
		}
	};
	*/
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
			infected = 0
		},
		specials = {
			dmg = 0,
			kills = 0,
			kills_hs = 0 // head shots
		}
	};
}

/**
 * Save data between maps
 */
function AdvStats::save()
{
	if (::ADV_STATS_DEBUG)
		printl("*** Saving stats...")

	if (::AdvStats.finale_win == true)
	{
		printl("     FINALE WIN !! Clearing stats....");
		::AdvStats.cache = {};
	}

	SaveTable("_adv_stats", ::AdvStats.cache)
	
	//if (::ADV_STATS_DEBUG)
	//	DeepPrintTable(::AdvStats.cache)
}

/**
 * Load data after a map load
 */
function AdvStats::load()
{
	if (::ADV_STATS_DEBUG)
		printl("*** Load stats...")
	
	RestoreTable("_adv_stats", ::AdvStats.cache)
	if (::AdvStats.cache.len() == 0)
		::AdvStats.init()
	
	//if (::ADV_STATS_DEBUG)
	//	DeepPrintTable(::AdvStats.cache)
}










/**
 * Called when a player leaves the start area
 *
 * NOTA: it seems to be called only when leaving the shelter of the first played map
 */
function OnGameEvent_player_left_start_area(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> player_left_start_area")
	
	clearHUD();
}

/**
 * Called when a player leaves a checkpoint
 *
 * NOTA: this function seems to be called when survivors spanw inside shelter,
 *       which is not helpful for clearing the HUD
 */
function OnGameEvent_player_left_checkpoint(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
	{
		printl(">>>>>>>>>>>>> player_left_checkpoint");
		if (::AdvStats.finale_win == true)
			printl("      Finale WIN!!!")
		else
			printl("      Not finale win...")
	}

	if (Director.HasAnySurvivorLeftSafeArea())
		clearHUD();
}



function OnGameEvent_final_reportscreen(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> final_reportscreen")
}

function OnGameEvent_finale_reportscreen(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> finale_reportscreen")
}

function OnGameEvent_finale_vehicle_ready(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> finale_vehicle_ready")
	
	::AdvStats.finale_win = true;
	
	showHUD();
}

function OnGameEvent_start_score_animation(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> start_score_animation")
}

function OnGameEvent_finale_escape_start(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> finale_escape_start")
	
	::AdvStats.finale_win = true;
	
	showHUD();
}

function OnGameEvent_finale_win(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> finale_win")
	
	::AdvStats.finale_win = true;
	
	showHUD();

	AdvStatsDebug()
}


/**
 * Hook before round starts
 */
function OnGameEvent_round_start_post_nav(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> round_start_post_nav")
	
	::AdvStats.load()
	
	showHUD()
	
	AdvStatsDebug()
}

/**
 * Hook when round ends
 */
function OnGameEvent_map_transition(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> map_transition")
	
	::AdvStats.save()
	
	AdvStatsDebug()
}

/**
 * Hook when round ends
 */
function OnGameEvent_mission_lost(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> mission_lost")
	
	::AdvStats.save()
	
	AdvStatsDebug()
}

/**
 * Hook when round ends
 */
function OnGameEvent_round_end(params)
{
	if (::ADV_STATS_DEBUG_EVENTS)
		printl(">>>>>>>>>>>>> round_end")
	
	::AdvStats.save()
	
	AdvStatsDebug()
}






/**
 * Called when an infected (infected, witch) is hurt
 */
function OnGameEvent_infected_hurt(params)
{
	if (::AdvStats.finale_win == true)
		return;

	if (!("attacker" in params && params.attacker != 0))
		return

	local victim = EntIndexToHScript(params.entityid)

/*
	printl("Name " + victim.GetName())
	printl("Health " + victim.GetHealth())
	printl("Classname " + victim.GetClassname())
*/

	if (victim.GetClassname() != "witch")
		return
	
	local attacker = GetPlayerFromUserID(params.attacker)
	if (!attacker.IsSurvivor())
		return
	
	local sAttName = attacker.GetPlayerName()
	
	// We don't want to store stats for bots
	if (::AdvStats.isBot(sAttName))
		return;

	if (::ADV_STATS_DEBUG)
	{
		printl("********** Witch Hurt **********")
		DeepPrintTable(params)
	}
	
	if (::ADV_STATS_DEBUG)
		printl("[ADV_STATS_EVENT] " + sAttName + " dealt " + params.amount + " to Witch")
	
	::AdvStats.initPlayerCache(sAttName);
	::AdvStats.cache[sAttName].dmg.witches += params.amount

	//if (::ADV_STATS_DEBUG)
	//	DeepPrintTable(::AdvStats.cache)
}




/**
 * Called when a player is dead
 */
function OnGameEvent_player_death(params)
{
	if (::AdvStats.finale_win == true)
		return;

	// We want only TK and killed SI
	//if (!("userid" in params && "attacker" in params && params.attacker != 0))
	if (params.attackerisbot == 1)
		return

	// We want only players kills
	local attacker = GetPlayerFromUserID(params.attacker)
	if (!attacker.IsSurvivor())
		return

	if (params.victimname == "Infected")
		return;


	if (::ADV_STATS_DEBUG)
	{
		printl("********** Player Death **********")
		printl("**********************************")
		DeepPrintTable(params)
	}
	
	local victim = GetPlayerFromUserID(params.userid)
 	printl(victim.GetPlayerName());


	//if (!victim.IsSurvivor())
	//	return

	local sAttName = attacker.GetPlayerName()//GetCharacterDisplayName(attacker)

	// We don't want to store stats for bots
	//if (::AdvStats.isBot(sAttName)) // NO NEED, already taken care of with params.attackerisbot
	//	return;

	local sVicName = victim.GetPlayerName()//GetCharacterDisplayName(victim)

	if (::ADV_STATS_DEBUG)
		printl("[ADV_STATS_EVENT] " + sAttName + " killed " + sVicName)

	// TK ...
	if (victim.IsSurvivor())
	{
		::AdvStats.initPlayerCache(sAttName);
		if (!(sVicName in ::AdvStats.cache[sAttName].ff.tk))
			::AdvStats.cache[sAttName].ff.tk[sVicName] <- 0
		::AdvStats.cache[sAttName].ff.tk[sVicName] += 1
	}
	else
	{
		// Special Infected killed
		if (::AdvStats.isSpecialInfected(sVicName))
		{
			::AdvStats.initPlayerCache(sAttName);
			::AdvStats.cache[sAttName].specials.kills += 1
			if (params.headshot == 1)
				::AdvStats.cache[sAttName].specials.kills_hs += 1
		}
	}

	AdvStatsDebug();

	//if (::ADV_STATS_DEBUG)
	//	DeepPrintTable(::AdvStats.cache)
}

/**
 * Called when a player is incapacitated
 */
function OnGameEvent_player_incapacitated(params)
{
	if (::AdvStats.finale_win == true)
		return;

	// We want only incap dealt by survivors
	if (!("userid" in params && "attacker" in params && params.attacker != 0))
		return
		
	local attacker = GetPlayerFromUserID(params.attacker)
	if (!attacker.IsSurvivor())
		return

	local victim = GetPlayerFromUserID(params.userid)
	if (!victim.IsSurvivor())
		return
	local sAttName = attacker.GetPlayerName()//GetCharacterDisplayName(attacker)

	// We don't want to store stats for bots
	if (::AdvStats.isBot(sAttName))
		return;
	
	local sVicName = victim.GetPlayerName()//GetCharacterDisplayName(victim)

	if (::ADV_STATS_DEBUG)
	{
		printl("********** Player Incapacitated **********")
		DeepPrintTable(params)
	}

	//FireGameEvent("game_message", {target = 1, text = sAttName + " incapacitatedss " + sVicName})
	//ShowMessage(sAttName + " incapacitatedss " + sVicName)

	if (::ADV_STATS_DEBUG)
		printl("[ADV_STATS_EVENT] " + sAttName + " incapacitated " + sVicName)
	
	::AdvStats.initPlayerCache(sAttName);
	if (!(sVicName in ::AdvStats.cache[sAttName].ff.incap))
		::AdvStats.cache[sAttName].ff.incap[sVicName] <- 0
	::AdvStats.cache[sAttName].ff.incap[sVicName] += 1
	
	//if (::ADV_STATS_DEBUG)
	//	DeepPrintTable(::AdvStats.cache)
}

/**
 * Called when a player got hurt
 */
function OnGameEvent_player_hurt(params)
{
	if (::AdvStats.finale_win == true)
		return;

	if (!params.rawin("userid") || ((!params.rawin("attackerentid") || params.attackerentid == 0) && params.attacker == 0))
		return


	if (::ADV_STATS_DEBUG)
	{
		printl("********** Player Hurt **********")
		DeepPrintTable(params)
	}
	
	local victim = GetPlayerFromUserID(params.userid)
	local sVicName = victim.GetPlayerName()//GetCharacterDisplayName(victim)

	printl("*******************")
	printl("***")
	printl(sVicName)
	printl("***")
	printl("*******************")

	
	// Not hit by a player (survivor, special infected, tank)
	if (!("attacker" in params && params.attacker != 0))
	{
		// We don't want to store stats for bots
		if (::AdvStats.isBot(sVicName))
			return;

		// Player hit by an infected or witch
		if ("attackerentid" in params && params.attackerentid != 0 && victim.IsSurvivor())
		{
			local infAttacker = EntIndexToHScript(params.attackerentid)
			// Do not count hits when we are incapacitated
			if (infAttacker.GetClassname() == "infected" && params.dmg_health != 0 && !victim.IsIncapacitated())
			{
				if (::ADV_STATS_DEBUG)
					printl("[ADV_STATS_EVENT] " + sVicName + " got hit by an infected for " + params.dmg_health + " points")
				::AdvStats.initPlayerCache(sVicName);
				::AdvStats.cache[sVicName].hits.infected += 1 //params.dmg_health
				
				//if (::ADV_STATS_DEBUG)
				//	DeepPrintTable(::AdvStats.cache)
			}
		}

		return
	}
	
	
	//
	// From now on we only take care with damage dealt by survivors
	//
	
	local attacker = GetPlayerFromUserID(params.attacker)
	if (!attacker.IsSurvivor())
		return

/*
	printl("Survivor " + victim.IsSurvivor())
	printl("Name " + victim.GetName())
	printl("Health " + victim.GetHealth())
	printl("Classname " + victim.GetClassname())
	printl("Playername " + victim.GetPlayerName())
*/

	local sAttName = attacker.GetPlayerName()//GetCharacterDisplayName(attacker)

	// We don't want to store stats for bots
	if (::AdvStats.isBot(sAttName))
		return;

	//
	// Damage to tanks
	//
	if (!victim.IsSurvivor())
	{
		if (sVicName == "Tank")
		{
			if (::ADV_STATS_DEBUG)
				printl("[ADV_STATS_EVENT] " + sAttName + " dealt " + params.dmg_health + " to Tank")
			
			::AdvStats.initPlayerCache(sAttName);
			::AdvStats.cache[sAttName].dmg.tanks += params.dmg_health

			//if (::ADV_STATS_DEBUG)
			//	DeepPrintTable(::AdvStats.cache)
		}
		else
		{
			// Damage to Special Infected
			if (::AdvStats.isSpecialInfected(sVicName))
			{
				::AdvStats.initPlayerCache(sAttName);
				::AdvStats.cache[sAttName].specials.dmg += params.dmg_health
			}
		}

		return
	}
	
	//
	// Damage to other players
	//
	if (::ADV_STATS_DEBUG)
		printl("[ADV_STATS_EVENT] " + sAttName + " hurt " + sVicName + " for " + params.dmg_health + " HP")

/*
	printl("Vic health : " + victim.GetHealth())
	printl("Vic is incap : " + victim.IsIncapacitated())
	printl("Vic is dying : " + victim.IsDying())
	printl("Vic is dead : " + victim.IsDead())
*/

	::AdvStats.initPlayerCache(sAttName);
	if (!(sVicName in ::AdvStats.cache[sAttName].ff.dmg))
		::AdvStats.cache[sAttName].ff.dmg[sVicName] <- 0
	::AdvStats.cache[sAttName].ff.dmg[sVicName] += params.dmg_health

	//if (::ADV_STATS_DEBUG)
	//	DeepPrintTable(::AdvStats.cache)
}












/*
function OnGameEvent_game_init(params)
{
	printl("************** game_init")
	DeepPrintTable(params)
}

function OnGameEvent_game_newmap(params)
{
	printl("************** game_newmap")
	DeepPrintTable(params)
}

function OnGameEvent_game_start(params)
{
	printl("************** game_start")
	DeepPrintTable(params)
}

function OnGameEvent_game_end(params)
{
	printl("************** game_end")
	DeepPrintTable(params)
}
*/

/*
function OnGameEvent_player_first_spawn(params)
{
	local user = GetPlayerFromUserID(params.userid)
	if (!user.IsSurvivor())
		return

	printl("************** player_first_spawn")
	DeepPrintTable(params)
}
*/

/*
function OnGameEvent_round_start(params)
{
	printl("************** round_start")
	DeepPrintTable(params)
}
*/
