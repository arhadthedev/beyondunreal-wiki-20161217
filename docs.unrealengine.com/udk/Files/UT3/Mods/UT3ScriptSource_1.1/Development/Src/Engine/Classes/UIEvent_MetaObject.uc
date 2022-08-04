/**
 * This object is a event that draw connections for all other UI Event objects, it allows the user to bind/remove input events.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * @note: native because C++ code activates this event
 */
class UIEvent_MetaObject extends UIEvent
	native(inherit)
	transient
	inherits(FCallbackEventDevice);



/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return false;
}

DefaultProperties
{
	ObjName="State Input Events"
	bDeletable=false
}

