/**
 * Abstract base class for UI actions.
 * Actions perform tasks for widgets, in response to some external event.  Actions are created by programmers and are
 * bound to widget events by designers using the UI editor.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIAction extends SequenceAction
	native(UISequence)
	abstract
	placeable;

/**
 * The ControllerId of the LocalPlayer corresponding to the 'PlayerIndex' element of the Engine.GamePlayers array.
 */
var	transient	noimport	int		GamepadID;

/**
 * Controls whether this action is automatically executed on the owning widget.  If true, this action will add the owning
 * widget to the Targets array when it's activated, provided the Targets array is empty.
 */
var()		bool		bAutoTargetOwner;



/**
 * Returns the widget that contains this UIAction.
 */
native final function UIScreenObject GetOwner() const;

/**
 * Returns the scene that contains this UIAction.
 */
native final function UIScene GetOwnerScene() const;

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return false;
}

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return true;
}


defaultproperties
{
	ObjCategory="UI"
	ObjClassVersion=4

	GamepadID=-1

	// the index for the player that activated this event
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Player Index",bWriteable=true,bHidden=true))

	// the gamepad id for the player that activated this event
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Gamepad Id",PropertyName=GamepadID,bWriteable=true,bHidden=true))
}
