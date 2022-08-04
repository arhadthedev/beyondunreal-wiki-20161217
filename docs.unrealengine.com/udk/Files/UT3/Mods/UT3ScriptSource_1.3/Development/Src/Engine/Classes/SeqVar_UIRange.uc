/**
 * This class allows designers to manipulate UIRangeData values.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class SeqVar_UIRange extends SequenceVariable
	native(UISequence);



/**
 * The value associated with this sequence variable.
 */
var()	UIRoot.UIRangeData	RangeValue;

/**
 * Determines whether this class should be displayed in the list of available ops in the level kismet editor.
 *
 * @return	TRUE if this sequence object should be available for use in the level kismet editor
 */
event bool IsValidLevelSequenceObject()
{
	return false;
}

DefaultProperties
{
	ObjName="UI Range"
	ObjCategory="UI"
	ObjColor=(R=128,G=128,B=192,A=255)	// light purple
}
