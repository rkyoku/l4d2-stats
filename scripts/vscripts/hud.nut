function subPseudo(sPseudo)
{
	if (sPseudo.len() < 9)
		return sPseudo;

	return sPseudo.slice(0, 8);
}

function sortTable(aTable, bMinFirst = true)
{
	local sMax = null;
	local sIdx = null;
	local iVal = null;
	local iMax = null;
	local aSorted = [];
	local aAdded = {};
	local iNb = aTable.len();
	local i;
	
	for (i = 0; i < iNb; i += 1)
	{
		iMax = null;
		sMax = null;
		foreach (sIdx, iVal in aTable)
		{
			if (aAdded.rawin(sIdx))
				continue;
			if (iMax == null || (!bMinFirst && iVal > iMax) || (bMinFirst && iVal < iMax))
			{
				sMax = sIdx;
				iMax = iVal;
			}
		}
		aAdded[sMax] <- 1;
		aSorted.append({key = sMax, value = iMax});
	}
	
	return aSorted;
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
 * Sum the damage done
 */
function sortForFFDmg()
{
	local aStats = {}, sPlayer = null, aData = null;
	
	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats[sPlayer] <- sumTable(aData.ff.dmg);
	
	return sortTable(aStats, false);
}

/**
 * Sum the damage dealt to Special Infected
 */
function sortForSIDmg()
{
	local aStats = {}, sPlayer = null, aData = null;
	
	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats[sPlayer] <- aData.specials.dmg;
	
	return sortTable(aStats, false);
}

/**
 * Sum the damage dealt to Common Infected
 */
function sortForCIHits()
{
	local aStats = {}, sPlayer = null, aData = null;

	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats[sPlayer] <- aData.hits.infected;

	return sortTable(aStats, true);
}

/**
 * Sum the damage dealt to Tanks and Witches
 */
function sortForDmgDealt()
{
	local aStats = {}, sPlayer = null, aData = null;

	foreach (sPlayer, aData in ::AdvStats.cache)
		aStats[sPlayer] <- aData.dmg.tanks + aData.dmg.witches;

	return sortTable(aStats, false);
}

/**
 * Compiling FF damage stats
 */
function compileStatsFF()
{
	local sRes = "";
	local aTmp = {}, aFFDMG = {};
	local iIdx = 0;
	local sPlayer = null;
	
	aFFDMG = sortForFFDmg();
	foreach (iIdx, aTmp in aFFDMG)
	{
		sPlayer = aTmp.key;
		/*sRes += (iIdx + 1) + ". " + sPlayer + " : " + aTmp.value
				+ " / " + sumTable(::AdvStats.cache[sPlayer].ff.incap)
				+ " / " + sumTable(::AdvStats.cache[sPlayer].ff.tk)
				+ "\n";*/
		sRes += subPseudo(sPlayer) + ": " + aTmp.value
				+ ", " + sumTable(::AdvStats.cache[sPlayer].ff.incap)
				+ ", " + sumTable(::AdvStats.cache[sPlayer].ff.tk)
				+ "\n";
	}
	
	return sRes == "" ? "No Stats Yet" : "FF (Dmg, Incap, TK)\n" + sRes;
}

/**
 * Compiling special infected stats
 */
function compileStatsSI()
{
	local sRes = "";
	local aTmp = {}, aTable = {};
	local iIdx = 0;
	local sPlayer = null;
	
	aTable = sortForSIDmg();
	foreach (iIdx, aTmp in aTable)
	{
		sPlayer = aTmp.key;
		sRes += subPseudo(sPlayer) + ": "
				+ ::AdvStats.cache[sPlayer].specials.kills
				+ ", " + ::AdvStats.cache[sPlayer].specials.kills_hs
				+ ", " + ::AdvStats.cache[sPlayer].specials.dmg
				+ "\n";
	}
		/*sRes += (iIdx + 1) + ". " + aTmp.key + " : " + aTmp.value + "\n";*/

	return sRes == "" ? "No Stats Yet" : "SI (Kills, HS, Dmg)\n" + sRes;
}

/**
 * Compiling common infected stats
 */
function compileStatsCI()
{
	local sRes = "";
	local aTmp = {}, aTable = {};
	local iIdx = 0;
	local sPlayer = null;
	
	aTable = sortForCIHits();
	foreach (iIdx, aTmp in aTable)
	{
		sPlayer = aTmp.key;
		sRes += subPseudo(sPlayer) + ": "
				+ aTmp.value
				+ ", " + ::AdvStats.cache[sPlayer].hits.si_hits
				+ ", " + ::AdvStats.cache[sPlayer].hits.si_dmg
				+  "\n";
	}

	return sRes == "" ? "No Stats Yet" : "Hits (Zs, SI) / Dmg (SI)\n" + sRes;
}

/**
 * Compiling damage received
 */
function compileStatsDMG()
{
	local sRes = "";
	local aTable = {}, aTmp = {};
	local iIdx = 0, sPlayer = null;
	
	aTable = sortForDmgDealt();
	foreach (iIdx, aTmp in aTable)
	{
		sPlayer = aTmp.key;
		/*sRes += (iIdx + 1) + ". " + sPlayer + " : "
				+ ::AdvStats.cache[sPlayer].dmg.tanks
				+ " / " + ::AdvStats.cache[sPlayer].dmg.witches
				+ "\n";*/
		sRes += subPseudo(sPlayer) + ": "
				+ ::AdvStats.cache[sPlayer].dmg.tanks
				+ ", " + ::AdvStats.cache[sPlayer].dmg.witches
				+ "\n";
	}
	
	return sRes == "" ? "No Stats Yet" : "Dmg (Tanks, Witches)\n" + sRes;
}

/**
 * Clear the HUD
 */
function clearHUD()
{
	::ADV_STATS_LOGGER.debug("HUD clearHUD")

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
	
	::ADV_STATS_LOGGER.debug("HUD cleared");
}

/**
 * Show the HUD
 */
function showHUD()
{
    ::ADV_STATS_LOGGER.debug("HUD showHUD");

	if (::AdvStats.hud_visible == true)
		return;

	//datafunc = @() g_ModeScript.compileStats()
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

HUDSetLayout(advStatsHUD)