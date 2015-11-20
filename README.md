L4D2 Advanced Stats
===================

L4D2 Advanced Stats is a small plugin for displaying various server-generated stats about friendly fire, special infected kills, etc.

Install
-------

Copy these files in a directory placed into your L4D2 addons directory.
Example on Windows: C:\Program Files (x86)\Steam\SteamApps\common\left 4 dead 2\left4dead2\addons\advstats

Then launch the game.

Bugs
----

* Script's damage to Tanks does not match game-computed values
* Sometimes the event 'incapacitated' happens after only 4 zombie hits (events) instead of five
* Right after the finale_win event, it seems that the HUD is removed. Must find a way around that (event before finale_win?)
* When using a 'Lee' mod (for Coach) the stats do not save for Lee...