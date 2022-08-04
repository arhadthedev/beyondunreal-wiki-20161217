/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Tab page for achievement progress.
 */
class UTUITabPage_AchievementList extends UTTabPage
	placeable;

`include(Core/Globals.uci)

/** Award icon image. */
var transient UIImage	IconImage;

/** Award description label. */
var transient UILabel	DescriptionLabel;

/** list of achievements - not necessarily all possible achievements */
var UTUIList AchievementList;

/** data store responsible for achievements **/
var UTUIDataStore_Content AchievementDS;

/** data provider responsible for achievement info **/
var UTUIDataProvider_AvailableContent AchievementDP;

/** Post initialization event - Setup widget delegates.*/
event PostInitialize()
{
	local UTUIScene OwnerUTScene;
	local UTPlayerController PC;

	Super.PostInitialize();
	
	// Setup the Achievement widgets
	AchievementList = UTUIList(FindChild('AchievementList', true));
	if(AchievementList != none)
	{
		AchievementList.OnValueChanged = OnAchievementList_ValueChanged;
		AchievementList.OnSubmitSelection = OnAchievementList_SubmitSelection;
	}

	AchievementDS = UTUIDataStore_Content(UTUIScene(GetScene()).FindDataStore('UTContent'));
	AchievementDP = AchievementDS.AvailableContentProvider;

	OwnerUTScene = UTUIScene(GetScene());
	PC = OwnerUTScene.GetUTPlayerOwner();

	// fill the achievement list
	AchievementDP.SetupAchievementList( PC );
	AchievementDS.RefreshSubscribers();

	// Set the button tab caption.
	SetDataStoreBinding("<Strings:UTGameUI.Community.AchievementProgress>");

	// Store widget references
	IconImage = UIImage(FindChild('imgAchievementPicture', true));
	DescriptionLabel = UILabel(FindChild('lblAchievementInfo', true));
}

/**
* Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
*
* @param	Sender	the list that is submitting the selection
*/
function OnAchievementList_ValueChanged( UIObject Sender, optional int PlayerIndex=0 )
{
	local int i, SelectedItem;
	local string StringValue;
	local array<String> CoordStrings;
	local array<String> ValPairs;
	local TextureCoordinates TexCoords;

	// Get the map's name from the list.
	SelectedItem = AchievementList.GetCurrentItem();

	// Preview Image
	if(class'UTUIMenuList'.static.GetCellFieldString(AchievementList, 'AchievementIcon', SelectedItem, StringValue))
	{
		IconImage.SetDatastoreBinding(StringValue);
		ParseStringIntoArray(Split(StringValue,";",true), CoordStrings, ",", true);
		if (CoordStrings.length > 1)
		{
			for (i=0; i<CoordStrings.length; i++)
			{
				ParseStringIntoArray(CoordStrings[i], ValPairs, "=", true);
				if (ValPairs[0] == "U")
				{
					TexCoords.U = float(ValPairs[1]);
				}
				else if (ValPairs[0] == "UL")
				{
					TexCoords.UL = float(ValPairs[1]);
				}
				else if (ValPairs[0] == "V")
				{
					TexCoords.V = float(ValPairs[1]);
				}
				else if (ValPairs[0] == "VL")
				{
					//Apparently the XX.X> happily converts to float
					TexCoords.VL = float(ValPairs[1]);
				}
			}
		}

		IconImage.ImageComponent.SetCoordinates(TexCoords);
	}

	// Description
	if(class'UTUIMenuList'.static.GetCellFieldString(AchievementList, 'AchievementHowTo', SelectedItem, StringValue))
	{
		DescriptionLabel.SetDatastoreBinding(StringValue);
	}

	// Update the button bar to get expand collapse button if appropriate
	UTUIFrontEnd(GetScene()).SetupButtonBar();
}

function OnAchievementList_SubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() )
{
	//Toggle the list if applicable
	OnExpandCollapse();
}

/**
 * GetMatchingProfileId
 */
function int GetMatchingProfileId( UTProfileSettings Profile, int MatchingId )
{
	local int Index;

	for (Index=0; Index<Profile.AchievementsArray.Length; Index++)
	{
		if (Profile.AchievementsArray[Index].Id == MatchingId)
		{
			return Index;
		}
	}

	return 0;
}


/** Callback allowing the tabpage to setup the button bar for the current scene. */
function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	local string StringValue;
	local int CurrentItem;

	CurrentItem = AchievementList.GetCurrentItem();

	if(CurrentItem!=INDEX_NONE)
	{
		//If this achievement has subdetails, allow expansion/contraction
		if(class'UTUIMenuList'.static.GetCellFieldString(AchievementList, 'Expandable', CurrentItem, StringValue) && StringValue ~= "TRUE")
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ExpandCollapse>", OnButtonBar_ExpandCollapse);
		}
	}
}

function bool OnButtonBar_ExpandCollapse(UIScreenObject InButton, int PlayerIndex)
{
	OnExpandCollapse();
	return true;
}

//Add/remove sub items from the datastore as appropriate
function OnExpandCollapse()
{
	local int CurrentItem;
	CurrentItem = AchievementList.GetCurrentItem();

	if(CurrentItem!=INDEX_NONE)
	{
		AchievementDP.ToggleCollapse( CurrentItem );
		AchievementDS.RefreshSubscribers();
		AchievementList.SetFocus(none);
	}
}

/** Buttonbar Callbacks */
function bool OnButtonBar_ShowAchievements(UIScreenObject InButton, int PlayerIndex)
{
	return true;
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	bResult=false;

	if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_A')
		{
			OnExpandCollapse();
			bResult=true;
		}
	}

	return bResult;
}

DefaultProperties
{
}