/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Our Widgets are collections of UIObjects that are group together with
 * the glue logic to make them tick.
 */

class UTUI_Widget extends UIObject
	abstract
	native(UI);

/** If true, this object require tick */
var bool bRequiresTick;

/** Cached link to the UTUIScene that owns this widget */
var UTUIScene UTSceneOwner;



function NotifyGameSessionEnded();



/** @return Returns a datastore given its tag. */
function UIDataStore FindDataStore(name DataStoreTag)
{
	local UIDataStore	Result;

	Result = GetCurrentUIController().DataStoreManager.FindDataStore(DataStoreTag);

	return Result;
}

/** @return Returns the controller id of a player given its player index. */
function int GetPlayerControllerId(int PlayerIndex)
{
	local int Result;

	Result = GetCurrentUIController().GetPlayerControllerId(PlayerIndex);;

	return Result;
}

defaultproperties
{
}
