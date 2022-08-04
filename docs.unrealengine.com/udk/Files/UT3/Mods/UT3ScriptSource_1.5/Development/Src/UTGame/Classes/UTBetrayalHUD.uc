/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTBetrayalHUD extends UTHUD;

/** Coin count at the time of the previous display */
var int LastCoinCount;

/** Position to draw the player's current coin count */
var vector2d CoinCountPosition;

var localized string PotString, RogueString, FreelanceString;

/** width / height of dagger icon  **/
var int DaggerWidth, DaggerHeight;

/** spacing between individual daggers **/
var float DaggerSpacing;

/** spacing between silver and gold daggers  **/
var float SilverDaggerOffset;

/** spacing between top of background and names/daggers **/
var float NameYPadding, DaggerYPadding;

/** spacing between individual teammates */
var float TeammateSpacing;

/** font size for teammates **/
var int NameFontSize;

/** spacing from above hud **/
var int YFudgeValue;

/** padding for the last row of text **/
var int PotValPadding;

/** Coordinates of dagger texture */
var TextureCoordinates DaggerTexCoords;

struct TeammateHudInfo 
{
	var string TeammateName;
	var float TeammateNameStrWidth;
	var int NumGoldDaggers;
	var int NumSilverDaggers;
};

function DisplayScoring()
{
	local vector2d POS;

	Super.DisplayScoring();

	if ( bShowFragCount || (bHasLeaderboard && bShowLeaderboard) )
	{
		POS = ResolveHudPosition(CoinCountPosition, 115, 44);
		DisplayScoreBonus(POS);
	}
}

/*
*   Draws the nameplate behind the teammate names/daggers
*   @param Pos - center of the 'hud'
*   @param TeammateNameWidth - width the name takes up (already accounts for resolution)
*   @param NumDaggersWidth - width the betrayal daggers take up
*/
function DrawTeammateBackground(vector2d Pos, float TeammateNameWidth, float NumDaggersWidth)
{
	local float NameplateHeight;
	
	NameplateHeight = NameplateCenter.VL * ResolutionScale;

	//Start to the right with the player name
	Canvas.SetPos(Pos.X - TeammateNameWidth - ((NameplateWidth + 0.5 * NameplateBubbleWidth) * ResolutionScale), Pos.Y);
	Canvas.DrawColorizedTile(UT3GHudTexture, NameplateWidth * ResolutionScale, NameplateHeight, NameplateLeft.U, NameplateLeft.V, NameplateLeft.UL, NameplateLeft.VL, BlackBackgroundColor);
	Canvas.DrawColorizedTile(UT3GHudTexture, TeammateNameWidth, NameplateHeight, NameplateCenter.U, NameplateCenter.V, NameplateCenter.UL, NameplateCenter.VL, BlackBackgroundColor); 

	Canvas.DrawColorizedTile(UT3GHudTexture, NameplateBubbleWidth * ResolutionScale, NameplateHeight, NameplateBubble.U, NameplateBubble.V, NameplateBubble.UL, NameplateBubble.VL, BlackBackgroundColor);
	Canvas.DrawColorizedTile(UT3GHudTexture, NumDaggersWidth * ResolutionScale, NameplateHeight, NameplateCenter.U, NameplateCenter.V, NameplateCenter.UL, NameplateCenter.VL, BlackBackgroundColor); 

	Canvas.DrawColorizedTile(UT3GHudTexture, NameplateWidth * ResolutionScale, NameplateHeight, NameplateRight.U, NameplateRight.V, NameplateRight.UL, NameplateRight.VL, BlackBackgroundColor);
}

function DisplayScoreBonus(vector2d Pos)
{
	local UTBetrayalPRI BPRI;
	local string PlayerName, PotValue;
	local float XL, YL, DaggerStartPos;
	local float PlayerNameWidth;
	local float MaxTeammmateNameStrWidth;
	local int TempCount;
	local int i,j;

	local TeammateHudInfo aTeammate;
	local array<TeammateHudInfo> HudTeammates;
	local int NumGoldDaggers, NumSilverDaggers;
	local float NumDaggersWidth;

	//Early out for wrong gametype
	BPRI = UTBetrayalPRI(UTOwnerPRI);
	if ( BPRI == None )
	{
		return;
	}

	Canvas.Font = GetFontSizeIndex(NameFontSize);

	//Start at top center screen
	DaggerStartPos = (FullWidth * SafeRegionPct) * 0.5;
	Pos.X = DaggerStartPos;
	Pos.Y += YFudgeValue;

	//Determine number of daggers drawn	for your teammates
	if (BPRI.CurrentTeam != None)
	{
		for (i=0; i<class'UTBetrayalTeam'.const.MAX_TEAMMATES; i++)
		{
			if (BPRI.CurrentTeam.Teammates[i] != None && BPRI.CurrentTeam.Teammates[i] != BPRI)
			{
				aTeammate.TeammateName = BPRI.CurrentTeam.Teammates[i].PlayerName;
				Canvas.StrLen(aTeammate.TeammateName, aTeammate.TeammateNameStrWidth, YL);
				aTeammate.NumGoldDaggers = 0;
				aTeammate.NumSilverDaggers = 0;

				if (aTeammate.TeammateNameStrWidth > MaxTeammmateNameStrWidth)
				{
					MaxTeammmateNameStrWidth = aTeammate.TeammateNameStrWidth;
				}

				//Just sanity clamp
				TempCount = Clamp(BPRI.CurrentTeam.Teammates[i].BetrayalCount, 0, 100);
				aTeammate.NumGoldDaggers = TempCount / 5;
				aTeammate.NumSilverDaggers = TempCount % 5;

				HudTeammates.AddItem(aTeammate);
			}
		}
	}

	//Add the betrayer to the list (in red)
	if (BPRI.Betrayer != None && BPRI.Betrayer.bIsRogue && (BPRI.Betrayer.RemainingRogueTime > 0) )
	{
		aTeammate.TeammateName = BPRI.Betrayer.PlayerName;
		Canvas.StrLen(aTeammate.TeammateName, aTeammate.TeammateNameStrWidth, YL);
		aTeammate.NumGoldDaggers = 0;
		aTeammate.NumSilverDaggers = 0;

		if (aTeammate.TeammateNameStrWidth > MaxTeammmateNameStrWidth)
		{
			MaxTeammmateNameStrWidth = aTeammate.TeammateNameStrWidth;
		}

		//Just sanity clamp
		TempCount = Clamp(BPRI.Betrayer.BetrayalCount, 0, 100);
		aTeammate.NumGoldDaggers = TempCount / 5;
		aTeammate.NumSilverDaggers = TempCount % 5;

		HudTeammates.AddItem(aTeammate);
	}

	Canvas.SetDrawColor(255, 255, 255, 255);

	//Draw the names of players on your team
	for (i=0; i<HudTeammates.length; i++)
	{
		PlayerName = HudTeammates[i].TeammateName;
		PlayerNameWidth = HudTeammates[i].TeammateNameStrWidth;
		NumGoldDaggers = HudTeammates[i].NumGoldDaggers;
		NumSilverDaggers = HudTeammates[i].NumSilverDaggers;

		//Calculate the width the daggers take up on screen
		NumDaggersWidth = 0;
		if (NumGoldDaggers > 0)
		{
			//Make room for one gold icon
			NumDaggersWidth += DaggerWidth;

			//Plus the spacing added for each additional
			if (NumGoldDaggers > 1)
			{
				NumDaggersWidth += ((NumGoldDaggers - 1) * DaggerSpacing);
			}
		}

		if (NumSilverDaggers > 0)
		{
			//Add the offset between gold/silver if there are gold and silver
			if (NumGoldDaggers > 0)
			{
				NumDaggersWidth += SilverDaggerOffset;
			}
			else
			{
				//Make room for one silver icon
				NumDaggersWidth += DaggerWidth;
			}

			//Plus the spacing added for each additional
			if (NumSilverDaggers > 1)
			{
				NumDaggersWidth += ((NumSilverDaggers - 1) * DaggerSpacing);
			}
		}

		NumDaggersWidth = Max(40, NumDaggersWidth);

		//Center of screen
		Pos.X = DaggerStartPos;

		//Draw some sort of bounds around the betrayal details
		DrawTeammateBackground(Pos, MaxTeammmateNameStrWidth, NumDaggersWidth);

		//The last guy in the list is the betrayer (if any)
		if (i == HudTeammates.length - 1 && BPRI.Betrayer != None && BPRI.Betrayer.bIsRogue)
		{
			Canvas.SetDrawColor(255, 64, 0, 255);

			//Draw the player name to the left of center
			Canvas.SetPos(DaggerStartPos - PlayerNameWidth - (0.5 * NameplateBubbleWidth) * ResolutionScale, Pos.Y + (NameYPadding * ResolutionScale));
			Canvas.DrawTextClipped(PlayerName, true);

			//Start drawing the daggers
			Pos.X = DaggerStartPos + (0.5 * NameplateBubbleWidth * ResolutionScale);
			Canvas.SetPos(Pos.X, Pos.Y + (NameYPadding * ResolutionScale));
			Canvas.DrawTextClipped(string(BPRI.Betrayer.RemainingRogueTime), true);
		}
		else
		{
			//Draw the player name to the left of center
			Canvas.SetPos(DaggerStartPos - PlayerNameWidth - (0.5 * NameplateBubbleWidth) * ResolutionScale, Pos.Y + (NameYPadding * ResolutionScale));
			Canvas.DrawTextClipped(PlayerName, true);

			//Start drawing the daggers
			Pos.X = DaggerStartPos + (0.5 * NameplateBubbleWidth * ResolutionScale);
			for (j=0; j<NumGoldDaggers; j++)
			{
				Canvas.SetPos(Pos.X, Pos.Y + (DaggerYPadding * ResolutionScale));
				Canvas.DrawColorizedTile(UT3GHudTexture, DaggerWidth * ResolutionScale, DaggerHeight * ResolutionScale, DaggerTexCoords.U, DaggerTexCoords.V, DaggerTexCoords.UL, DaggerTexCoords.VL, GoldLinearColor);

				//Don't bump for the last gold dagger drawn
				if (j<NumGoldDaggers-1)
				{
					Pos.X += (DaggerSpacing * ResolutionScale);
				}
			}

			//Add spacing between gold/silver daggers
			if (NumGoldDaggers > 0)
			{
				Pos.X += (SilverDaggerOffset * ResolutionScale);
			}

			for (j=0; j<NumSilverDaggers; j++)
			{
				Canvas.SetPos(Pos.X, Pos.Y + (DaggerYPadding * ResolutionScale));
				Canvas.DrawColorizedTile(UT3GHudTexture, DaggerWidth * ResolutionScale, DaggerHeight * ResolutionScale, DaggerTexCoords.U, DaggerTexCoords.V, DaggerTexCoords.UL, DaggerTexCoords.VL, SilverLinearColor);

				Pos.X += (DaggerSpacing * ResolutionScale);
			}
		}

		//Go down some
		Pos.Y += ((NameplateCenter.VL + TeammateSpacing) * ResolutionScale);
	}

	//Draw the POT string
	Canvas.DrawColor = WhiteColor;
	if ( BPRI.CurrentTeam != None )
	{
		Canvas.DrawColor.R = 64;
		Canvas.DrawColor.G = 128;
		PotValue = PotString@BPRI.CurrentTeam.TeamPot;
	}
	else if ( BPRI.bIsRogue )
	{
		Canvas.DrawColor.B = 0;
		Canvas.DrawColor.G = 64;
		PotValue = RogueString@BPRI.RemainingRogueTime;
	}
	else
	{
		Canvas.DrawColor.B = 0;
		PotValue = FreelanceString;
	}

	//Draw the pot value / freelance or rogue text
	Canvas.Font = GetFontSizeIndex(NameFontSize);
	Canvas.StrLen(PotValue, XL, YL);

	Pos.X = DaggerStartPos;
	DrawNameplateBackground(Pos, XL, BlackBackgroundColor);

	//Center the string
	Canvas.SetPos(DaggerStartPos - (0.5 * XL), Pos.Y + (PotValPadding * ResolutionScale));
	Canvas.DrawText(PotValue);
	Canvas.DrawColor = WhiteColor;
}

/** Draw postrenderfor team beacon for an on-foot player
  */
function DrawPlayerBeacon(UTPawn P, Canvas BeaconCanvas, Vector CameraPosition, Vector ScreenLoc)
{
	local float TextXL, TextYL, XL, YL, NumXL, NumYL, Dist, FontScale, AudioWidth, AudioHeight, PulseAudioWidth;
	local LinearColor BeaconTeamColor;
	local Color	TextColor;
	local string ScreenName, NumString;
	local bool bSameTeam;
	local UTBetrayalPRI PRI, ViewerPRI;

	Canvas = BeaconCanvas;
	bSameTeam = WorldInfo.GRI.OnSameTeam(P, PlayerOwner);
	TextColor = LightGoldColor;
	BeaconTeamColor = bSameTeam ? BlueLinearColor : DMLinearColor;
	ScreenName = P.PlayerReplicationInfo.GetPlayerAlias();
	Canvas.StrLen(ScreenName, TextXL, TextYL);

	PRI = UTBetrayalPRI(P.PlayerReplicationInfo);
	ViewerPRI = UTBetrayalPRI(PlayerOwner.PlayerReplicationInfo);
	Dist = VSize(CameraPosition - P.Location);
	NumString = "+"$PRI.ScoreValueFor(ViewerPRI);
	Canvas.Font = GetFontSizeIndex(3);
	Canvas.StrLen(NumString, NumXL, NumYL);
	Canvas.Font = GetFontSizeIndex(0);
	FontScale = FClamp(800.0/(Dist+1.0), 0.65, 1.0);
	NumXL *= FontScale;
	NumYL *= FontScale;

	XL = Max(TextXL, NumXL);
	YL = TextYL + NumYL;

	if ( CharPRI == P.PlayerReplicationInfo )
	{
		AudioHeight = 34 * Canvas.ClipX/1280;
		YL += AudioHeight;
	}

	DrawBeaconBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-1.7*YL,1.4*XL,1.9*YL, BeaconTeamColor, Canvas);

	if ( CharPRI == P.PlayerReplicationInfo )
	{
		AudioWidth = 57*Canvas.ClipX/1280;
		PulseAudioWidth = AudioWidth * (0.75 + 0.25*sin(6.0*WorldInfo.TimeSeconds));
		Canvas.DrawColor = TextColor;
		Canvas.SetPos(ScreenLoc.X-0.5*PulseAudioWidth,ScreenLoc.Y-1.5*AudioHeight-1.5*TextYL*FontScale);
		Canvas.DrawTile(UT3GHudTexture, PulseAudioWidth, AudioHeight, 173, 132, 57, 34);
	}

	Canvas.DrawColor = TextColor;
	Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-2.5*TextYL*FontScale);
	Canvas.DrawTextClipped(ScreenName, true);

	if ( !bSameTeam )
	{
		if ( PRI.bIsRogue && (ViewerPRI.Betrayer == PRI) )
		{
			//This pawn is a rogue and betrayed the PC looking at him
			Canvas.DrawColor = RedColor;
		}
		else if (ViewerPRI.bIsRogue && (PRI.Betrayer == ViewerPRI))
		{
			//This pawn is out to get the rogue looking at him
			Canvas.DrawColor = GreenColor;
		}
	}

	// draw value of this player
	Canvas.Font = GetFontSizeIndex(3);
	Canvas.SetPos(ScreenLoc.X - 0.5*NumXL,ScreenLoc.Y-2.0*TextYL*FontScale-NumYL-AudioHeight);
	Canvas.DrawTextClipped(NumString, true, FontScale, FontScale);
	Canvas.Font = GetFontSizeIndex(0);
}

defaultproperties
{
	CoinCountPosition=(X=0.5,Y=0)

	NameFontSize=1			//font size for teammates
	DaggerWidth=16			//width of dagger icon
	DaggerHeight=28			//height of dagger icon
	DaggerSpacing=7			//spacing between individual daggers
	SilverDaggerOffset=10	//spacing between silver and gold daggers
	YFudgeValue=10			//spacing between other hud
	NameYPadding=6		    //spcaing between top of background and teammate name text
	DaggerYPadding=3.6		//spacing between top of background and dagger icons
	PotValPadding=7		    //distance between teamnames and potvalue text
	TeammateSpacing=-3		//distance between individual teammate huds

	DaggerTexCoords=(U=262,UL=16,V=53,VL=28)
}

