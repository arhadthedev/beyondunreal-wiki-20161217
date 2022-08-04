/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedHUD extends UTTeamHUD;

/** Coin count at the time of the previous display */
var int LastCoinCount;

/** Last resolution cached for display update */
var float LastResolutionScale;

/** Position to draw the player's current coin count */
var vector2d CoinCountPosition;

/** Cached coin amounts for HUD (updated when coin count changes only) **/
var int NumRedCoins, NumGoldCoins, NumSilverCoins;

/** Screen position of the start of the greed hud */
var float GreedHudStartX, GreedHudStartY;

/** Cached screen length for the coin drawing */
var float CoinDrawLength;

/** Cached screen length for the current score */
var float ScoreWidth;

/** width / height of coin icon  **/
var int CoinWidth, CoinHeight;

/** spacing between individual coins **/
var float CoinSpacing;

/** spacing between coin types  **/
var float CoinGroupOffset;

/** padding above the start of the coin drawing */
var float CoinYStartPadding;
/** padding between top of coin background and start of coins */
var float CoinYPadding;

/** Screen padding to prevent glow text from wrapping */
var float ScreenPadding;

function DisplayFragCount(vector2d POS)
{
	local int CoinCount;
	local bool CoinCountChanged;
	local UTGreedPRI CoinPRI;
	
	CoinPRI = ((PawnOwner != None) && (PawnOwner.PlayerReplicationInfo != None)) ? UTGreedPRI(PawnOwner.PlayerReplicationInfo) : UTGreedPRI(UTOwnerPRI);  
	if ( CoinPRI != None )
	{
		CoinCount = CoinPRI.NumCoins;

		// Figure out if we should be pulsing
		if ( CoinCount != LastCoinCount || LastResolutionScale != ResolutionScale)
		{
			LastCoinCount = CoinCount;
			LastResolutionScale = ResolutionScale;
			FragPulseTime = WorldInfo.TimeSeconds;
			CoinCountChanged = true;
		}

		Canvas.DrawColor = WhiteColor;
		DrawCoinCount(CoinCountChanged);
	}
}

/*
 *   Draws the coin nameplate behind the coins
 *   @param Pos - start position of the coins themselves
 *   @param CoinDisplayWidth - width the coins take up with resolution scale already accounted for
 */
function DrawCoinBackground(vector2d Pos, float CoinDisplayWidth, float ScoreDisplayWidth)
{
	local float NameplateHeight;
	local float ScreenEdge;

	ScreenEdge = (FullWidth * SafeRegionPct) - ScreenPadding;

	NameplateHeight = NameplateCenter.VL * ResolutionScale;

	Canvas.SetPos(ScreenEdge - CoinDisplayWidth - ((2.0 * NameplateWidth + NameplateBubbleWidth + ScoreDisplayWidth) * ResolutionScale), Pos.Y);
	Canvas.DrawColorizedTile(UT3GHudTexture, NameplateWidth * ResolutionScale, NameplateHeight, NameplateLeft.U, NameplateLeft.V, NameplateLeft.UL, NameplateLeft.VL, BlackBackgroundColor);
	Canvas.DrawColorizedTile(UT3GHudTexture, CoinDisplayWidth, NameplateHeight, NameplateCenter.U, NameplateCenter.V, NameplateCenter.UL, NameplateCenter.VL, BlackBackgroundColor); 
	
	Canvas.DrawColorizedTile(UT3GHudTexture, NameplateBubbleWidth * ResolutionScale, NameplateHeight, NameplateBubble.U, NameplateBubble.V, NameplateBubble.UL, NameplateBubble.VL, BlackBackgroundColor);
	Canvas.DrawColorizedTile(UT3GHudTexture, ScoreDisplayWidth * ResolutionScale, NameplateHeight, NameplateCenter.U, NameplateCenter.V, NameplateCenter.UL, NameplateCenter.VL, BlackBackgroundColor); 

	Canvas.DrawColorizedTile(UT3GHudTexture, NameplateWidth * ResolutionScale, NameplateHeight, NameplateRight.U, NameplateRight.V, NameplateRight.UL, NameplateRight.VL, BlackBackgroundColor);
}

function DrawCoinCount(bool CoinCountChanged)
{
	local vector2d Pos;
	local int i, CoinCount;
	local int RedCoinValue, GoldCoinValue, SilverCoinValue;
	local float ScreenEdge;
	local float YL;
	local UTGreedPRI CoinPRI;
	
	CoinPRI = ((PawnOwner != None) && (PawnOwner.PlayerReplicationInfo != None)) ? UTGreedPRI(PawnOwner.PlayerReplicationInfo) : UTGreedPRI(UTOwnerPRI);  
	
	if ( CoinPRI != None && LastCoinCount >= 0)
	{
		Pos = ResolveHudPosition(CoinCountPosition, GreedHudStartX, GreedHudStartY);

		ScreenEdge = (FullWidth * SafeRegionPct) - ScreenPadding;

		//Only update cached values on coin count change
		if (CoinCountChanged)
		{
			RedCoinValue = class'UTGreedCoin_Red'.default.Value;
			GoldCoinValue = class'UTGreedCoin_Gold'.default.Value;
			SilverCoinValue = class'UTGreedCoin_Silver'.default.Value;

            //Sanity clamp
			CoinCount = Clamp(LastCoinCount, 0, 400);

			NumRedCoins = 0;
			NumGoldCoins = 0;
			NumSilverCoins = 0;

			//Tally coins
			while (CoinCount >= RedCoinValue)
			{
				CoinCount -= RedCoinValue;
				NumRedCoins++;
			}

			while (CoinCount >= GoldCoinValue)
			{
				CoinCount -= GoldCoinValue;
				NumGoldCoins++;
			}

			while (CoinCount >= SilverCoinValue)
			{
				CoinCount -= SilverCoinValue;
				NumSilverCoins++;
			}

			//Calculate the appropriate right justify for the Coins
			CoinDrawLength = 0;
			if (NumRedCoins > 0)
			{
				//Make room for one red icon
				CoinDrawLength += (CoinWidth * ResolutionScale);
				//Plus the spacing added for each additional
				if (NumRedCoins > 1)
				{
					CoinDrawLength += ((NumRedCoins - 1) * (CoinSpacing * ResolutionScale));
				}
			}

			if (NumGoldCoins > 0)
			{
				//Add the offset between red/gold if there are red and gold
				if (NumRedCoins > 0)
				{
					CoinDrawLength += (CoinGroupOffset * ResolutionScale);
				}
				else
				{
					//Make room for one gold icon
					CoinDrawLength += (CoinWidth * ResolutionScale);
				}

				//Plus the spacing added for each additional
				if (NumGoldCoins > 1)
				{
					CoinDrawLength += ((NumGoldCoins - 1) * (CoinSpacing * ResolutionScale));
				}
			}

			if (NumSilverCoins > 0)
			{
				//Add the offset between gold/silver if there are gold and silver
				if (NumRedCoins > 0 || NumGoldCoins > 0)
				{
					CoinDrawLength += (CoinGroupOffset * ResolutionScale);
				}
				else
				{
					//Make room for one silver icon
					CoinDrawLength += (CoinWidth * ResolutionScale);
				}

				//Plus the spacing added for each additional
				if (NumSilverCoins > 1)
				{
					CoinDrawLength += ((NumSilverCoins - 1) * (CoinSpacing * ResolutionScale));
				}
			}

			//Calculate the width of the score
			Canvas.Font = GlowFonts[0];
			if (LastCoinCount < 100)
			{
				Canvas.StrLen("88", ScoreWidth, YL);
				//Some magic contained inside DrawGlowText that isn't in StrLen
				ScoreWidth *= (42 / YL);
			}
			else
			{
				Canvas.StrLen("888", ScoreWidth, YL);
				//Some magic contained inside DrawGlowText that isn't in StrLen
				ScoreWidth *= (42 / YL);
			}
		}

		//Start drawing the Coins
		Pos.Y += (CoinYStartPadding * ResolutionScale);

		DrawCoinBackground(Pos, Max(88, CoinDrawLength), ScoreWidth);
		
		Pos.X = ScreenEdge - CoinDrawLength - (NameplateBubbleWidth + ScoreWidth + NameplateWidth) * ResolutionScale;
		Pos.Y += (CoinYPadding * ResolutionScale);
		for (i=0; i<NumRedCoins; i++)
		{
			Canvas.SetPos(Pos.X, Pos.Y);
			Canvas.DrawColorizedTile(UT3GHudTexture, CoinWidth * ResolutionScale, CoinHeight * ResolutionScale, 
										class'UTGreedCoin'.default.CoinIconCoords.U,
										class'UTGreedCoin'.default.CoinIconCoords.V, 
										class'UTGreedCoin'.default.CoinIconCoords.UL,
										class'UTGreedCoin'.default.CoinIconCoords.VL, RedLinearColor);

			//Don't bump for the last red Coin drawn
			if (i<NumRedCoins-1)
			{
				Pos.X += (CoinSpacing * ResolutionScale);
			}
		}

		//Add spacing between red/gold Coins
		if (NumRedCoins > 0)
		{
			Pos.X += (CoinGroupOffset * ResolutionScale);
		}

		for (i=0; i<NumGoldCoins; i++)
		{
			Canvas.SetPos(Pos.X, Pos.Y);
			Canvas.DrawColorizedTile(UT3GHudTexture, CoinWidth * ResolutionScale, CoinHeight * ResolutionScale, 
										class'UTGreedCoin'.default.CoinIconCoords.U,
										class'UTGreedCoin'.default.CoinIconCoords.V, 
										class'UTGreedCoin'.default.CoinIconCoords.UL,
										class'UTGreedCoin'.default.CoinIconCoords.VL, GoldLinearColor);

			//Don't bump for the last gold Coin drawn
			if (i<NumGoldCoins-1)
			{
				Pos.X += (CoinSpacing * ResolutionScale);
			}
		}

		//Add spacing between gold/silver Coins
		if (NumGoldCoins > 0)
		{
			Pos.X += (CoinGroupOffset * ResolutionScale);
		}

		for (i=0; i<NumSilverCoins; i++)
		{
			Canvas.SetPos(Pos.X, Pos.Y);
			Canvas.DrawColorizedTile(UT3GHudTexture, CoinWidth * ResolutionScale, CoinHeight * ResolutionScale, 
										class'UTGreedCoin'.default.CoinIconCoords.U,
										class'UTGreedCoin'.default.CoinIconCoords.V, 
										class'UTGreedCoin'.default.CoinIconCoords.UL,
										class'UTGreedCoin'.default.CoinIconCoords.VL, SilverLinearColor);

			Pos.X += (CoinSpacing * ResolutionScale);
		}

		//Draw the score text
		Pos.X = ScreenEdge - (NameplateWidth * ResolutionScale);
		Pos.Y -= (CoinYPadding + CoinYStartPadding) * ResolutionScale;
		DrawGlowText(string(LastCoinCount), Pos.X, Pos.Y, 42 * ResolutionScale, FragPulseTime, true);
	}
}

/** Draw postrenderfor team beacon for an on-foot player
  */
function DrawPlayerBeacon(UTPawn P, Canvas BeaconCanvas, Vector CameraPosition, Vector ScreenLoc)
{
	local float TextXL, TextYL, XL, YL, Dist, NumXL, NumYL, FontScale, AudioWidth, AudioHeight, PulseAudioWidth;
	local LinearColor BeaconTeamColor;
	local Color	TextColor;
	local string ScreenName, NumString;

	Canvas = BeaconCanvas;
	GetTeamColor( P.GetTeamNum(), BeaconTeamColor, TextColor);
	ScreenName = P.PlayerReplicationInfo.GetPlayerAlias();
	Canvas.StrLen(ScreenName, TextXL, TextYL);

	Dist = VSize(CameraPosition - P.Location);
	// now we always just use the text width, solves a lot of problems
	XL = TextXL;
//	XL = Max( TextXL, 24 * Canvas.ClipX/1024 * (1 + 2*Square((P.TeamBeaconPlayerInfoMaxDist-Dist)/P.TeamBeaconPlayerInfoMaxDist)));

	YL = TextYL;

	if ( UTGreedPRI(P.PlayerReplicationInfo).NumCoins > 0 )
	{
		Canvas.Font = GetFontSizeIndex(2);
		NumString = string(UTGreedPRI(P.PlayerReplicationInfo).NumCoins);
		Canvas.StrLen(NumString, NumXL, NumYL);
		FontScale = FClamp(800.0/(Dist+1.0), 0.75, 1.0);
		Canvas.Font = GetFontSizeIndex(0);
		YL += NumYL * FontScale;
	}
	if ( CharPRI == P.PlayerReplicationInfo )
	{
		AudioHeight = 34 * Canvas.ClipX/1280;
		YL += AudioHeight;
	}
	DrawBeaconBackground(ScreenLoc.X-0.65*XL,ScreenLoc.Y-1.7*YL,1.3*XL,1.8*YL, BeaconTeamColor, Canvas);
	if ( CharPRI == P.PlayerReplicationInfo )
	{
		AudioWidth = 57*Canvas.ClipX/1280;
		PulseAudioWidth = AudioWidth * (0.75 + 0.25*sin(6.0*WorldInfo.TimeSeconds));
		Canvas.DrawColor = TextColor;
		Canvas.SetPos(ScreenLoc.X-0.5*PulseAudioWidth,ScreenLoc.Y-1.5*AudioHeight-0.2*NumYL);
		Canvas.DrawTile(UT3GHudTexture, PulseAudioWidth, AudioHeight, 173, 132, 57, 34);
	}
	Canvas.DrawColor = TextColor;

	if ( UTGreedPRI(P.PlayerReplicationInfo).NumCoins > 0 )
	{
		Canvas.Font = GetFontSizeIndex(2);
		Canvas.SetPos(ScreenLoc.X - 0.5*FontScale*NumXL,ScreenLoc.Y-1.5*NumYL*FontScale-AudioHeight);
		Canvas.DrawTextClipped(NumString, true, FontScale, FontScale);
		Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.2*YL);
		Canvas.Font = GetFontSizeIndex(0);
	}
	else
	{
		Canvas.SetPos(ScreenLoc.X-0.5*TextXL,ScreenLoc.Y-1.2*YL);
	}
	Canvas.DrawTextClipped(ScreenName, true);
}

defaultproperties
{
	GreedHudStartX=115
	GreedHudStartY=44

	ScreenPadding=10 //right screen padding to prevent glowtext from wrapping score

	CoinCountPosition=(X=-1,Y=0)

	CoinWidth=28			//width of coin icon
	CoinHeight=28			//height of coin icon
	CoinSpacing=8			//spacing between individual coins
	CoinGroupOffset=10		//spacing between coin groupings

	CoinYPadding=3.6    //padding between top of background and drawing the coin
	CoinYStartPadding=5 //padding between the upper score hud and the coin hud
}

