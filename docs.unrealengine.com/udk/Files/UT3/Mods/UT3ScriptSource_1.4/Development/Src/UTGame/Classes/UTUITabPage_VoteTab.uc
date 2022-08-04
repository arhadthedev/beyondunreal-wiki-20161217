/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

Class UTUITabPage_VoteTab extends UTTabPage_MidGame;

enum EVoteListState
{
	VLS_Hidden,
	VLS_Visible,
	VLS_Disabled
};

var transient UTSimpleList MapVoteList;

var transient UILabel MapVoteInfo;
var transient UILabel ConText;

var transient int ConsoleTextCnt;
var transient bool bShowingVotes;
var transient int LastBestVoteIndex;
var transient int LastBestVoteCount;

/** list of local maps - used to get more friendly names when possible */
var array<UTUIDataProvider_MapInfo> LocalMapList;

var UTUIDataStore_2DStringList StringDataStore;


// New vote UI
var transient UIList GameList;
var transient UIList MapList;
var transient UIList MutatorList;
var int MutHeaderIndicies[2];

var transient UIImage GameListImg;
var transient UIImage GameListImgBG;
var transient UIImage MapListImg;
var transient UIImage MapListImgBG;
var transient UIImage MutatorListImg;
var transient UIImage MutatorListImgBG;

var transient UILabel VoteMenuHintLabel;

var transient UILabel GameListLabel;
var transient UILabel GameVotesLabel;
var transient UILabel MapListLabel;
var transient UILabel MapVotesLabel;
var transient UILabel MutatorListLabel;
var transient UILabel MutatorVotesLabel;

// Used to override (and reset) UIList cell/overlay styles, when displaying the winning votes
var UIStyleReference WinningVoteCellStyle;
var UIStyleReference WinningVoteOverlayStyle;
var UIStyleReference DefaultVoteCellStyle;
var UIStyleReference DefaultVoteOverlayStyle;

var bool bGameVotingInitialized;
var bool bMapVotingInitialized;
var bool bMutatorVotingInitialized;
var int LastPlayerCount;
var float LastPCountTimestamp;
var bool bRefreshVoteLists;
var float MapSwitchTimestamp;

function PostInitialize()
{
	local UTConsole Con;
	local int i;
	local array<UTUIResourceDataProvider> ProviderList;

	// Find Everything
	MapVoteList = UTSimpleList(FindChild('MapVoteList',true));
	MapVoteList.OnItemChosen = RecordVote;
	MapVoteList.OnDrawItem = DrawVote;
	MapVoteList.OnPostDrawSelectionBar = DrawVotePostSelectionBar;

	MapVoteInfo = UILabel(FindChild('MapVoteInfo',true));


	// New vote UI controls
	GameList = UIList(FindChild('lstGames', True));
	MapList = UIList(FindChild('lstMaps', True));
	MutatorList = UIList(FindChild('lstMutators', True));

	GameList.OnSubmitSelection = OnListSubmitSelection;
	MapList.OnSubmitSelection = OnListSubmitSelection;
	MutatorList.OnSubmitSelection = OnListSubmitSelection;


	GameListImg = UIImage(FindChild('imgGames', True));
	GameListImgBG = UIImage(FindChild('imgGamesBG', True));
	MapListImg = UIImage(FindChild('imgMaps', True));
	MapListImgBG = UIImage(FindChild('imgMapsBG', True));
	MutatorListImg = UIImage(FindChild('imgMutators', True));
	MutatorListImgBG = UIImage(FindChild('imgMutatorsBG', True));

	VoteMenuHintLabel = UILabel(FindChild('VoteMenuHint', True));

	GameListLabel = UILabel(FindChild('lblGames', True));
	GameVotesLabel = UILabel(FindChild('lblGameVotes', True));
	MapListLabel = UILabel(FindChild('lblMaps', True));
	MapVotesLabel = UILabel(FindChild('lblMapVotes', True));
	MutatorListLabel = UILabel(FindChild('lblMutators', True));
	MutatorVotesLabel = UILabel(FindChild('lblMutatorVotes', True));



	// Copy of the console...
	Con = UTConsole(GetPlayerOwner().ViewportClient.ViewportConsole);

	if (Con != none)
		ConsoleTextCnt = Con.TextCount - 5;


	// fill the local map list
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', ProviderList);

	for (i=0; i<ProviderList.Length; ++i)
		LocalMapList.AddItem(UTUIDataProvider_MapInfo(ProviderList[i]));


	// If winning votes have been set, then refresh the vote lists upon reopening the scene, so that the winning index is properly set
	bRefreshVoteLists = True;
}

/**
 * This tab is being ticked
 */
function TabTick(float DeltaTime)
{
	local UTConsole Con;
	local string Work;
	local UTVoteReplicationInfo VRI;
	local WorldInfo WI;

	// Update the Console
	if (bShowingVotes && ConText != None)
	{
		Con = UTConsole(GetPlayerOwner().ViewportClient.ViewportConsole);

		if (Con != none && ConsoleTextCnt != Con.TextCount)
		{
			Work = UTUIScene_MidGameMenu(GetScene()).ParseScrollback(Con.Scrollback);
			ConText.SetDatastoreBinding( Work );
			ConsoleTextCnt = Con.TextCount;
		}
	}

	VRI = GetVoteRI();

	if (GetScene() != none)
		WI = GetScene().GetWorldInfo();


	if (WI != none && WI.Netmode != NM_Standalone)
	{
		// Detect map switches, and refresh all of the vote lists upon map switch
		if (MapSwitchTimeStamp == 0 || WI.RealTimeSeconds < MapSwitchTimeStamp)
		{
			UpdateGameVoteLists(none);
			UpdateMapVoteLists(none);
			UpdateMutatorVoteLists(none);
		}
		else
		{
			if (bRefreshVoteLists || VRI == none || VRI.WinningGameIndex != 255 || VRI.WinningMapIndex != 255)
			{
				bRefreshVoteLists = False;

				if (bShowingVotes && (VRI == none || VRI.WinningGameIndex != 255 || VRI.WinningMapIndex != 255))
				{
					if (VRI == none || VRI.WinningGameIndex != 255)
						UpdateGameVoteLists(VRI);

					if (VRI == none || VRI.WinningMapIndex != 255)
						UpdateMapVoteLists(VRI);
				}
			}


			// When displaying the votes, periodically check for new players so that elements in the mutator list don't go out of date
			if (bShowingVotes && bMutatorVotingInitialized && GetPlayerCount() != LastPlayerCount
				&& GetPlayerOwner().Actor.WorldInfo.RealTimeSeconds - LastPCountTimestamp > 2.0)
			{
				LastPlayerCount = GetPlayerCount();
				UpdateMutatorVoteLists(VRI);
			}
		}

		MapSwitchTimeStamp = WI.RealTimeSeconds;
	}

	// Update the game's status
	CheckGameStatus();
}

function CheckGameStatus()
{
	local WorldInfo WI;

	WI = GetScene().GetWorldInfo();

	if (WI != none && bShowingVotes && GetVoteRI() != none && GetVoteRI().bVotingOver)
	{
		if (!GameList.IsHidden())
			SetGameVoteListState(VLS_Disabled);

		if (!MapList.IsHidden())
			SetMapVoteListState(VLS_Disabled);

		if (!MutatorList.IsHidden())
			SetMutatorVoteListState(VLS_Disabled);

		bShowingVotes = false;
		MapVoteList.SetVisibility(false);

		if (IsActivePage())
			UTUIScene_MidGameMenu(GetScene()).ActivateTab('ChatTab');
	}
}


function UTVoteReplicationInfo GetVoteRI()
{
	local UTPlayerController UTPC;

	UTPC = UTUIScene_MidGameMenu(GetScene()).GetUTPlayerOwner();

	return (UTPC != None) ? UTPC.VoteRI : None;
}

function RecordVote(UTSimpleList SourceList, int SelectedIndex, int PlayerIndex)
{
	local UTVoteReplicationInfo VoteRI;

	VoteRI = GetVoteRI();

	if (VoteRI != none)
		VoteRI.ServerRecordVoteFor(VoteRI.Maps[SourceList.Selection].MapID);
}


function BeginVoting(UTVoteReplicationInfo VoteRI)
{
	local int i;

	bShowingVotes = True;

	if (VoteRI == none)
		return;


	if (VoteRI.bSupportsNewVoting)
	{
		if (StringDataStore == none)
			InitializeStringDataStore();


		// Unhide, fill in and refresh the new controls/labels
		if (VoteRI.bGameVotingEnabled && !VoteRI.bVotingOver)
		{
			SetGameVoteListState(VLS_Visible);
			UpdateGameVoteLists(VoteRI);
		}
		else
		{
			SetGameVoteListState(VLS_Disabled);
		}

		if (VoteRI.bMapVotingEnabled && !VoteRI.bVotingOver)
		{
			SetMapVoteListState(VLS_Visible);
			UpdateMapVoteLists(VoteRI);
		}
		else
		{
			SetMapVoteListState(VLS_Disabled);
		}

		if (VoteRI.bMutatorVotingEnabled && !VoteRI.bVotingOver)
		{
			SetMutatorVoteListState(VLS_Visible);
			UpdateMutatorVoteLists(VoteRI);
		}
		else
		{
			SetMutatorVoteListState(VLS_Disabled);
		}

		VoteMenuHintLabel.SetVisibility(True);

		if (VoteRI.bMapVotePending)
			VoteMenuHintLabel.SetDataStoreBinding("<Strings:UTGameUI.MidGameMenu.VoteTabGameAndMapVoteHint>");
		else if (VoteRI.bGameVotingEnabled)
			VoteMenuHintLabel.SetDataStoreBinding("<Strings:UTGameUI.MidGameMenu.VoteTabGameVoteHint>");
		else if (VoteRI.bMapVotingEnabled)
			VoteMenuHintLabel.SetDataStoreBinding("<Strings:UTGameUI.MidGameMenu.VoteTabMapVoteHint>");
		else if (VoteRI.bMutatorVotingEnabled)
			VoteMenuHintLabel.SetDataStoreBinding("<Strings:UTGameUI.MidGameMenu.VoteTabMutatorVoteHint>");
		else
			VoteMenuHintLabel.SetValue("");


		// Hide old controls
		MapVoteList.SetVisibility(False);
		MapVoteList.Empty();
	}
	else
	{
		MapVoteList.SetVisibility(True);
		MapVoteList.Empty();

		for (i=0;i<VoteRI.Maps.Length;i++)
			MapVoteList.AddItem(VoteRI.Maps[I].Map);


		// Hide new controls/labels
		VoteMenuHintLabel.SetVisibility(True);
		VoteMenuHintLabel.SetDataStoreBinding("<Strings:UTGameUI.MidGameMenu.VoteTabMapVoteHint>");

		SetGameVoteListState(VLS_Hidden);
		SetMapVoteListState(VLS_Hidden);
		SetMutatorVoteListState(VLS_Hidden);
	}
}

// Called when seamless travel has ended; used to wipe the previous levels values from the vote lists
function ResetVoteLists()
{
	if (GetScene() == none || GetScene().GetWorldInfo() == none || GetScene().GetWorldInfo().Netmode == NM_Standalone)
		return;

	if (StringDataStore == none)
		InitializeStringDataStore();

	if (StringDataStore != none)
	{
		if (GameList != none)
		{
			StringDataStore.EmptyFieldLists('UTVoteGameList');
			GameList.RefreshSubscriberValue();
		}

		if (MapList != none)
		{
			StringDataStore.EmptyFieldLists('UTVoteMapList');
			MapList.RefreshSubscriberValue();
		}

		if (MutatorList != none)
		{
			StringDataStore.EmptyFieldLists('UTVoteMutators');
			MutatorList.RefreshSubscriberValue();
		}
	}
}

function OnActiveStateChanged(UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState)
{
	local UTVoteReplicationInfo VRI;

	Super.OnActiveStateChanged(Sender, PlayerIndex, NewlyActiveState, PreviouslyActiveState);

	// If voting is enabled and the vote tab has just been focused, then update the list
	if (bShowingVotes && UIState_Focused(NewlyActiveState) != none)
	{
		VRI = GetVoteRI();

		if (VRI != none && GetScene() != none && GetScene().GetWorldInfo().Netmode != NM_Standalone)
		{
			// Speed up the remaining transfers
			VRI.ServerRushTransfers();

			UpdateGameVoteLists(VRI);
			UpdateMapVoteLists(VRI);
			UpdateMutatorVoteLists(VRI, True);
		}
	}
}

function SetGameVoteListState(EVoteListState ListState)
{
	local bool bVisible;

	bVisible = (ListState != VLS_Hidden);

	GameList.SetVisibility(bVisible);
	GameListImg.SetVisibility(bVisible);
	GameListImgBG.SetVisibility(bVisible);
	GameListLabel.SetVisibility(bVisible);
	GameVotesLabel.SetVisibility(bVisible);

	if (bVisible)
	{
		GameListLabel.RefreshSubscriberValue();
		GameVotesLabel.RefreshSubscriberValue();

		GameListImg.SetEnabled(ListState == VLS_Disabled);
		GameList.SetEnabled(ListState != VLS_Disabled);
		GameList.RefreshSubscriberValue();
	}
}

function UpdateGameVoteLists(UTVoteReplicationInfo VRI)
{
	if (StringDataStore == none)
		InitializeStringDataStore();

	if (VRI != none && !VRI.bGameVotingReady)
	{
		if (VRI.bGameVotingEnabled)
			DisplayGameTransferPending();

		return;
	}


	bGameVotingInitialized = VRI != none && VRI.bGameVotingReady;
	RefreshGameList(VRI);
}

function SetMapVoteListState(EVoteListState ListState)
{
	local bool bVisible;

	bVisible = (ListState != VLS_Hidden);

	MapList.SetVisibility(bVisible);
	MapListImg.SetVisibility(bVisible);
	MapListImgBG.SetVisibility(bVisible);
	MapListLabel.SetVisibility(bVisible);
	MapVotesLabel.SetVisibility(bVisible);

	if (bVisible)
	{
		MapListLabel.RefreshSubscriberValue();
		MapVotesLabel.RefreshSubscriberValue();

		MapListImg.SetEnabled(ListState == VLS_Disabled);
		MapList.SetEnabled(ListState != VLS_Disabled);
		MapList.RefreshSubscriberValue();
	}
}

function UpdateMapVoteLists(UTVoteReplicationInfo VRI)
{
	if (StringDataStore == none)
		InitializeStringDataStore();

	if (VRI != none && !VRI.bMapVotingReady)
	{
		if (VRI.bMapVotingEnabled)
			DisplayMapTransferPending();

		return;
	}

	bMapVotingInitialized = VRI != none && VRI.bMapVotingEnabled;
	RefreshMapList(VRI);
}

function SetMutatorVoteListState(EVoteListState ListState)
{
	local bool bVisible;

	bVisible = (ListState != VLS_Hidden);

	MutatorList.SetVisibility(bVisible);
	MutatorListImg.SetVisibility(bVisible);
	MutatorListImgBG.SetVisibility(bVisible);
	MutatorListLabel.SetVisibility(bVisible);
	MutatorVotesLabel.SetVisibility(bVisible);

	if (bVisible)
	{
		MutatorListLabel.RefreshSubscriberValue();
		MutatorVotesLabel.RefreshSubscriberValue();

		MutatorListImg.SetEnabled(ListState == VLS_Disabled);
		MutatorList.SetEnabled(ListState != VLS_Disabled);
		MutatorList.RefreshSubscriberValue();
	}
}

function UpdateMutatorVoteLists(UTVoteReplicationInfo VRI, optional bool bFullUpdate)
{
	if (StringDataStore == none)
		InitializeStringDataStore();

	if (VRI != none && !VRI.bMutatorVotingReady)
	{
		if (VRI.bMutatorVotingEnabled)
			DisplayMutTransferPending();

		return;
	}

	RefreshMutatorList(VRI, bFullUpdate || !bMutatorVotingInitialized);
	bMutatorVotingInitialized = VRI != none && VRI.bMutatorVotingReady;
}

// These functions display a "Transferring..." message on the vote menu, when waiting for replication to finish
function DisplayGameTransferPending()
{
	local int i;
	local array<string> RowData;

	// Setup the list
	if (StringDataStore != none)
	{
		i = StringDataStore.GetFieldIndex('UTVoteGameList');
		StringDataStore.SetFieldRowLength(i, 1, True);

		RowData[0] = Localize("MidGameMenu", "VoteTabTransferMessage", "UTGameUI");
		RowData[1] = "";

		StringDataStore.UpdateFieldRow(i, 0, RowData);
	}


	// Refresh the list
	GameList.RefreshSubscriberValue();
}

function DisplayMapTransferPending()
{
	local int i;
	local array<string> RowData;

	// Setup the list
	if (StringDataStore != none)
	{
		i = StringDataStore.GetFieldIndex('UTVoteMapList');
		StringDataStore.SetFieldRowLength(i, 1, True);

		RowData[0] = Localize("MidGameMenu", "VoteTabTransferMessage", "UTGameUI");
		RowData[1] = "";

		StringDataStore.UpdateFieldRow(i, 0, RowData);
	}


	// Refresh the list
	MapList.RefreshSubscriberValue();
}

function DisplayMutTransferPending()
{
	local int i;
	local array<string> RowData;

	// Setup the list
	if (StringDataStore != none)
	{
		i = StringDataStore.GetFieldIndex('UTVoteMutators');
		StringDataStore.SetFieldRowLength(i, 1, True);

		RowData[0] = "";
		RowData[1] = Localize("MidGameMenu", "VoteTabTransferMessage", "UTGameUI");

		StringDataStore.UpdateFieldRow(i, 0, RowData);
	}


	// Refresh the list
	MutatorList.RefreshSubscriberValue();
}


function RefreshGameList(UTVoteReplicationInfo VRI)
{
	local int i, j;
	local byte WinningCount;
	local array<string> RowData;
	local color GoldColour;

	if (StringDataStore == none)
	{
		GameList.RefreshSubscriberValue();
		return;
	}


	i = StringDataStore.GetFieldIndex('UTVoteGameList');

	if (VRI == none)
	{
		StringDataStore.SetFieldRowLength(i, 0);
		GameList.RefreshSubscriberValue();

		return;
	}


	StringDataStore.SetFieldRowLength(i, VRI.GameVotes.Length);
	//GoldColour = class'UTHUD'.default.GoldColor;

	if (VRI.WinningGameIndex == 255)
		for (j=0; j<VRI.GameVotes.Length; ++j)
			if (VRI.GameVotes[j].NumVotes > WinningCount)
				WinningCount = VRI.GameVotes[j].NumVotes;

	if (WinningCount == 0)
		WinningCount = 255;

	for (j=0; j<VRI.GameVotes.Length; ++j)
	{
		RowData[0] = VRI.GameVotes[j].GameName;

		if (j != VRI.WinningGameIndex)
		{
			RowData[1] = string(VRI.GameVotes[j].NumVotes);

			if (VRI.GameVotes[j].NumVotes == WinningCount)
				RowData[1] $= "*";
		}
		else
		{
			RowData[1] = "<Color:R="$(float(GoldColour.R)/255)$",G="$(float(GoldColour.G)/255)$
					",B="$(float(GoldColour.B)/255)$",A=1.0>"$string(VRI.GameVotes[j].NumVotes);
		}

		StringDataStore.UpdateFieldRow(i, j, RowData,, (j<(VRI.GameVotes.Length-1)));
	}

	// If the winning game index is set, then force the game list to that index and update the styles
	if (VRI.WinningGameIndex != 255)
	{
		GameList.GlobalCellStyle[ELEMENT_Selected] = WinningVoteCellStyle;
		GameList.ItemOverlayStyle[ELEMENT_Selected] = WinningVoteOverlayStyle;
		GameList.ResolveStyles();

		GameList.SetIndex(VRI.WinningGameIndex);
	}
	else
	{
		GameList.GlobalCellStyle[ELEMENT_Selected] = DefaultVoteCellStyle;
		GameList.ItemOverlayStyle[ELEMENT_Selected] = DefaultVoteOverlayStyle;
		GameList.ResolveStyles();
	}

	GameList.RefreshSubscriberValue();
}

function RefreshMapList(UTVoteReplicationInfo VRI)
{
	local int i, j;
	local array<string> RowData;
	local color GoldColour;
	local byte WinningCount;
	local string MapName;

	if (StringDataStore == none)
	{
		MapList.RefreshSubscriberValue();
		return;
	}


	i = StringDataStore.GetFieldIndex('UTVoteMapList');

	if (VRI == none)
	{
		StringDataStore.SetFieldRowLength(i, 0);
		MapList.RefreshSubscriberValue();

		return;
	}


	StringDataStore.SetFieldRowLength(i, VRI.MapVotes.Length);
	//GoldColour = class'UTHUD'.default.GoldColor;


	if (VRI.WinningMapIndex == 255)
		for (j=0; j<VRI.MapVotes.Length; ++j)
			if (VRI.MapVotes[j].NumVotes > WinningCount)
				WinningCount = VRI.MapVotes[j].NumVotes;

	if (WinningCount == 0)
		WinningCount = 255;

	for (j=0; j<VRI.MapVotes.Length; ++j)
	{
		MapName = VRI.MapVotes[j].MapName;

		if (VRI.MapVotes[j].bSelectable)
		{
			RowData[0] = MapName;

			if (j != VRI.WinningMapIndex)
			{
				RowData[1] = string(VRI.MapVotes[j].NumVotes);

				if (VRI.MapVotes[j].NumVotes == WinningCount)
					RowData[1] $= "*";
			}
			else
			{
				RowData[1] = "<Color:R="$(float(GoldColour.R)/255)$",G="$(float(GoldColour.G)/255)$
						",B="$(float(GoldColour.B)/255)$",A=1.0>"$string(VRI.MapVotes[j].NumVotes);
			}
		}
		else
		{
			RowData[0] = "<Color:R=0.1,G=0.1,B=0.1,A=1.0>"$MapName;
			RowData[1] = "";
		}

		StringDataStore.UpdateFieldRow(i, j, RowData, !VRI.MapVotes[j].bSelectable, (j<(VRI.MapVotes.Length-1)));
	}


	// If the winning map index is set, then force the map list to that index and update the styles
	if (VRI.WinningMapIndex != 255)
	{
		MapList.GlobalCellStyle[ELEMENT_Selected] = WinningVoteCellStyle;
		MapList.ItemOverlayStyle[ELEMENT_Selected] = WinningVoteOverlayStyle;
		MapList.ResolveStyles();

		MapList.SetIndex(VRI.WinningMapIndex);
	}
	else
	{
		MapList.GlobalCellStyle[ELEMENT_Selected] = DefaultVoteCellStyle;
		MapList.ItemOverlayStyle[ELEMENT_Selected] = DefaultVoteOverlayStyle;
		MapList.ResolveStyles();
	}

	MapList.RefreshSubscriberValue();
}

function RefreshMutatorList(UTVoteReplicationInfo VRI, optional bool bFullUpdate)
{
	local float ReqMutVotes;
	local int i, j, k;
	local array<string> RowData;

	if (StringDataStore == none)
	{
		MutatorList.RefreshSubscriberValue();
		return;
	}


	i = StringDataStore.GetFieldIndex('UTVoteMutators');

	if (VRI == none || VRI.MutatorVotes.Length == 0)
	{
		StringDataStore.SetFieldRowLength(i, 0);
		MutatorList.RefreshSubscriberValue();

		return;
	}


	// Multiple by 1000.0 for increased accuracy
	ReqMutVotes = Max(1000.0, GetPlayerCount() * float(VRI.MutatorVotePercentage) * 10.0);

	StringDataStore.SetFieldRowLength(i, VRI.MutatorVotes.Length+2, True);


	RowData[0] = "";
	RowData[1] = "<Color:R=0.1,G=0.1,B=0.1,A=1.0>"$Localize("MidGameMenu", "VoteTabAddMutHeader", "UTGameUI");
	RowData[2] = "";

	MutHeaderIndicies[0] = 0;
	StringDataStore.UpdateFieldRow(i, 0, RowData, True, True);


	// Now add all of the currently disabled mutators under the 'Add' header
	k=1;

	for (j=0; j<VRI.MutatorVotes.Length; ++j)
	{
		if (VRI.MutatorVotes[j].bIsActive)
			continue;


		RowData[0] = string(VRI.MutatorVotes[j].NumVotes);

		if (float(VRI.MutatorVotes[j].NumVotes) * 1000.0 >= ReqMutVotes)
			RowData[0] $= "*";

		RowData[1] = VRI.MutatorVotes[j].MutName;

		// Include the mutator index in the row data, but don't display it; this is to help match the list to the MutatorVotes array
		RowData[2] = string(j);


		StringDataStore.UpdateFieldRow(i, k, RowData,, True);

		++k;
	}


	// Add the 'Remove' header
	RowData[0] = "";
	RowData[1] = "<Color:R=0.1,G=0.1,B=0.1,A=1.0>"$Localize("MidGameMenu", "VoteTabRemoveMutHeader", "UTGameUI");
	RowData[2] = "";

	MutHeaderIndicies[1] = k;
	StringDataStore.UpdateFieldRow(i, k, RowData, True, True);
	++k;


	// Now add all of the currently enabled mutators
	for (j=0; j<VRI.MutatorVotes.Length; ++j)
	{
		if (!VRI.MutatorVotes[j].bIsActive)
			continue;


		RowData[0] = string(VRI.MutatorVotes[j].NumVotes);

		if (float(VRI.MutatorVotes[j].NumVotes) * 1000.0 >= ReqMutVotes)
			RowData[0] $= "*";

		RowData[1] = VRI.MutatorVotes[j].MutName;

		// Include the mutator index in the row data, but don't display it; this is to help with the list to the MutatorVotes array
		RowData[2] = string(j);


		StringDataStore.UpdateFieldRow(i, k, RowData,, (k<VRI.MutatorVotes.Length+2));

		++k;
	}

	// Refresh the list
	MutatorList.RefreshSubscriberValue();
}

// Used for calculating required votes from vote percentages
final function float GetPlayerCount()
{
	local UTPlayerController UTPC;
	local GameReplicationInfo GRI;
	local int i, ReturnVal;

	if (GetScene() == none || UTUIScene(GetScene()) == none)
		return 256.0;

	UTPC = UTUIScene(GetScene()).GetUTPlayerOwner();

	if (UTPC == none)
		return 256.0;

	LastPCountTimestamp = UTPC.WorldInfo.RealTimeSeconds;

	GRI = UTPC.WorldInfo.GRI;

	if (GRI == none)
		return 256.0;


	for (i=0; i<GRI.PRIArray.Length; ++i)
		if (!GRI.PRIArray[i].bOnlySpectator && !GRI.PRIArray[i].bBot)
			++ReturnVal;

	return ReturnVal;
}


function OnListSubmitSelection(UIList Sender, int PlayerIndex)
{
	local int CurIdx;
	local UTVoteReplicationInfo VRI;

	VRI = GetVoteRI();

	if (VRI == none)
		return;


	if (Sender == GameList)
	{
		if (bGameVotingInitialized)
		{
			CurIdx = GetGameListGameIdx();

			if (CurIdx == INDEX_None || CurIdx > VRI.GameVotes.Length)
				return;

			VRI.ServerRecordGameVote(CurIdx);
		}
	}
	else if (Sender == MapList)
	{
		if (bMapVotingInitialized)
		{
			CurIdx = GetMapListMapIdx();

			if (CurIdx == INDEX_None || CurIdx > VRI.MapVotes.Length || !VRI.MapVotes[CurIdx].bSelectable)
				return;

			VRI.ServerRecordMapVote(CurIdx);
		}
	}
	else if (Sender == MutatorList)
	{
		if (bMutatorVotingInitialized)
		{
			CurIdx = GetSelectedMutIdx();

			if (CurIdx == INDEX_None || CurIdx > VRI.MutatorVotes.Length)
				return;

			// Make the vote
			VRI.ServerRecordMutVote(CurIdx, VRI.CurMutVoteIndicies.Find(CurIdx) == INDEX_None);
		}
	}
}

final function int GetGameListGameIdx()
{
	return GameList.GetCurrentItem();
}

final function int GetMapListMapIdx()
{
	return MapList.GetCurrentItem();
}

final function int GetSelectedMutIdx()
{
	local int i, j;
	local array<string> RowData;

	i = MutatorList.GetCurrentItem();

	if (i == MutHeaderIndicies[0] || i == MutHeaderIndicies[1] || StringDataStore == none)
		return INDEX_None;


	// Grab the mutator index from the third string in the selected row
	j = StringDataStore.GetFieldIndex('UTVoteMutators');
	StringDataStore.GetFieldRow(j, i, RowData);

	if (RowData[2] == "")
		return INDEX_None;


	return int(RowData[2]);
}

final function InitializeStringDataStore()
{
	local DataStoreClient DSC;
	local int i;

	if (StringDataStore != none)
		return;


	// Get a reference to (or create) a 2D string list data store
	DSC = Class'UIInteraction'.static.GetDataStoreClient();

	StringDataStore = UTUIDataStore_2DStringList(DSC.FindDataStore('UT2DStringList'));

	if (StringDataStore == none)
	{
		StringDataStore = DSC.CreateDataStore(Class'UTUIDataStore_2DStringList');
		DSC.RegisterDataStore(StringDataStore);
	}


	// Setup the data fields within the data store (if they are not already set)
	if (StringDataStore.GetFieldIndex('UTVoteGameList') == INDEX_None)
	{
		i = StringDataStore.AddField('UTVoteGameList');
		StringDataStore.AddFieldList(i, 'GameList');
		StringDataStore.AddFieldList(i, 'VoteCount');


		i = StringDataStore.AddField('UTVoteMapList');
		StringDataStore.AddFieldList(i, 'MapList');
		StringDataStore.AddFieldList(i, 'VoteCount');


		i = StringDataStore.AddField('UTVoteMutators');
		StringDataStore.AddFieldList(i, 'VoteCount');
		StringDataStore.AddFieldList(i, 'Mutator');

		// Not displayed, used to retrieve the index into UTVoteReplicationInfo.MutatorVotes
		StringDataStore.AddFieldList(i, 'MutVoteIdx');
	}
}


// Old vote code (still used, when joining 1.2 servers)

// Not used (and obsolete, due to possibility of multiple winning maps)
function FindWinningMap()
{
	local int i,BestIdx;
	local string s;
	local UTVoteReplicationInfo VoteRI;

	VoteRI = GetVoteRI();

	if ( VoteRI != none )
	{
		BestIdx = -1;
		for (i=0;i<VoteRI.Maps.Length;i++)
		{
			if ( VoteRI.Maps[i].NoVotes > 0 )
			{
				if (BestIdx <0 || VoteRI.Maps[i].NoVotes > VoteRI.Maps[BestIdx].NoVotes)
				{
					BestIdx = i;
				}
			}
		}

		if ( (LastBestVoteIndex != BestIdx) || ((BestIdx >=0) && (LastBestVoteCount != VoteRI.Maps[BestIdx].NoVotes)) )
		{
			LastBestVoteIndex = BestIdx;
			if (BestIdx>=0)
			{
				LastBestVoteCount = VoteRI.Maps[BestIdx].NoVotes;
				s = GetMapFriendlyName(VoteRI.Maps[BestIdx].Map)@"<strings:UTGameUI.MidGameMenu.BestVoteA>"@string(int(VoteRI.Maps[BestIdx].NoVotes))@"<strings:UTGameUI.MidGameMenu.BestVoteB>";
			}
			else
			{
				s = "<strings:UTGameUI.MidGameMenu.BestVoteNone>";
			}

			MapVoteInfo.SetDatastoreBinding(s);
		}
	}
}

function string GetMapFriendlyName(string Map)
{
	local int i, p, StartIndex, EndIndex;
	local array<string> LocPieces;

	// try to use a friendly name from the UI if we can find it
	for (i = 0; i < LocalMapList.length; i++)
	{
		if (LocalMapList[i] != None && LocalMapList[i].MapName ~= Map)
		{
			// try to resolve the UI string binding into a readable name
			StartIndex = InStr(Caps(LocalMapList[i].FriendlyName), "<STRINGS:");
			if (StartIndex == INDEX_NONE)
			{
				return LocalMapList[i].FriendlyName;
			}
			Map = Right(LocalMapList[i].FriendlyName, Len(LocalMapList[i].FriendlyName) - StartIndex - 9); // 9 = Len("<STRINGS:")
			EndIndex = InStr(Map, ">");
			if (EndIndex != INDEX_NONE)
			{
				Map = Left(Map, EndIndex);
				ParseStringIntoArray(Map, LocPieces, ".", true);
				if (LocPieces.length >= 3)
				{
					Map = Localize(LocPieces[1], LocPieces[2], LocPieces[0]);
				}
			}
			return Map;
		}
	}

	// just strip the prefix
	p = InStr(Map,"-");
	if (P > INDEX_NONE)
	{
		Map = Right(Map, Len(Map) - P - 1);
	}


	// If the map still has a link setup (possible with custom maps), then clean that up
	i = InStr(Caps(Map), "?LINKSETUP=");

	if (i != INDEX_None)
		Map = Left(Map, i)@"("$Mid(Map, i+11)$")";


	return Map;
}

/** OBSOLETE - used GetMapFriendlyName */
function string TrimGameType(string Map)
{
	local int p;
	p = InStr(Map,"-");
	if (P>INDEX_None)
	{
		Map = Right(Map,Len(Map)-P-1);
	}
	return map;
}

function bool DrawVote(UTSimpleList SimpleList,int ItemIndex, float XPos, out float YPos)
{
	local float H, PaddingHeight, PaddedYpos;
	local vector2d DrawScale;
	local float PaddingAmount;
	local float PaddingOffset;
	local float ShadowOffset;
	local string VoteText;
	local UTVoteReplicationInfo VoteRI;

	VoteRI = GetVoteRI();

	if (VoteRI == none )
	{
		return true;
	}

	DrawScale = SimpleList.ResScaling;
	DrawScale.X *= SimpleList.List[ItemIndex].CurHeightMultiplier;
	DrawScale.Y *= SimpleList.List[ItemIndex].CurHeightMultiplier;

	// Figure out the total height of this cell
	H = SimpleList.DefaultCellHeight * DrawScale.Y;

	if (ItemIndex == SimpleList.Selection)
	{
		VoteText = GetMapFriendlyName(VoteRI.Maps[ItemIndex].Map);
	}
	else
	{
		VoteText = (VoteRI.Maps[ItemIndex].NoVotes > 0) ? string(VoteRI.Maps[ItemIndex].NoVotes) : "-";
		VoteText $= "-"@GetMapFriendlyName(VoteRI.Maps[ItemIndex].Map);
	}

	if ( VoteText != "" )
	{

		// Handle text padding
		PaddingAmount = SimpleList.List[ItemIndex].TransitionAlpha * SimpleList.SelectedTextPadding.Y + (1.0f - SimpleList.List[ItemIndex].TransitionAlpha) * SimpleList.NormalTextPadding.Y;
		PaddingOffset = SimpleList.List[ItemIndex].TransitionAlpha * SimpleList.SelectedTextOffset.Y + (1.0f - SimpleList.List[ItemIndex].TransitionAlpha) * SimpleList.NormalTextOffset.Y;
		PaddingHeight = PaddingAmount * H;
		PaddedYpos = YPos + PaddingHeight + PaddingOffset*H;

		// Draw text shadow
		ShadowOffset = 1*DrawScale.Y;
		SimpleList.Canvas.SetDrawColor(0,0,0,255);
		SimpleList.DrawStringToFit(VoteText,XPos+ShadowOffset, PaddedYpos+ShadowOffset, PaddedYpos+(H-PaddingHeight*2)+ShadowOffset);

		// Take power of the alpha to make the falloff a bit stronger.
		SimpleList.Canvas.DrawColor = (SimpleList.SelectedColor-SimpleList.NormalColor)*(SimpleList.List[ItemIndex].TransitionAlpha ** 3)+ SimpleList.NormalColor;
		SimpleList.DrawStringToFit(VoteText,XPos, PaddedYpos, PaddedYpos+(H-PaddingHeight*2));
	}
	SimpleList.List[ItemIndex].bWasRendered = true;
	return true;
}

function bool DrawVotePostSelectionBar(UTSimpleList SimpleList, float YPos, float Width, float Height)
{
	local float DrawScale;
	local string VoteCnt;
	local float xl,yl;

	local UTVoteReplicationInfo VoteRI;

	VoteRI = GetVoteRI();

	if (VoteRI == none )
	{
		return true;
	}

	VoteCnt = string(VoteRI.Maps[SimpleList.Selection].NoVotes);
	if (len(VoteCnt)==1)
	{
		VoteCnt = "0"$VoteCnt;
	}


	SimpleList.Canvas.StrLen(VoteCnt,xl,yl);
	DrawScale = (Width * 0.65) / XL;


	SimpleList.Canvas.SetDrawColor(0,0,0,255);
	SimpleList.Canvas.SetPos(Width * 0.125 +1,YPos + (Height * 0.5) - (YL * DrawSCale * 0.5)+1);
	SimpleList.Canvas.DrawTextClipped(VoteCnt,,DrawScale,DrawScale);

	SimpleList.Canvas.DrawColor = (SimpleList.SelectedColor-SimpleList.NormalColor)*(SimpleList.List[SimpleList.Selection].TransitionAlpha**3)+ SimpleList.NormalColor;
	SimpleList.Canvas.SetPos(Width * 0.125,YPos + (Height * 0.5) - (YL * DrawSCale * 0.5));
	SimpleList.Canvas.DrawTextClipped(VoteCnt,,DrawScale,DrawScale);

	return true;
}


// Unused function stubs (kept to retain binary compatibility)
function bool SetupMutatorToolTip(UIObject Sender, out UIToolTip CustomToolTip)
{
	return False;
}

function RefreshAvailableMaps(UTVoteReplicationInfo VRI);
function RefreshVotedMaps(UTVoteReplicationInfo VRI);
function OnComboValueChanged(UIObject Sender, int PlayerIndex);
final function int GetAvailableListMapIdx();
final function int GetVotedMapsIndex();


defaultproperties
{
	bRequiresTick=true
	OnTick=TabTick

	WinningVoteCellStyle=(DefaultStyleTag="DefaultCellStyleHover",RequiredStyleClass=class'Engine.UIStyle_Combo')
	WinningVoteOverlayStyle=(DefaultStyleTag="ListItemBackgroundHoverStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	DefaultVoteCellStyle=(DefaultStyleTag="DefaultCellStyleSelected",RequiredStyleClass=class'Engine.UIStyle_Combo')
	DefaultVoteOverlayStyle=(DefaultStyleTag="ListItemBackgroundSelectedStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
}