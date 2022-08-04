/**
 * Base class for all condition sequence objects which act as switch constructs.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class SeqCond_SwitchBase extends SequenceCondition
	native(inherit)
	abstract
	placeable;



/* === Events === */
/**
 * Ensures that the last item in the value array represents the "default" item.  Child classes should override this method to ensure that
 * their value array stays synchronized with the OutputLinks array.
 */
event VerifyDefaultCaseValue();

/**
 * Returns whether fall through is enabled for the specified case value.
 */
event bool IsFallThruEnabled( int ValueIndex )
{
	// by default, fall thru is not enabled on anything
	return false;
}

/**
 * Insert an empty element into this switch's value array at the specified index.
 */
event InsertValueEntry( int InsertIndex );

/**
 * Remove an element from this switch's value array at the specified index.
 */
event RemoveValueEntry( int RemoveIndex );

DefaultProperties
{
	ObjCategory="Switch"
	OutputLinks(0)=(LinkDesc="Default")
	VariableLinks.Empty
}
