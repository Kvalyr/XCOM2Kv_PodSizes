class Kv_PS_UpdateArrays extends Object;// config(Kv_PodSizes_Settings);

var Kv_PodSizes_Settings Settings;

// TODO: Refactor this to support calling UpdateEncountersArray() multiple times without re-multiplying already-modified values. 
// This would obviate needing to restart the game after making settings changes.

static final function string ReplaceText(coerce string Text, coerce string Replace, coerce string With)
{
	// This function replaces any occurance of a substring Replace inside a string Text with the string With.
	// From: https://wiki.beyondunreal.com/Legacy:Useful_String_Functions
	local int i;
	local string Output;
 	i = InStr(Text, Replace);
	while (i != -1) {	
		Output = Output $ Left(Text, i) $ With;
		Text = Mid(Text, i + Len(Replace));	
		i = InStr(Text, Replace);
	}
	Output = Output $ Text;
	return Output;
}

// Restore a backed-up Encounter to its original functional state.
static function ConfigurableEncounter RestoreBackupEncounter(ConfigurableEncounter Enc)
{
	local string EncounterID;
	EncounterID = string(Enc.EncounterID);
	if(InStr(EncounterID, "_KVPSBackup") >= 0)
	{
		`KvCLog("KVPS: Restoring backup encounter: " @ Enc.EncounterID);
		if(InStr(EncounterID, "_KVPSBackup_Disabled") >= 0)
		{
			// Encounter had spawn already disabled when we backed it up. Keep that.
			Enc.EncounterID = name( ReplaceText(EncounterID, "_KVPSBackup_Disabled", "") );
			Enc.bDisableSpawn = True;
		}
		else
		{
			// Return to being spawnable
			Enc.EncounterID = name( ReplaceText(EncounterID, "_KVPSBackup", "") );
			Enc.bDisableSpawn = False;
		}
	}
	else
	{
		`KvCLog("KVPS: RestoreBackupEncounter :: Not a backup!: " @ Enc.EncounterID);
	}
	return Enc;
}

// Is this ConfigurableEncounter a backup we made during previous adjustments?
static function bool IsBackupEncounter(ConfigurableEncounter Enc, optional bool bIsDisabledSpawn=False)
{
	if(InStr(string(Enc.EncounterID), "_KVPSBackup") >= 0) // || InStr(string(Enc.EncounterID), "_KVPSBackup_Disabled") >= 0
	{
		if(bIsDisabledSpawn)
		{
			return InStr(string(Enc.EncounterID), "_KVPSBackup_Disabled") >= 0;
		}
		return True;
	}
	return False;
}

// Return the backed up version of an Encounter by its EncounterID
static function ConfigurableEncounter GetBackUpForEncounter(string QueryID, out int backupFound)
{
	local XComTacticalMissionManager MissionManager;
	local ConfigurableEncounter Enc;
	local int i;
	local string BackupName, BackupNameDisabled;
	MissionManager = `TACTICALMISSIONMGR;
	backupFound = 0;
	for(i = 0; i < MissionManager.ConfigurableEncounters.Length; ++i)
	{
		Enc = MissionManager.ConfigurableEncounters[i];
		BackupName = QueryID $ "_KVPSBackup";
		BackupNameDisabled = BackupName $ "_Disabled";
		if(BackupName == QueryID || BackupNameDisabled == QueryID)
		{
			backupFound = 1;
			return Enc;
		}
	}
	`KvCLog("KVPS: No backup found for Encounter: " @ QueryID);
	Enc.EncounterID = 'KVPSIgnore';
	return Enc;
}

static function ConfigurableEncounter CreateBackupCopyOfEncounter(ConfigurableEncounter Enc)
{
	//bDisableSpawn
	local ConfigurableEncounter backupEnc;
	local name backupID;
	local string DisableSpawnIndicator;

	`KvCLog("KVPS: Creating backup of Encounter: " @ Enc.EncounterID);
	
	// If bDisableSpawn is already True for this encounter we should note that in the backupID.
	DisableSpawnIndicator = "";
	if(Enc.bDisableSpawn)
	{
		DisableSpawnIndicator = "_Disabled";
	}
	
	backupID = name( string(Enc.EncounterID) $ "_KVPSBackup" $ DisableSpawnIndicator);
	backupEnc.EncounterID = backupID;
	backupEnc.MaxSpawnCount = Enc.MaxSpawnCount;
	backupEnc.bDisableSpawn = True;
	// We don't need to backup other values unless this mod starts modifying them.
	return backupEnc;
}

// Requires Community Highlander - Encounter * ConfigurableEncounters are const vars in non-Highlander XComTacticalMissionManager
function UpdateEncountersArray()
{
	local XComTacticalMissionManager MissionManager;
	local ConfigurableEncounter Enc, cleanEnc;
	local array<ConfigurableEncounter> NewEncounterArray, arrNewBackups, oldBackups;
	local int i, oldMaxSpawnCount;
	local int ENCOUNTER_MULTIPLIER;
	local bool ENCOUNTER_MULTIPLIER_BEFORE, IGNORE_SINGLE, IGNORE_FIXED, AFFECT_ALIENS, AFFECT_LOST, AFFECT_XCOM, AFFECT_NEUTRAL, AFFECT_RESISTANCE;
	local int backupFound;
	local bool firstRun;
	//local array<int> PodSizeMappings;
	//local array<string> PodEncounterIDMappings;	
	MissionManager = `TACTICALMISSIONMGR;
	
	Settings = new class'Kv_PodSizes_Settings';
	ENCOUNTER_MULTIPLIER = Settings.ENCOUNTER_MULTIPLIER;
	ENCOUNTER_MULTIPLIER_BEFORE = Settings.ENCOUNTER_MULTIPLIER_BEFORE;
	IGNORE_SINGLE = Settings.IGNORE_SINGLE;
	IGNORE_FIXED = Settings.IGNORE_FIXED;
	AFFECT_ALIENS = Settings.AFFECT_ALIENS;
	AFFECT_LOST = Settings.AFFECT_LOST;
	AFFECT_XCOM = Settings.AFFECT_XCOM;
	AFFECT_NEUTRAL = Settings.AFFECT_NEUTRAL;
	AFFECT_RESISTANCE = Settings.AFFECT_RESISTANCE;
	// PodSizeMappings = Settings.PodSizeMappings;
	// PodEncounterIDMappings = Settings.PodEncounterIDMappings;
	
	`KvCLog("KVPS: Config -- ENCOUNTER_MULTIPLIER: " @ Settings.ENCOUNTER_MULTIPLIER);
	/*
	`KvCLog("KVPS: Pod Size Mappings -- Length: " @ PodSizeMappings.Length);
	for(i = 0; i < PodSizeMappings.Length; ++i)
	{
		if(i != PodSizeMappings[i])
		{
			`KvCLog("KVPS: Pod Size Mapping -- Index: " @ i @ " NewPodSize: " @ PodSizeMappings[i]);
		}
	}
	*/

	// Reconstruct array of clean, unmodified Encounters from backups stored alongside modified Encounters in MissionManager.ConfigurableEncounters
	// Discard modified Encounters
	`KvCLog("KVPS: Number of encounters in MissionManager.ConfigurableEncounters before any processing: " @ MissionManager.ConfigurableEncounters.Length);
	/*
	for(i = 0; i < MissionManager.ConfigurableEncounters.Length; ++i)
	{
		Enc = MissionManager.ConfigurableEncounters[i];
		
		if(IsBackupEncounter(Enc)) // Checking if an Encounter is a backup is a cheaper operation than retrieving a backup by ID.
		{
			// Shouldn't reach here on first run during game load
			`KvCLog("KVPS: IsBackupEncounter: " @ Enc.EncounterID);
			cleanEnc = RestoreBackupEncounter(Enc); // Get unmodified Encounter from Backup
			NewEncounterArray.AddItem(cleanEnc);
		}
		else
		{
			// Get backup for this EncID
			backupFound = 0;
			cleanEnc = GetBackUpForEncounter(string(Enc.EncounterID), backupFound); 
			`KvCLog("KVPS: cleanEnc, backupFound: " @ Enc.EncounterID @ ", " @ backupFound);
			if(backupFound == 0)
			{
				// This should only happen on first load of the game, or if another mod is adding Encounters dynamically
				// If there's no backup for this encounter, this Encounter is new to us. Probably a fresh game load. 
				// Make a backup and store it separately in arrNewBackups<> to be appended to MissionManager.ConfigurableEncounters later (after processing).
				arrNewBackups.AddItem(CreateBackupCopyOfEncounter(Enc));
				NewEncounterArray.AddItem(Enc);
			}
			else
			{
				// Get the unmodified encounter from the backup, we don't want to work on backups
				cleanEnc = RestoreBackupEncounter(cleanEnc);
				NewEncounterArray.AddItem(cleanEnc);
			}
		}
	}
	*/
	// First get existing backups in case this is an Nth run
	for(i = 0; i < MissionManager.ConfigurableEncounters.Length; ++i)
	{
		Enc = MissionManager.ConfigurableEncounters[i];
		// If Enc is a backup, get the clean version and put that in the NewEncounterArray
		if(IsBackupEncounter(Enc)) // Checking if an Encounter is a backup is a cheaper operation than retrieving a backup by ID.
		{
			// Shouldn't reach here on first run during game load
			`KvCLog("KVPS: IsBackupEncounter: " @ Enc.EncounterID);
			cleanEnc = RestoreBackupEncounter(Enc); // Get unmodified Encounter from Backup
			NewEncounterArray.AddItem(cleanEnc);
		}
	}
	`KvCLog("KVPS: Number of encounters in NewEncounterArray before any processing: " @ NewEncounterArray.Length);
	if(NewEncounterArray.Length < 1)
	{
		// This is a first run on game load, no backups restored. Fill NewEncounterArray with clean encounters.
		// NewEncounterArray = MissionManager.ConfigurableEncounters; // Unsure if this assigns by reference or creates a copy. Let's just do another ugly loop instead.
		for(i = 0; i < MissionManager.ConfigurableEncounters.Length; ++i)
		{
			NewEncounterArray.AddItem(MissionManager.ConfigurableEncounters[i]);
		}
	}
	
	// At this point NewEncounterArray should contain only fresh, unmodified encounters; either restored from backups or fresh at game start
	for(i = 0; i < NewEncounterArray.Length; ++i)
	{
		Enc = NewEncounterArray[i];
		arrNewBackups.AddItem(CreateBackupCopyOfEncounter(Enc)); // Create a backup and put it in arrNewBackups
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
			//`KvCLog("KVPS: Ignoring Alien Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		if(Enc.TeamToSpawnInto == eTeam_TheLost && !AFFECT_LOST)
		{
			//`KvCLog("KVPS: Ignoring Lost Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}		
		if(Enc.TeamToSpawnInto == eTeam_XCOM && !AFFECT_XCOM)
		{
			//`KvCLog("KVPS: Ignoring XCom Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		if(Enc.TeamToSpawnInto == eTeam_Resistance && !AFFECT_RESISTANCE)
		{
			//`KvCLog("KVPS: Ignoring Resistance Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}		
		if(Enc.TeamToSpawnInto == eTeam_Neutral && !AFFECT_NEUTRAL)
		{
			//`KvCLog("KVPS: Ignoring Neutral Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		// Encounter sizes
		if(Enc.MaxSpawnCount == 1 && IGNORE_SINGLE)
		{
			//`KvCLog("KVPS: Ignoring One-Unit Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}
		if(Enc.MaxSpawnCount == Enc.ForceSpawnTemplateNames.Length && IGNORE_FIXED)
		{
			//`KvCLog("KVPS: Ignoring Fixed Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
			continue;
		}		
		
		/*
		// TODO PodSizeMappings
		if(PodSizeMappings.Length < 1 || Enc.MaxSpawnCount >= PodSizeMappings.Length || Enc.MaxSpawnCount < 0)
		{
			`KvCLog("KVPS: Not setting pod size from mapping due to SpawnCount out of bounds: " @ Enc.MaxSpawnCount @ " - PodSizeMappings.Length: " @ PodSizeMappings.Length);
		}
		else
		{
			`KvCLog("KVPS: Setting pod size from PodSizeMappings: Encounter: " @ Enc.EncounterID @ " - Old MaxSpawnCount: " @ Enc.MaxSpawnCount @ "NewPodSize: " @ PodSizeMappings[Enc.MaxSpawnCount]);
			Enc.MaxSpawnCount = PodSizeMappings[Enc.MaxSpawnCount];
		}
		*/
		
		// if(PodEncounterIDMappings.Length < 1) // Need to key by EncounterID here. Wish UnrealScript had native associative arrays :(
		//PodEncounterIDMappings
		
		if(!ENCOUNTER_MULTIPLIER_BEFORE)
		{
			Enc.MaxSpawnCount = Round(Enc.MaxSpawnCount * ENCOUNTER_MULTIPLIER);
		}
		NewEncounterArray[i] = Enc;
		`KvCLog("KVPS: Encounter: " @ Enc.EncounterID @ " - oldMaxSpawnCount, New MaxSpawnCount: " @ oldMaxSpawnCount @ ", " @ Enc.MaxSpawnCount);
	}
	// Finished modifying clean Encounters. Encounters in NewEncounterArray are now a mixture of clean and dirty depending on filters applied during processing.
	
	`KvCLog("KVPS: Number of encounters in NewEncounterArray after modifying: " @ MissionManager.ConfigurableEncounters.Length);
	
	// Put the backups in first. Array order matters, and we want the backup-retriever to find them fast.
	// Add backups with their spawn disabled to MissionManager.ConfigurableEncounters so that we can retrieve them again later next time this function is called.
	MissionManager.ConfigurableEncounters.Length = 0; // Dump old Encounters array
	MissionManager.ConfigurableEncounters = arrNewBackups;
		
	// Add NewEncounterArray encounters to MissionManager.ConfigurableEncounters
	for(i = 0; i < NewEncounterArray.Length; ++i)
	{
		MissionManager.ConfigurableEncounters.AddItem(NewEncounterArray[i]);
	}
	`KvCLog("KVPS: Number of encounters in MissionManager.ConfigurableEncounters after adding backups: " @ MissionManager.ConfigurableEncounters.Length);
}

	/* 
	// ConfigurableEncounter from XGGameData.uc:
	struct native ConfigurableEncounter
	{
		// The name of this encounter (used in conjunction with Mission triggers)
		var name				EncounterID;
		// A hard limit on the maximum number of group members that this encounter should contain
		var int					MaxSpawnCount;
		// If >0, this value overrides the Force Level for the next group to spawn.
		var int					OffsetForceLevel;
		// If >0, this value overrides the AlertLevel for the next group to spawn.
		var int					OffsetAlertLevel;
		// The name of an Inclusion/Exclusion list of character types that are permitted to spawn as part of this encounter as a group leader.
		var Name				EncounterLeaderSpawnList;
		// The name of an Inclusion/Exclusion list of character types that are permitted to spawn as part of this encounter as a group follower.
		var Name				EncounterFollowerSpawnList;
		// When constructing this encounter, the leader (index 0) and followers will be selected first from these template names; 
		// the remainder will be filled out using normal encounter construction rules.
		var array<Name>			ForceSpawnTemplateNames;
		// This encounter will only be available if the current Alert Level is greater than or equal to this value.
		var int					MinRequiredAlertLevel;
		// This encounter will only be available if the current Alert Level is less than or equal to this value.
		var int					MaxRequiredAlertLevel;
		// This encounter will only be available if the current Force Level is greater than or equal to this value.
		var int					MinRequiredForceLevel;
		// This encounter will only be available if the current Force Level is less than or equal to this value.
		var int					MaxRequiredForceLevel;
		// If configured as a reinforcement encounter, this is the number of turns until the group spawns for this encounter.
		var int					ReinforcementCountdown;
		// If true, this encounter group will not drop loot.
		var bool				bGroupDoesNotAwardLoot;
		// The team that this encounter group should spawn into.
		var ETeam				TeamToSpawnInto;
		// Whether to skip soldier VO
		var bool				SkipSoldierVO;
		// Prevent certain units (mainly VIPs) from scampering.
		var bool				bDisableScamper;
		// If true, this group will not automatically spawn if it is selected at the start of a map.  
		// Used for any groups that will be dynamically spawned later in the mission.
		var bool				bDisableSpawn;
		structdefaultproperties
		{
			MaxSpawnCount = 10
			ReinforcementCountdown = 1
			MinRequiredAlertLevel = 0
			MaxRequiredAlertLevel = 1000
			MinRequiredForceLevel = 0
			MaxRequiredForceLevel = 20
			TeamToSpawnInto = eTeam_Alien
		}
	};	
	*/

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