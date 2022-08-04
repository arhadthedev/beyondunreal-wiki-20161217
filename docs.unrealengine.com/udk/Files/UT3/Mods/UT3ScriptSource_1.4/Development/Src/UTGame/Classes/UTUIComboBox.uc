/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Extended version of combo box for UT3.
 */
class UTUIComboBox extends UIComboBox
	native(UI);

var name	ToggleButtonStyleName;
var name	ToggleButtonCheckedStyleName;
var name	EditboxBGStyleName;
var name	ListBackgroundStyleName;



/** Called after initialization. */
event Initialized()
{
	Super.Initialized();

	// Make it so the list can't save out its value
	UTUIList(ComboList).bAllowSaving=false;

	// Set subwidget styles.
	SetupChildStyles();
}

/**
 * Called immediately after a child has been added to this screen object.
 *
 * @param	WidgetOwner		the screen object that the NewChild was added as a child for
 * @param	NewChild		the widget that was added
 */
event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild )
{
	Super.AddedChild( WidgetOwner, NewChild );

	if ( WidgetOwner == Self && NewChild != None && NewChild == ComboList )
	{
		// we want the list to only be as wide as the editbox
		SetListDocking(true);
	}
}


/** Initializes styles for child widgets. */
native function SetupChildStyles();

/**
 * @returns the Selection Index of the currently selected list item
 */
function Int GetSelectionIndex()
{
	return ( ComboList != none ) ? ComboList.Index : -1;
}

/**
 * Sets the current index for the list.
 *
 * @param	NewIndex		The new index to select
 */
function SetSelectionIndex(int NewIndex)
{
	if ( ComboList != none && NewIndex >= 0 && NewIndex < ComboList.GetItemCount() )
	{
		ComboList.SetIndex(NewIndex);
	}
}



/**
 * Sets the currently selected item.
 *
 * @param ItemIndex		Not the list index but the index of the item which is a value of the Items array.
 */
function SetSelectedItem(int ItemIndex)
{
	local int ItemIter;

	for(ItemIter=0; ItemIter<ComboList.Items.length; ItemIter++)
	{
		if(ComboList.Items[ItemIter]==ItemIndex)
		{
			ComboList.SetIndex(ItemIter);
			break;
		}
	}
}


defaultproperties
{
	ComboListClass=class'UTGame.UTUIList'
	ToggleButtonStyleName="ComboBoxUp"
	ToggleButtonCheckedStyleName="ComboBoxDown"
	EditboxBGStyleName="DefaultEditboxImageStyle"
	ListBackgroundStyleName="ComboListBackgroundStyle"
}
