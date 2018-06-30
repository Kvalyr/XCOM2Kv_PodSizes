Configurable Pod Sizes by Kvalyr
=== FAQ ===
Q: What are pods?
A: Pods are the 'groups' of enemies you encounter in tacical missions. Normally they can range in size from a single unit to a dozen, depending on difficulty and the type of enemy units in that pod.

Q: What does this mod do?
A: Each pod has a list of enemies that it can contain (from Troopers to Andromedons, and even The Lost and The Chosen). 
All pods have a 'MaxSpawnCount' that determines how many enemies should spawn for that pod. This mod lets you scale the 'MaxSpawnCount' for all pods in the game by a multiplier. e.g.; Set the multiplier to 1.5 in the mod options to get 50% bigger pods. It also includes filters, so that you can ignore pods designed to only spawn 1 unit ever (such as bosses), or ignore pods that spawn friendly resistance units on terror missions.

Q: How does this mod work?
A: Most pod modificationss work through adjustments to DefaultEncounters/XComEncounters.ini, with painstaking, manual editing by the modder to make targeted changes. This mod instead looks at what pods have been defined in the ini files and loaded by the game, modifies the data dynamically in-memory (instead of in .ini files) according to your options.

Q: Why does this need the highlander? Other mods that modify pods don't.
A: Dynamically modifying the Encounter definitions was made by possible by changes in the Community Highlander. Those changes give modders better access to things in game memory than Firaxis' original code allows us to do.

Q: Will this mess with my ini files?
A: No. This mod doesn't write any new data to ini files. It just looks at what has been loaded already and modifies it in-memory. When you exit the game, everything goes back to defaults (or back to whatever pods you've got from another mod).

=== Requirements ===
* Requires WOTC.
* Requires XCOM2 Community Highlander: https://steamcommunity.com/sharedfiles/filedetails/?id=1134256495
* Requires MCM: https://steamcommunity.com/sharedfiles/filedetails/?id=667104300

If you experience crashes, double-check that the Community Highlander is installed. This mod absolutely will not work without it.

=== Compatibility ===
* Does NOT require a new game. Removing this mod should also restore Pod sizes to their defaults in an ongoing game.

* This mod applies its affects AFTER .ini files have been loaded. It should not have ini conflicts with mods that add or remove Encounters/Pods.

  * That means that this mod IS compatible with other mods that adjust pod sizes, such as "[WOTC] Larger Enemy Pods" by Charmed: https://steamcommunity.com/sharedfiles/filedetails/?id=1125516692 

=== How to use ===
* Adjust values using the Mod Configuration Menu (link above). 

* This mod won't have any perceptible effect on your game unless you change some of its default values.

=== Known Issues: ===
* PodSizeMappings in this mod's .ini currently have no effect. Feature will be restored later.

=== Planned Features: ===
* Adjust pod sizes by their EncounterID

* Add/Remove ForceSpawnTemplateNames to Pods by EncounterID

* Filter by individual unit types in settings. (E.g.; "Don't adjust Chryssalid pods", etc.)

https://github.com/Kvalyr/XCOM2Kv_PodSizes