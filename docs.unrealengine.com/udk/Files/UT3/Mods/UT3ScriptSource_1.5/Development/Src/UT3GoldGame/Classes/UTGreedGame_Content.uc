/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedGame_Content extends UTGreedGame;

/** Handles the spawning of the coin when a pawn dies
 *  Clears the coin count of the killed pawn
 */
function ScoreKill(Controller Killer, Controller Other)
{
	local UTGreedPRI KillerPRI;
	local UTGreedPRI VictimPRI;
	local UTVehicle VictimVehicle;
	local int CoinValue;
	local int RedCoinValue, GoldCoinValue, SilverCoinValue;
	local UTPawn KillerPawn;

	RedCoinValue = class'UTGreedCoin_Red'.default.Value;
	GoldCoinValue = class'UTGreedCoin_Gold'.default.Value;
	SilverCoinValue = class'UTGreedCoin_Silver'.default.Value;

	if ( Killer == None && Other != None )
	{
		VictimPRI = UTGreedPRI(Other.PlayerReplicationInfo);
		VictimPRI.ClearCoins();
		return;
	}

	KillerPRI = UTGreedPRI(Killer.PlayerReplicationInfo);
	VictimPRI = UTGreedPRI(Other.PlayerReplicationInfo);
	if ( KillerPRI != None && VictimPRI != None )
	{
		CoinValue = VictimPRI.NumCoins;
		if ( KillerPRI != VictimPRI )
		{
			if ( VictimPRI.IsSuperHero() )
			{
				CoinValue += RedCoinValue;
			}
			else if ( VictimPRI.IsHero() )
			{
				CoinValue += GoldCoinValue;
			}
			else
			{
				CoinValue += SilverCoinValue;
			}

			// Add extra coins for killing vehicles
			VictimVehicle = UTVehicle(Other.Pawn);
			if ( (VictimVehicle != None) && (VictimVehicle.GreedCoinBonus > 0) )
			{
				CoinValue += VictimVehicle.GreedCoinBonus;
			}

			// Announcements related to this kill
			if ( NearGoal(Other) && VictimPRI.NumCoins > 0 )
			{	
				if ( PlayerController(Killer) != None )
				{
					PlayerController(Killer).ReceiveLocalizedMessage(class'UTGreedMessage', 1, VictimPRI, None, KillerPRI.Team);
				}
			}
		}
		
		DropCoins( Other, CoinValue );
		VictimPRI.NumCoins = 0;
	}

	if( (killer != Other) && (killer != None) && (killer.PlayerReplicationInfo != None) )
	{
		Killer.PlayerReplicationInfo.Kills++;
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);
	
	KillerPawn = UTPawn(Killer.Pawn);
	if ( (KillerPawn != None) && KillerPawn.bKillsAffectHead )
	{
		KillerPawn.SetBigHead();
	}
}

/** Clears the coin count of CoinOwner, and spawns 
 *  CoinValue coins at CoinOwner's location
 */
function DropCoins(Controller CoinOwner, int CoinValue)
{
	local UTGreedPRI CoinOwnerPRI;
	local UTGreedCoin Coin;
	local vector TossVelocity, SpawnLocation;
	local int GoldCoinValue, SilverCoinValue, RedCoinValue;

	GoldCoinValue = class'UTGreedCoin_Gold'.default.Value;
	SilverCoinValue = class'UTGreedCoin_Silver'.default.Value;
	RedCoinValue = class'UTGreedCoin_Red'.default.Value;

	// Spawn at the center of the Pawn's collision
	SpawnLocation = CoinOwner.Pawn.Location;
	SpawnLocation.Z += CoinOwner.Pawn.CylinderComponent.CollisionHeight / 2.0;

	CoinOwnerPRI = UTGreedPRI(CoinOwner.PlayerReplicationInfo);
	if (CoinOwnerPRI != None)
	{
		CoinOwnerPRI.NumCoins = 0;
	}

	while (CoinValue > 0)
	{
		if (CoinValue / RedCoinValue > 0)
		{
			Coin = Spawn(class'UTGreedCoin_Red', CoinOwner.Pawn,, SpawnLocation, CoinOwner.Pawn.Rotation);
			if (Coin == None)
			{
				Coin = Spawn(class'UTGreedCoin_Red_Small', CoinOwner.Pawn,, SpawnLocation, CoinOwner.Pawn.Rotation);
			}
			CoinValue -= RedCoinValue;
		}
		else if (CoinValue / GoldCoinValue > 0)
		{	
			Coin = Spawn(class'UTGreedCoin_Gold', CoinOwner.Pawn,, SpawnLocation, CoinOwner.Pawn.Rotation);
			if (Coin == None)
			{
				Coin = Spawn(class'UTGreedCoin_Gold_Small', CoinOwner.Pawn,, SpawnLocation, CoinOwner.Pawn.Rotation);
			}
			CoinValue -= GoldCoinValue;
		}
		else
		{
			Coin = Spawn(class'UTGreedCoin_Silver', CoinOwner.Pawn,, SpawnLocation, CoinOwner.Pawn.Rotation);
			if (Coin == None)
			{
				Coin = Spawn(class'UTGreedCoin_Silver_Small', CoinOwner.Pawn,, SpawnLocation, CoinOwner.Pawn.Rotation);
			}
			CoinValue -= SilverCoinValue;
		}

		if (Coin != None)
		{
			TossVelocity = vector(CoinOwner.Pawn.GetViewRotation());
			TossVelocity = TossVelocity * ((CoinOwner.Velocity dot TossVelocity) + 500.f) + 300.f * VRand() + vect(0,0,400);

			Coin.Velocity = TossVelocity;
			Coin.SetPhysics(PHYS_Falling);
			/*
			Coin.PickupMesh.SetRBLinearVelocity(TossVelocity, false);
			Coin.PickupMesh.SetRBAngularVelocity(VRand() * 50, false);
			*/
			Coin.DroppedFrom(CoinOwner.Pawn);
		}
		else
		{
			CoinValue = 0;
		}
	}
}

function bool AllowBecomeHero(UTPlayerReplicationInfo PendingHeroPRI)
{
	if ( (UTGreedPRI(PendingHeroPRI).NumCoins > 3) && (UTBot(PendingHeroPRI.Owner) != None) )
	{
		// don't let bots become heroes if carrying lots of skulls
		return false;
	}

	return super.AllowBecomeHero(PendingHeroPRI);
}

/** Finds an objective for the player to complete and tells the player about it
 *  Returns the opposing team's flag base
 */
function Actor GetAutoObjectiveFor(UTPlayerController PC)
{
	local UTGreedPRI PRI;
	PRI = UTGreedPRI(PC.PlayerReplicationInfo);

	if ( PRI != None &&
		 UTTeamInfo(PRI.Team) != None &&
		 PRI.NumCoins > 0 )
	{
		return FlagBases[1 - PRI.Team.TeamIndex];
	}
	else
	{
		return None;
	}
}

/*
 * Increments the player and team score when coins are returned to
 * the opposing team's base.
 * Returns true if the score is incremented, false other
 */ 
function bool ScoreCoinReturn(Controller Scorer)
{
	local UTGreedPRI PRI;
	local UTPlayerController PC;
	local int ScoreBump;

	PRI = UTGreedPRI(Scorer.PlayerReplicationInfo);
	PC = UTPlayerController(Scorer);
	if (PRI != None && UTVehicle(Scorer.Pawn) == None && PRI.NumCoins > 0)
	{
		if ( (PRI.NumCoins >= HoarderMessageThreshold) && (PC != None) )
		{
			PC.ReceiveLocalizedMessage( class'UTGreedMessage', 0, PRI);
		}
		PRI.Score += PRI.NumCoins;
		PRI.Team.Score += PRI.NumCoins;
		ScoreBump = PRI.NumCoins;
		if (PRI.BestCoinReturn < PRI.NumCoins)
		{
			PRI.BestCoinReturn = PRI.NumCoins;
		}
		PRI.AddToEventStat('EVENT_SKULLSRETURNED', PRI.NumCoins);
		// Update "Skull Collector" achievement
		if (PC != None)
		{
			PC.ClientUpdateAchievement(EUTA_UT3GOLD_SkullCollector, PRI.NumCoins);
			if ( PRI.NumCoins >= 50 && GetBotSkillLevel() >= 4 )
			{
				PC.ClientUpdateAchievement(EUTA_UT3GOLD_BagOfBones, PRI.NumCoins);
			}
		}

		PRI.IncrementHeroMeter(PRI.NumCoins);
		PRI.NumCoins = 0;
		PRI.bForceNetUpdate = TRUE;
		if (!CheckScore(PRI))
		{
			if (PC != None)
				PC.ReceiveLocalizedMessage(TeamScoreMessageClass, 7, PRI);
			TeleportToBase(UTPawn(Scorer.Pawn));
		}
		AnnounceGreedScore(PRI.GetTeamNum(), ScoreBump);
		Scorer.Pawn.PlaySound(CoinReturnSound);
		return true;
	}
	return false;
}

function EndGame( PlayerReplicationInfo Winner, string Reason )
{
	local int i;
	local UTGreedPRI PRI;

	for (i = 0; i < GameReplicationInfo.PRIArray.length; ++i)
	{
		PRI = UTGreedPRI(GameReplicationInfo.PRIArray[i]);
		if (PRI != None)
		{
			PRI.AddToEventStat('EVENT_MAXSKULLRETURN', PRI.NumCoins);
		}
	}

	Super.EndGame(Winner, Reason);
}

defaultproperties
{
	PlayerReplicationInfoClass=class'UTGreedPRI'
	DefaultPawnClass=class'UTHeroPawn'

	TeamAIType(0)=class'UTGreedTeamAI'
	TeamAIType(1)=class'UTGreedTeamAI'

	OnlineGameSettingsClass=class'UTGameSettingsGreed'
	HUDType=class'UTGreedHUD'

	TeamScoreMessageClass=class'UTGameContent.UTTeamScoreMessage'

	RedFlagType = class'UT3GoldGame.UTGreedRedFlag'
	BlueFlagType = class'UT3GoldGame.UTGreedBlueFlag'

	CoinReturnSound=SoundCue'A_Gameplay_UT3G.Greed.A_Gameplay_UT3G_Greed_DeliverSkulls01_Cue'
}
