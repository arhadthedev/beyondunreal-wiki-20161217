/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTScoreboardPanel extends UTDrawPanel
	config(Game);

/** Defines the different font sizes */
enum EFontType
{
	EFT_Tiny,
	EFT_Small,
	EFT_Med,
	EFT_Large,
};

/**
 * Holds the font data.  We cache the max char height for quick lookup
 */
struct SBFontData
{
	var() font Font;
	var transient int CharHeight;

};

/** Font Data 0 = Tiny, 1=Small, 2=Med, 3=Large */
var() SBFontData Fonts[4];

/** If true, this scoreboard will be considered to be interactive */
var() bool bInteractive;

/** Holds a list of PRI's currently being worked on.  Note it cleared every frame */
var transient array<UTPlayerReplicationInfo> PRIList;

/** Cached reference to the HUDSceneOwner */
var UTUIScene_Hud UTHudSceneOwner;

var(Test) transient int EditorTestNoPlayers;

var() float MainPerc;
var() float ClanTagPerc;
var() float MiscPerc;
var() float SpacerPerc;
var() float BarPerc;
var() Texture2D SelBarTex;
var() int AssociatedTeamIndex;
var() bool bDrawPlayerNum;
var() config string LeftMiscStr;
var() config string RightMiscStr;

var() Texture2D BackgroundTex;
var() TextureCoordinates BackgroundCoords;
var() Texture2D BlingTex;
var() TextureCoordinates BlingCoords;
var() TextureCoordinates BlingPct;

var() float TextPctWidth;
var() float TextPctHeight;
var() float TextLeftPadPct;
var() float TextTopPadPct;

var() vector2D ScorePosition;
var() font ScoreFont;

var() font HeaderFont;
var() float HeaderXPct;
var() float HeaderYPos;

var() float FragsXPct;


var(Test) transient bool bShowTextBounds;
var transient UTPlayerController PlayerOwner;

var transient int NameCnt;
var transient string FakeNames[32];

var transient color TeamColors[2];

/** The Player Index of the currently selected player */
var transient int SelectedPI;

/** Index of the selected player in the UI list */
var transient int SelectedUIIndex;

/** We cache this so we don't have to resize everything for a mouse click */
var transient float LastCellHeight;

var string HeaderTitle_Name;
var string HeaderTitle_Score;
var string HeaderTitle_Deaths;

var transient bool bCensor;

// X screen position for the right stat on the panel.
var transient float RightColumnPosX;
// Width of the header drawn for the right column.
var transient float RightColumnWidth;

// X screen position for the left stat on the panel.
var transient float LeftColumnPosX;
// Width of the header drawn for the left column.
var transient float LeftColumnWidth;
// Is this splitscreen
var transient bool bIsSplitScreen;

// Adjustments to scoreboard positioning when in splitscreen
var float SplitScreenHeaderAdjustmentY;
var float SplitScreenScorePosAdjustmentY;


// Padding between the top/bottom of the highlighter and the string(s) it is behind.
var() float HighlightPad;
// Padding on either side of the playername string, for when other strings (clan, location) are drawn above or under it.
var() float PlayerNamePad;

// Minimum scale percentage we will scale a font.
var() float MinFontScale;

// Pixels to adjust ClanName position.
var() float ClanPosAdjust;
var() float ClanMultiplier;
// Pixels to adjust Misc position.
var() float MiscPosAdjust;
var() float MiscMultiplier;

var localized string PingString;

/** whether or not this list should always attempt to include the local player's PRI, skipping other players if necessary to make it fit */
var bool bMustDrawLocalPRI;

var transient int PRIListSize;

var() Texture2D HeroTexture;
var() TextureCoordinates HeroCoords;

/** Scoreboard color for allies (in betrayal gametype)*/
var  color AllyColor;

/** Weapon icon coordinates */
var UIRoot.TextureCoordinates WeaponCoords[10];

event PostInitialize()
{
	local UTPlayerController PC;
	local EFeaturePrivilegeLevel Level;
	local GameReplicationInfo GRI;

	Super.PostInitialize();
	SizeFonts();

	UTHudSceneOwner = UTUIScene_Hud( GetScene() );
	NotifyResolutionChanged = OnNotifyResolutionChanged;

	if (bInteractive)
	{
		OnRawInputKey=None;
		OnProcessInputKey=ProcessInputKey;
	}

	// Set the localized header strings.
	SetHeaderStrings();

	PC = UTHudSceneOwner.GetUTPlayerOwner();
	if (PC != none )
	{
		Level = PC.OnlineSub.PlayerInterface.CanCommunicate( LocalPlayer(PC.Player).ControllerId );
		bCensor = Level != FPL_Enabled;
		GRI = PC.WorldInfo.GRI;
	}

	HighlightPad = 3.0f;
	PlayerNamePad = 1.0f;

	// increase scoreboard panel on PC
	if (UTHudSceneOwner.IsGame())
	{
		if ( (GRI != None) && (GRI.GameClass != None) && GRI.GameClass.default.bTeamGame )
		{
			if ( GRI.GameClass != class'UTDuelGame' )
			{
				SetPosition( 0.12 , UIFACE_Top, EVALPOS_PercentageOwner);
				SetPosition( 0.85, UIFACE_Bottom, EVALPOS_PercentageOwner);
			}
		}
		else
		{
			SetPosition( 0.14, UIFACE_Top, EVALPOS_PercentageOwner);
			SetPosition( 0.84, UIFACE_Bottom, EVALPOS_PercentageOwner);
		}
	}

	bIsSplitScreen = class'Engine'.static.IsSplitScreen();

	if (bIsSplitScreen)
	{
        //Larger scoreboard layout to accomodate more players
		SetPosition( 0.002756+0.05 , UIFACE_Top, EVALPOS_PercentageOwner);
		SetPosition( 0.80, UIFACE_Bottom, EVALPOS_PercentageOwner);

		HeaderYPos = default.HeaderYPos * SplitScreenHeaderAdjustmentY;
		ScorePosition.Y = default.ScorePosition.Y * SplitScreenScorePosAdjustmentY;
	}

	PRIListSize = 0;
}

/** Sets the header strings using localized values */
function SetHeaderStrings()
{
	HeaderTitle_Name = Localize( "Scoreboards", "Name", "UTGameUI" );
	HeaderTitle_Score = Localize( "Scoreboards", "Kills", "UTGameUI" );
	HeaderTitle_Deaths = Localize( "Scoreboards", "Deaths", "UTGameUI" );
}

/**
 * Setup Input subscriptions
 */
event GetSupportedUIActionKeyNames(out array<Name> out_KeyNames )
{
	out_KeyNames[out_KeyNames.Length] = 'SelectionUp';
	out_KeyNames[out_KeyNames.Length] = 'SelectionDown';
	out_KeyNames[out_KeyNames.Length] = 'Select';

}

/**
 * Whenever there is a resolution change, make sure we recache the font sizes
 */
function OnNotifyResolutionChanged( const out Vector2D OldViewportsize, const out Vector2D NewViewportSize )
{
	SizeFonts();
}

function NotifyGameSessionEnded()
{
	SelectedUIIndex = INDEX_None;
	SelectedPI = INDEX_None;
	PRIList.Length = 0;
	PlayerOwner = None;
	Super.NotifyGameSessionEnded();
}

/**
 * Precache the sizing of the fonts so we don't have to constant look it up
 */
function SizeFonts()
{
	local int i;
	for (i = 0; i < ARRAYCOUNT(Fonts); i++)
	{
		if ( Fonts[i].Font != none )
		{
			Fonts[i].CharHeight = Fonts[i].Font.GetMaxCharHeight();
		}
	}
}

/** Get the header color */
function LinearColor GetHeaderColor()
{
	local LinearColor LC;
	LC = MakeLinearColor(1.0f,0.15f,0.0f,1.0f);
	return LC;
}

/**
 * Draw the Scoreboard
 */
event DrawPanel()
{
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;
	local int i;
	local float YPos;
	local float CellHeight;

	/** Which font to use for clan tags */
	local int ClanTagFontIndex;

	/** Which font to use for the Misc line */
	local int MiscFontIndex;

	/** Which font to use for the main text */
	local int FontIndex;

	/** Finally, if we must, scale it */
	local float FontScale;

	local LinearColor LC;

	local float OrgX, OrgY, ClipX, ClipY, tW, tH;
	local int NumPRIsToDraw;
	local bool bHasDrawnLocalPRI;
	local float LastPRIY;
	local UTPlayerReplicationInfo OwningPRI;

	local int BeginIdx,EndIdx;

	WI = UTHudSceneOwner.GetWorldInfo();
	GRI = UTGameReplicationInfo(WI.GRI);

	if (bIsSplitScreen)
	{
		ResolutionScale *= 2.0;
	}

	MainPerc = 1.0f;
 	ClanTagPerc = 0.35f;
	ClanMultiplier = -1.25f;
 	MiscPerc = 0.35f;
 	MiscMultiplier = -1.75f;
	ClanPosAdjust = 8.0f * ((ResolutionScale-1.0f)/ClanTagPerc * ClanMultiplier);
	MiscPosAdjust = 8.0f * ((ResolutionScale-1.0f)/MiscPerc * MiscMultiplier);

	// Grab the PawnOwner.  We will ditch this at the end of the draw
	// cycle to make sure there are no Object->Actor references laying around
	PlayerOwner = UTHudSceneOwner.GetUTPlayerOwner();
	OwningPRI = UTHudSceneOwner.GetPRIOwner();

	// Figure out if we can fit everyone at the default font levels
	FontIndex = EFT_Large;

	if ( bInteractive )
	{
		ClanTagFontIndex = -1;
		MiscFontIndex = -1;
	}
	else
	{
		ClanTagFontIndex = EFT_Small;
		MiscFontIndex = EFT_Small;
	}

    OrgX = Canvas.OrgX;
    OrgY = Canvas.OrgY;
    ClipX = Canvas.ClipX;
    ClipY = Canvas.ClipY;

	// Draw the background
	Canvas.SetPos(0,0);
	LC = GetHeaderColor();
	Canvas.DrawTileStretched(BackgroundTex, Canvas.ClipX, Canvas.ClipY, BackgroundCoords.U, BackgroundCoords.V, BackgroundCoords.UL, BackgroundCoords.VL,LC,,,ResolutionScale);

    // Readjust the clip region
	tW = ClipX * TextPctWidth;
	tH = ClipY * TextPctHeight;

	Canvas.OrgX += (tW * TextLeftPadPct);
	Canvas.ClipX -= tW;

	// Draw the scoring header.  We remain at full height here
	DrawScoreHeader();

	Canvas.OrgY += (tH * TextTopPadPct);
	Canvas.ClipY -= tH;

    if (bShowTextBounds)
    {
    	Canvas.SetPos(0,0);
    	Canvas.SetDrawColor(255,255,255,255);
    	Canvas.DrawBox(Canvas.ClipX, Canvas.ClipY);
    }

	if (bCensor)	// Hide the ClanTag
	{
		ClanTagFontIndex = 0;
	}

	// Adjust font
	FontScale = 1.0f;

	// Attempt to AutoFit the text.
	CellHeight = AutoFit(GRI, FontIndex, ClanTagFontIndex, MiscFontIndex, FontScale, true);
	LastCellHeight = CellHeight;

	// Draw each score.
	NameCnt=0;
	YPos = 0.0;

    //Number of player scores to draw is canvas size dependent (rounded up)
	NumPRIsToDraw = Min( ((Canvas.ClipY-YPos)/CellHeight) + 0.5, PRIList.length );
	bHasDrawnLocalPRI = !bMustDrawLocalPRI;

	if ( bInteractive )
	{
		//Create a scrollable list of players NumPRIsToDraw tall
		BeginIdx = Max(0, SelectedUIIndex - (NumPRIsToDraw/2));
		EndIdx = Min(PRIList.length, BeginIdx + NumPRIsToDraw);
		BeginIdx = EndIdx - NumPRIsToDraw;
		for (i = BeginIdx; i<EndIdx; i++)
		{
			// Draw the score
			LastPRIY = YPos;
			DrawPRI(i, PRIList[i], CellHeight, FontIndex, ClanTagFontIndex, MiscFontIndex, FontScale, YPos);
			YPos = LastPRIY + CellHeight;
		}
	}
	else
	{
		for (i=0;i<PRIList.length;i++)
		{
			// If we are at the end of the draw list and haven't drawn the local player yet, wait until we find him to draw the last PRI.
			if ( !bHasDrawnLocalPRI && (OwningPRI != None) && IsValidScoreboardPlayer(OwningPRI) && (OwningPRI.GetTeamNum() == AssociatedTeamIndex || AssociatedTeamIndex == -1) && (NameCnt == NumPRIsToDraw-1) && (PRIList[i] != OwningPRI) )
			{
				continue;
			}

			// Keep track of whether the local PRI has been drawn yet.
			if ( OwningPRI != None && PRIList[i] == OwningPRI )
			{
				bHasDrawnLocalPRI = true;
			}

			// Draw the score
			LastPRIY = YPos;
			DrawPRI(i, PRIList[i], CellHeight, FontIndex, ClanTagFontIndex, MiscFontIndex, FontScale, YPos);
			YPos = LastPRIY + CellHeight;
			NameCnt++;

			if ( NameCnt >= NumPRIsToDraw )
			{
				break;
			}
		}
	}
	
	// Clear up Object->Actor references
	PlayerOwner = none;
	PRIList.Length = 0;

    // Restore Clip Region
    Canvas.OrgX = OrgX;
    Canvas.OrgY = OrgY;
    Canvas.ClipX = ClipX;
    Canvas.ClipY = ClipY;

	// If we have a team, draw it's score here
	DrawTeamScore();

	Canvas.SetPos(Canvas.ClipX * BlingPct.U, Canvas.ClipY * BlingPct.V);
	Canvas.DrawTileStretched(BlingTex, (Canvas.CLipX * BlingPct.UL), (Canvas.ClipY * BlingPct.VL), BlingCoords.U, BlingCoords.V, BlingCoords.UL, BlingCoords.VL,MakeLinearColor(1.0,1.0,1.0,1.0));
}


/** Default to drawing nothing */
function DrawTeamScore();

function DrawScoreHeader()
{
	local float xl,yl,columnWidth, numXL, numYL;

    if ( HeaderFont != none )
    {
		Canvas.SetDrawColor(255,255,255,255);

		Canvas.Font = Fonts[EFT_Large].Font;
		Canvas.StrLen("0000",numXL,numYL);

		Canvas.Font = HeaderFont;
		Canvas.SetPos(Canvas.ClipX * HeaderXPct,Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Name);

		Canvas.StrLen(HeaderTitle_Deaths,xl,yl);
		RightColumnWidth = xl;
		columnWidth = Max(xl+0.25f*numXL, numXL);
		RightColumnPosX = Canvas.ClipX - columnWidth;
		Canvas.SetPos(RightColumnPosX,Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Deaths);

		Canvas.StrLen(HeaderTitle_Score,xl,yl);
		LeftColumnWidth = xl;
		columnWidth = Max(xl, numXL);
		columnWidth += 0.25f*numXL;
		LeftColumnPosX = RightColumnPosX - columnWidth;
		Canvas.SetPos(LeftColumnPosX, Canvas.ClipY * HeaderYPos);
		Canvas.DrawTextClipped(HeaderTitle_Score);
	}
}


function CheckSelectedPRI()
{
	local int i;

	for (i=0;i<PRIList.Length;i++)
	{
		if ( PRIList[i].PlayerID == SelectedPI )
		{
			return;
		}
	}

	SelectedPI = INDEX_None;
	SelectedUIIndex = INDEX_None;
}

/** Scan the PRIArray and get any valid PRI's for display */
function GetPRIList(UTGameReplicationInfo GRI)
{
	local int i,Idx;
	local UTPlayerReplicationInfo PRI;

	if (GRI != None)
	{
		for (i=0; i < GRI.PRIArray.Length; i++)
		{
			PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
			if ( PRI != none && IsValidScoreboardPlayer(PRI) )
			{
				Idx = PRIList.Length;
				PRIList.Length = Idx + 1;
				PRIList[Idx] = PRI;
			}
		}
	}
}

/**
 * Figure a way to fit the data.  This will probably be specific to each game type
 *
 * @Param	GRI 				The Game ReplicationIfno
 * @Param	FontIndex			The Index to use for the main text
 * @Param 	ClanTagFontIndex	The Index to use for the Clan Tag
 * @Param	MiscFontIndex		The Index to use for the Misc tag
 * @Param	FontSCale			The final font scaling factor to use if all else fails
 * @Param	bPrimeList			Should only be true the first call.  Will build a list of
 *								who needs to be checked.
 */
function float AutoFit(UTGameReplicationInfo GRI, out int FontIndex,out int ClanTagFontIndex,
					out int MiscFontIndex, out float FontScale, bool bPrimeList)
{
	local float CellHeight;
	local bool bRecurse;

	// We need to prime our list, so do that first.
	if ( bPrimeList )
	{
		if ( UTHudSceneOwner.IsGame() )
		{
			GetPRIList(GRI);

			if (bInteractive)
			{
				if (SelectedPI != INDEX_None )
				{
					CheckSelectedPRI();
				}
			}
		}
		else
		{
			// Create Fake Entries for the editor
			PRIList.Length = EditorTestNoPlayers;
		}
	}

	// Calculate the Actual Cell Height given all the data
	CellHeight  = (Fonts[FontIndex].CharHeight * MainPerc * FontScale) + (HighlightPad * 2 * ResolutionScale) - MiscPosAdjust;
	CellHeight += (ClanTagFontIndex >= 0) ? (Fonts[ClanTagFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) - ClanPosAdjust : 0.0f;
	CellHeight += MiscFontIndex >= 0 ? (Fonts[MiscFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) : 0.0f;

	// Check to see if we fit
	if ( CellHeight * PRIList.Length > Canvas.ClipY )
	{
		bRecurse = false;		// By default, don't recurse

		if ( FontScale > 0.75 )
		{
			FontScale = FClamp( (Canvas.ClipY/(CellHeight * PRIList.Length)), 0.75f, 1.0f );
			bRecurse = (FontScale <= 0.75);
		}
		else if ( MiscFontIndex > 0 || (ClanTagFontIndex == 0 && MiscFontIndex == 0) )
		{
			// MiscFontIndex is the first to go
			MiscFontIndex--;
			bRecurse = true;
		}
		else if ( ClanTagFontIndex >= 0 )
		{
			// Then the Clan Tag
			ClanTagFontIndex--;
			bRecurse = (ClanTagFontIndex >= 0);
		}

		// If we adjusted the ClanTag or Misc sizes, we need to retest the fit.
		if (bRecurse)
		{
			return AutoFit(GRI, FontIndex, ClanTagFontIndex, MiscFontIndex, FontScale, false);
		}
	}

	CellHeight  = (Fonts[FontIndex].CharHeight * MainPerc * FontScale) + (HighlightPad * 2 * ResolutionScale) - MiscPosAdjust;
	CellHeight += (ClanTagFontIndex >= 0) ? (Fonts[ClanTagFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) - ClanPosAdjust : 0.0f;
	CellHeight += MiscFontIndex >= 0 ? (Fonts[MiscFontIndex].CharHeight * FontScale) + (PlayerNamePad * ResolutionScale) : 0.0f;

	return CellHeight;
}


/**
 * Tests a PRI to see if we should display it on the scoreboard
 *
 * @Param PRI		The PRI to test
 * @returns TRUE if we should display it, returns FALSE if we shouldn't
 */
function bool IsValidScoreboardPlayer( UTPlayerReplicationInfo PRI)
{
	//@hack: workaround for ghost PRIs - don't show a PRI on the scoreboard for the server if it's unowned
	if ( !PRI.bIsInactive && PRI.WorldInfo.NetMode != NM_Client &&
		(PRI.Owner == None || (PlayerController(PRI.Owner) != None && PlayerController(PRI.Owner).Player == None)) )
	{
		return false;
	}

	if ( AssociatedTeamIndex < 0 || PRI.GetTeamNum() == AssociatedTeamIndex )
	{
		return !PRI.bOnlySpectator;
	}

	return false;
}

/**
 * Draw any highlights.  These should render underneath the full width of the cell
 */
function DrawHighlight(UTPlayerReplicationInfo PRI, float YPos, float CellHeight, float FontScale)
{
	local float X;
	local UTPlayerController PC;
 	local LinearColor LC;
	local bool MyPRI;

	MyPRI = (UTUIScene(GetScene()).GetPRIOwner() == PRI) ? true : false;

	PC = PRI != none ? UTPlayerController(PRI.Owner) : None;

	if ( (!bInteractive && PC != none && PC.Player != none && LocalPlayer(PC.Player) != none && MyPRI ) ||
		 ( bInteractive && PRI != None && PRI.PlayerID == SelectedPI ) )
	{

		if ( bInteractive || IsFocused() )
		{
			// Figure out where to draw the bar
			X = (Canvas.ClipX * 0.5) - (Canvas.ClipX * BarPerc * 0.5);
			Canvas.SetPos(X,YPos);
			LC = MakeLinearColor( 0.02f, 0.02f, 0.02f, 1.0f );
 			Canvas.DrawTileStretched(SelBarTex,Canvas.ClipX * BarPerc,CellHeight /** FontScale*/,650,310,325,64,LC);
		}
		Canvas.SetDrawColor(255,255,255,255);
	}
	else
	{
		Canvas.SetDrawColor(255,255,255,160);
	}
}

/**
 * Draw the player's clan tag.
 */
function DrawClanTag(UTPlayerReplicationInfo PRI, float X, out float YPos, int FontIndex, float FontScale)
{
	if ( FontIndex < 0 )
	{
		return;
	}

	// Draw the clan tag
	DrawString( GetClanTagStr(PRI),X, YPos, FontIndex, FontScale);
	YPos += Fonts[FontIndex].CharHeight * FontScale + (PlayerNamePad*ResolutionScale) - ClanPosAdjust;
}

/**
 * Draw the Player's Score
 */
function float DrawScore(UTPlayerReplicationInfo PRI, float YPos, int FontIndex, float FontScale)
{
	local string Spot;
	local float Width, Height;

	// Draw the player's Kills
	Spot = GetPlayerDeaths(PRI);
	Canvas.Font = Fonts[FontIndex].Font;
	Canvas.StrLen( Spot, Width, Height );
	DrawString( Spot, RightColumnPosX+RightColumnWidth-Width, YPos,FontIndex,FontScale * MainPerc);

	// Draw the player's Frags
	Spot = GetPlayerScore(PRI);
	Canvas.StrLen( Spot, Width, Height );
	DrawString( Spot, LeftColumnPosX+LeftColumnWidth-Width, YPos,FontIndex,FontScale * MainPerc);

	return LeftColumnPosX;
}

/**
 * Draw's the player's Number (ie "1.")
 */
simulated function DrawPlayerNum(UTPlayerReplicationInfo PRI,int PIndex, out float YPos, float FontIndex, float FontScale)
{
	local float XL, YL, Y, W, H;
	local color C;
	local UIRoot.TextureCoordinates WeapCoords;

	if ( PRI == None )
	{
		return;
	}
	else if ( PRI.WorldInfo.GRI.bMatchIsOver && (PRI.WeaponAwardIndex >= 0) && (PRI.WorldInfo.GRI.GameClass != class'UTDuelGame') )
	{
		C = Canvas.DrawColor;
		WeapCoords = WeaponCoords[PRI.WeaponAwardIndex];
		StrLen("00",XL,YL, FontIndex, FontScale);
		W = XL * 1.8;
		H = 1.25 * W * WeapCoords.VL/WeapCoords.UL;
		Y = YPos + (YL * 0.5) - (H * 0.5);

		Canvas.SetPos(-0.5*XL, Y);
		Canvas.SetDrawColor(0,0,0,255);
		Canvas.DrawTile(class'UTHUD'.default.IconHudTexture, W+2.0, H+2.0, WeapCoords.U, WeapCoords.V, WeapCoords.UL, WeapCoords.VL);
		Canvas.SetPos(-0.5*XL, Y);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawTile(class'UTHUD'.default.IconHudTexture, W, H, WeapCoords.U, WeapCoords.V, WeapCoords.UL, WeapCoords.VL);
		Canvas.DrawColor = C;
	}
	else if ( PRI.IsHero() )
	{
		C = Canvas.DrawColor;

		// Figure out how much space we have
		StrLen("00",XL,YL, FontIndex, FontScale);
		W = XL * 0.8;
		H = W * HeroCoords.VL/HeroCoords.UL;

		Y = YPos + (YL * 0.5) - (H * 0.5);

		Canvas.SetPos(XL * 0.5, Y);
		Canvas.SetDrawColor(255,255,0,255);
		Canvas.DrawTile(class'UTHUD'.default.UT3GHudTexture, W, H, HeroCoords.U, HeroCoords.V, HeroCoords.UL, HeroCoords.VL);
		Canvas.DrawColor = C;
	}
}

/**
 * Draw the Player's Name
 */
function DrawPlayerName(UTPlayerReplicationInfo PRI, float NameOfst, float NameClipX, out float YPos, int FontIndex, float FontScale, bool bIncludeClan)
{
	local float XL, YL;
	local string Spot;

	Spot = bIncludeClan ? GetPlayerNameStr(PRI) : GetClanTagStr(PRI)$GetPlayerNameStr(PRI);
	StrLen(Spot, XL, YL, FontIndex, FontScale * MainPerc);
	YL = Fonts[FontIndex].CharHeight * FontScale * MainPerc;

	if ( XL > (NameClipX - NameOfst) && !bIncludeClan )
	{
		Spot = GetPlayerNameStr(PRI);
	}

	DrawString( Spot, NameOfst, YPos, FontIndex, FontScale * MainPerc);

	if (UTBetrayalPRI(PRI) != None)
	{
		DrawDaggers(UTBetrayalPRI(PRI), NameOfst + XL + 5, YPos);
	}

	YPos += YL;
}

function DrawDaggers(UTBetrayalPRI PRI, float PosX, float PosY)
{
	local int i, TempCount, DaggerWidth, DaggerHeight;
	local int NumGoldDaggers, NumSilverDaggers;
	local TextureCoordinates DaggerTexCoords;
	local float DaggerSpacing, SilverDaggerOffset;

	DaggerWidth = class'UTBetrayalHUD'.default.DaggerWidth;
	DaggerHeight = class'UTBetrayalHUD'.default.DaggerHeight;
	DaggerSpacing = class'UTBetrayalHUD'.default.DaggerSpacing;
	SilverDaggerOffset = class'UTBetrayalHUD'.default.SilverDaggerOffset;
	DaggerTexCoords = class'UTBetrayalHUD'.default.DaggerTexCoords;

	//Just sanity clamp
	TempCount = Clamp(PRI.BetrayalCount, 0, 100);
	NumGoldDaggers = TempCount / 5;
	NumSilverDaggers = TempCount % 5;

	//Start drawing the daggers
	for (i=0; i<NumGoldDaggers; i++)
	{
		Canvas.SetPos(PosX, PosY);
		Canvas.DrawColorizedTile(class'UTHUD'.default.UT3GHudTexture, DaggerWidth * ResolutionScale, DaggerHeight * ResolutionScale, DaggerTexCoords.U, DaggerTexCoords.V, DaggerTexCoords.UL, DaggerTexCoords.VL, class'UTHUD'.default.GoldLinearColor);

		//Don't bump for the last gold dagger drawn
		if (i<NumGoldDaggers-1)
		{
			PosX += (DaggerSpacing * ResolutionScale);
		}
	}

	//Add spacing between gold/silver daggers
	if (NumGoldDaggers > 0)
	{
		PosX += (SilverDaggerOffset * ResolutionScale);
	}

	for (i=0; i<NumSilverDaggers; i++)
	{
		Canvas.SetPos(PosX, PosY);
		Canvas.DrawColorizedTile(class'UTHUD'.default.UT3GHudTexture, DaggerWidth * ResolutionScale, DaggerHeight * ResolutionScale, DaggerTexCoords.U, DaggerTexCoords.V, DaggerTexCoords.UL, DaggerTexCoords.VL, class'UTHUD'.default.SilverLinearColor);

		PosX += (DaggerSpacing * ResolutionScale);
	}
}

/**
 * Draw any Misc data
 */
function DrawMisc(UTPlayerReplicationInfo PRI, float NameOfst, out float YPos, int FontIndex, float FontScale)
{
	local string Spot;
	local float XL,YL;

	// Draw the Misc Strings
	if ( FontIndex < 0 )
	{
		return;
	}

	YPos += PlayerNamePad * ResolutionScale;
	DrawString( GetLeftMisc(PRI), NameOfst, YPos - MiscPosAdjust, FontIndex, FontScale);
	Spot = GetRightMisc(PRI);
	StrLen(Spot,XL,YL, FontIndex, FontScale);
	DrawString( Spot, Canvas.ClipX-XL-15, YPos - MiscPosAdjust, FontIndex,FontScale);
	YPos += Fonts[FontIndex].CharHeight * FontScale - MiscPosAdjust;
}


/**
 * Draw an full cell.. Call the functions above.
 */
function DrawPRI(int PIndex, UTPlayerReplicationInfo PRI, float CellHeight, int FontIndex, int ClanTagFontIndex, int MiscFontIndex, float FontScale, out float YPos)
{
	local float NameOfst, NameClipX;
	local PlayerReplicationInfo OwnerPRI;

	// Set the default Drawing Color
	DrawHighlight(PRI, YPos, CellHeight, FontScale);

	OwnerPRI = UTUIScene(GetScene()).GetPRIOwner();
	if ( PRI == OwnerPRI )
	{
		Canvas.DrawColor = class'UTHUD'.default.GoldColor;
	}
	else if ( (UTBetrayalPRI(PRI) != None) && PRI.WorldInfo.GRI.OnSameTeam(PRI, OwnerPRI) )
	{
		Canvas.DrawColor = AllyColor;
	}
	else
	{
		Canvas.DrawColor = class'HUD'.default.WhiteColor;
	}

	// Line up the names with the header.
	NameOfst = Canvas.ClipX * HeaderXPct;

	YPos += (HighlightPad*ResolutionScale);

	Canvas.DrawColor.A = 105;
	DrawClanTag(PRI, NameOfst, YPos, ClanTagFontIndex, FontScale);

	// Draw the player's Score so we can see how much room we have to draw the name
	if ( PRI == OwnerPRI )
	{
		Canvas.DrawColor.A = 255;
	}
	else
	{
		Canvas.DrawColor.A = 128;
	}
	if ( PRI == None || !PRI.bFromPreviousLevel || PRI.WorldInfo.IsInSeamlessTravel() ||
		(PlayerOwner != None && PlayerOwner.PlayerReplicationInfo != None && PlayerOwner.PlayerReplicationInfo.bFromPreviousLevel) )
	{
		NameClipX = DrawScore(PRI, YPos, FontIndex, FontScale);
	}
	else
	{
		NameClipX = Canvas.ClipX;
	}


	// Draw the Player's Name and position on the team - NOTE it doesn't increment YPos
		DrawPlayerNum(PRI, PIndex, YPos, FontIndex, FontScale);

	DrawPlayerName(PRI, NameOfst, NameClipX, YPos, FontIndex, FontScale, (ClanTagFontIndex >= 0));

	Canvas.DrawColor.A = 105;
	DrawMisc(PRI, NameOfst, YPos, MiscFontIndex, FontScale);

	YPos += (HighlightPad*ResolutionScale);
}

/**
 * Returns the Clan Tag in the PRI
 */
function string GetClanTagStr(UTPlayerReplicationInfo PRI)
{
	local UTGameReplicationInfo GRI;

	if ( PRI != none )
	{
		GRI = UTGameReplicationInfo(PRI.WorldInfo.GRI);
		if ( GRI != none && GRI.bStoryMode )
		{
			if (PRI.bBot || PRI.SinglePlayerCharacterIndex == INDEX_NONE)
			{
				return "";
			}

			return "["$GRI.SinglePlayerBotNames[PRI.SinglePlayerCharacterIndex]$"]";
		}

		return PRI.ClanTag != "" ? ("["$PRI.ClanTag$"]") : "";
	}
	else
	{
		return "[Clan]";
	}
}

/**
 * Returns the Player's Name
 */
function string GetPlayerNameStr(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		return PRI.GetPlayerAlias();
	}
	else
	{
		return FakeNames[NameCnt];
	}
}

/**
 * Returns the # of deaths as a string
 */
function string GetPlayerDeaths(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		return string(int(PRI.Deaths));
	}
	else
	{
		return "0000";
	}
}

/**
 * Returns the score as a string
 */
function string GetPlayerScore(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		return string(int(PRI.Score));
	}
	else
	{
		return "0000";
	}
}

/**
 * Returns the time online as a string
 */
function string GetTimeOnline(UTPlayerReplicationInfo PRI)
{
	return "Time:"@ class'UTHUD'.static.FormatTime( PRI.WorldInfo.GRI.ElapsedTime );
}

/**
 * Get the Left Misc string
 */
function string GetLeftMisc(UTPlayerReplicationInfo PRI)
{
	if ( PRI != None )
	{
		if (LeftMiscStr != "")
		{
			return UserString(LeftMiscStr, PRI);
		}
		else
		{
			return "";
		}
	}
	return "";
}

/**
 * Get the Right Misc string
 */
function string GetRightMisc(UTPlayerReplicationInfo PRI)
{
	local int TotalSeconds, Hours, Minutes, Seconds;
	local string TimeString;
	local bool bHasHours;

	if ( (PRI.WorldInfo.NetMode != NM_Standalone) && !PRI.bBot )
	{
		TotalSeconds = PRI.WorldInfo.GRI.ElapsedTime - PRI.StartTime;
		hours = TotalSeconds/3600;
		if ( hours > 0 )
		{
			TimeString = Hours$":";
			TotalSeconds -= 3600*Hours;
			bHasHours = true;
		}
		minutes = TotalSeconds/60;
		if ( bHasHours && (minutes < 10) )
		{
			TimeString = TimeString$"0";
		}
		TimeString = TimeString$minutes$":";

		seconds = TotalSeconds - 60*minutes;
		if ( seconds < 10 )
		{
			TimeString = TimeString$"0";
		}
		TimeString = TimeString$seconds;
		return TimeString$"   "$PingString@(4*PRI.Ping);
	}
	return "";
}

/**
 * Does string replace on the user string for several values
 */
function string UserString(string Template, UTPlayerReplicationInfo PRI)
{
	// TO-DO - Hook up the various values
	return Template;
}

/**
 * Our own implementation of DrawString that manages font lookup and scaling
 */
function float DrawString(String Text, float XPos, float YPos, int FontIdx, float FontScale)
{
	if (FontIdx >= 0 && Text != "")
	{
		Canvas.Font = Fonts[FontIdx].Font;
		Canvas.SetPos(XPos, YPos);
		Canvas.DrawTextClipped(Text,,FontScale,FontScale);
		return Fonts[FontIdx].CharHeight* FontScale;
	}
	return 0;
}

/**
 * Our own version of StrLen that manages font lookup and scaling
 */
function StrLen(String Text, out float XL, out float YL, int FontIdx, float FontScale)
{
	if (FontIdx >= 0 && Text != "")
	{
		Canvas.Font = Fonts[FontIdx].Font;
		Canvas.StrLen(Text, xl,yl);
		xl *= FontScale;
		yl *= FontScale;
	}
	else
	{
		xl = 0;
		yl = 0;
	}
}

function int GetPRICount()
{
	local UTPlayerReplicationInfo PRI;
	local int CurPRIIndex;
	local int Players;
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo( UTHudSceneOwner.GetWorldInfo().GRI );

	// Iterate over our PRIs and figure out the GUI index for the currently selected player
	Players = 0;
	for( CurPRIIndex = 0; CurPRIIndex < GRI.PRIArray.Length; CurPRIIndex++ )
	{
		PRI = UTPlayerReplicationInfo( GRI.PRIArray[ CurPRIIndex ] );
		if( PRI != none && IsValidScoreboardPlayer( PRI ) )
		{
			Players++;
		}
	}

	return Players;
}


function int GetSelectedIndex()
{
	local UTPlayerReplicationInfo PRI;
	local int CurPRIIndex;
	local int PlayerIndex;
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo( UTHudSceneOwner.GetWorldInfo().GRI );

	// Iterate over our PRIs and figure out the GUI index for the currently selected player
	PlayerIndex = 0;
	for( CurPRIIndex = 0; CurPRIIndex < GRI.PRIArray.Length; CurPRIIndex++ )
	{
		PRI = UTPlayerReplicationInfo( GRI.PRIArray[ CurPRIIndex ] );
		if( PRI != none && IsValidScoreboardPlayer( PRI ) )
		{
			if( PRI.PlayerID == SelectedPI )
			{
				return PlayerIndex;
			}
			PlayerIndex++;
		}
	}

	return -1;
}

function SetSelectedIndex(int GUIIndex)
{
	local UTPlayerReplicationInfo PRI;
	local int CurPRIIndex;
	local array<UTPlayerReplicationInfo> PRIs;
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo( UTHudSceneOwner.GetWorldInfo().GRI );

	// Iterate over our PRIs and figure out the GUI index for the currently selected player
	SelectedUIIndex = 0;
	for( CurPRIIndex = 0; CurPRIIndex < GRI.PRIArray.Length; CurPRIIndex++ )
	{
		PRI = UTPlayerReplicationInfo( GRI.PRIArray[ CurPRIIndex ] );
		if( PRI != none && IsValidScoreboardPlayer( PRI ) )
		{
			PRIs[ PRIs.Length ] = PRI;
			if( GUIIndex == SelectedUIIndex )
			{
				break;
			}
			SelectedUIIndex++;
		}
	}

	// clamp them
	SelectedUIIndex = Clamp(SelectedUIIndex, 0, PRIs.length - 1);
	if ( SelectedUIIndex >= 0 )
	{
		SelectedPI = PRIs[ SelectedUIIndex ].PlayerID;
		OnSelectionChange( self, PRIs[ SelectedUIIndex ] );
	}
}

function bool FindSelfInScoreboard(out int GUIIndex)
{
	local UTPlayerReplicationInfo OwningPRI;
	local UTPlayerReplicationInfo PRI;
	local int CurPRIIndex;
	local int PlayerIndex;
	local UTGameReplicationInfo GRI;

	OwningPRI = UTHudSceneOwner.GetPRIOwner();
	GRI = UTGameReplicationInfo( UTHudSceneOwner.GetWorldInfo().GRI );

	// Iterate over our PRIs and figure out the GUI index for the currently selected player
	GUIIndex = -1;
	if (OwningPRI != None && GRI != None)
	{
		PlayerIndex = 0;
		for( CurPRIIndex = 0; CurPRIIndex < GRI.PRIArray.Length; CurPRIIndex++ )
		{
			PRI = UTPlayerReplicationInfo( GRI.PRIArray[ CurPRIIndex ] );
			if( PRI != none && IsValidScoreboardPlayer( PRI ) )
			{
				if( PRI == OwningPRI )
				{
					GUIIndex = PlayerIndex;
					return true;
				}
				PlayerIndex++;
			}
		}
	}
	return false;
}

function int DisableScoreboard()
{
	OnSelectionChange = None;
	OnProcessInputKey = None;
	SelectedUIIndex = GetSelectedIndex();
	SelectedPI = -1;

	return SelectedUIIndex;
}

function EnableScoreboard(optional int NewUIIndex = -1)
{
	OnProcessInputKey = ProcessInputKey;
	if (NewUIIndex != -1)
	{
		SetSelectedIndex(NewUIIndex);
	}
	else
	{
		SetSelectedIndex(SelectedUIIndex);
	}

	SetFocus(none);
}

/*********************************[ InteractiveMode ]*****************************/

function ChangeSelection(int Ofst)
{
	local UTGameReplicationInfo GRI;
	local array<UTPlayerReplicationInfo> PRIs;
	local UTPlayerReplicationInfo PRI;
	local int CurPRIIndex;
	local int OldSelectedPlayerIndex;

	GRI = UTGameReplicationInfo(UTHudSceneOwner.GetWorldInfo().GRI);

	// Iterate over our PRIs and figure out the GUI index for the currently selected player
	OldSelectedPlayerIndex = -1;
	for( CurPRIIndex = 0; CurPRIIndex < GRI.PRIArray.Length; CurPRIIndex++ )
	{
		PRI = UTPlayerReplicationInfo( GRI.PRIArray[ CurPRIIndex ] );
		if ( PRI != none && IsValidScoreboardPlayer(PRI) )
		{
			if (PRI.PlayerID == SelectedPI)
			{
				OldSelectedPlayerIndex = PRIs.Length;
			}
			PRIs[PRIs.Length] = PRI;
		}
	}

	// Adjust and clamp the selection
	SelectedUIIndex = OldSelectedPlayerIndex + Ofst;
	SelectedUIIndex = Clamp(SelectedUIIndex, 0, PRIs.length - 1);

	// Selection changed!
	SelectedPI = PRIs[ SelectedUIIndex ].PlayerID;
	OnSelectionChange( self, PRIs[ SelectedUIIndex ] );
}

delegate OnSelectionChange(UTScoreboardPanel TargetScoreboard, UTPlayerReplicationInfo PRI);

function Vector GetMousePosition()
{
	local int x,y;
	local float w,h,tw,th;
	local vector2D MousePos;
	local vector AdjustedMousePos;

	// Figure out where the press was in overall widget space

	class'UIRoot'.static.GetCursorPosition( X, Y );
	MousePos.X = X;
	MousePos.Y = Y;
	AdjustedMousePos = PixelToCanvas(MousePos);
	AdjustedMousePos.X -= GetPosition(UIFACE_Left,EVALPOS_PixelViewport);
	AdjustedMousePos.Y -= GetPosition(UIFACE_Top, EVALPOS_PixelViewport);

	// Now figure out where it is just in list space (minus headers / padding / etc)


	w = GetBounds(UIORIENT_Horizontal, EVALPOS_PixelViewport);
	h = GetBounds(UIORIENT_Vertical, EVALPOS_PixelViewport);

	tW = w * TextPctWidth;
	tH = h * TextPctHeight;

	AdjustedMousePos.X -= tW * 0.5;		// We center the horiz.
	AdjustedMousePos.Y -= tH;

	return AdjustedMousePos;
}


function SelectUnderCursor()
{
	local UTGameReplicationInfo GRI;
	local Vector CursorVector;
	local int Item, c, i;
	local UTPlayerReplicationInfo PRI;

	CursorVector = GetMousePosition();

	// Attampt to figure out


	Item = int( CursorVector.Y / LastCellHeight);

	GRI = UTGameReplicationInfo(UTHudSceneOwner.GetWorldInfo().GRI);
	for (i=0; i < GRI.PRIArray.Length; i++)
	{
		PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
		if ( PRI != none && IsValidScoreboardPlayer(PRI) )
		{
			if (c == Item)
			{
				SelectedPI = PRI.PlayerID;
				OnSelectionChange(self,PRI);
				return;
			}
			c++;
		}
	}
}

function UTPlayerReplicationInfo GetPRIUnderCursor()
{
	local UTGameReplicationInfo GRI;
	local Vector CursorVector;
	local int Item, c, i;
	local UTPlayerReplicationInfo PRI;

	CursorVector = GetMousePosition();
	GRI = UTGameReplicationInfo(UTHudSceneOwner.GetWorldInfo().GRI);

	Item = int(CursorVector.Y / LastCellHeight);


	for (i=0; i<GRI.PRIArray.Length; ++i)
	{
		PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);

		if (PRI != none && IsValidScoreboardPlayer(PRI))
		{
			if (c == Item)
				return PRI;

			c++;
		}
	}

	return none;
}

function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	if (EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat)
	{
		if (EventParms.InputAliasName == 'SelectionUp')
		{
		 	ChangeSelection(-1);
		 	return true;
		}
		else if (EventParms.InputAliasName == 'SelectionDown')
		{
			ChangeSelection(1);
			return true;
		}
		else if (EventParms.InputAliasName == 'Select')
		{
			SetFocus(none);
			SelectUnderCursor();
			return true;
		}
	}
	else if (EventParms.InputKeyName == 'LeftMouseButton' && EventParms.EventType == IE_DoubleClick)
	{
		//Call the double click delegate
		OnDoubleClick(self, 0);
	}

    return false;
}

defaultproperties
{
	Fonts(0)=(Font=Font'EngineFonts.SmallFont');
 	Fonts(1)=(Font=Font'UI_Fonts_Final.HUD.MF_Small');
 	Fonts(2)=(Font=Font'UI_Fonts_Final.HUD.MF_Medium');
 	Fonts(3)=(Font=Font'UI_Fonts_Final.HUD.MF_Large');

	ClanTagPerc=0.7
	MiscPerc=1.1
	MainPerc=0.95
	SelBarTex=Texture2D'UI_HUD.HUD.UI_HUD_BaseC'
	AssociatedTeamIndex=-1
	BarPerc=1.2
	bDrawPlayerNum=false

	FakeNames(0)="WWWWWWWWWWWWWWW"
	FakeNames(1)="DrSiN"
	FakeNames(2)="Mysterial"
	FakeNames(3)="Reaper"
	FakeNames(4)="ThomasDaTank"
	FakeNames(5)="Luke Skywalker"
	FakeNames(6)="Indy"
	FakeNames(7)="UTBabe"
	FakeNames(8)="Mulder"
	FakeNames(9)="Starbuck"
	FakeNames(10)="Scully"
	FakeNames(11)="Starbuck"
	FakeNames(12)="Quiet Riot"
	FakeNames(13)="BonusPoint"
	FakeNames(14)="Gripper"
	FakeNames(15)="Midnight"
	FakeNames(16)="too damn tired"
	FakeNames(17)="Spiff"
	FakeNames(18)="Mr. Sckum"
	FakeNames(19)="SkummyBoy"
	FakeNames(20)="DrSiN"
	FakeNames(21)="Mysterial"
	FakeNames(22)="Reaper"
	FakeNames(23)="Mr.PooPoo"
	FakeNames(24)="ThomasDaTank"
	FakeNames(25)="Luke Skywalker"
	FakeNames(26)="Indy"
	FakeNames(27)="UTBabe"
	FakeNames(28)="Mulder"
	FakeNames(29)="Scully"
	FakeNames(30)="Screwy"
	FakeNames(31)="Starbuck"

	TeamColors(0)=(R=51,G=0,B=0,A=255)
	TeamColors(1)=(R=0,G=0,B=51,A=255)

	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Focused')
	SelectedPI=-1
	SelectedUIIndex=-1

	bMustDrawLocalPRI=true

	HeroCoords=(U=136,UL=81,V=11,VL=74)
	AllyColor=(R=64,G=128,B=255)

	WeaponCoords(0)=(U=453,V=327,UL=135,VL=57)
	WeaponCoords(1)=(U=600,V=341,UL=111,VL=58)
	WeaponCoords(2)=(U=600,V=399,UL=128,VL=62)
	WeaponCoords(3)=(U=728,V=382,UL=162,VL=45)
	WeaponCoords(4)=(U=453,V=467,UL=147,VL=41)
	WeaponCoords(5)=(U=131,V=429,UL=132,VL=52)
	WeaponCoords(6)=(U=453,V=508,UL=147,VL=52)
	WeaponCoords(7)=(U=131,V=379,UL=129,VL=50)
	WeaponCoords(8)=(U=726,V=532,UL=165,VL=51)
	WeaponCoords(9)=(U=453,V=384,UL=147,VL=82)

	SplitScreenHeaderAdjustmentY=1.25
	SplitScreenScorePosAdjustmentY=1.5
}
