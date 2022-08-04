/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/** Holds the settings that are advertised for a match */
class UTGameSettingsDUEL extends UTGameSettingsCommon;

defaultproperties
{
	// Set the specific game mode
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_DUEL,AdvertisementType=ODAT_OnlineService)

	Properties(2)=(PropertyId=PROPERTY_GOALSCORE,Data=(Type=SDT_Int32,Value1=0),AdvertisementType=ODAT_OnlineService)
	Properties(3)=(PropertyId=PROPERTY_TIMELIMIT,Data=(Type=SDT_Int32,Value1=5),AdvertisementType=ODAT_OnlineService)
	// Default numbots for duel to 1
	Properties(4)=(PropertyId=PROPERTY_NUMBOTS,Data=(Type=SDT_Int32,Value1=1),AdvertisementType=ODAT_OnlineService)

}
