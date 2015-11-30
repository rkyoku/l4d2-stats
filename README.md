L4D2 Advanced Stats
===================

*L4D2 Advanced Stats is a plugin that displays better stats at map transitions and end games.*

Features
--------

* Advanced stats display for coop and realism game modes
* Friendly Fire (damage, incapacitated, team kills)
* Damage done to special infected
* Damage done to Tanks and Witches
* Damage received by common and special infected
* Configurable by editing plugin's files

Install
-------

Download the vpk.exe file located in the dist folder.

Copy this file in your L4D2 addons folder.

Example on Windows: C:\Program Files (x86)\Steam\SteamApps\common\left 4 dead 2\left4dead2\addons\advstats

Launch the game and activate the addon if not already activated.

Contributing
------------

Feel free to contribute to this project and open pull requests.

Copy these files in a directory placed into your L4D2 addons directory.

Example on Windows: C:\Program Files (x86)\Steam\SteamApps\common\left 4 dead 2\left4dead2\addons\

```bash
git clone git@github.com:RenaudParis/l4d2-stats.git
```

### Usage

Change these settings at your own convenience:

```squirrel
::ADV_STATS_BOTS_DISPLAY <- true 		// Activate the display of the bots' stats
::ADV_STATS_FF_BOTS_ENABLED <- true 	// Activate FF done to bots
```

Bugs
----

* Script's damage to Tanks and Witches does not match game-computed values
* Sometimes the event 'incapacitated' happens after only 4 zombie hits (events) instead of five
* When using a survivor mod (for example, 'Lee' for Coach) the stats do not save for Lee.


License
-------

Copyright (c) 2015 RenaudParis.
This content is released under [the MIT license](https://github.com/RenaudParis/l4d2-stats/blob/master/LICENSE).