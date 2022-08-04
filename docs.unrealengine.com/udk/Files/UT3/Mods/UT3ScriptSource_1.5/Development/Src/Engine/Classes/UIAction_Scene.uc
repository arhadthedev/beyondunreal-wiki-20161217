/**
 * Base class for all actions that manipulate scenes.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_Scene extends UIAction
	abstract
	native(UISequence);



/** the scene that this action will manipulate */
var()	UIScene		Scene;

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return true;
}

DefaultProperties
{
	bAutoActivateOutputLinks=false
	bCallHandler=false

	OutputLinks(0)=(LinkDesc="Success")
	OutputLinks(1)=(LinkDesc="Failed")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Scene",PropertyName=Scene)
}
