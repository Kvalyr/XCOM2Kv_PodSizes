//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_Kv_PodSizes.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_Kv_PodSizes extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{}

static event OnPostTemplatesCreated()
{
	local Kv_PS_UpdateArrays inst;
	local Kv_PodSizes_DefaultPods defaultPods;
	local XComTacticalMissionManager MissionManager;
	`KvCLog("KVPS: OnPostTemplatesCreated()");
	
	MissionManager = `TACTICALMISSIONMGR;
	defaultPods = new class'Kv_PodSizes_DefaultPods' ;
	defaultPods.SaveDefaultPods(MissionManager.ConfigurableEncounters, MissionManager.SpawnDistributionLists);
	
	inst = new class'Kv_PS_UpdateArrays' ;
	inst.UpdateEncountersArray();
}