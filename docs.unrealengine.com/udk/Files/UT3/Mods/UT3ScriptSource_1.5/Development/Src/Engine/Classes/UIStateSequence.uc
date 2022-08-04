/**
 * UISequence used to contain sequence objects which are associated with a particular UIState.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIStateSequence extends UISequence
	native(inherit);



/**
 * Returns the UIState that created this UIStateSequence.
 */
native final function UIState GetOwnerState() const;

DefaultProperties
{

}
