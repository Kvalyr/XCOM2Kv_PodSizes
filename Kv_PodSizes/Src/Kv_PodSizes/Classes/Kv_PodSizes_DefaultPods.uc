class Kv_PodSizes_DefaultPods extends Object config(Kv_PS_DefaultPods);

// Load a copy of the ConfigurableEncounters list from ini so we can restore from it later when we need to modify clean instances of the Encounter definitions
var config(Encounters) array<ConfigurableEncounter> ConfigurableEncounters;
var config(EncounterLists) array<SpawnDistributionList> SpawnDistributionLists;

function SaveDefaultPods(array<ConfigurableEncounter> NewConfigurableEncounters, array<SpawnDistributionList> NewSpawnDistributionLists)
{
	local int numDefaults;
	numDefaults = ConfigurableEncounters.Length;
	`KvCLog("KVPS: Number of encounters in NewConfigurableEncounters: " @ NewConfigurableEncounters.Length);
	if(numDefaults < 1)
	{
		ConfigurableEncounters = NewConfigurableEncounters;
		`KvCLog("KVPS: Number of encounters in ConfigurableEncounters: " @ ConfigurableEncounters.Length);
	}
	
	numDefaults = SpawnDistributionLists.Length;
	`KvCLog("KVPS: Number of encounters in NewSpawnDistributionLists: " @ NewSpawnDistributionLists.Length);
	if(numDefaults < 1)
	{
		SpawnDistributionLists = NewSpawnDistributionLists;
		`KvCLog("KVPS: Number of encounters in SpawnDistributionLists: " @ SpawnDistributionLists.Length);
		
	}
	SaveConfig();
}