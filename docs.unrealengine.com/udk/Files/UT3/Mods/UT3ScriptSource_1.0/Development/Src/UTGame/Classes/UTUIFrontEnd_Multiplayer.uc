/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Multiplayer Scene for UT3.
 */

class UTUIFrontEnd_Multiplayer extends UTUIFrontEnd_BasicMenu
	dependson(UTCustomChar_Data)
	dependson(UTUIScene_MessageBox);

const MULTIPLAYER_OPTION_QUICKMATCH = 0;
const MULTIPLAYER_OPTION_JOINGAME = 1;
const MULTIPLAYER_OPTION_HOSTGAME = 2;

/** Reference to the quick match scene. */
var string	QuickMatchScene;

/** Reference to the host game scene. */
var string	HostScene;

/** Reference to the join game scene. */
var string	JoinScene;

/** Reference to the character selection scene. */
var string	CharacterSelectionScene;

/** Reference to the settings panels scene. */
var string	SettingsPanelsScene;

/** Whether or not we have already displayed the new player message box to the user. */
var transient	bool bDisplayedNewPlayerMessageBox;

/** @return bool Returns whether or not this user has saved character data. */
function bool HasSavedCharacterData()
{
	local bool bHaveLoadedCharData;
	local string CharacterDataStr;

	bHaveLoadedCharData = false;


	if(GetDataStoreStringValue("<OnlinePlayerData:ProfileData.CustomCharData>", CharacterDataStr, none, GetPlayerOwner()))
	{
		if(Len(CharacterDataStr) > 0)
		{
			bHaveLoadedCharData = true;
		}
	}

	return bHaveLoadedCharData;
}

/** Called when the screen has finished showing. */
function OnMainRegion_Show_UIAnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq)
{
	local UTProfileSettings Profile;
	local UTUIScene_MessageBox MessageBoxReference;
	local string OutValue;
	Super.OnMainRegion_Show_UIAnimEnd(AnimTarget, AnimIndex, AnimSeq);


	Profile = GetPlayerProfile();

	if(Profile!=None)
	{
		if(IsConsole(CONSOLE_Any)==false && Profile.GetProfileSettingValue(class'UTProfileSettings'.const.UTPID_FirstTimeMultiplayer, OutValue) && OutValue!="1")
		{
			OutValue="1";
			Profile.SetProfileSettingValue(class'UTProfileSettings'.const.UTPID_FirstTimeMultiplayer, OutValue);
			MessageBoxReference = GetMessageBoxScene();
			MessageBoxReference.DisplayAcceptBox("<Strings:UTGameUI.MessageBox.FirstTimeMultiplayer_Message>", 
				"<Strings:UTGameUI.MessageBox.FirstTimeMultiplayer_Title>", OnFirstTimeMultiplayer_Confirm);
		}
		else
		{	
			// See if the current player hasn't setup a character yet.
			if(bDisplayedNewPlayerMessageBox==false)
			{
				bDisplayedNewPlayerMessageBox=true;
				DisplayNewPlayerMessageBox();
			}
		}
	}
}

/**
 * Callback when the user dismisses the firsttime multiplayer message box.
 */
function OnFirstTimeMultiplayer_Confirm(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	OpenSceneByName(SettingsPanelsScene, false, OnSettingsSceneOpened);
}

/** Callback for when the settings scene has opened. */
function OnSettingsSceneOpened(UIScene OpenedScene, bool bInitialActivation)
{
	UTUIFrontEnd_SettingsPanels(OpenedScene).TabControl.ActivatePage(UTUIFrontEnd_SettingsPanels(OpenedScene).NetworkTab, GetBestPlayerIndex());
}


/** Displays a messagebox if the player doesn't have a custom character set. */
function DisplayNewPlayerMessageBox()
{
	local UTUIScene_MessageBox MessageBoxReference;
	local array<string> MessageBoxOptions;
	local array<PotentialOptionKeys> PotentialOptionKeyMappings;

	if(HasSavedCharacterData()==false)
	{
		// Pop up a message box asking the user if they want to edit their character or randomly generate one.
		MessageBoxReference = GetMessageBoxScene();

		if(MessageBoxReference != none)
		{
			MessageBoxOptions.AddItem("<Strings:UTGameUI.CharacterCustomization.RandomlyGenerate>");
			MessageBoxOptions.AddItem("<Strings:UTGameUI.CharacterCustomization.CreateCharacter>");
			MessageBoxOptions.AddItem("<Strings:UTGameUI.Generic.Cancel>");

			PotentialOptionKeyMappings.length = 3;
			PotentialOptionKeyMappings[0].Keys.AddItem('XboxTypeS_X');
			PotentialOptionKeyMappings[1].Keys.AddItem('XboxTypeS_A');
			PotentialOptionKeyMappings[2].Keys.AddItem('XboxTypeS_B');
			PotentialOptionKeyMappings[2].Keys.AddItem('Escape');

			MessageBoxReference.SetPotentialOptionKeyMappings(PotentialOptionKeyMappings);
			MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
			MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.FirstTimeCharacter_Message>", "<Strings:UTGameUI.MessageBox.FirstTimeCharacter_Title>", OnFirstTimeCharacter_Confirm);
		}
	}
}

/**
 * Callback when the user dismisses the firsttime character message box.
 */

function OnFirstTimeCharacter_Confirm(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local CustomCharData CustomData;
	local string DataString;

	switch ( SelectedOption )
	{
	case 0:	// Randomly generate a character
		CustomData = class'UTCustomChar_Data'.static.MakeRandomCharData();
		DataString = class'UTCustomChar_Data'.static.CharDataToString(CustomData);

		if(SetDataStoreStringValue("<OnlinePlayerData:ProfileData.CustomCharData>", DataString, none, GetPlayerOwner()))
		{
			UTGameUISceneClient(GetSceneClient()).ShowSaveProfileScene(GetUTPlayerOwner());
		}
		break;
	case 1:	// Open the character selection scene
		OpenSceneByName(CharacterSelectionScene);
		bDisplayedNewPlayerMessageBox=false;	// Need to recheck for a customized character after the user has closed the player customization screen.
		break;
	case 2:	// Close this scene
		CloseScene(self);
		break;
	}
}

/**
 * Executes a action based on the currently selected menu item.
 */
function OnSelectItem(int PlayerIndex=GetPlayerIndex())
{
	local int SelectedItem, ControllerId;

	SelectedItem = MenuList.GetCurrentItem();
	ControllerId = class'UIInteraction'.static.GetPlayerControllerId(PlayerIndex);
	switch(SelectedItem)
	{
	case MULTIPLAYER_OPTION_QUICKMATCH:
		if ( CheckLinkConnectionAndError() && CheckLoginAndError(ControllerId, true) )
		{
			OpenSceneByName(QuickMatchScene);
		}
		break;

	case MULTIPLAYER_OPTION_HOSTGAME:
		if ( CheckLinkConnectionAndError() )
		{
			OpenSceneByName(HostScene);
		}
		break;

	case MULTIPLAYER_OPTION_JOINGAME:
		if ( CheckLinkConnectionAndError() )
		{
			OpenSceneByName(Joinscene);
		}
		break;
	}
}

defaultproperties
{
	QuickMatchScene="UI_Scenes_ChrisBLayout.Scenes.QuickMatch"
	JoinScene="UI_Scenes_FrontEnd.Scenes.JoinGame"
	HostScene="UI_Scenes_ChrisBLayout.Scenes.HostGame"
	SettingsPanelsScene="UI_Scenes_ChrisBLayout.Scenes.SettingsPanels"
	CharacterSelectionScene="UI_Scenes_ChrisBLayout.Scenes.CharacterFaction"
	bMenuLevelRestoresScene=true
	bRequiresNetwork=true
}
