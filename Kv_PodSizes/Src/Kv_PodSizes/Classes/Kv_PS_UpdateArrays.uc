class Kv_PS_UpdateArrays extends Object config(Kv_PodSizes);

var config float ENCOUNTER_MULTIPLIER;
var config bool ENCOUNTER_MULTIPLIER_BEFORE;

var config bool IGNORE_SINGLE;
var config bool IGNORE_FIXED;

var config bool AFFECT_ALIENS;
var config bool AFFECT_LOST;
var config bool AFFECT_XCOM;
var config bool AFFECT_NEUTRAL;
var config bool AFFECT_RESISTANCE;

var config array<int> PodSizeMappings;
var config array<string> PodEncounterIDMappings;


// Requires Highlander - Encounter * ConfigurableEncounters are const vars in non-Highlander XComTacticalMissionManager
function UpdateEncountersArray()
{
	local XComTacticalMissionManager MissionManager;
	local ConfigurableEncounter Enc;
	local int i, oldMaxSpawnCount;
	MissionManager = `TACTICALMISSIONMGR;
	
	`KvCLog("KVPS: Config -- ENCOUNTER_MULTIPLIER: " @ ENCOUNTER_MULTIPLIER);
	`KvCLog("KVPS: Pod Size Mappings -- Length: " @ PodSizeMappings.Length);
	for(i = 0; i < PodSizeMappings.Length; ++i)
	{
		if(i != PodSizeMappings[i])
		{
			`KvCLog("KVPS: Pod Size Mapping -- Index: " @ i @ " NewPodSize: " @ PodSizeMappings[i]);
		}
	}
	
	for(i = 0; i < MissionManager.ConfigurableEncounters.Length; ++i)
	{
		Enc = MissionManager.ConfigurableEncounters[i];
		oldMaxSpawnCount = Enc.MaxSpawnCount;
		
		if(ENCOUNTER_MULTIPLIER_BEFORE)
		{
			Enc.MaxSpawnCount = Round(Enc.MaxSpawnCount * ENCOUNTER_MULTIPLIER);
			`KvCLog("KVPS: Applying ENCOUNTER_MULTIPLIER early: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
		}
		
		/*
		// The Lost by EncounterID
		if((InStr(Enc.EncounterID, "TheLost") >= 0 || InStr(Enc.EncounterID, "LSTx") >= 0) && IGNORE_LOST ) // Ignore encounters for The Lost
		{
			`KvCLog("KVPS: Ignoring Lost Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		*/
		// Teams
		if(Enc.TeamToSpawnInto == eTeam_Alien && !AFFECT_ALIENS)
		{
			`KvCLog("KVPS: Ignoring Alien Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		if(Enc.TeamToSpawnInto == eTeam_TheLost && !AFFECT_LOST)
		{
			`KvCLog("KVPS: Ignoring Lost Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}		
		if(Enc.TeamToSpawnInto == eTeam_XCOM && !AFFECT_XCOM)
		{
			`KvCLog("KVPS: Ignoring XCom Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		if(Enc.TeamToSpawnInto == eTeam_Resistance && !AFFECT_RESISTANCE)
		{
			`KvCLog("KVPS: Ignoring Resistance Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}		
		if(Enc.TeamToSpawnInto == eTeam_Neutral && !AFFECT_NEUTRAL)
		{
			`KvCLog("KVPS: Ignoring Neutral Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		// Encounter sizes
		if(Enc.MaxSpawnCount == 1 && IGNORE_SINGLE)
		{
			`KvCLog("KVPS: Ignoring One-Unit Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		if(Enc.MaxSpawnCount == Enc.ForceSpawnTemplateNames.Length && IGNORE_FIXED)
		{
			`KvCLog("KVPS: Ignoring Fixed Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}		
		
		if(PodSizeMappings.Length < 1 || Enc.MaxSpawnCount >= PodSizeMappings.Length || Enc.MaxSpawnCount < 0)
		{
			`KvCLog("KVPS: Not setting pod size from mapping due to SpawnCount out of bounds: " @ Enc.MaxSpawnCount @ " - PodSizeMappings.Length: " @ PodSizeMappings.Length);
		}
		else
		{
			`KvCLog("KVPS: Setting pod size from PodSizeMappings: Encounter: " @ Enc.EncounterID @ " - Old MaxSpawnCount: " @ Enc.MaxSpawnCount @ "NewPodSize: " @ PodSizeMappings[Enc.MaxSpawnCount]);
			Enc.MaxSpawnCount = PodSizeMappings[Enc.MaxSpawnCount];
		}
		
		// if(PodEncounterIDMappings.Length < 1) // Need to key by EncounterID here. Wish UnrealScript had native associative arrays :(
		
		//PodEncounterIDMappings
		
		if(!ENCOUNTER_MULTIPLIER_BEFORE)
		{
			Enc.MaxSpawnCount = Round(Enc.MaxSpawnCount * ENCOUNTER_MULTIPLIER);
		}
		MissionManager.ConfigurableEncounters[i] = Enc;
		`KvCLog("Encounter: " @ Enc.EncounterID @ " - New oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);

		

		/*
		// Groupings
		// ADVENT - ADVx
		if(InStr(DataNameStr, "ADVx") < 1 && InStr(DataNameStr, "ADVx") < 1 ) // Ignore encounters for The Lost
		{	
			// Subgroups
			// Contains: FlightDevice // Dropship groups
		}

		// Check TeamToSpawnInto != eTeam_Neutral || eTeam_Resistance and ! eTeam_XCOM

		// BOSS - BOSSx

		// TERROR - TERx

			// TERROR - Chryssalid -> Filter out 'NoChryssalid'

			// TERx1_CivilianGroup
			// SPCx1_Faceless - Untransformed faceless // Comments say it's unused

		// Dark Events  DKVx
			// DKVx3_GodSaveTheQueen - Specific. 3 Sectopods. Probably filter out.

		// Tutorial_ // Ignore?

		// Demo_  // Ignore?

		// GP_ // Critical path / Story missions // Encounters are fixed sizes
		// LIST_Fortress // Looks to be related to GP

		// LIST_FinalShowdown // Avatar fight?

		// AvengerDefense_

		// RESx - Resistance ambush?

		// LNA_ - Lost and abandoned

		// ResistanceSoldier_


		// SPCx1_FieldCommander

		// LIST_OPNx3_IfNoChosen // LIST_OPNx4_IfNoChosen  // Chosen retaliation

		// CHOSENx // Probably don't want to allow multiples of these to spawn..

		// CompoundRescue_
		*/

	}
}

defaultproperties
(
	ENCOUNTER_MULTIPLIER = 1.0f;

	IGNORE_SINGLE = True;
	IGNORE_FIXED = True;

	AFFECT_ALIENS = True;
	AFFECT_LOST = False;
	AFFECT_XCOM = False;
	AFFECT_NEUTRAL = False;
	AFFECT_RESISTANCE = False;
)