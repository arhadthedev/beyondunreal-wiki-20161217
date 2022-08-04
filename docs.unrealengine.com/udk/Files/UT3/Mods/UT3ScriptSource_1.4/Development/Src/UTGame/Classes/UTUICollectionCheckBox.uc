/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Checkbox widget that works with collection datasources.
 */
class UTUICollectionCheckBox extends UICheckbox
	native(UI)
	placeable;

;

/** the list element provider referenced by DataSource */
var	const	transient			UIListElementProvider	DataProvider;

/**
 * Changed the checked state of this checkbox and activates a checked event.
 *
 * @param	bShouldBeChecked	TRUE to turn the checkbox on, FALSE to turn it off
 * @param	PlayerIndex			the index of the player that generated the call to SetValue; used as the PlayerIndex when activating
 *								UIEvents; if not specified, the value of GetBestPlayerIndex() is used instead.
 */
native function SetValue( bool bShouldBeChecked, optional int PlayerIndex=INDEX_NONE );

defaultproperties
{
	ValueDataSource=(RequiredFieldType=DATATYPE_Collection)
}
