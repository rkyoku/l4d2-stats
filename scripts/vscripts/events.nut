/**
 * Called when a player spawns for the first time 
 * It concerns players, but also special infected, bots...
 *
 * NOTA: At a map transition, the event is fired for the first time when a
 * special infected spawns
 */
function OnGameEvent_player_first_spawn(params)
{
	::ADV_STATS_LOGGER.debug("Event player_first_spawn");
	
	if (::AdvStats.current_map)
		return;
	
	::AdvStats.current_map = params.map_name;
	::ADV_STATS_LOGGER.info("Map changed to " + ::AdvStats.current_map);
}

/**
 * Called when a player leaves a checkpoint
 *
 * NOTA: this function seems to be called when survivors spawn inside shelter,
 *       which is not helpful for clearing the HUD
 */
function OnGameEvent_player_left_checkpoint(params)
{
	::ADV_STATS_LOGGER.debug("Event player_left_checkpoint");

	if (!Director.HasAnySurvivorLeftSafeArea())
		return;
	
	clearStatsHUD();
	
	if (!::AdvStats.welcome_hud_visible)
		return;

	clearWelcomeHUD();
	createStatsHUD();
}

function OnGameEvent_finale_vehicle_leaving(params)
{
	::ADV_STATS_LOGGER.debug("Event finale_vehicle_leaving");
	
	::AdvStats.endgame_hud_triggered = true;
	showStatsHUD();
}

function OnGameEvent_finale_win(params)
{
	::ADV_STATS_LOGGER.debug("Event finale_win");
	
	::AdvStats.finale_win = true;
	::AdvStats.endgame_hud_triggered = true;
	showStatsHUD();

	AdvStatsDebug();
	
	::ADV_STATS_LOGGER.info("Finale win!");
}

/**
 * Hook before round starts
 */
function OnGameEvent_round_start_post_nav(params)
{
	::ADV_STATS_LOGGER.debug("Event round_start_post_nav");
	
	::AdvStats.load();
	AdvStatsDebug();
	
	if (::AdvStats.cache.len()) {
		showStatsHUD();
	} else {
		// Replace the stats HUD by the welcome HUD for the first map, when no stats have been stored yet
		createWelcomeHUD();
		::AdvStats.welcome_hud_visible = true;
	}
}

/**
 * Hook when round ends
 */
function OnGameEvent_map_transition(params)
{
	::ADV_STATS_LOGGER.debug("Event map_transition");
	
	::AdvStats.save();
	
	AdvStatsDebug();
}

/**
 * Hook when round ends
 */
function OnGameEvent_mission_lost(params)
{
	::ADV_STATS_LOGGER.debug("Event mission_lost");
	
	::AdvStats.save();
	
	AdvStatsDebug();
}

/**
 * Hook when round ends
 */
function OnGameEvent_round_end(params)
{
	::ADV_STATS_LOGGER.debug("Event round_end");
	
	::AdvStats.save();
	
	AdvStatsDebug();
}

/**
 * Called when an infected (infected, witch) is hurt
 */
function OnGameEvent_infected_hurt(params)
{
	::ADV_STATS_LOGGER.debug("Event infected_hurt");

	if (::AdvStats.finale_win == true)
		return;

	if (!("attacker" in params && params.attacker != 0))
		return

	local victim = EntIndexToHScript(params.entityid)
	if (victim.GetClassname() != "witch")
		return
	
	local attacker = GetPlayerFromUserID(params.attacker)
	if (!attacker.IsSurvivor())
		return
	
	local sAttName = attacker.GetPlayerName()
	
	// Bots
	if (!::ADV_STATS_BOTS_DISPLAY && ::AdvStats.isBot(sAttName))
		return;
	if (::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT && ::ADV_STATS_BOTS.L4D1.find(sAttName) != null)
		return;
		
	if (params.amount > victim.GetHealth())
		::ADV_STATS_LOGGER.debug("Witch damage error: " + params.amount + " > " + victim.GetHealth());

	::AdvStats.initPlayerCache(sAttName);
	::AdvStats.cache[sAttName].dmg.witches += params.amount;
	
	::ADV_STATS_LOGGER.info(sAttName + " dealt " + params.amount + " to a Witch");
}

/**
 * Called when a player is dead
 *
 * NOTA: this event is also fired for a special infected, a common infected, a witch, a tank...
 */
function OnGameEvent_player_death(params)
{
    ::ADV_STATS_LOGGER.debug("Event player_death");

	if (::AdvStats.finale_win == true)
		return;

	// We want only survivors
	if (!("userid" in params && "attacker" in params && params.attacker != 0))
		return;
	
	if (params.victimname == "Infected")
		return;
	
	if (params.victimname == "Witch" || params.victimname == "Tank") {
		::ADV_STATS_LOGGER.debug("A " +  params.victimname + " was killed");
		
		return;
	}
		
	// We want only players kills
	local attacker = GetPlayerFromUserID(params.attacker);
	if (!attacker.IsSurvivor())
		return

	local victim = GetPlayerFromUserID(params.userid);
	local sAttName = attacker.GetPlayerName();
	local sVicName = victim.GetPlayerName();

	// Team Kill
	if (victim.IsSurvivor())
	{
		// Bots
		if ((!::ADV_STATS_BOTS_DISPLAY && ::AdvStats.isBot(sAttName)) || (!::ADV_STATS_FF_BOTS_ENABLED && AdvStats.isBot(sVicName)))
			return;
		if (::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT && ::ADV_STATS_BOTS.L4D1.find(sAttName) != null)
			return;

		::AdvStats.initPlayerCache(sAttName);
		if (!(sVicName in ::AdvStats.cache[sAttName].ff.tk))
			::AdvStats.cache[sAttName].ff.tk[sVicName] <- 0;

		::AdvStats.cache[sAttName].ff.tk[sVicName] += 1;
		
		::ADV_STATS_LOGGER.info(sAttName + " killed teammate " + sVicName);
	}
	else
	{
		// Special Infected killed
		if (::AdvStats.isSpecialInfected(sVicName))
		{
			// Bots
			if (!::ADV_STATS_BOTS_DISPLAY && ::AdvStats.isBot(sAttName))
				return;
			if (::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT && ::ADV_STATS_BOTS.L4D1.find(sAttName) != null)
				return;
			
			::AdvStats.initPlayerCache(sAttName);
			::AdvStats.cache[sAttName].specials.kills += 1;
			if (params.headshot == 1)
				::AdvStats.cache[sAttName].specials.kills_hs += 1;
		}
		
		::ADV_STATS_LOGGER.info(sAttName + " killed a " + sVicName);
	}
}

/**
 * Called when a player is incapacitated
 */
function OnGameEvent_player_incapacitated(params)
{
    ::ADV_STATS_LOGGER.debug("Event player_incapacitated");

	if (::AdvStats.finale_win == true)
		return;

	// We want only players incapacitated by survivors
	if (!("userid" in params && "attacker" in params && params.attacker != 0))
		return
		
	local attacker = GetPlayerFromUserID(params.attacker)
	if (!attacker.IsSurvivor())
		return

	local victim = GetPlayerFromUserID(params.userid)
	if (!victim.IsSurvivor())
		return;

	local sAttName = attacker.GetPlayerName();
	local sVicName = victim.GetPlayerName();
	
	::ADV_STATS_LOGGER.debug("Player Incapacitated", params);
	
	// Bots
	if ((!::ADV_STATS_BOTS_DISPLAY && ::AdvStats.isBot(sAttName)) || (!::ADV_STATS_FF_BOTS_ENABLED && AdvStats.isBot(sVicName)))
		return;
	if (::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT && ::ADV_STATS_BOTS.L4D1.find(sAttName) != null)
		return;

	::AdvStats.initPlayerCache(sAttName);
	if (!(sVicName in ::AdvStats.cache[sAttName].ff.incap))
		::AdvStats.cache[sAttName].ff.incap[sVicName] <- 0;
	::AdvStats.cache[sAttName].ff.incap[sVicName] += 1;
	
	::ADV_STATS_LOGGER.info(sAttName + " incapacitated " + sVicName);
}

/**
 * Called when a player got hurt
 */
function OnGameEvent_player_hurt(params)
{
	::ADV_STATS_LOGGER.debug("Event player_hurt");

	if (::AdvStats.finale_win == true)
		return;

	if (!params.rawin("userid") || ((!params.rawin("attackerentid") || params.attackerentid == 0) && params.attacker == 0))
		return
	
	local victim = GetPlayerFromUserID(params.userid)
	local sVicName = victim.GetPlayerName()

	::ADV_STATS_LOGGER.debug("Victim name: " + sVicName);

	// Not hit by a player (survivor, special infected, tank)
	if (!("attacker" in params && params.attacker != 0))
	{
		// Bots
		if (!::ADV_STATS_BOTS_DISPLAY && ::AdvStats.isBot(sVicName))
			return;
		if (::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT && ::ADV_STATS_BOTS.L4D1.find(sVicName) != null)
			return;
	
		// Player hit by an infected or witch
		if ("attackerentid" in params && params.attackerentid != 0 && victim.IsSurvivor())
		{
			local infAttacker = EntIndexToHScript(params.attackerentid)
			// Do not count hits when we are incapacitated
			if (infAttacker.GetClassname() == "infected" && params.dmg_health != 0 && !victim.IsIncapacitated())
			{
				::AdvStats.initPlayerCache(sVicName);
				::AdvStats.cache[sVicName].hits.infected += 1;
			}

			::ADV_STATS_LOGGER.info(sVicName + " got hit by an infected for " + params.dmg_health + " HP");
		}

		return
	}
	
	local attacker = GetPlayerFromUserID(params.attacker);
	local sAttName = attacker.GetPlayerName();
	
	// Damage dealt by special infected. Beware: special infected are also Players
	if (!::AdvStats.isSpecialInfected(sVicName) && ::AdvStats.isSpecialInfected(sAttName) && params.dmg_health != 0 && !victim.IsIncapacitated() && sVicName != "tank")
	{
		// Bots
		if (!::ADV_STATS_BOTS_DISPLAY && ::AdvStats.isBot(sVicName))
			return;
		if (::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT && ::ADV_STATS_BOTS.L4D1.find(sVicName) != null)
			return;

		::AdvStats.initPlayerCache(sVicName);
		::AdvStats.cache[sVicName].hits.si_dmg += params.dmg_health;
		::AdvStats.cache[sVicName].hits.si_hits += 1;
		
		::ADV_STATS_LOGGER.info(sVicName + " received damage by a " + sAttName + " for " + params.dmg_health + " HP");
		
		return;
	}

	//
	// From now on we only take care with damage dealt by survivors
	//

	if (!attacker.IsSurvivor())
	{
		::ADV_STATS_LOGGER.debug("Attacker is not a survivor");

		return;
	}

	local sAttName = attacker.GetPlayerName();

	// Bots
	if (!::ADV_STATS_BOTS_DISPLAY && ::AdvStats.isBot(sAttName))
		return;
	if ((::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT) && ::ADV_STATS_BOTS.L4D1.find(sAttName) != null)
		return;	

	//
	// Damage to tanks and special infected
	//

	if (!victim.IsSurvivor())
	{
		local damageDone = 0;
		if (params.dmg_health > params.health)
			damageDone = params.health;
		else
			damageDone = params.dmg_health;
		
		::AdvStats.initPlayerCache(sAttName);	

		if (sVicName == "Tank") {
			::AdvStats.cache[sAttName].dmg.tanks += damageDone;
		} else if (::AdvStats.isSpecialInfected(sVicName)) {
			::AdvStats.cache[sAttName].specials.dmg += damageDone;
			
			if (::AdvStats.cache[sAttName].specials.seen.find(params.userid) == null) {
				::AdvStats.cache[sAttName].specials.seen.append(params.userid);
				::ADV_STATS_LOGGER.debug(sAttName + " has seen a " + sVicName);
			}
		}

		::ADV_STATS_LOGGER.info(sAttName + " dealt " + damageDone + " to a " + sVicName);

		return;
	}
	
	//
	// Damage to other players
	//

	// Bots
	if (!::ADV_STATS_FF_BOTS_ENABLED && ::AdvStats.isBot(sVicName))
		return;
	if (::AdvStats.current_map == ::ADV_STATS_MAP_PASSING_PORT && ::ADV_STATS_BOTS.L4D1.find(sVicName) != null)
		return;
	
	::AdvStats.initPlayerCache(sAttName);
	if (!(sVicName in ::AdvStats.cache[sAttName].ff.dmg))
		::AdvStats.cache[sAttName].ff.dmg[sVicName] <- 0;

	if (!::ADV_STATS_SELF_FF_ENABLED && sAttName == sVicName)
		return;

	::AdvStats.cache[sAttName].ff.dmg[sVicName] += params.dmg_health;
	
	::ADV_STATS_LOGGER.info(sAttName + " hurt teammate " + sVicName + " for " + params.dmg_health + " HP");
}

/*
 * Fired when survivors die or when a vote to return to lobby passes
 */
function OnGameEvent_round_end(params)
{
	::ADV_STATS_LOGGER.debug("Event round_end");
	
	if (params.reason != 3)
		return;
	
	::AdvStats.cache = {};
	::ADV_STATS_LOGGER.info("Return to lobby vote passed. Clearing stats...");
}
