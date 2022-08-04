/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Character customization screen for UT3
 */
class UTUIFrontEnd_CharacterCustomization extends UTUIFrontEnd
	native(UIFrontEnd)
	dependson(UTCustomChar_Preview);

const CHARACTERCUSTOMIZATION_BUTTONBAR_ACCEPT = 0;
const CHARACTERCUSTOMIZATION_BUTTONBAR_BACK = 1;



/** Reference to the actor that we are previewing part changes on. */
var transient UTCustomChar_Preview PreviewActor;

/** Reference to the character customization list. */
var transient UTUICharacterCustomizationList CustomizationList;

/** Panel that contains a bunch of widgets to show when loading a character package. */
var transient UIObject	LoadingPanel;

/** Panel that contains widgets to show when a character is finished loading. */
var transient UIObject	CharacterPanel;

/** Button to rotate the character left. */
var transient UTUIPressButton RotateLeftButton;

/** Button to rotate the character right. */
var transient UTUIPressButton RotateRightButton;

/** List of paper doll images. */
var transient array<UIImage> PartImages;

/** Data structure that contains information about the character package that is already loaded. */
var transient UTCharFamilyAssetStore	LoadedPackage;

/** Data structure that contains information about the character package that is being loaded. */
var transient UTCharFamilyAssetStore	PendingPackage;

/** The current faction we are viewing. */
var	transient string	Faction;

/** The name of the current character we are viewing. */
var transient string	CharacterID;

/** The current character we are viewing. */
var transient CharacterInfo	Character;

/** Whether or not we loaded character data. */
var transient bool bHaveLoadedCharData;

/** Loaded character data. */
var transient CustomCharData LoadedCharData;

/** Rotation button flags. */
var transient bool	bRotateLeftDown;
var transient bool  bRotateRightDown;

/** Reference to the current camera actor. */
var transient CameraActor	CurrentCameraActor;

/** Current rotation delta of the camera actor. */
var transient float		CurrentRotation;

/** Original rotation of the camera actor. */
var transient rotator	OriginalCameraRotation;

/** Original location of the camera actor. */
var transient vector	OriginalCameraLocation;

/** How fast to rotate the camera when the user clicks on it in degrees per second. */
var() float				CameraRotationSpeed;

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize( )
{
	local int PartPanelIdx;
	local UIImage PartImage;
	local UIScreenObject NextParent;
	local UIScene	BackgroundScene;

	Super.PostInitialize();

	// Store widget references
	RotateLeftButton = UTUIPressButton(FindChild('butRotateLeft', true));
	RotateLeftButton.OnBeginPress = OnRotateLeftButton_BeginPress;
	RotateLeftButton.OnEndPress = OnRotateLeftButton_EndPress;

	// we don't want the user to be able to use the left/right keys for navigating focus in this scene, because we always want
	// left/right key presses to go to the CustomizationList.  This could also be done by changing the associated state for the
	// UTUICharacterCustomizationList's MoveSelectionRight/MoveSelectionLeft aliases to Enabled, rather than focused.
	// we'll also need to disable this alias in all parents of this button [stopping at the scene]
	for ( NextParent = RotateLeftButton; NextParent != None && NextParent != Self; NextParent = NextParent.GetParent() )
	{
		NextParent.EventProvider.DisabledEventAliases.AddItem('NavFocusLeft');
		NextParent.EventProvider.DisabledEventAliases.AddItem('NavFocusRight');
	}

	RotateRightButton = UTUIPressButton(FindChild('butRotateRight', true));
	RotateRightButton.OnBeginPress = OnRotateRightButton_BeginPress;
	RotateRightButton.OnEndPress = OnRotateRightButton_EndPress;

	// same goes for the rotate right button
	for ( NextParent = RotateRightButton; NextParent != None && NextParent != Self; NextParent = NextParent.GetParent() )
	{
		NextParent.EventProvider.DisabledEventAliases.AddItem('NavFocusLeft');
		NextParent.EventProvider.DisabledEventAliases.AddItem('NavFocusRight');
	}

	CustomizationList = UTUICharacterCustomizationList(FindChild('lstCustomization', true));
	CustomizationList.OnSelectionChange=OnCustomizationList_SelectionChange;

	PartPanelIdx = 0;
	PartImage = UIImage(FindChild(name("imgPart" $ PartPanelIdx), true));

	while(PartImage != none)
	{
		if(PartImage != none)
		{
			PartImage.SetVisibility(false);
		}
		PartImages.AddItem(PartImage);

		// Try to get another image.
		PartPanelIdx++;
		PartImage = UIImage(FindChild(name("imgPart" $ PartPanelIdx), true));
	}

	// Store a reference to the loading panel.
	LoadingPanel = FindChild('pnlLoading', true);
	CharacterPanel = FindChild('pnlCharacter', true);

	// Show the first part panel.
	PartImages[0].SetVisibility(true);
	UpdatePaperDoll();


	// Load the player's character data from the profile.
	if(IsGame())
	{
		LoadCharacterData();
	}

	// Disable post process for the character customization screen
	GetPlayerOwner().GetPostProcessChain(0).FindPostProcessEffect('MenuAdjust').bShowInGame=false;

	// Hide background scene
	BackgroundScene = GetSceneClient().FindSceneByTag('Background');
	BackgroundScene.bAlwaysRenderScene = false;

	SetupButtonBar();
}

/** Sets up the buttonbar for this scene. */
function SetupButtonBar()
{
	ButtonBar.Clear();

	if(ButtonBar != None)
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Cancel>", OnButtonBar_Back);

		// Only display some button bar options if the user is done loading the model.
		if(LoadingPanel.IsVisible()==false)
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Accept>", OnButtonBar_Accept);
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ToggleShoulderType>", OnButtonBar_ToggleShoulderType);
		}
	}
}

/** Starts loading a asset package. */
function StartLoadingPackage(string FamilyID)
{
	if(IsGame())
	{
		`Log("UTUIFrontEnd_CharacterCustomization::StartLoadingPackage() - Starting to load character part package (" $ Character.CharData.FamilyID $ ")");

		LoadedPackage = none;
		PendingPackage = class'UTCustomChar_Data'.static.LoadFamilyAssets(FamilyID, false, false);

		// Show loading panel.
		LoadingPanel.SetVisibility(true);

		// Hide character menus
		CharacterPanel.SetVisibility(false);

		// Hide Preview Actor
		PreviewActor.SetHidden(true);
	}
}

/** Checks the status of the package that is currently loading. */
event UpdateLoadingPackage()
{
	local int PanelIdx;
	local string PartID;

	if(PendingPackage != none && PendingPackage.NumPendingPackages == 0)
	{
		`Log("UTUIFrontEnd_CharacterCustomization::UpdateLoadingPackage() - Pending character part package done loading (" $ Character.CharData.FamilyID $ ")");

		// Hide loading panel
		LoadingPanel.SetVisibility(false);

		// set the character's data
		PreviewActor.SetCharacter(Character.Faction, Character.CharID);
		if(bHaveLoadedCharData)
		{
			PreviewActor.SetCharacterData(LoadedCharData);
		}

		// Update the currently selected list item for all parts.
		for(PanelIdx=0; PanelIdx<PART_MAX; PanelIdx++)
		{
			switch(PanelIdx)
			{
			case PART_ShoPad:
				PartID = PreviewActor.Character.CharData.ShoPadID;
				break;
			case PART_Boots:
				PartID = PreviewActor.Character.CharData.BootsID;
				break;
			case PART_Thighs:
				PartID = PreviewActor.Character.CharData.ThighsID;
				break;
			case PART_Arms:
				PartID = PreviewActor.Character.CharData.ArmsID;
				break;
			case PART_Torso:
				PartID = PreviewActor.Character.CharData.TorsoID;
				break;
			case PART_Goggles:
				PartID = PreviewActor.Character.CharData.GogglesID;
				break;
			case PART_Facemask:
				PartID = PreviewActor.Character.CharData.FacemaskID;
				break;
			case PART_Helmet:
				PartID = PreviewActor.Character.CharData.HelmetID;
				break;
			}


			CustomizationList.SetPartSelection(ECharPart(PanelIdx), PartID);
		}

		// Show Actor
		PreviewActor.SetHidden(false);

		// Show character menus
		CharacterPanel.SetVisibility(true);
		CharacterPanel.SetFocus(None);

		CurrentCameraActor = CameraActor(GetUTPlayerOwner().ViewTarget);
		OriginalCameraLocation = CurrentCameraActor.Location;
		OriginalCameraRotation = CurrentCameraActor.Rotation;
		CurrentCameraActor.SetPhysics(PHYS_None);

		LoadedPackage = PendingPackage;
		PendingPackage = none;

		PlayUISound('CharacterLoaded');

		SetupButtonBar();
	}
}

/** Find the preview actor. */
function FindPreviewActor()
{
	local UTCustomChar_Preview	PreviewActorIter, FallbackPreviewActor;

	// Find a preview actor to set changes on.
	ForEach PlayerOwner.GetCurrentWorldInfo().AllActors(class'UTCustomChar_Preview', PreviewActorIter)
	{
		// If this is a faction that we don't have a specific preview actor for, fall back to Ironguard one.
		if(PreviewActorIter.UseForFaction ~= "Ironguard")
		{
			FallbackPreviewActor = PreviewActorIter;
		}

		if(PreviewActorIter.UseForFaction ~= Faction)
		{
			PreviewActor=PreviewActorIter;
			break;
		}
	}

	if(PreviewActor == None)
	{
		PreviewActor = FallbackPreviewActor;
	}

	assert(PreviewActor != None);
}

/** Loads the character data from the datastore. */
function LoadCharacterData()
{
	local bool bUseDefault;
	local string CharacterDataStr;
	local LocalPlayer LP;
	local string FamilyID;
	local class<UTFamilyInfo> FamilyInfoClass;
	local string EventName;

	bUseDefault = true;
	LP = GetPlayerOwner();

	// Try to load data from the profile
	if(GetDataStoreStringValue("<OnlinePlayerData:ProfileData.CustomCharData>", CharacterDataStr, none, LP))
	{
		`Log("UTUIFrontEnd_CharacterCustomization::LoadCharacterData() - Loaded Profile Data, Value string: " $ CharacterDataStr);

		if(Len(CharacterDataStr) > 0)
		{
			LoadedCharData = class'UTCustomChar_Data'.static.CharDataFromString(CharacterDataStr);
			FamilyID = LoadedCharData.FamilyID;

			// Update the Faction from the character data
			FamilyInfoClass = class'UTCustomChar_Data'.static.FindFamilyInfo(FamilyID);
			Faction = FamilyInfoClass.default.Faction;

			// Find the right PreviewActor
			FindPreviewActor();

			// Activate kismet for faction's scene
			if (PreviewActor != None)
			{
				EventName = "CharacterCustomizationEnter_"$PreviewActor.UseForFaction;
			}
			else
			{
				EventName = "CharacterCustomizationEnter_"$Faction;
			}
			ActivateLevelEvent( name(EventName) );

			PreviewActor.Character.CharData = LoadedCharData;

			bUseDefault = false;
			bHaveLoadedCharData = true;
		}
	}


	if(bUseDefault)
	{
		`Log("UTUIFrontEnd_CharacterCustomization::LoadCharacterData() - Unable to load profile data, using default.");
		GetDataStoreStringValue("<UTCustomChar:Faction>", Faction);
		GetDataStoreStringValue("<UTCustomChar:Character>", CharacterID);

		Character = class'UTCustomChar_Data'.static.FindCharacter(Faction, CharacterID);
		FamilyID = Character.CharData.FamilyID;

		// Find the right PreviewActor
		FindPreviewActor();

		// Activate kismet for faction's scene
		if (PreviewActor != None)
		{
			EventName = "CharacterCustomizationEnter_"$PreviewActor.UseForFaction;
		}
		else
		{
			EventName = "CharacterCustomizationEnter_"$Faction;
		}
		ActivateLevelEvent( name(EventName) );

		bHaveLoadedCharData = false;
	}

	// Finally load the package using our FamilyID
	SetDataStoreStringValue("<UTCustomChar:Family>", FamilyID);

	StartLoadingPackage(FamilyID);
}

/** Saves the character data to the datastore. */
function SaveCharacterData()
{
	local UIDataStore_OnlinePlayerData	PlayerDataStore;
	local UTUIScene_SaveProfile SaveProfileScene;
	local string CharacterDataStr;
	local LocalPlayer LP;

	LP = GetPlayerOwner();

	// Save the character data to the profile.
	CharacterDataStr = class'UTCustomChar_Data'.static.CharDataToString(PreviewActor.Character.CharData);
	`Log("UTUIFrontEnd_CharacterCustomization::SaveCharacterData() - Saving Profile Data, Value string: " $ CharacterDataStr);

	SetDataStoreStringValue("<OnlinePlayerData:ProfileData.CustomCharData>", CharacterDataStr, none, LP);


	// Save profile
	PlayerDataStore = UIDataStore_OnlinePlayerData(FindDataStore('OnlinePlayerData', LP));

	if(PlayerDataStore != none)
	{
		`Log("UTUIFrontEnd_SettingsPanels::OnBack() - Saving player profile.");
		SaveProfileScene = UTGameUISceneClient(GetSceneClient()).ShowSaveProfileScene(GetUTPlayerOwner());

		if(SaveProfileScene != None)
		{
			SaveProfileScene.OnSaveFinished = OnSaveProfileCompleted;
		}
		else
		{
			OnSaveProfileCompleted();
		}
	}
	else
	{
		`Log("UTUIFrontEnd_SettingsPanels::OnBack() - Unable to locate OnlinePlayerData datastore for saving out profile.");
		OnSaveProfileCompleted();
	}

}

/** Callback for when the profile save has completed. */
function OnSaveProfileCompleted()
{
	local UIScene FactionSelectionScene;

	RestoreWorldSettings();

	// Close the scene, if we came through the create new character flow, then close the faction scene
	// so that all of the scenes above it are closed.
	FactionSelectionScene = GetSceneClient().FindSceneByTag('CharacterFaction');

	if(FactionSelectionScene!=None)
	{
		CloseScene(FactionSelectionScene);
	}
	else
	{
		CloseScene(self);
	}
}

/** Delegate for when the customization list's index changes. */
function OnCustomizationList_SelectionChange(UTSimpleList InObject, int InNewIndex)
{
	UpdatePaperDoll();
}

/** Reset the world settings. */
function RestoreWorldSettings()
{
	local UIScene BackgroundScene;

	// Show background scene
	BackgroundScene = GetSceneClient().FindSceneByTag('Background');
	BackgroundScene.bAlwaysRenderScene = true;

	CurrentCameraActor.SetLocation(OriginalCameraLocation);
	CurrentCameraActor.SetRotation(OriginalCameraRotation);
	CurrentCameraActor.SetPhysics(PHYS_Interpolating);

	// Activate kismet for exiting scene
	ActivateLevelEvent('CharacterCustomizationExit');

	// Reenable post process for the rest of the menus
	GetPlayerOwner().GetPostProcessChain(0).FindPostProcessEffect('MenuAdjust').bShowInGame=true;
}

/** Callback for when the user is trying to back out of the character customization menu. */
function OnBack()
{
	RestoreWorldSettings();

	// Close the scene
	CloseScene(self);
}

/** Callback for when the player has accepted the changes to their character. */
function OnAccept()
{
	// Save their character data
	SaveCharacterData();
}

/** Callback for when the user is trying to toggle the shoulder type of the character. */
function OnToggleShoulderType()
{
	// @todo: This could probably use an enum.
	if(PreviewActor.Character.CharData.bHasLeftShoPad && PreviewActor.Character.CharData.bHasRightShoPad)	// Both
	{
		// None
		PreviewActor.Character.CharData.bHasLeftShoPad = false;
		PreviewActor.Character.CharData.bHasRightShoPad = false;
	}
	else if(PreviewActor.Character.CharData.bHasLeftShoPad==false && PreviewActor.Character.CharData.bHasRightShoPad==false)	// None
	{
		// Left Only
		PreviewActor.Character.CharData.bHasLeftShoPad = true;
		PreviewActor.Character.CharData.bHasRightShoPad = false;
	}
	else if(PreviewActor.Character.CharData.bHasLeftShoPad==true && PreviewActor.Character.CharData.bHasRightShoPad==false)	// Left
	{
		// Right Only
		PreviewActor.Character.CharData.bHasLeftShoPad = false;
		PreviewActor.Character.CharData.bHasRightShoPad = true;
	}
	else if(PreviewActor.Character.CharData.bHasLeftShoPad==false && PreviewActor.Character.CharData.bHasRightShoPad==true)	// Right
	{
		// Both
		PreviewActor.Character.CharData.bHasLeftShoPad = true;
		PreviewActor.Character.CharData.bHasRightShoPad = true;
	}

	// Tell the actor to update its look since the data changed.
	PreviewActor.NotifyCharacterDataChanged();
}

/** Button bar callbacks - Accept Button */
function bool OnButtonBar_Accept(UIScreenObject InButton, int InPlayerIndex)
{
	OnAccept();

	return true;
}

/** Button bar callbacks - Back Button */
function bool OnButtonBar_Back(UIScreenObject InButton, int InPlayerIndex)
{
	OnBack();

	return true;
}

/** Button bar callbacks - Toggle shoulder type Button */
function bool OnButtonBar_ToggleShoulderType(UIScreenObject InButton, int InPlayerIndex)
{
	OnToggleShoulderType();

	return true;
}

/** Press button callbacks. */
function OnRotateLeftButton_BeginPress(UIScreenObject InObject, INT InPlayerIndex)
{
	bRotateLeftDown = true;
}

function OnRotateLeftButton_EndPress(UIScreenObject InObject, INT InPlayerIndex)
{
	bRotateLeftDown = false;
}

function OnRotateRightButton_BeginPress(UIScreenObject InObject, INT InPlayerIndex)
{
	bRotateRightDown = true;
}

function OnRotateRightButton_EndPress(UIScreenObject InObject, INT InPlayerIndex)
{
	bRotateRightDown = false;
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

	if(EventParms.EventType==IE_Released || EventParms.EventType==IE_Repeat)
	{
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
		{
			OnBack();
			bResult=true;
		}

		// Only let the user perform certain actions if we are done loading.
		else if(LoadingPanel.IsVisible()==false)
		{
			if(EventParms.InputKeyName=='XboxTypeS_A')
			{
				OnAccept();
				bResult=true;
			}
			else if(EventParms.InputKeyName=='XboxTypeS_Y')
			{
				OnToggleShoulderType();
				bResult=true;
			}
		}
	}

	if(EventParms.EventType==IE_Pressed)
	{
		if(EventParms.InputKeyName=='X' || EventParms.InputKeyName=='XboxTypeS_RightTrigger')
		{
			bRotateRightDown = true;
		}
		else if(EventParms.InputKeyName=='Z' || EventParms.InputKeyName=='XboxTypeS_LeftTrigger')
		{
			bRotateLeftDown = true;
		}
	}
	else if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='Z' || EventParms.InputKeyName=='XboxTypeS_LeftTrigger')
		{
			bRotateLeftDown = false;
		}
		else if(EventParms.InputKeyName=='X' || EventParms.InputKeyName=='XboxTypeS_RightTrigger')
		{
			bRotateRightDown=false;
		}
	}

	return bResult;
}


/**
 * Called when the accepts a current list selection.
 *
 * @param	PartType	The type of part we are changing.
 * @param	string		The id of the part we are changing.
 */
function OnPartSelected( ECharPart PartType, string PartID )
{
	OnAccept();
}

/**
 * Called when the user changes the selected index of a parts list.
 *
 * @param	PartType	The type of part we are changing.
 * @param	string		The id of the part we are changing.
 */
function OnPreviewPartChanged( ECharPart PartType, string PartID )
{
	PreviewActor.SetPart(PartType, PartID);
}

/** Updates the paper doll part visibility using the current/previous part panels. */
function UpdatePaperDoll()
{
	local int PreviousIdx;
	local int CurrentIdx;


	PreviousIdx = CustomizationList.OldSelection;
	CurrentIdx = CustomizationList.Selection;

	if(PreviousIdx != INDEX_NONE)
	{
		//PartImages[PreviousIdx].SetVisibility(false);
		PartImages[PreviousIdx].PlayUIAnimation('FadeOut',None,6.0);
	}

	if(CurrentIdx != INDEX_NONE)
	{
		PartImages[CurrentIdx].SetVisibility(true);
		PartImages[CurrentIdx].PlayUIAnimation('FadeIn',None,6.0);
	}

	ActivateLevelEventForCurrentPart();
}

/** Activates the level kismet remote event for the currently selected part. */
function ActivateLevelEventForCurrentPart()
{
	local name EventName;

	switch(CustomizationList.GetSelectedCharPartType())
	{
	case PART_Boots:
		EventName = 'CharacterCustomization_Boots';
		break;
	case PART_Thighs:
		EventName = 'CharacterCustomization_Thighs';
		break;
	case PART_Arms:
		EventName = 'CharacterCustomization_Arms';
		break;
	case PART_Torso:
		EventName = 'CharacterCustomization_Torso';
		break;
	case PART_ShoPad:
		EventName = 'CharacterCustomization_ShoPad';
		break;
	case PART_Helmet:
		EventName = 'CharacterCustomization_Helmet';
		break;
	case PART_Facemask:
		EventName = 'CharacterCustomization_Facemask';
		break;
	case PART_Goggles:
		EventName = 'CharacterCustomization_Goggles';
		break;
	}

	ActivateLevelEvent(EventName);
}

defaultproperties
{
	CameraRotationSpeed=72
	Faction="IronGuard"
	CharacterID="A"
}
