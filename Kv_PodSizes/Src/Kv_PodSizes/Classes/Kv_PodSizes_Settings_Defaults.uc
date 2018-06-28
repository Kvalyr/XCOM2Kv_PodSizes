class Kv_PodSizes_Settings_Defaults extends Object config(Kv_PodSizes_Defaults);

var config float ENCOUNTER_MULTIPLIER;
var config bool ENCOUNTER_MULTIPLIER_BEFORE;

var config bool IGNORE_SINGLE;
var config bool IGNORE_FIXED;

var config bool AFFECT_ALIENS;
var config bool AFFECT_LOST;
var config bool AFFECT_XCOM;
var config bool AFFECT_NEUTRAL;
var config bool AFFECT_RESISTANCE;

var const int MAX_PODSIZE_MAPPINGS;
var config array<int> PodSizeMappings;
var config array<string> PodEncounterIDMappings;

var config int ConfigVersion;

defaultproperties
{
	MAX_PODSIZE_MAPPINGS=20

}
