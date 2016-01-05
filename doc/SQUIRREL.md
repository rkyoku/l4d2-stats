Squirrel
========

Documentation about Squirrel programming language can be found here:

* [Squirrel](http://squirrel-lang.org/)
* [Squirrel 2.2 Reference Manual](http://squirrel-lang.org/doc/squirrel2.html)
* [Squirrel Programming Guide](https://electricimp.com/docs/squirrel/squirrelcrib/)


Useful functions for debugging purposes
---------------------------------------

```squirrel
local victim = EntIndexToHScript(params.entityid)
printl("Name " + victim.GetName())
printl("Health " + victim.GetHealth())
printl("Classname " + victim.GetClassname())
printl("Survivor " + victim.IsSurvivor())
printl("Playername " + victim.GetPlayerName())
printl("Vic is incap : " + victim.IsIncapacitated())
printl("Vic is dying : " + victim.IsDying())
printl("Vic is dead : " + victim.IsDead())

local attacker = GetPlayerFromUserID(params.attacker)
printl(attacker.GetPlayerName())
printl(GetCharacterDisplayName(attacker))
```