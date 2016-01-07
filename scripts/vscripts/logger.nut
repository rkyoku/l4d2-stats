class Logger
{
    // Available log levels
	static levels = {
		info = 1,
		debug = 2
	};
	
	// Prefix text for all logs
	static log_prefix = "[ADV_STATS]";
	
	constructor(level)
	{
		currentLevel = level;
	}

	function info(message)
	{
		if (!(currentLevel >= levels.info))
		    return;
		
		printl(log_prefix + "[INFO] " + message);
	}
	
	function debug(message, params = null)
	{
		if (!(currentLevel >= levels.debug))
		    return;
			
		printl(log_prefix + "[DEBUG] " + message);
		
		if (!params)
		    return;

		g_ModeScript.DeepPrintTable(params);
	}
	
	currentLevel = 0;
}