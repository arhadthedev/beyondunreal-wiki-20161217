/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base game search for a DM match.
 */
class UTGameSearchGreed extends UTGameSearchCommon;

defaultproperties
{
	GameSettingsClass=class'UTGame.UTGameSettingsGreed'

	// Which server side query to execute
	Query=(ValueIndex=QUERY_GREED)

	// Set the specific game mode that we are searching for
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_GREED,AdvertisementType=ODAT_OnlineService)
}
