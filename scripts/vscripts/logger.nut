class Logger
{
    // available log levels
	static levels = {
		info = 1,
		debug = 2
	};
	
	// all messages from AdvStats will be prefixed by this text 
	static log_prefix = "[ADV_STATS] ";

	function info(message)
	{
		if (!(::ADV_STATS_LOG_LEVEL >= levels.info))
		    return
		
		printl(log_prefix + "[INFO] " + message);
	}
	
	function debug(message, params = null)
	{
		if (!(::ADV_STATS_LOG_LEVEL >= levels.debug))
		    return
			
		printl(log_prefix + "[DEBUG] " + message);
		
		if (!params)
		    return

		// @TODO find a way to access to the DeepPrintTable method from here
 		//DeepPrintTable(params);
	}
}