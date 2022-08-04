/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTCinematicPlayerController extends UTEntryPlayerController;

function QuitToMainMenu()
{
	`Log("UTCinematicPlayerController::QuitToMainMenu() - Quitting to main menu from a cinematic.");

	Super(UTPlayerController).QuitToMainMenu();
}

defaultproperties
{
	EntryPostProcessChain=None
}
