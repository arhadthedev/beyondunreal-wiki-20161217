/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This action creates an online game based upon the settings object that
 * is bound to the UI widget
 */
class UIAction_FindOnlineGames extends UIAction
	native(inherit);

/** The datastore to perform the search on */
var() name DataStoreName;



defaultproperties
{
	ObjName="Find Online Games"
	ObjCategory="Online"

	bAutoTargetOwner=true

	bAutoActivateOutputLinks=false
	OutputLinks(0)=(LinkDesc="Failure")
	OutputLinks(1)=(LinkDesc="Success")
}
