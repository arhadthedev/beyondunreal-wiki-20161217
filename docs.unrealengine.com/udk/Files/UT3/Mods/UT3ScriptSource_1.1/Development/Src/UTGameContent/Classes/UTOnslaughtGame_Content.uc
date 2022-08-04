/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtGame_Content extends UTOnslaughtGame;

defaultproperties
{
	HUDType=class'UTGame.UTOnslaughtHUD'
	PlayerReplicationInfoClass=class'UTGame.UTOnslaughtPRI'
	GameReplicationInfoClass=class'UTOnslaughtGRI'

	TeamAIType(0)=class'UTGame.UTOnslaughtTeamAI'
	TeamAIType(1)=class'UTGame.UTOnslaughtTeamAI'

	MessageClass=class'UTOnslaughtMessage'
}
