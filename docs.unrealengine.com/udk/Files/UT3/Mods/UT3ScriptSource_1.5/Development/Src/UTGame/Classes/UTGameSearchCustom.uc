/** this is used when searching for mod gametypes */
class UTGameSearchCustom extends UTGameSearchDM;

defaultproperties
{
	// Set the specific game mode that we are searching for
	// Updated elsewhere, to search directly for the game class name
	//LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_CUSTOM,AdvertisementType=ODAT_OnlineService)

	// This class is now also used to list 'all gametypes', so reenable the pure server filter
	//LocalizedSettings(0)=(Id=CONTEXT_PURESERVER,ValueIndex=CONTEXT_PURESERVER_NO,AdvertisementType=ODAT_OnlineService)

	FilterQuery={
	(OrClauses=((OrParams=((EntryId=CONTEXT_PURESERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_LOCKEDSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_ALLOWKEYBOARD,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_FULLSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_EMPTYSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals))),
				(OrParams=((EntryId=CONTEXT_DEDICATEDSERVER,EntryType=OGSET_LocalizedSetting,ComparisonType=OGSCT_Equals)))
	))}
}
