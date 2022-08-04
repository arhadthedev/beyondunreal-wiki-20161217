/** this is used when searching for mod gametypes */
class UTGameSearchCustom extends UTGameSearchDM;

defaultproperties
{
	// Set the specific game mode that we are searching for
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_CUSTOM,AdvertisementType=ODAT_OnlineService)

	LocalizedSettings(1)=(Id=CONTEXT_PURESERVER,ValueIndex=CONTEXT_PURESERVER_NO,AdvertisementType=ODAT_OnlineService)
}
