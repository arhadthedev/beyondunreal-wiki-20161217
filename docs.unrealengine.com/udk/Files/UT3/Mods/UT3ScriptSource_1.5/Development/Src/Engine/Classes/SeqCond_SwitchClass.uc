/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqCond_SwitchClass extends SeqCond_SwitchBase
	native(Sequence);



/** Stores class name to compare for each output link and whether it should fall through to next node */
struct native SwitchClassInfo
{
	var() Name ClassName;
	var() Byte bFallThru;
};
var() array<SwitchClassInfo> ClassArray;

/* === Events === */
/**
 * Ensures that the last item in the value array represents the "default" item.  Child classes should override this method to ensure that
 * their value array stays synchronized with the OutputLinks array.
 */
event VerifyDefaultCaseValue()
{
	Super.VerifyDefaultCaseValue();

	ClassArray.Length = OutputLinks.Length;
	ClassArray[ClassArray.Length-1].ClassName = 'Default';
	ClassArray[ClassArray.Length-1].bFallThru = 0;
}

/**
 * Returns whether fall through is enabled for the specified case value.
 */
event bool IsFallThruEnabled( int ValueIndex )
{
	// by default, fall thru is not enabled on anything
	return ValueIndex >= 0 && ValueIndex < ClassArray.Length && ClassArray[ValueIndex].bFallThru != 0;
}

/**
 * Insert an empty element into this switch's value array at the specified index.
 */
event InsertValueEntry( int InsertIndex )
{
	InsertIndex = Clamp(InsertIndex, 0, ClassArray.Length);

	ClassArray.Insert(InsertIndex, 1);
}

/**
 * Remove an element from this switch's value array at the specified index.
 */
event RemoveValueEntry( int RemoveIndex )
{
	if ( RemoveIndex >= 0 && RemoveIndex < ClassArray.Length )
	{
		ClassArray.Remove(RemoveIndex, 1);
	}
}

defaultproperties
{
	ObjName="Switch Class"

	InputLinks(0)=(LinkDesc="In")
	OutputLinks(0)=(LinkDesc="Default")
	ClassArray(0)=(ClassName=Default)

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Object")
}
