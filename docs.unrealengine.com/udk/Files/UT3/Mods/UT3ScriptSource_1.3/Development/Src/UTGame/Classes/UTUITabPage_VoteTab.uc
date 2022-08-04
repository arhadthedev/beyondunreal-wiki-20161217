/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

Class UTUITabPage_VoteTab extends UTTabPage_MidGame;

var transient UTSimpleList MapVoteList;

var transient UILabel MapVoteInfo;
var transient UILabel ConText;

var transient int ConsoleTextCnt;
var transient bool bShowingVotes;
var transient int LastBestVoteIndex;
var transient int LastBestVoteCount;

/** list of local maps - used to get more friendly names when possible */
var array<UTUIDataProvider_MapInfo> LocalMapList;


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


	// Copy of the console...
	Con = UTConsole(GetPlayerOwner().ViewportClient.ViewportConsole);

	if (Con != none)
		ConsoleTextCnt = Con.TextCount - 5;


	// fill the local map list
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', ProviderList);

	for (i=0; i<ProviderList.Length; ++i)
		LocalMapList.AddItem(UTUIDataProvider_MapInfo(ProviderList[i]));
}

/**
 * This tab is being ticked
 */
function TabTick(float DeltaTime)
{
	local UTConsole Con;
	local string Work;

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

	// Update the game's status
	CheckGameStatus();
}

function CheckGameStatus()
{
	//local UTGameReplicationInfo GRI;
	local WorldInfo WI;

	WI = GetScene().GetWorldInfo();

	if (WI != none)
	{
		//GRI = UTGameReplicationInfo(WI.GRI);

		if (bShowingVotes && GetVoteRI() != none && GetVoteRI().bVotingOver /*&& GRI != none && WI.GRI.bMatchIsOver && GRI.MapVoteTimeRemaining == 0*/)
		{
			bShowingVotes = false;
			MapVoteList.SetVisibility(false);

			if (IsActivePage())
				UTUIScene_MidGameMenu(GetScene()).ActivateTab('ChatTab');
		}
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

	//`log("###"@Self$".BeginVoting"@VoteRI,, 'UTVotingDebug');

	MapVoteList.SetVisibility(True);

	bShowingVotes = true;

	//SetTabCaption("<Strings:UTGameUI.MidGameMenu.TabCaption_Vote>");


	MapVoteList.Empty();

	for (i=0;i<VoteRI.Maps.Length;i++)
	{
//		`log("### Adding Map:"@i@VoteRI.Maps[I].Map);
		MapVoteList.AddItem(VoteRI.Maps[I].Map);
	}

}

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

defaultproperties
{
	bRequiresTick=true
	OnTick=TabTick
}