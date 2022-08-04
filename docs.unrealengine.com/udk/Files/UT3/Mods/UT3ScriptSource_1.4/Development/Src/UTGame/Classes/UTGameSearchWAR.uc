/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Holds the base game search for a WAR match.
 */
class UTGameSearchWAR extends UTGameSearchCommon;

defaultproperties
{
	GameSettingsClass=class'UTGame.UTGameSettingsWAR'

	// Which server side query to execute
	Query=(ValueIndex=QUERY_WAR)

	// Set the specific game mode that we are searching for
	LocalizedSettings(0)=(Id=CONTEXT_GAME_MODE,ValueIndex=CONTEXT_GAME_MODE_WAR,AdvertisementType=ODAT_OnlineService)
}