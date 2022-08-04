/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTUITabPage_MapTab extends UTTabPage;

var transient UTUIButtonBar MyButtonBar;
var transient UTDrawMapPanel Map;
var transient UTSimpleList ObjectivePrefs;

var transient UTUIScene_MidGameMenu UTSceneOwner;
var transient UTUICollectionCheckBox PopupMapOnDeath;
var transient bool bAllowTeleport;
var transient bool bAllowSpawn;

var transient bool bIgnoreChange;

function PostInitialize()
{
	local UTPlayerController PC;
	Super.PostInitialize();

    UTSceneOwner = UTUIScene_MidGameMenu(GetScene());

	Map = UTDrawMapPanel(FindChild('MapPanel',true));
	ObjectivePrefs = UTSimpleList(FindChild('ObjectivePrefs',true));
	ObjectivePrefs.OnDrawItem = OnDrawItem;

    PopupMapOnDeath = UTUICollectionCheckBox( FindChild('PopupMapOnDeath',true));
    PopupMapOnDeath.OnValueChanged = PopupSaved;

	if ( !ClassIsChildOf(UTSceneOwner.GetWorldInfo().GetGameClass(), class'UTOnslaughtGame' ) )
	{
		FindChild('SpawnOptions',true).SetVisibility(False);
		PopupMapOnDeath.SetVisibility(False);
	}

	ObjectivePrefs.OnSelectionChange = None;
	ObjectivePrefs.Empty();
/*
	ObjectivePrefs.AddItem("Disabled");
	ObjectivePrefs.AddItem("No Preference");
	ObjectivePrefs.AddItem("Attack");
	ObjectivePrefs.AddItem("Defend");
	ObjectivePrefs.AddItem("Orb Runner");
	ObjectivePrefs.AddItem("Special Ops");
*/

	ObjectivePrefs.AddItem("<Strings:UTGameUI.MidGameMenu.ObjectivePrefsDisabled>");
	ObjectivePrefs.AddItem("<Strings:UTGameUI.MidGameMenu.ObjectivePrefsNoPreference>");
	ObjectivePrefs.AddItem("<Strings:UTGameUI.MidGameMenu.ObjectivePrefsAttack>");
	ObjectivePrefs.AddItem("<Strings:UTGameUI.MidGameMenu.ObjectivePrefsDefend>");
	ObjectivePrefs.AddItem("<Strings:UTGameUI.MidGameMenu.ObjectivePrefsOrbRunner>");
	ObjectivePrefs.AddItem("<Strings:UTGameUI.MidGameMenu.ObjectivePrefsSpecialOps>");


	PC = UTSceneOwner.GetUTPlayerOwner();
	ObjectivePrefs.SelectItem( int(PC.AutoObjectivePreference) );

	// Set the Delegate
	ObjectivePrefs.OnSelectionChange = SelectionChange;
	ObjectivePrefs.OnDrawSelectionBar =  OnDrawSelectionBar;

	OnPreRenderCallback = PreRenderCallback;

}

function PreRenderCallback()
{
	OnPreRenderCallback = None;
	bIgnoreChange=false;
}

function PopupSaved( UIObject Sender, int PlayerIndex )
{
	local UIDataStorePublisher Publisher;
	local array<UIDataStore> BoundDataStores;

	if ( !bIgnoreChange )
	{
		Publisher = UIDataStorePublisher(Sender);

		if ( Publisher != None )
		{
			Publisher.SaveSubscriberValue(BoundDataStores);
			UTSceneOwner.bNeedsProfileSave = true;
		}
	}
}

function bool OnDrawItem(UTSimpleList SimpleList, int ItemIndex, float XPos, out float YPos)
{
	local float xl, yl, CellHeight, TextScale, ImgScale;
	local string text;
	local vector2D ViewportSize;

	Text = SimpleList.List[ItemIndex].Text;

	GetViewportSize(ViewportSize);

	CellHeight = SimpleList.DefaultCellHeight * (ViewportSize.Y / 768);
	SimpleList.Canvas.StrLen("Q",XL,YL);
	TextScale = (YL > CellHeight) ? CellHeight / YL : 1.0;
	ImgScale  = (20 > CellHeight) ? CellHeight / 20 : 1.0;

	if ( ItemIndex == SimpleList.Selection )
	{
		if ( SimpleList.IsFocused() )
		{
			SimpleList.Canvas.SetPos(0,YPos);
			SimpleList.Canvas.DrawColor = SimpleList.SelectionBarColor;
			SimpleList.Canvas.DrawRect(SimpleList.Canvas.ClipX, CellHeight);
		}

		SimpleList.Canvas.DrawColor = SimpleList.SelectedColor;
	}
	else
	{
		SimpleList.Canvas.DrawColor = SimpleList.NormalColor;
	}

	// Draw the text

	SimpleList.Canvas.StrLen(Text,XL,YL);
	SimpleList.Canvas.SetPos(SimpleList.Canvas.ClipX - (23 * ImgScale) - (XL * TextScale),YPos);
	SimpleList.Canvas.DrawTextClipped(Text,,TextScale,TextScale);

	// Draw the Image

	SimpleList.Canvas.SetPos(SimpleList.Canvas.ClipX - (21 * ImgScale), YPos + (CellHeight - (16 * ImgScale)) * 0.5);

	if ( ItemIndex == SimpleList.Selection )
	{
		SimpleList.Canvas.DrawTile(class'UTHud'.default.IconHudTexture, 21 * ImgScale, 16* ImgScale, 725,158,21,16);
	}
	else
	{
		SimpleList.Canvas.DrawTile(class'UTHud'.default.IconHudTexture, 21 * ImgScale, 16* ImgScale, 725,142,21,16);
	}

	SimpleList.List[ItemIndex].bWasRendered = true;

	return true;
}

function bool OnDrawSelectionBar( UTSimpleList SimpleList, float YPos )
{
	return true;
}


function SelectionChange(UTSimpleList SourceList, int NewSelectedIndex)
{
	local UTPlayerController PC;

	if ( !bIgnoreChange )
	{
		PC = UTSceneOwner.GetUTPlayerOwner();
		PC.AutoObjectivePreference = EAutoObjectivePreference(ObjectivePrefs.Selection);
	}
}

function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	Super.SetupButtonBar(ButtonBar);
	MyButtonBar = ButtonBar;
	ButtonBar.AppendButton("<Strings:UTGameUI.MidGameMenu.ChangePref>", OnChangePref);

	if (bAllowTeleport)
	{
		MyButtonBar.SetButton(3,"<Strings:UTGameUI.OnslaughtMap.SelectionText>", OnSelectDest);
	}
	else if (bAllowSpawn)
	{
		MyButtonBar.SetButton(3, "<Strings:UTGameUI.MidGameMenu.SetSpawnLoc>", OnSetSpawn);
	}
}

function AllowTeleporting()
{
	bAllowTeleport = true;
	MyButtonBar.SetButton(3,"<Strings:UTGameUI.OnslaughtMap.SelectionText>", OnSelectDest);
	Map.OnActorSelected = MapActorSelected;
	Map.SetFocus(none);
	Map.FindBestActor();
}

function AllowSpawning()
{
	bAllowSpawn = true;
	MyButtonBar.SetButton(3, "<Strings:UTGameUI.MidGameMenu.SetSpawnLoc>", OnSetSpawn);
	Map.OnActorSelected = SpawnPointSelected;
	Map.SetFocus(none);
	Map.FindBestActor();

}

function bool OnChangePref(UIScreenObject InButton, int InPlayerIndex)
{
	local int i;
	i = ObjectivePrefs.Selection;
	i++;
	if ( i >= ObjectivePrefs.List.Length )
	{
		i = 0;
	}
	ObjectivePrefs.SelectItem(i);

	return true;

}

function SpawnPlayer(UTPlayerController PC)
{
	local UTPlayerReplicationInfo PRI;
	local UTGameObjective Dest;
	local UTMapInfo MI;
	if ( PC != none )
	{
		PRI = UTPlayerReplicationInfo(PC.PlayerReplicationInfo);
		if ( PRI != none )
		{
			MI = Map.GetMapInfo();
			if ( MI != none && MI.CurrentActor != none )
			{
				Dest = UTGameObjective(MI.CurrentActor);
				if ( Dest != none )
				{
					PRI.SetStartObjective(Dest,true);
				}
			}
			PC.ServerRestartPlayer();
			CloseParentScene();
		}
	}
}



function bool OnSetSpawn(UIScreenObject InButton, int InPlayerIndex)
{
   	local UTPlayerController UTPC;

	UTPC = UTUIScene(GetScene()).GetUTPlayerOwner(InPlayerIndex);
	if ( UTPC != none )
	{
		SpawnPlayer(UTPC);
	}
	return true;
}


function SpawnPointSelected(Actor Selected, UTPlayerController UTPC)
{
	SpawnPlayer(UTPC);
}


/**
 * Teleport to the node
 */
function bool OnSelectDest(UIScreenObject InButton, int InPlayerIndex)
{
	local UTPlayerController UTPC;
	local UTMapInfo Mi;
	UTPC = UTUIScene(GetScene()).GetUTPlayerOwner();
	if ( UTPC != none && Map != none )
	{
		MI = Map.GetMapInfo();
		if ( MI != none && MI.CurrentActor != none )
		{
			TeleportToActor( UTPC, MI.CurrentActor);
		}
	}
	return true;
}


/**
 * Call back - Attempt to teleport
 */
function MapActorSelected(Actor Selected, UTPlayerController SelectedBy)
{
	if ( SelectedBy != none && Selected != none && Map != none )
	{
		TeleportToActor(SelectedBy, Selected);
	}
}

function TeleportToActor(UTPlayerController PCToTeleport, Actor Destination)
{
	if ( PCToTeleport != none && Destination != none )
	{
		UTPlayerReplicationInfo(PCToTeleport.PlayerReplicationInfo).ServerTeleportToActor(Destination);
		CloseParentScene();
	}
}


function bool HandleInputKey( const out InputEventParameters EventParms )
{
	if(EventParms.EventType==IE_Released)
	{
		if ( EventParms.InputKeyName == 'F2' || EventParms.InputKeyName == 'XboxTypeS_Y' )
		{
			CloseParentScene();
			return true;
		}

		if(EventParms.InputKeyName=='XboxTypeS_X')
		{
			OnChangePref(none, EventParms.PlayerIndex);
			return true;
		}
		if(EventParms.InputKeyName=='XboxTypeS_A')
		{
			if ( bAllowTeleport )
			{
				OnSelectDest(none, EventParms.PlayerIndex);
			}
			else if ( bAllowSpawn )
			{
				OnSetSpawn(none, EventParms.PlayerIndex);
			}

			return true;
		}
		if (EventPArms.InputKeyName == 'XboxTypeS_LeftTrigger')
		{
			PopupMapOnDeath.SetValue( !PopupMapOnDeath.IsChecked() );
		}
	}

	return false;
}


defaultproperties
{
	bIgnoreChange=true
}
