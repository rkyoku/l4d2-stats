function createWelcomeHUD()
{
	::ADV_STATS_LOGGER.debug("createWelcomeHUD");

	WelcomeHUD <-
	{
	   Fields = 
	   {
		  version = {slot = HUD_LEFT_TOP, dataval = "L4D2 Advanced Stats\nversion 0.4", name = "version", flags = HUD_FLAG_NOBG | HUD_FLAG_ALIGN_LEFT}
	   }
	}

	HUDSetLayout(WelcomeHUD);
}

function clearWelcomeHUD()
{
	::ADV_STATS_LOGGER.debug("clearWelcomeHUD");
	
	if (!WelcomeHUD)
		return;
	
	WelcomeHUD.Fields.version.dataval = "";
	WelcomeHUD.Fields.version.flags = HUD_FLAG_NOBG | HUD_FLAG_NOTVISIBLE;
}

function subPseudo(sPseudo)
{
	if (sPseudo.len() < 9)
		return sPseudo;

	return sPseudo.slice(0, 8);
}

/**
 * Sum the items inside the table
 */
function sumTable(aTable)
{
	local iTotal = 0, sPlayer = null, iVal = null;

	foreach (sPlayer, iVal in aTable)
		iTotal += iVal

	return iTotal;
}

/**
 * asc sort
 */
function ascComparison(a, b)
{
	if (a.value > b.value)
		return 1;
	else if(a.value < b.value)
		return -1;

	return 0;
}

/**
 * desc sort
 */
function descComparison(a, b)
{
	if (a.value < b.value)
		return 1;
	else if(a.value > b.value)
		return -1;

	return 0;
}

/**
 * Compiling Friendly Fire stats
 */
function compileStatsFF()
{
	local result = "", aStats = [], sPlayer = null, aData = null;
	
	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats.append({ name = sPlayer, value = sumTable(aData.ff.dmg) });
		
	aStats.sort(ascComparison);
	
	foreach (aStat in aStats)
		result += subPseudo(aStat.name) + ": "
				+ aStat.value
				+ ", " + sumTable(::AdvStats.cache[aStat.name].ff.incap)
				+ ", " + sumTable(::AdvStats.cache[aStat.name].ff.tk)
				+ "\n";

	return "FF (Dmg, Incap, TK)\n" + result;
}

/**
 * Compiling Special Infected stats
 */
function compileStatsSI()
{
	local result = "", aStats = [], sPlayer = null, aData = null;
	
	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats.append({ name = sPlayer, value = aData.specials.dmg });
	
	aStats.sort(descComparison);
		
	foreach (aStat in aStats)
		result += subPseudo(aStat.name) + ": "
				+ aStat.value
				+ ", " + ::AdvStats.cache[aStat.name].specials.kills
				+ ", " + ::AdvStats.cache[aStat.name].specials.kills_hs
				+ "\n";

	return "SI (Dmg, Kills, HS)\n" + result;
}

/**
 * Compiling Common Infected stats
 */
function compileStatsCI()
{
	local result = "", aStats = [], sPlayer = null, aData = null;
		  
	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats.append({ name = sPlayer, value = aData.hits.infected });
	
	aStats.sort(ascComparison);

	foreach (aStat in aStats)
		result += subPseudo(aStat.name) + ": "
				+ aStat.value
				+ ", " + ::AdvStats.cache[aStat.name].hits.si_dmg
				+  "\n";

	return "Hits CI, Damage SI\n" + result;
}

/**
 * Compiling Tanks and Witches damage dealt
 */
function compileStatsDMG()
{
	local result = "", aStats = [], sPlayer = null, aData = null;
	
	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats.append({ name = sPlayer, value =  aData.dmg.tanks + aData.dmg.witches });
	
	aStats.sort(descComparison);
	
	foreach (aStat in aStats)
		result += subPseudo(aStat.name) + ": "
				+ ::AdvStats.cache[aStat.name].dmg.tanks
				+ ", " + ::AdvStats.cache[aStat.name].dmg.witches
				+ "\n";
	
	return "Dmg (Tanks, Witches)\n" + result;
}

/**
 * Clear the HUD
 */
function clearHUD()
{
	::ADV_STATS_LOGGER.debug("clearHUD");

	if (::AdvStats.hud_visible == false || ::AdvStats.finale_win == true)
		return;

	local sField, aData;
	
	advStatsHUD.Fields.ff.dataval = "";
	advStatsHUD.Fields.ci.dataval = "";
	advStatsHUD.Fields.dmg.dataval = "";
	advStatsHUD.Fields.si.dataval = "";
	
	advStatsHUD.Fields.ff.flags = HUD_FLAG_NOBG | HUD_FLAG_NOTVISIBLE;
	advStatsHUD.Fields.ci.flags = HUD_FLAG_NOBG | HUD_FLAG_NOTVISIBLE;
	advStatsHUD.Fields.dmg.flags = HUD_FLAG_NOBG | HUD_FLAG_NOTVISIBLE;
	advStatsHUD.Fields.si.flags = HUD_FLAG_NOBG | HUD_FLAG_NOTVISIBLE;
	
	::AdvStats.hud_visible = false;
}

/**
 * Show the HUD
 */
function showHUD()
{
    ::ADV_STATS_LOGGER.debug("showHUD");

	if (::AdvStats.hud_visible == true)
		return;

	advStatsHUD.Fields.ff.dataval = g_ModeScript.compileStatsFF();
	advStatsHUD.Fields.ci.dataval = g_ModeScript.compileStatsCI();
	advStatsHUD.Fields.dmg.dataval = g_ModeScript.compileStatsDMG();
	advStatsHUD.Fields.si.dataval = g_ModeScript.compileStatsSI();
	
	advStatsHUD.Fields.ff.flags = HUD_FLAG_NOBG;
	advStatsHUD.Fields.ci.flags = HUD_FLAG_NOBG;
	advStatsHUD.Fields.dmg.flags = HUD_FLAG_NOBG;
	advStatsHUD.Fields.si.flags = HUD_FLAG_NOBG;

	::AdvStats.hud_visible = true;
}

function createHUD()
{
	::ADV_STATS_LOGGER.debug("createHUD");

	HUDPlace(HUD_LEFT_TOP, 0, 0.01, 0.3, 0.2)
	HUDPlace(HUD_MID_TOP, 0.4, 0.01, 0.2, 0.2)
	HUDPlace(HUD_RIGHT_TOP, 0.7, 0.01, 0.3, 0.2)
	HUDPlace(HUD_FAR_LEFT, 0, 0.4, 0.3, 0.2)

	advStatsHUD <-
	{
	   Fields = 
	   {
		  ff = {slot = HUD_LEFT_TOP, dataval = "", name = "ff", flags = HUD_FLAG_NOBG},
		  ci = {slot = HUD_MID_TOP, dataval = "", name = "ci", flags = HUD_FLAG_NOBG},
		  dmg = {slot = HUD_RIGHT_TOP, dataval = "", name = "dmg", flags = HUD_FLAG_NOBG},
		  si = {slot = HUD_FAR_LEFT, dataval = "", name = "si", flags = HUD_FLAG_NOBG}
	   }
	}

	HUDSetLayout(advStatsHUD);
}