/**
 * Base class for all switch condition ops which use an object value for branching.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class SeqCond_SwitchObject extends SeqCond_SwitchBase
	native(inherit);



/** Stores class name to compare for each output link and whether it should fall through to next node */
struct native SwitchObjectCase
{
	/** the value of this case statement */
	var() Object	ObjectValue;

	/** indicates whether control should fall through to the next case upon a match*/
	var() bool		bFallThru;

	/** true if this represents the default value option */
	var() bool		bDefaultValue;
};

/**
 * Stores the list of values which are handled by this switch object.
 */
var() array<SwitchObjectCase>	SupportedValues;

/**
 * Limits which types of objects can be used by this switch op.
 *
 * @fixme ronp - not yet implemented!
 */
var() class						MetaClass;

/* === Events === */
/**
 * Ensures that the last item in the value array represents the "default" item.  Child classes should override this method to ensure that
 * their value array stays synchronized with the OutputLinks array.
 */
event VerifyDefaultCaseValue()
{
	local int i;

	Super.VerifyDefaultCaseValue();

	SupportedValues.Length = OutputLinks.Length;
	for ( i = 0; i < SupportedValues.Length - 1; i++ )
	{
		SupportedValues[i].bDefaultValue = false;
	}

	SupportedValues[SupportedValues.Length-1].ObjectValue = None;
	SupportedValues[SupportedValues.Length-1].bFallThru = false;
	SupportedValues[SupportedValues.Length-1].bDefaultValue = true;
}

/**
 * Returns whether fall through is enabled for the specified case value.
 */
event bool IsFallThruEnabled( int ValueIndex )
{
	// by default, fall thru is not enabled on anything
	return ValueIndex >= 0 && ValueIndex < SupportedValues.Length && SupportedValues[ValueIndex].bFallThru;
}

/**
 * Insert an empty element into this switch's value array at the specified index.
 */
event InsertValueEntry( int InsertIndex )
{
	InsertIndex = Clamp(InsertIndex, 0, SupportedValues.Length);

	SupportedValues.Insert(InsertIndex, 1);
}

/**
 * Remove an element from this switch's value array at the specified index.
 */
event RemoveValueEntry( int RemoveIndex )
{
	if ( RemoveIndex >= 0 && RemoveIndex < SupportedValues.Length )
	{
		SupportedValues.Remove(RemoveIndex, 1);
	}
}

DefaultProperties
{
	SupportedValues(0)=(bDefaultValue=true)
	MetaClass=class'Core.Object'

	ObjName="Switch Object"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Object")
}
