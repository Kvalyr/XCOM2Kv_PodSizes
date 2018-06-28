class Kv_PodSizes_Settings extends UIScreenListener config(Kv_PodSizes_Settings);

var config float ENCOUNTER_MULTIPLIER;
var config bool ENCOUNTER_MULTIPLIER_BEFORE;

var config bool ALLOW_RUNTIME;

var config bool IGNORE_SINGLE;
var config bool IGNORE_FIXED;

var config bool AFFECT_ALIENS;
var config bool AFFECT_LOST;
var config bool AFFECT_XCOM;
var config bool AFFECT_NEUTRAL;
var config bool AFFECT_RESISTANCE;

var const int MAX_PODSIZE_MAPPINGS;
// var config array<int> PodSizeMappings;
// var config array<string> PodEncounterIDMappings;

var config int ConfigVersion;

`include(Kv_PodSizes/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(Kv_PodSizes/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
`MCM_CH_VersionChecker(class'Kv_PodSizes_Settings_Defaults'.default.ConfigVersion, ConfigVersion)

event OnInit(UIScreen Screen)
{
	//local KVPSSettings settings;
	`MCM_API_Register(Screen, ClientModCallback);
    if(UIShell(Screen) != none)
    {
        EnsureConfigExists();
    }
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    // Build the settings UI
    local MCM_API_SettingsPage page;
    local MCM_API_SettingsGroup group1, group2, group3;

    LoadSavedSettings();

    page = ConfigAPI.NewSettingsPage("Configurable Pod Sizes");
    page.SetPageTitle("Configurable Pod Sizes");
    page.SetSaveHandler(SaveButtonClicked);

	group1 = Page.AddGroup('Group1', "Pod Size");
    
	// Name, Text, Tooltip, Min, Max, Step, Init Value, Save Handler
	// Group 1
	group1.AddSlider('MainMultiplier', 	"Global Pod Size Multiplier", "This multiplier is applied to pod sizes in general. If you want 25% bigger pods, set it to 1.25. 100% bigger pods: 2.0; etc.", 0, 10, 0.01, ENCOUNTER_MULTIPLIER, GlobalMultSaveHandler);	
	group1.AddCheckbox('MainMultiplierBefore', "Global Multiplier Before Others", "Enable if 'Global Pod Size Multiplier' should be applied to pod sizes before other checks like PodSizeMappings", ENCOUNTER_MULTIPLIER_BEFORE, GlobalMultBeforeSaveHandler);	
	
	group2 = Page.Addgroup('Group2', "Filters");
	group2.AddCheckbox('IgnoreSingle', "Ignore Single-Unit Pods", "Ignore Pods that normally only have a single unit and MaxSpawnCount of 1", IGNORE_SINGLE, IgnoreSingleSaveHandler);	
	group2.AddCheckbox('IgnoreFixed', "Ignore Fixed Pods", "Ignore Pods that normally have a MaxSpawnCount identical to the number of Unit Templates. (ie; No RNG in what they spawn)", IGNORE_FIXED, IgnoreFixedSaveHandler);	
	
	group2.AddCheckbox('AffectAliens', "Affect Alien Pods", "Affect Pods that spawn for the Aliens team", AFFECT_ALIENS, AffectAliensSaveHandler);	
	group2.AddCheckbox('AffectLost', "Affect The Lost Pods", "Affect Pods that spawn The Lost", AFFECT_LOST, AffectLostSaveHandler);	
	group2.AddCheckbox('AffectNeutral', "Affect Neutral Pods", "Affect Pods that spawn for the Neutral team (civilians, etc.)", AFFECT_NEUTRAL, AffectNeutralSaveHandler);	
	group2.AddCheckbox('AffectResistance', "Affect Resistance Pods", "Affect Pods that spawn for the Resistance team", AFFECT_RESISTANCE, AffectResistanceSaveHandler);	
	group2.AddCheckbox('AffectXCOM', "Affect XCOM Pods", "Affect Pods that spawn for XCOM", AFFECT_XCOM, AffectXcomSaveHandler);	
	
	group3 = Page.Addgroup('Group2', "Advanced / Experimental");
	group3.AddCheckbox('AllowRuntime', "Update pods without Restarting (Experimental)", "If enabled, settings take effect immediately instead of requiring a game restart. If you get weird pods, switch this off and restart the game once; then always restart the game client after making settings changes here.", ALLOW_RUNTIME, AllowRuntimeSaveHandler);	
	
	// CreatePodSizeMappingSliders(group3)

    page.ShowSettings();
}

`MCM_API_BasicSliderSaveHandler(GlobalMultSaveHandler, ENCOUNTER_MULTIPLIER)
`MCM_API_BasicCheckboxSaveHandler(GlobalMultBeforeSaveHandler, ENCOUNTER_MULTIPLIER_BEFORE)

`MCM_API_BasicCheckboxSaveHandler(IgnoreSingleSaveHandler, IGNORE_SINGLE)
`MCM_API_BasicCheckboxSaveHandler(IgnoreFixedSaveHandler, IGNORE_FIXED)

`MCM_API_BasicCheckboxSaveHandler(AffectAliensSaveHandler, AFFECT_ALIENS)
`MCM_API_BasicCheckboxSaveHandler(AffectLostSaveHandler, AFFECT_LOST)
`MCM_API_BasicCheckboxSaveHandler(AffectNeutralSaveHandler, AFFECT_NEUTRAL)
`MCM_API_BasicCheckboxSaveHandler(AffectResistanceSaveHandler, AFFECT_RESISTANCE)
`MCM_API_BasicCheckboxSaveHandler(AffectXcomSaveHandler, AFFECT_XCOM)

`MCM_API_BasicCheckboxSaveHandler(AllowRuntimeSaveHandler, ALLOW_RUNTIME)


function LoadSavedSettings()
{
	`KvCLog("KVPS: LoadSavedSettings()");
    ENCOUNTER_MULTIPLIER = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.ENCOUNTER_MULTIPLIER, ENCOUNTER_MULTIPLIER);
    ENCOUNTER_MULTIPLIER_BEFORE = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.ENCOUNTER_MULTIPLIER_BEFORE, ENCOUNTER_MULTIPLIER_BEFORE);
    
	IGNORE_SINGLE = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.IGNORE_SINGLE, IGNORE_SINGLE);
    IGNORE_FIXED = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.IGNORE_FIXED, IGNORE_FIXED);
    
	AFFECT_ALIENS = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.AFFECT_ALIENS, AFFECT_ALIENS);
    AFFECT_LOST = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.AFFECT_LOST, AFFECT_LOST);
    AFFECT_NEUTRAL = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.AFFECT_NEUTRAL, AFFECT_NEUTRAL);
    AFFECT_RESISTANCE = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.AFFECT_RESISTANCE, AFFECT_RESISTANCE);
    AFFECT_XCOM = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.AFFECT_XCOM, AFFECT_XCOM);
	
    ALLOW_RUNTIME = `MCM_CH_GetValue(class'Kv_PodSizes_Settings_Defaults'.default.ALLOW_RUNTIME, ALLOW_RUNTIME);
	
	`KvCLog("KVPS: Loaded:" @ ENCOUNTER_MULTIPLIER @ "," @ ENCOUNTER_MULTIPLIER_BEFORE @ "," @ IGNORE_SINGLE @ "," @ IGNORE_FIXED @ "," @ AFFECT_ALIENS @ "," @ AFFECT_LOST @ "," @ AFFECT_NEUTRAL @ "," @ AFFECT_RESISTANCE @ "," @ AFFECT_XCOM @ ", " @ ALLOW_RUNTIME);
	
	// PodSizeMappings = 
}

/*
static function CreatePodSizeMappingSliders(MCM_API_SettingsGroup group)
{
	local int i, numMappings;
	local string indexStr;
	numMappings = min(PodSizeMappings.Length, MAX_PODSIZE_MAPPINGS)
	for(i=0; i < numMappings; ++i)
	{
		indexStr = string(i);
		group.AddSlider('PodSizeMapping_' $ name(i), 		// Name
		  "Pod Size" $ indexStr $ " Adjustment", 			// Text
		  "Number of spawns to create for a pod that was previously " $ indexStr $ " in size", // Tooltip
		  0, 20, 1, 										// Min, Max, Step
		  PodSizeMappings[i], 								// Initial value
		  name("PodSizeSaveHandler_" $ indexStr) 			// Save handler
		);
	}
}

`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_0, PodSizeMappings[0])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_1, PodSizeMappings[1])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_2, PodSizeMappings[2])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_3, PodSizeMappings[3])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_4, PodSizeMappings[4])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_5, PodSizeMappings[5])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_6, PodSizeMappings[6])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_7, PodSizeMappings[7])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_8, PodSizeMappings[8])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_9, PodSizeMappings[9])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_10, PodSizeMappings[10])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_11, PodSizeMappings[11])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_12, PodSizeMappings[12])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_13, PodSizeMappings[13])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_14, PodSizeMappings[14])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_15, PodSizeMappings[15])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_16, PodSizeMappings[16])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_17, PodSizeMappings[17])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_18, PodSizeMappings[18])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_19, PodSizeMappings[19])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_20, PodSizeMappings[20])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_21, PodSizeMappings[21])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_22, PodSizeMappings[22])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_23, PodSizeMappings[23])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_24, PodSizeMappings[24])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_25, PodSizeMappings[25])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_26, PodSizeMappings[26])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_27, PodSizeMappings[27])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_28, PodSizeMappings[28])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_29, PodSizeMappings[29])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_30, PodSizeMappings[30])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_31, PodSizeMappings[31])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_32, PodSizeMappings[32])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_33, PodSizeMappings[33])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_34, PodSizeMappings[34])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_35, PodSizeMappings[35])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_36, PodSizeMappings[36])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_37, PodSizeMappings[37])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_38, PodSizeMappings[38])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_39, PodSizeMappings[39])
`MCM_API_BasicSliderSaveHandler(PodSizeSaveHandler_40, PodSizeMappings[40])
*/


function SaveButtonClicked(MCM_API_SettingsPage Page)
{	
	local Kv_PS_UpdateArrays inst;
	self.ConfigVersion = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
	if(Page != none && ALLOW_RUNTIME)
	{
		`KvCLog("KVPS: SaveButtonClicked(), Page!= none, ALLOW_RUNTIME: " @ ALLOW_RUNTIME);
		inst = new class'Kv_PS_UpdateArrays' ;
		inst.UpdateEncountersArray();
	}
}

function EnsureConfigExists()
{
	`KvCLog("KVPS: EnsureConfigExists");
    if(ConfigVersion == 0)
    {
		`KvCLog("KVPS: EnsureConfigExists ConfigVersion is 0");
        LoadSavedSettings();
        SaveButtonClicked(none);
    }
}

defaultproperties
{
	MAX_PODSIZE_MAPPINGS=20
}
