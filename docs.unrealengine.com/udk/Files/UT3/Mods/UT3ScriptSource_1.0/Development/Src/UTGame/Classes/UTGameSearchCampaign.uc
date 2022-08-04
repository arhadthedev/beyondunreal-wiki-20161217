/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base game search for a Campaign match.
 */
class UTGameSearchCampaign extends UTGameSearchCommon;

defaultproperties
{
	GameSettingsClass=class'UTGame.UTGameSettingsCampaign'

	// Which server side query to execute
	Query=(ValueIndex=QUERY_CAMPAIGN)

	// Set the specific game mode that we are searching for
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_CAMPAIGN,AdvertisementType=ODAT_OnlineService)
}