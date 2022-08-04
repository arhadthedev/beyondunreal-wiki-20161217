/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTUITabPage_Scoreboard extends UTTabPage_MidGame;


var transient array<UTScoreboardPanel> Scoreboards;
var transient UTScoreInfoPanel InfoPanel;

var UTUIButtonBar ButtonBarRef;
var int KickButtonIdx;

var int KickContextIdx;
var int AdminContextIdx;

var int SelectedSB;
var bool bContextMenuActive;

function PostInitialize()
{
	local Name PanelTag;
	local class<UTGame> GameClass;

	Super.PostInitialize();

	InfoPanel = UTScoreInfoPanel( FindChild('InfoPanel',true));

	if ( GetScene().GetWorldInfo().GRI.GameClass.Default.bTeamGame )
	{
		InfoPanel.SetPosition( 0.247424, UIFACE_Left, EVALPOS_PercentageOwner);
		InfoPanel.SetPosition( 0.002756, UIFACE_Top, EVALPOS_PercentageOwner);
		InfoPanel.SetPosition( 0.505429, UIFACE_Right, EVALPOS_PercentageOwner);
		InfoPanel.SetPosition( 0.167105, UIFACE_Bottom, EVALPOS_PercentageOwner);
	}

	GameClass = Class<UTGame>( GetScene().GetWorldInfo().GRI.GameClass);
	PanelTag = GameClass.Default.MidgameScorePanelTag;
	FindScoreboards(PanelTag);

	OnRawInputKey=None;

	OnPreRenderCallBack = RenderCallBack;
}

function RenderCallBack()
{
	local rotator R;
	if ( InfoPanel != none && GetScene().GetWorldInfo().GRI.GameClass.Default.bTeamGame )
	{
		R.Roll = 2736.6666; // 15 degrees
		InfoPanel.RotateWidget(r);
	}
}

final function UTVoteReplicationInfo GetVoteRI()
{
	return UTUIScene(GetScene()).GetUTPlayerOwner().VoteRI;
}

function SetupButtonBar(UTUIButtonBar ButtonBar)
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local OnlineSubsystem OnlineSub;
	local OnlineGameSettings GameSettings;
	local bool bIsLanMatch;

	Super.SetupButtonBar(ButtonBar);

	ButtonBarRef = ButtonBar;
	WI = GetScene().GetWorldInfo();
	GRI = UTGameReplicationInfo(WI.GRI);
	if ( GRI != None && GRI.CanChangeTeam() )
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ChangeTeam>", OnChangeTeam);
	}

	if (WI.NetMode != NM_StandAlone && !UTUIScene_MidGameMenu(GetScene()).bWaitingForReady)
	{
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None && OnlineSub.GameInterface != None)
		{
		   GameSettings = OnlineSub.GameInterface.GetGameSettings();
		   bIsLanMatch = GameSettings.bIsLanMatch;
		}
		
		if (!bIsLanMatch)
		{
			if ( UTUIScene(GetScene()).GetPRIOwner().bAdmin )
			{
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.PlayerAdmin>", OnPlayerDetails);
			}
			else
			{
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.SendMessage>", OnPlayerDetails);
			}
		}
	}
}

function FindScoreboards(name PanelTagName)
{
	local int i;
	local array<UIObject> Kids;
	local UTScoreboardPanel SB;
	local UIPanel Panel;

	Panel = UIPanel( FindChild(PanelTagName,true));
	if ( Panel == none )
	{
		`log("ERROR: Could not find Scoreboard panel ["$PanelTagName$"] so MidGame Scoreboard is broken.");
		return;
	}

	Panel.SetVisibility(true);
	Kids = Panel.GetChildren(true);

	for (i=0;i<Kids.Length;i++)
	{
		SB = UTScoreboardPanel(Kids[i]);
		if ( SB != none )
		{
			Scoreboards[Scoreboards.Length] = SB;
			SB.OnSelectionChange = None;
			SB.OnOpenContextMenu = InitScoreboardContextMenu;
			SB.OnCloseContextMenu = ScoreboardContextMenuClose;
			SB.OnContextMenuItemSelected = ScoreboardContextMenuSelect;
			SB.NotifyActiveStateChanged = OnNotifyActiveStateChanged;
			SB.OnDoubleClick = OnDoubleClick;
		}
	}
}

function UTPlayerReplicationInfo GetSelectedPRI()
{
	local int i;
	local WorldInfo WI;
	WI = UTUIScene(GetScene()).GetWorldInfo();
	for (i=0;i<WI.GRI.PRIArray.Length;i++)
	{
		if (WI.GRI.PRIArray[i].PlayerID == Scoreboards[SelectedSB].SelectedPI)
		{
			return UTPlayerReplicationInfo(WI.GRI.PRIArray[i]);
		}
	}
	return none;
}	   

function OnDoubleClick( UIScreenObject EventObject, int PlayerIndex )
{
	OnPlayerDetails(EventObject, PlayerIndex);
}

function bool OnPlayerDetails(UIScreenObject InButton, int InPlayerIndex)
{
	local UTUIScene_PlayerCard PCScene;
	local UTUIScene Scene;
	local bool bIsAdmin, bIsLocal, bkick, bban;
	local UTPlayerController PC;
	local GameUISceneClient SC;
	local WorldInfo WI;
	local string PName, PAlias;
	local UTPlayerReplicationInfo SelectedPRI;
	local OnlineSubsystem OnlineSub;
	local OnlineGameSettings GameSettings;

	Scene = UTUIScene(GetScene());

	// don't allow someone spamming on A to confuse the quitting to main menu dialog
	SC = class'UIRoot'.static.GetSceneClient();
	if (UTUIScene_MidGameMenu(Scene).bReturningToMainMenu || SC.ActiveScenes[SC.ActiveScenes.length-1] != Scene)
	{
		return false;
	}

	WI = Scene.GetWorldInfo();

	//LAN matches don't do details
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None && OnlineSub.GameInterface != None)
	{
		GameSettings = OnlineSub.GameInterface.GetGameSettings();
	}

	if ((WI.NetMode == NM_Standalone) || (GameSettings != None && GameSettings.bIsLanMatch))
	{
		Scene.DisplayMessageBox ("<Strings:UTGameUI.MidGameMenu.CantViewLan>");
		return true;
	}

	PC = Scene.GetUTPlayerOwner();
	bIsAdmin = PC.PlayerReplicationInfo.bAdmin;
	bIsLocal = WI.NetMode == NM_Standalone || WI.NetMode == NM_ListenServer;

	SelectedPRI = GetSelectedPRI();
	if ( SelectedPRI != None && SelectedPRI != PC.PlayerReplicationInfo  )
	{
		if ( SelectedPRI.bBot )
		{
			Scene.DisplayMessageBox ("<Strings:UTGameUI.MidGameMenu.DetailsWithBots>");
			return true;
		}

		bKick = bIsAdmin || bIsLocal;
		bBan  = bKick && !SelectedPRI.bBot;

		PName = SelectedPRI.PlayerName;
		PAlias = SelectedPRI.GetPlayerAlias();

		PCScene = Scene.ShowPlayerCard(SelectedPRI.UniqueId, PAlias, (PName == PAlias) ? "" : PName,bKick,bBan);	// FIXME - Add account name for PC
		if ( PCScene != none )
		{
			PCScene.OnSceneDeactivated = DetailsIsDone;
		    Scene.FindChild('MidGameSafeRegion',true).PlayUIAnimation('FadeOut',,3.0);
		}
	}
	else if (SelectedPRI == PC.PlayerReplicationInfo)
	{
		Scene.DisplayMessageBox ("<Strings:UTGameUI.MidGameMenu.CantViewSelf>");
	}
	else
	{
		Scene.DisplayMessageBox ("<Strings:UTGameUI.MidGameMenu.CantViewDetails>");
	}

	return true;
}

function DetailsIsDone( UIScene DeactivatedScene )
{
	GetScene().FindChild('MidGameSafeRegion',true).PlayUIAnimation('FadeIn',,3.0);
}


function bool OnChangeTeam(UIScreenObject InButton, int InPlayerIndex)
{
	local LocalPlayer LP;

   	LP = GetPlayerOwner(InPlayerIndex);
	if ( LP != none && LP.Actor != none )
	{
		LP.Actor.ChangeTeam();
		CloseParentScene();
	}
	return true;
}


/**
 * Setup Input subscriptions
 */
event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames )
{
	out_KeyNames[out_KeyNames.Length] = 'CloseScoreboard';
}

function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local OnlineSubsystem OnlineSub;
	local OnlineGameSettings GameSettings;
	local bool bIsLanMatch;

	if ( EventParms.InputKeyName == 'F1' )
	{
		CloseParentScene();
		return true;
	}


	if (EventParms.EventType == IE_Released)
	{
		if (EventParms.InputKeyName == 'XboxtypeS_X')
		{
			WI = GetScene().GetWorldInfo();
			GRI = UTGameReplicationInfo(WI.GRI);
			if ( GRI != None && GRI.CanChangeTeam() )
			{
				OnChangeTeam(none, EventParms.PlayerIndex);
				return true;
			}
		}
		else if (EventParms.InputKeyName =='XboxtypeS_A')
		{
			OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
			if (OnlineSub != None && OnlineSub.GameInterface != None)
			{
				GameSettings = OnlineSub.GameInterface.GetGameSettings();
				bIsLanMatch = GameSettings.bIsLanMatch;
			}

			if (!bIsLanMatch)
			{
				OnPlayerDetails(none, EventParms.PlayerIndex);
			}
			return true;
		}
		else if (EventParms.InputKeyName == 'MouseScrollUp')
		{
			Scoreboards[SelectedSB].ChangeSelection(-1);
		}
		else if (EventParms.InputKeyName == 'MouseScrollDown')
		{
			Scoreboards[SelectedSB].ChangeSelection(1);
		}
	}
	return true;
}

function bool OnKickVote(UIScreenObject InButton, int InPlayerIndex)
{
	return False;
}

function NotifyKickVoteConfirmed();

function KickSelectedPlayer()
{
	local UTPlayerReplicationInfo PRI;
	local UTVoteReplicationInfo VRI;

	PRI = GetSelectedPRI();
	VRI = GetVoteRI();

	if (PRI != none && VRI != none)
		VRI.ServerRecordKickVote(PRI.PlayerID, VRI.CurKickVoteIDs.Find(PRI.PlayerID) == INDEX_None);
}


function bool InitScoreboardContextMenu(UIObject Sender, int PlayerIndex, out UIContextMenu CustomContextMenu)
{
	local UTPlayerReplicationInfo ContextPRI;
	local UTVoteReplicationInfo VRI;
	local UTUI_ContextMenu UTContextMenu;
	local array<string> NullArray;
	local string PlayerStr;

	if (GetScene().GetWorldInfo().NetMode == NM_Standalone)
		return False;


	UTScoreboardPanel(Sender).SelectUnderCursor();
	ContextPRI = UTScoreboardPanel(Sender).GetPRIUnderCursor();


	if (ContextPRI != none)
		CustomContextMenu = GetScene().GetDefaultContextMenu();

	UTContextMenu = UTUI_ContextMenu(CustomContextMenu);


	if (UTContextMenu != none && ContextPRI != none)
	{
		// Empty the context menu
		NullArray.Length = 0;
		UTContextMenu.SetMenuItems(Sender, NullArray);


		// Add an admin menu selection (with the players name)
		PlayerStr = ContextPRI.GetPlayerAlias();

		AdminContextIdx = UTContextMenu.GetMenuItemCount(Sender);
		UTContextMenu.AddMenuItem(Sender, PlayerStr);


		// Add a kick vote selection
		VRI = GetVoteRI();

		if (VRI != none && VRI.bKickVotingEnabled && ContextPRI != UTUIScene(GetScene()).GetUTPlayerOwner().PlayerReplicationInfo)
		{
			KickContextIdx = UTContextMenu.GetMenuItemCount(Sender);

			if (VRI.CurKickVoteIDs.Find(ContextPRI.PlayerID) != INDEX_None)
				UTContextMenu.AddMenuItem(Sender, Localize("Scoreboards", "RemoveKickVote", "UTGameUI"));
			else
				UTContextMenu.AddMenuItem(Sender, Localize("Scoreboards", "KickVote", "UTGameUI"));
		}


		if (UTContextMenu.GetMenuItemCount(Sender) > 0)
		{
			bContextMenuActive = True;
			return True;
		}
	}
	else if (CustomContextMenu != none)
	{
		CustomContextMenu.Close();
	}


	return False;
}

function bool ScoreboardContextMenuClose(UIContextMenu ContextMenu, int PlayerIndex)
{
	bContextMenuActive = False;
	return True;
}

function ScoreboardContextMenuSelect(UIContextMenu ContextMenu, int PlayerIndex, int ItemIndex)
{
	if (ItemIndex == KickContextIdx)
	{
		KickSelectedPlayer();
	}
	else if (ItemIndex == AdminContextIdx)
	{
		OnPlayerDetails(None, 0);
	}

	bContextMenuActive = False;
}

/** Callback for when the object's active state changes. */
function OnNotifyActiveStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	local UTScoreboardPanel SBPanel;
	local int i;

	// Prevent this from closing the context menu as it opens
	if (bContextMenuActive)
		return;

	SBPanel = UTScoreboardPanel(Sender);
	if (SBPanel != None)
	{
		if( NewlyActiveState.Class == class'UIState_Focused' )
		{
			// OK, we just gained focus, so update the currently selected player.  This is important because when
			// switching between multiple visible scoreboards (such as during team games) we want the currently
			// selected player to be updated, too!
			if (SBPanel.SelectedPI == -1)
			{
				if (SBPanel.SelectedUIIndex == -1)
				{
					//We haven't made a previous selection
					if (SBPanel.FindSelfInScoreboard(i))
					{
						//We are in this scoreboard so point to that
						SBPanel.EnableScoreboard(i);
					}
					else
					{
						//Initialize to first element
						SBPanel.EnableScoreboard(0);
					}
				}
				else
				{
					//Initialize to previous selection
					SBPanel.EnableScoreboard();
				}
			}

			//need to switch scroll wheel focus to me
			for (i=0; i<Scoreboards.length; i++)
			{
				if (Scoreboards[i] == SBPanel && SelectedSB != i)
				{
					//Disable the previous scoreboard
					Scoreboards[SelectedSB].DisableScoreboard();
					SelectedSB = i;
				}
			}
		}
		else if( NewlyActiveState.Class == class'UIState_Active' )
		{
			if (SBPanel.SelectedPI == -1)
			{
				SBPanel.SelectUnderCursor();
			}

			//Sets focus which will call the code above
			SBPanel.EnableScoreboard(SBPanel.GetSelectedIndex());
		}
	}
}

defaultproperties
{
	SelectedSB=0;
	KickContextIdx=-1
	AdminContextIdx=-1
}
