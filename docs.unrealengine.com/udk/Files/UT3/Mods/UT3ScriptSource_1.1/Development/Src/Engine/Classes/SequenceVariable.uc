/**
 * Base class for all variables used by SequenceOps.
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SequenceVariable extends SequenceObject
	native(Sequence)
	abstract;



/** This is used by SeqVar_Named to find a variable anywhere in the levels sequence. */
var()	name	VarName;

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
	ObjName="Undefined Variable"
	ObjColor=(R=0,G=0,B=0,A=255)
	bDrawLast=true
}

