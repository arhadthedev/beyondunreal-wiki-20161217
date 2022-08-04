/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTHeroPRI extends UTPlayerReplicationInfo;

var float HeroMeter;
var bool bIsHero, bIsSuperHero;
/** true if associated player can become hero */
var bool bCanBeHero;
/** Tracks number of kills for each hero weapon during a single hero transformation */
var int HeroWeaponKills[2];

replication
{
	if ( bNetOwner && ROLE==ROLE_Authority )
		HeroMeter, bCanBeHero;
	if ( ROLE==ROLE_Authority )
		bIsHero, bIsSuperHero;
}

reliable client function SetHeroAllowed(bool bAllowed)
{
	UTGameReplicationInfo(WorldInfo.GRI).bHeroesAllowed = bAllowed;
}

function Reset()
{
	Super.Reset();
	HeroMeter = 0;
	bIsHero = false;
	bIsSuperHero = false;
}

simulated function bool IsHero()
{
	return bIsHero;
}

simulated function bool IsSuperHero()
{
	return bIsSuperHero;
}

simulated function bool CanBeHero()
{
	return bCanBeHero;
}

simulated function float GetHeroMeter()
{
	return HeroMeter;
}

simulated function ResetHero()
{
	local int i;

	bIsHero = false;
	bIsSuperHero = false;
	HeroMeter = 0;
	for ( i = 0; i < 2; ++i )
	{
		HeroWeaponKills[i] = 0;
	}
}

function int IncrementKillStat(name NewStatName)
{
	local int i;
	local bool bGiveAchievement;
	local UTPlayerController PC;

	PC = UTPlayerController(Owner);
	if ( IsHero() && PC != None )
	{
		if ( NewStatName == 'KILLS_HEROSHOCKCOMBO' || NewStatName == 'KILLS_HEROSHOCKRIFLE' )
		{
			++HeroWeaponKills[0];
		}
		else if ( NewStatName == 'KILLS_HEROROCKETLAUNCHER' )
		{
			++HeroWeaponKills[1];
		}
		

		bGiveAchievement = true;
		for ( i = 0; i < 2; ++i )
		{
			if ( HeroWeaponKills[i] < 10 )
			{
				bGiveAchievement = false;
				break;
			}
		}
		if ( bGiveAchievement )
		{
			PC.ClientUpdateAchievement(EUTA_UT3GOLD_Unholy, 1);
		}
	}
	return Super.IncrementKillStat(NewStatName);
}

function IncrementHeroMeter(float AddedValue, optional class<UTDamageType> DamageType)
{
	local float Multiplier;

	if ( DamageType == None )
	{
		Multiplier = 1.0;
	}
	else
	{
		Multiplier = DamageType.default.HeroPointsMultiplier;
	}


	if ( UTGameReplicationInfo(WorldInfo.GRI).bHeroesAllowed && !bIsSuperHero )
	{
		// No hero points for current heroes
		HeroMeter += AddedValue * Multiplier;
		CheckHeroMeter();
	}
}

function CheckHeroMeter()
{
	local UTHeroPawn PlayerPawn;

	if ( HeroMeter > HeroThreshold )
	{
		bCanBeHero = UTGame(WorldInfo.Game).AllowBecomeHero(self);
		SetTimer(0.25, false, 'CheckHeroMeter');

		PlayerPawn = UTHeroPawn(Controller(Owner).Pawn);
		if ( PlayerPawn != None )
		{
			if ( !PlayerPawn.bHeroPending  && !PlayerPawn.IsHero() )
				PlayerPawn.SetHeroPending((Team != None) ? Team.TeamIndex : 0);
			if ( UTBot(Owner) != None )
			{
				PlayerPawn.SetTimer(0.1, false, 'DelayedTriggerHero');
			}
		}
	}
}
 
function bool TriggerHero()
{
	local UTPawn PlayerPawn;
	local bool bBecameHero;

	if ( HeroMeter > HeroThreshold )
	{
		if ( UTGame(WorldInfo.Game).AllowBecomeHero(self) )
		{
			PlayerPawn = UTPawn(Controller(Owner).Pawn);
			if ( PlayerPawn != None )
			{
				bBecameHero = PlayerPawn.BecomeHero();
			}
			if ( bBecameHero )
			{
				if ( bIsHero )
				{
					bIsSuperHero = true;
				}
				bHasBeenHero = true;
				bIsHero = true;
				HeroMeter = 0;
				bNetDirty = true;

				PlayerPawn.DropFlag();
				UTGame(WorldInfo.Game).ProvideHeroBonus();
				return true;
			}
		}
		else if ( PlayerController(Owner) != None )
		{
			PlayerController(Owner).ReceiveLocalizedMessage(class'UTHeroMessage',0);
			return false;
		}
	}
	return false;
}


defaultproperties
{
}
