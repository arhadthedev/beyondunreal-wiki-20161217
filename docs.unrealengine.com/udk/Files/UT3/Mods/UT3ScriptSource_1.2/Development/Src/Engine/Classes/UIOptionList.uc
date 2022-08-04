/**
 * Copyright 2006-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Option widget that works similar to a read only combobox.
 */
class UIOptionList extends UIOptionListBase
	native(UIPrivate)
	placeable;

/** Current index in the datastore */
var	transient 			int						CurrentIndex;

/** the list element provider referenced by DataSource */
var	transient	const	UIListElementProvider	DataProvider;



/* === Natives === */
/**
* @param ListIndex		List index to get the value of.
* @param OutValue		Storage string for the list value
*
* @return Returns TRUE if we were able to get a value, FALSE otherwise
*/
native final function bool GetListValue( int ListIndex, out string OutValue );

/**
 * Decrements the widget to the previous value
 */
native function SetPrevValue();

/**
 * Increments the widget to the next value
 */
native function SetNextValue();

/** @return Returns the current index of the optionbutton. */
native function int GetCurrentIndex() const;

/**
 * Sets a new index for the option button.
 *
 * @param NewIndex		New index for the option button.
 */
native function SetCurrentIndex( int NewIndex );


/* == Kismet action handlers == */
protected final function OnSetListIndex( UIAction_SetListIndex Action )
{
	local int OutputLinkIndex;

	// For now always active the success link
	OutputLinkIndex = 0;

	if ( Action != None )
	{
		`Log("SADSADSA: "$Action.NewIndex);
		SetCurrentIndex(Action.NewIndex);

		// activate the appropriate output link on the action
		if ( !Action.OutputLinks[OutputLinkIndex].bDisabled )
		{
			Action.OutputLinks[OutputLinkIndex].bHasImpulse = true;
		}
	}
}


defaultproperties
{
	Begin Object Name=DecrementButtonTemplate
	End Object
	Begin Object Name=IncrementButtonTemplate
	End Object
}

