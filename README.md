L4D2 Advanced Stats
===================

A small plugin for displaying various server-generated stats about friendly fire, special infected kills, etc. 

# Bugs

* Script's damage to Tanks does not match game-computed values
* Sometimes the event 'incapacitated' happens after only 4 zombie hits (events) instead of five
* Right after the finale_win event, it seems that the HUD is removed. Must find a way around that (event before finale_win?)
* When using a 'Lee' mod (for Coach) the stats do not save for Lee...