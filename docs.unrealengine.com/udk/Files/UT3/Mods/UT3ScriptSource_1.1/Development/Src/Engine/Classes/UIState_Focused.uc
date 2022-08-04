/**
 * Represents the "focused" widget state.  Focused widgets recieve the first chance to process input events.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIState_Focused extends UIState
	native(UIPrivate)
	hidedropdown;



/**
 * Activate this state for the specified target.
 *
 * @param	Target			the widget that is activating this state.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE to allow this state to be activated for the specified Target.
 */
event bool ActivateState( UIScreenObject Target, int PlayerIndex )
{
	local bool bResult;

	bResult = Super.ActivateState(Target,PlayerIndex);
	if ( Target != None )
	{
		// ensure that Target has the enabled state on its StateStack
		bResult = Target.HasActiveStateOfClass(class'UIState_Enabled',PlayerIndex);
	}

	return bResult;
}

DefaultProperties
{
	StackPriority=10
}
