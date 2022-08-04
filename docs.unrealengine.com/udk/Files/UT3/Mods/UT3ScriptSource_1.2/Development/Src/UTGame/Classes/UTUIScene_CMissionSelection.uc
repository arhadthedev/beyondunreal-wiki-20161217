/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_CMissionSelection extends UTUIScene_Campaign
	native(UI);

var transient UTUIButtonBar ButtonBar;
var transient UTUIOptionButton NextMission;
var transient UILabel NextMissionCaption;
var transient UIImage NextMissionBox;
var transient UTUIDataStore_StringList StringStore;

var transient UIImage MissionNotesBKG;
var transient UILabel MissionNotesTitle;
var transient UILabel MissionNotes_Title;
var transient UILabel MissionNotes_Type;
var transient UILabel MissionNotes_Region;

var transient UIPanel FadePanel;

var transient UILabel MissionNotes_ExtendedDesc;
var transient UIPanel SizePanel;
var transient UIPanel HeaderPanel;

var transient UIImage PlayerBox;
var transient UILabel PlayerLabels[4];
var transient UIImage PlayerReady[4];

var transient UIPanel CardPanel;
var transient UTSimpleImageList CardImgList;
var transient UILabel CardDesc;

var transient UIImage CardImage;

var editconst AudioComponent AudioPlayer;

var transient UTSeqObj_SPMission PreviousMissionObj;

var transient bool bIsHost;

var transient int CurrentMissionID, PendingMissionID;

var transient bool bShowingDetails;

var SoundCue AnimCues[2];
var editconst AudioComponent AnimAudioPlayer;

var transient int CurrentSelectionIndex;

var transient bool bSelectingCard;
var transient bool bSingleMission;



event Initialized()
{
	local UISkin Skin;

	if ( IsGame() )
	{
		// make sure we're using the right skin
		Skin = UISkin(DynamicLoadObject("UI_Skin_Derived.UTDerivedSkin",class'UISkin'));
		if ( Skin != none )
		{
			SceneClient.ChangeActiveSkin(Skin);
		}
	}

	Super.Initialized();
}


/**
 * Setup the various UI elements
 */
event PostInitialize()
{
	local int i;

	Super.PostInitialize();

	ButtonBar = UTUIButtonBar(FindChild('ButtonBar',true));

	// Get all the UI controls

	NextMission = UTUIOptionButton(FindChild('NextMission',true));
	NextMissionCaption = UILabel( FindChild('NextMissionCaption',true));
	NextMissionBox = UIImage( FindCHild('NextMissionBox',true));

	MissionNotesTitle = UILabel( FindChild('MissionNotesTitle',true));
	MissionNotesBKG = UIImage( FindChild('MissionNotesBKG',true));
	MissionNotes_Title = UILabel( FindChild('MissionNotes_Title',true));
	MissionNotes_Type = UILabel( FindChild('MissionNotes_Type',true));
	MissionNotes_Region = UILabel( FindChild('MissionNotes_Region',true));

	MissionNotes_ExtendedDesc = UILabel( FindChild('MissionNotes_ExtendedDesc',true));
	SizePanel = UIPanel( Findchild('SizePanel',True) );
	HeaderPanel= UIPanel( Findchild('HeaderPanel',True) );
	FadePanel = UIPanel( FindCHild('FadePanel',true) );
    PlayerBox = UIImage (FindChild('PlayerBox',true));
    PlayerBox.SetVisibility(true);

	for (i=0;i<4;i++)
	{
	    PlayerLabels[i] = UILabel( FindChild(name("PlayerLabel"$i),true));
	    PlayerReady[i] = UIImage (FindChild(name("ReadyU"$i),true));
	}

	CardPanel = UIPanel(FindChild('CardPanel',true));
	CardPanel.SetVisibility(false);
    CardImgList = UTSimpleImageList(FindChild('CardImgList',true));
    CardImgList.OnSelectionChange = CardImgListOnSelectionChange;
    CardImgList.OnItemChosen = CardChosen;
    CardDesc = UILabel(FindChild('CardDesc',true));

	CardImage = UIImage(FindChild('CardImage',true));

	NextMission.OnValueChanged = NextMissionValueChanged;

	// Get a pointer to the string list

	StringStore = UTUIDataStore_StringList( ResolveDataStore('UTStringList') );
	if ( StringStore != none )
	{
		StringStore.Empty('MissionList');
	}
	else
	{
		return;
	}
}

/**
 * Cleanup
 */
function NotifyGameSessionEnded()
{
	PreviousMissionObj=none;
}

/**
 * This is called from the PRI when the results of the last mission are in/replicated.
 * It will generate a list of missions and fill everything out.
 *
 * @param Result	The result of the last mission
 */
function InitializeMissionMenu(ESinglePlayerMissionResult MissionResult, bool bYouAreHost, int LastMissionID, UTMissionGRI MGRI)
{
	local int i;
	local UTSeqObj_SPMission MissionObj;

	bIsHost = bYouAreHost;


	if ( ButtonBar != none )
	{
		if (bIsHost)
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.Campaign.EndCampaign>", OnButtonBar_Back);
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.AcceptMission>", OnButtonBar_MissionAccept);
			ButtonBar.AppendButton("<Strings:UTGameUI.Campaign.PlayCard>", OnButtonBar_PlayCard);
		}
		else
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.Campaign.LeaveCampaign>", OnButtonBar_Back);
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Ready>", OnButtonBar_MissionAccept);
			NextMissionBox.SetVisibility(false);
		}
	}

	ButtonBar.AppendButton("<Strings:UTGameUI.Campaign.MissionDetails>", OnButtonBar_Details);

	if ( NextMission != none && !bIsHost )
	{
		NextMission.SetVisibility(false);
		NextMissionCaption.SetVisibility(false);
	}

	// Prime the combo box

	if ( bYouAreHost )
	{
		StringStore.Empty('MissionList',MGRI.AvailMissionList.length > 0);

		for (i=0;i<MGRI.AvailMissionList.length;i++)
		{
			StringStore.AddStr('MissionList',MGRI.AvailMissionList[i].Title,i < Max(1, MGRI.AvailMissionList.length - 1));
		}
	}

	// Play Malcolms speach

	MissionObj = MGRI.GetMissionObj(LastMissionID);
	if ( MissionObj != none )
	{
		if ( MissionObj.MalcolmSounds[INT(MissionResult)] != none )
		{
			AudioPlayer.SoundCue = MissionObj.MalcolmSounds[INT(MissionResult)];
			AudioPlayer.Play();
		}
	}

	if (GetWorldInfo().Role == ROLE_Authority)
	{
		NextMission.SetCurrentIndex(0);
	}

	// Only 1 mission, shut selection down.
	if (MGRI.AvailMissionList.Length == 1)
	{
		bSingleMission = true;
		NextMissionBox.SetVisibility(False);
	}

}

function bool OnButtonBar_PlayCard(UIScreenObject InButton, int InPlayerIndex)
{
	ToggleCardSelection(true);
	return true;
}

function bool OnButtonBar_AcceptPlayCard(UIScreenObject InButton, int InPlayerIndex)
{
	AcceptCard();
	return true;
}

function bool OnButtonBar_ClearCard(UIScreenObject InButton, int InPlayerIndex)
{
	ClearCard();
	return true;
}

function bool OnButtonBar_MissionAccept(UIScreenObject InButton, int InPlayerIndex)
{
	AcceptMission(InPlayerIndex);
	return true;
}

function bool OnButtonBar_Details(UIScreenObject InButton, int InPlayerIndex)
{
	ToggleDetails();
	return true;

}

function ToggleDetails()
{
	local EMissionInformation Mission;
	local UTMissionGRI MGRI;

	if ( bShowingDetails )
	{
		SizePanel.PlayUIAnimation('ContractDetails',,3.5);
		FadePanel.PlayUIAnimation('FadeOut',,5.5);
		bShowingDetails = false;
		ButtonBar.SetVisibility(false);
		AnimAudioPlayer.SoundCue = AnimCues[0];
		AnimAudioPlayer.Play();

	}
	else
	{
		SizePanel.PlayUIAnimation('ExpandDetails',,3.5);
		FadePanel.PlayUIAnimation('FadeIn',,5.5);

		bShowingDetails = true;

		MGRI = UTMissionGRI( GetWorldInfo().GRI );
		if ( MGRI != none )
		{
			if ( MGRI.GetCurrentMission(Mission) )
			{
				MissionNotes_ExtendedDesc.SetDataStoreBinding(Mission.BriefingText);
				MissionNotes_ExtendedDesc.SetVisibility(true);
				ButtonBar.SetVisibility(false);
			}
		}

		AnimAudioPlayer.SoundCue = AnimCues[1];
		AnimAudioPlayer.Play();

	}
}

/**
 * Call when it's time to go back to the previous scene
 */
function AcceptMission(int PlayerIndex)
{
	local UTPlayerController UTPlayerOwner;
	local UTMissionSelectionPRI PRI;

	UTPlayerOwner = GetUTPlayerOwner(PlayerIndex);
	if ( UTPlayerOwner != none )
	{
		PRI = UTMissionSelectionPRI(UTPlayerOwner.PlayerReplicationInfo);
		if ( PRI != none )
		{
			PRI.AcceptMission();
		}
	}


}

/**
 * Call when it's time to go back to the previous scene
 */
function bool Scene_Back()
{
	local UTUIScene_MessageBox MB;

	if (bSelectingCard)
	{
		ToggleCardSelection(false);
	}
	else
	{

		MB = GetMessageBoxScene();
		if (MB!=none)
		{
			MB.DisplayAcceptCancelBox("<Strings:UTGameUI.Campaign.EndCampaignMsg>","<Strings:UTGameUI.Campaign.Confirmation", MB_Selection);
		}

	}
	return true;
}

function MB_Selection(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	if (SelectedOption==0)
	{
		CloseScene(self);
		GetUTPlayerOwner().QuitToMainMenu();
	}
}



/**
 * Button bar callbacks - Back Button
 */
function bool OnButtonBar_Back(UIScreenObject InButton, int InPlayerIndex)
{
	return Scene_Back();
}



function NextMissionValueChanged( UIObject Sender, int PlayerIndex )
{
	local int NewMissionIndex;
	local UTMissionSelectionPRI PRI;
	local UTMissionGRI MGRI;

	if (bSingleMission)
	{
		return;
	}

	MGRI= UTMissionGRI(GetWorldInfo().GRI);

	NewMissionIndex = NextMission.GetCurrentIndex();
	if ( NewMissionIndex >= 0 )
	{
		PRI = UTMissionSelectionPRI( GetPRIOwner() );
		if ( PRI != none )
		{
			PRI.ChangeMission( MGRI.AvailMissionList[NewMissionIndex].MissionID );
		}
	}
}

function ChangeSelection(int NewSelectionIndex)
{
	local int NewMissionIndex;
	local UTMissionSelectionPRI PRI;
	local UTMissionGRI MGRI;

	MGRI= UTMissionGRI(GetWorldInfo().GRI);

	if (bSingleMission)
	{
		return;
	}

	NewMissionIndex = NextMission.GetCurrentIndex();
	if ( NewMissionIndex >= 0 )
	{

		if ( NewSelectionIndex < 0 )
		{
			NewSelectionIndex = MGRI.AvailMissionList.Length-1;
		}
		else if (NewSelectionIndex >= MGRI.AvailMissionList.Length)
		{
			NewSelectionIndex = 0;
		}

		CurrentSelectionIndex = NewSelectionIndex;

		PRI = UTMissionSelectionPRI( GetPRIOwner() );
		if ( PRI != none )
		{
			PRI.ChangeMission( MGRI.AvailMissionList[CurrentSelectionIndex].MissionID );
		}
	}
}

function FindMissionNearestToCursor(LocalPlayer LocalPlayerOwner)
{
	local EMissionInformation Mission;
	local UTMissionGRI MGRI;
	local vector Loc,Screen, Mouse;
	local UTSPGlobe Globe;
	local int i;
	local float Dist, BestDist;
	local int BestID;
	local INT X,Y;
	local Vector2D ViewSize;

	if (bSingleMission)
	{
		return;
	}

	GetViewportSize(ViewSize);

	class'UIRoot'.static.GetCursorPosition( X, Y );
	Mouse.X = X;
	Mouse.Y = Y;

	BestID = -1;
	MGRI= UTMissionGRI(GetWorldInfo().GRI);
	if ( MGRI != none )
	{
		for (i=0;i<MGRI.AvailMissionList.Length;i++)
		{
			if ( MGRI.GetMission(MGRI.AvailMissionList[i].MissionID, Mission) )
			{
				if ( MGRI.FindGlobe(Mission.GlobeTag, Globe) )
				{
					Loc = Globe.SkeletalMeshComponent.GetBoneLocation(Mission.GlobeBoneName);
					ViewportProject(LocalPlayerOwner, Loc, Screen);

					Dist = Abs(Vsize(Screen - Mouse)) / (ViewSize.Y / 768);

		    if (Dist < 30)
		    {
		    	if (BestID<0 || Dist < BestDist)
		    	{
		    		BestDist = Dist;
		    		BestID = i;
		    	}
		    }
				}
			}
		}

		if ( BestID >=0 )
		{
			NextMission.SetCurrentIndex(BestID);
		}
	}
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
    local vector Start,Dir;
    local UTPlayerController PC;

	if (bSelectingCard)
	{
		if (EventParms.EventType==IE_Released)
		{
			if (EventParms.InputKeyName=='XboxTypeS_A')
			{
				AcceptCard();
				return true;
			}

			if ( EventParms.InputKeyName == 'XboxTypeS_B' || EventParms.InputKeyName == 'Escape' )
			{
				ToggleCardSelection(false);
				return true;
			}

			if (EventParms.InputKeyName=='XboxTypeS_X' )
			{
				ClearCard();
				return true;
			}
		}
		return true;

	}

	if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_A')
		{
			AcceptMission(EventParms.PlayerIndex);
			return true;
		}

		else if (EventParms.InputKeyName== 'XboxTypeS_B' || EventParms.InputKeyName =='Escape')
		{
			Scene_Back();
			return true;
		}

		if(EventParms.InputKeyName=='XboxTypeS_X')
		{
			ToggleCardSelection(true);
			return true;
		}
		if(EventParms.InputKeyName=='XboxTypeS_Y')
		{
			ToggleDetails();
			return true;
		}
		if (EventParms.InputKeyName=='F7')
		{
			GetPlayerProfile().AddPersistentKey(ESPKey_IronGuardUpgrade);
		}
		if (EventParms.InputKeyName=='F8')
		{
			GetPlayerProfile().RemovePersistentKey(ESPKey_IronGuardUpgrade);
		}

	}
	else
	{
		if (EventParms.EventType == IE_Pressed)
		{
			if (EventParms.InputKeyName == 'LeftMouseButton')
			{
				PC = GetUTPlayerOwner();
				if ( PC != none )
				{
					FindMissionNearestToCursor( GetPlayerOwner(EventParms.PlayerIndex) );
				}

				GetWorldInfo().DrawDebugLine(Start, Start+(Dir * 4096), 255, 255, 255, true);
				return true;
			}

		}

		if ( EventParms.InputKeyName == 'XboxTypeS_DPad_Left' || EventParms.InputKeyName == 'NumPadfour' || EventParms.InputKeyName == 'Left' )
		{
			if ( NextMission.IsFocused(EventParms.PlayerIndex) )
			{
				ChangeSelection(CurrentSelectionIndex-1);
			}
			return true;
		}

		if ( EventParms.InputKeyName == 'XboxTypeS_DPad_Right' || EventParms.InputKeyName == 'NumPadsix' || EventParms.InputKeyName == 'Right' )
		{
			if ( NextMission.IsFocused(EventParms.PlayerIndex) )
			{
				ChangeSelection(CurrentSelectionIndex+1);
			}
			return true;
		}
	}

	return false;
}


function CardImgListOnSelectionChange(UTSimpleImageList SourceList, int NewSelectedIndex)
{
	local name Card;
	Card = CardImgList.GetSelectedTag();
	if (Card != '')
	{
		CardDesc.SetDataStoreBinding( class'UTGameModifierCard'.static.GetDesc(Card));
	}
}


function MissionChanged(EMissionInformation NewMission)
{

	if (NewMission.MissionID != CurrentMissionID)
	{
		PendingMissionID = NewMission.MissionID;
		SizePanel.ClearUIAnimation('FadeIn');
		SizePanel.PlayUIAnimation('FadeOut',,3);
		HeaderPanel.PlayUIAnimation('FadeOut',,3);
		return;
	}
	if ( !MissionNotesBKG.IsVisible() )
	{
		MissionNotesBKG.SetVisibility(true);
	}
	FinishMissionChanged(NewMission.MissionID);
}

function AnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq)
{
	if ( AnimSeq.SeqName == 'ExpandDetails' || AnimSeq.SeqName == 'ContractDetails' )
	{
		ButtonBar.SetVisibility(true);
	}
}

function FinishMissionChanged(int NewMissionID)
{
	local EMissionInformation Mission;
	local UTMissionGRI MGRI;

	PendingMissionID = -1;
	MGRI = UTMissionGRI( GetWorldInfo().GRI );
	if ( MGRI != none )
	{
		if ( MGRI.GetMission(NewMissionID, Mission) )
		{

			MissionNotesTitle.SetDatastoreBinding( "<Strings:UTGameUI.Campaign.CurrentMission>" );
			MissionNotes_Region.SetDatastoreBinding("<Strings:UTGameUI.Campaign.MissionNotes_Location><Color:R=0.4,G=0.4,B=0.4,A=1.0>"@Mission.Location);

			if (bIsHost && !bSelectingCard)
			{
				ButtonBar.SetButton(1, "<Strings:UTGameUI.ButtonCallouts.AcceptMission>", OnButtonBar_MissionAccept);
			}

			MissionNotes_Title.SetDatastoreBinding(Mission.Title);
			MissionNotes_Type.SetDatastoreBinding("<Strings:UTGameUI.Campaign.MissionNotes_Type><Color:R=0.4,G=0.4,B=0.4,A=1.0>"@MGRI.GetMissionStyleName(Mission.Style));
			MissionNotes_ExtendedDesc.SetDataStoreBinding(Mission.BriefingText);
			SizePanel.PlayUIAnimation('FadeIn',,3);
			HeaderPanel.PlayUIAnimation('FadeIn',,3);
		}
	}
}


function ToggleCardSelection(bool bOn)
{
	local int i;
	local UTProfileSettings Profile;
	local array<Name> Deck;
	local array<int> Count;

	if (!bIsHost)
	{
		return;
	}

	if (bOn)
	{

		Profile = GetPlayerProfile();
		Profile.GetDeck(Deck,Count);

		if (Deck.Length == 0)
		{
			DisplayMessageBox ("<Strings:UTGameUI.Campaign.NoCardsInDeck>", "<Strings:UTGameUI.Campaign.NoCardsInDeckTitle>");
			return;
		}

		CardImgList.Empty();
		for (i=0;i<Deck.Length;i++)
		{
			CardImgList.AddItem(Deck[i],Count[i],0,Class'UTGameModifierCard'.static.GetUVs(Deck[i], Profile));
		}

		ButtonBar.ToggleButton(2,false);
		ButtonBar.ToggleButton(3,false);
		ButtonBar.SetButton(0, "<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
		ButtonBar.SetButton(1, "<Strings:UTGameUI.ButtonCallouts.Select>", OnButtonBar_AcceptPlayCard);
		ButtonBar.SetButton(2, "<Strings:UTGameUI.Campaign.ClearCard>", OnButtonBar_ClearCard);

		CardPanel.SetVisibility(true);
		CardImgList.SetFocus(none);

		NextMissionBox.SetVisibility(False);

	}
	else
	{
		ButtonBar.ToggleButton(2,true);
		ButtonBar.ToggleButton(3,true);

		if (bIsHost)
		{
			ButtonBar.SetButton(0,"<Strings:UTGameUI.Campaign.EndCampaign>", OnButtonBar_Back);
		}
		else
		{
			ButtonBar.SetButton(0,"<Strings:UTGameUI.Campaign.LeaveCampaign>", OnButtonBar_Back);
		}

		ButtonBar.SetButton(1, "<Strings:UTGameUI.ButtonCallouts.AcceptMission>", OnButtonBar_MissionAccept);
		ButtonBar.SetButton(2, "<Strings:UTGameUI.Campaign.PlayCard>", OnButtonBar_PlayCard);
		CardPanel.SetVisibility(false);

		if (!bSingleMission)
		{
			NextMissionBox.SetVisibility(true);
		}
	}

	bSelectingCard = bOn;
}

function ClearCard()
{
	local UTPlayerController UTPlayerOwner;
	local UTMissionSelectionPRI PRI;

	UTPlayerOwner = GetUTPlayerOwner();
	if ( UTPlayerOwner != none )
	{
		PRI = UTMissionSelectionPRI(UTPlayerOwner.PlayerReplicationInfo);
		if ( PRI != none )
		{
	    	PRI.SetModifierCard('');
	    }
	}

	ToggleCardSelection(false);
}


function AcceptCard()
{
	local UTPlayerController UTPlayerOwner;
	local name Card;
	local UTMissionSelectionPRI PRI;

	Card = CardImgList.GetSelectedTag();
	UTPlayerOwner = GetUTPlayerOwner();
	if ( UTPlayerOwner != none )
	{
		PRI = UTMissionSelectionPRI(UTPlayerOwner.PlayerReplicationInfo);
		if ( PRI != none )
		{
	    	PRI.SetModifierCard(Card);
	    }
	}

	ToggleCardSelection(false);
}

function ModifierCardChanged(name Card, UTMissionGRI MGRI)
{
	if ( Card != '' )
	{
		// Add Animation Here
		CardImage.ImageComponent.SetCoordinates(class'UTGameModifierCard'.static.GetUVs(Card, GetPlayerProfile()));
		CardImage.SetVisibility(true);
	}
	else
	{
		// Add Animation Here
		CardImage.SetVisibility(false);
	}
}

function CardChosen(UTSimpleImageList SourceList, int SelectedIndex, int PlayerIndex)
{
	AcceptCard();
}

defaultproperties
{
	Begin Object class=AudioComponent Name=ACPlayer
		bAllowSpatialization=false
	End Object
	AudioPlayer=ACPlayer
	CurrentMissionID=-1
	PendingMissionID=-1


	Begin Object class=AudioComponent Name=AnimACPlayer
		bAllowSpatialization=false
	End Object
	AnimAudioPlayer=AnimACPlayer
	AnimCues(0)=soundcue'A_Interface.Menu.UT3ServerSignInCue'
	AnimCues(1)=SoundCue'A_Interface.Menu.UT3ServerSignOutCue'

}
