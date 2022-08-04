/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedGame extends UTTeamGame abstract;

/** Flag bases at which to UTGreedFlags are spawned */
var UTCTFBase FlagBases[2];
/** Number of skulls needed for a "Hoarder" message */
var int HoarderMessageThreshold;

var class<UTCTFFlag> BlueFlagType;
var class<UTCTFFlag> RedFlagType;

var SoundCue CoinReturnSound;

simulated function PostBeginPlay()
{
	local UTCTFBase CTFBase;
	local UTVehicleFactory VF;

	Super.PostBeginPlay();
	ForEach WorldInfo.AllNavigationPoints(class'UTCTFBase', CTFBase)
	{
		if (CTFBase.DefenderTeamIndex < 2)
		{
			if (CTFBase.DefenderTeamIndex == 0)
			{
				CTFBase.FlagType = RedFlagType; 
			}
			else
			{
				CTFBase.FlagType = BlueFlagType;
			}

			FlagBases[CTFBase.DefenderTeamIndex] = CTFBase;
			CTFBase.myflag = Spawn(CTFBase.FlagType, CTFBase);
			CTFBase.myFlag.HomeBase = CTFBase;
			CTFBase.myFlag.Team = Teams[CTFBase.DefenderTeamIndex];
		}
	}

	// If we find any vehicle factories, allow the hoverboard
	ForEach WorldInfo.AllNavigationPoints(class'UTVehicleFactory', VF)
	{
		bAllowHoverboard = true;
		bStartWithLockerWeaps = true;
		break;
	}
}

// Returns whether a mutator should be allowed with this gametype
static function bool AllowMutator( string MutatorClassName )
{
	if (( MutatorClassName ~= "UTGame.UTMutator_NoTranslocator") ||
		( MutatorClassName ~= "UTGame.UTMutator_NoOrbs") ||
		( MutatorClassName ~= "UTGame.UTMutator_Survival") ||
		( MutatorClassName ~= "UTGame.UTMutator_LowGrav"))
	{
		return false;
	}

	return Super.AllowMutator(MutatorClassName);
}

function AddMutator(string mutname, optional bool bUserAdded)
{
	local UTVehicleFactory VF;

	// don't allow instagib or low grav with vehicles
	if ( (mutname ~= "UTGame.UTMutator_Instagib") || (mutname ~= "UTGame.UTMutator_LowGrav") )
	{
		ForEach AllActors(class'UTVehicleFactory', VF)
		{
			return;
		}
	}
	super.AddMutator(mutname, bUserAdded);
}

/** Announce a greed score - requires different rules since can increment by more than one point at a time 
  */
function AnnounceGreedScore(int ScoringTeam, int ScoreBump)
{
	local UTPlayerController PC;
	local int OtherTeam, MessageIndex;

	if ( TeamScoreMessageClass == None )
	{
		return;
	}

	OtherTeam = 1 - ScoringTeam;
	
	if ( Teams[ScoringTeam].Score - ScoreBump <= Teams[OtherTeam].Score )
	{
		// scoring team was behind or tied
		if ( Teams[ScoringTeam].Score > Teams[OtherTeam].Score )
		{
			// takes the lead
			MessageIndex = 4 + ScoringTeam;
		}
		else
		{
			MessageIndex = ScoringTeam;
		}
	}
	else
	{
		// scoring team was already leading
		MessageIndex = ScoringTeam;
	}

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		PC.ReceiveLocalizedMessage(TeamScoreMessageClass, MessageIndex);
	}
}

/** Clears the coin count of CoinOwner, and spawns 
*  CoinValue coins at CoinOwner's location
*/
function DropCoins(Controller CoinOwner, int CoinValue);

/*
* Increments the player and team score when coins are returned to
* the opposing team's base.
* Returns true if the score is incremented, false other
*/ 
function bool ScoreCoinReturn(Controller Scorer);

function bool NearGoal(Controller C)
{
	local UTGameObjective B;

	B = FlagBases[1 - C.PlayerReplicationInfo.Team.TeamIndex];
	return ( VSize(C.Pawn.Location - B.Location) < 1000 );
}

/** Teleports a pawn to a spawn location at it's team base */
function TeleportToBase(UTPawn Traveler)
{
	local NavigationPoint BestStart;
	local vector PrevPosition;
	local rotator NewRotation;

	BestStart = ChoosePlayerStart(Traveler.Controller);

	if (BestStart != None)
	{
		PrevPosition = Traveler.Location;
		Traveler.SetLocation(BestStart.Location);
		Traveler.DoTranslocate(PrevPosition);
		NewRotation = BestStart.Rotation;
		NewRotation.Roll = 0;
		Traveler.Controller.ClientSetRotation(NewRotation);
	}
}

defaultproperties
{
	bAllowTranslocator=false
	bUndrivenVehicleDamage=true
	bSpawnInTeamArea=true
	bScoreTeamKills=False
	bShouldPostRenderEnemyPawns=true

	bScoreDeaths=false
	MapPrefixes[0]="CTF"
	MapPrefixes[1]="VCTF"
 	DeathMessageClass=class'UTTeamDeathMessage'

	// Class used to write stats to the leaderboard
	OnlineStatsWriteClass=class'UTGame.UTLeaderboardWriteGreed'

	HoarderMessageThreshold=20
	OnlineGameSettingsClass=class'UTGameSettingsGreed'
}
