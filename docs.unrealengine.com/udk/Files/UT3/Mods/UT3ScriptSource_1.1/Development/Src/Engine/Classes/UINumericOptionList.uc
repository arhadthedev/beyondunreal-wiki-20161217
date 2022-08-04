/**
 * Copyright 2006-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Widget which looks like a UIOptionList but contains a numeric range for its data instead of a list of strings
 */
class UINumericOptionList extends UIOptionListBase
	native(UIPrivate)
	placeable;

/**
 * The value and range parameters for this numeric optionlist.
 */
var(Data)	UIRangeData		RangeValue;



/* === Natives === */
/**
 * Change the value of this slider at runtime.
 *
 * @param	NewValue			the new value for the slider.
 * @param	bPercentageValue	TRUE indicates that the new value is formatted as a percentage of the total range of this slider.
 *
 * @return	TRUE if the slider's value was changed
 */
native final function bool SetValue( coerce float NewValue, optional bool bPercentageValue );

/**
 * Gets the current value of this slider
 *
 * @param	bPercentageValue	TRUE to format the result as a percentage of the total range of this slider.
 */
native final function float GetValue( optional bool bPercentageValue ) const;

defaultproperties
{
	DataSource=(RequiredFieldType=DATATYPE_RangeProperty)
	RangeValue=(NudgeValue=1.f)

	Begin Object Name=DecrementButtonTemplate
	End Object
	Begin Object Name=IncrementButtonTemplate
	End Object
}

