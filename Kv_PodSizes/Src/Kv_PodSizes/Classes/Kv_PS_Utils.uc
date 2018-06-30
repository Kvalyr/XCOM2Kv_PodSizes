class Kv_PS_Utils extends Object;

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