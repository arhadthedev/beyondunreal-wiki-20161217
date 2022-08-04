/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Character Part tab page.
 */

class UTUITabPage_CharacterPart extends UTTabPage
	placeable
	native(UIFrontEnd);



var transient vector OffsetVector;
var transient float	AnimTimeElapsed;

enum TabAnimDir
{
	TAD_None,
	TAD_LeftIn,
	TAD_LeftOut,
	TAD_RightOut,
	TAD_RightIn
};

var transient TabAnimDir AnimDir;

/** The type of parts we are enumerating over. */
var() ECharPart CharPartType;

/** List of maps widget. */
var transient UTUICharacterPartMenuList PartList;

/** Delegate for when the user selects a part on this page. */
delegate transient OnPartSelected(ECharPart PartType, string InPartID);

/** Delegate for when the user changes the selected part on this page. */
delegate transient OnPreviewPartChanged(ECharPart PartType, string InPartID);

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	Super.PostInitialize();

	// Setup delegates
	PartList = UTUICharacterPartMenuList(FindChild('lstParts', true));
	if(PartList != none)
	{
		PartList.OnSubmitSelection = OnPartList_SubmitSelection;
		PartList.OnValueChanged = OnPartList_ValueChanged;
	}

	// Set the button tab caption.
	SetDataStoreBinding("");
}

/** @return Whether or not we are currently animating. */
function bool IsAnimating()
{
	return (AnimDir != TAD_None);
}

/** Starts animation for showing/hiding this tab page. */
function StartAnim(TabAnimDir InAnimDir)
{
	AnimDir = InAnimDir;
	AnimTimeElapsed = 0.0;
	SetVisibility(true);
	PartList.SetVisibility(true);
	OnUIAnimEnd = OnAnimEnd;
}

/** Called when this tab page has finished animating. */
function OnAnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq)
{
	OnUIAnimEnd = None;

	if(AnimDir==TAD_LeftOut || AnimDir==TAD_RightOut)
	{
		SetVisibility(false);
		PartList.SetVisibility(false);
	}
	else
	{
		PartList.SetFocus(none);
	}

	AnimDir = TAD_None;
}

/**
 * Called when the user changes the current list index.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnPartList_SubmitSelection( UIObject Sender, optional int PlayerIndex=0 )
{
	local int SelectedItem;
	local UTUIMenuList MenuList;
	local string StringValue;

	MenuList = UTUIMenuList(Sender);

	if(MenuList != none)
	{
		SelectedItem = MenuList.GetCurrentItem();

		if(MenuList.GetCellFieldString(MenuList, 'PartID', SelectedItem, StringValue))
		{
			OnPartSelected(CharPartType, StringValue);
		}
	}
}

/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
function OnPartList_ValueChanged( UIObject Sender, optional int PlayerIndex=0 )
{
	local int SelectedItem;
	local UTUIMenuList MenuList;
	local string StringValue;

	MenuList = UTUIMenuList(Sender);

	if(MenuList != none)
	{
		SelectedItem = MenuList.GetCurrentItem();

		if(MenuList.GetCellFieldString(MenuList, 'PartID', SelectedItem, StringValue))
		{
			OnPreviewPartChanged(CharPartType, StringValue);
		}
	}
}

defaultproperties
{
	bRequiresTick=true;
}