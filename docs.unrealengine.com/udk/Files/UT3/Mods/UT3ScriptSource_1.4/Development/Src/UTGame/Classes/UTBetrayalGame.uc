/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTBetrayalGame extends UTDeathMatch;

var array<UTBetrayalTeam> Teams;

var string InstagibRifleClassNameStr;

/** Score bonus for killing Rogue that betrayed you */
var int RogueValue;

/** Class for announcement messages related to Betrayal */
var class<UTLocalMessage> AnnouncerMessageClass;

/** Sounds for Betrayal events */
var SoundCue BetrayingSound; 
var SoundCue BetrayedSound;
var SoundCue JoinTeamSound;

// FIXME no instagib/weapon replacement etc.

/* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
event InitGame( string Options, out string ErrorMessage )
{
	local class<UTWeap_InstagibRifle> InstagibRifleClass;

	Super.InitGame(Options, ErrorMessage);

	DefaultInventory.Length = 0;
	InstagibRifleClass = class<UTWeap_InstagibRifle>(DynamicLoadObject(InstagibRifleClassNameStr, class'Class'));

	if (InstagibRifleClass != None)
	{
		DefaultInventory[0] = InstagibRifleClass;
	}
}

event PreBeginPlay()
{
	super.PreBeginPlay();

	SetTimer(1.0, true, 'MaybeStartTeam');
}

// Returns whether a mutator should be allowed with this gametype
static function bool AllowMutator( string MutatorClassName )
{
	if (( MutatorClassName ~= "UTGame.UTMutator_Handicap") ||
		( MutatorClassName ~= "UTGame.UTMutator_NoPowerups") ||
		( MutatorClassName ~= "UTGame.UTMutator_NoTranslocator") ||
		( MutatorClassName ~= "UTGame.UTMutator_NoOrbs") ||
		( MutatorClassName ~= "UTGame.UTMutator_Survival") ||
		( MutatorClassName ~= "UTGame.UTMutator_Instagib") || 
		( MutatorClassName ~= "UTGame.UTMutator_WeaponReplacement") ||
		( MutatorClassName ~= "UTGame.UTMutator_WeaponsRespawn") || 
		( MutatorClassName ~= "UTGame.UTMutator_Hero") )
	{
		return false;
	}

	return Super.AllowMutator(MutatorClassName);
}

/* CheckRelevance()
returns true if actor is relevant to this game and should not be destroyed.  Called in Actor.PreBeginPlay(), intended to allow
mutators to remove or replace actors being spawned
*/
function bool CheckRelevance(Actor Other)
{
	if (Other.IsA('UTWeapon') && !Other.IsA('UTVehicleWeapon') )
	{
		if ( UTWeap_InstagibRifle(Other) != None ) 
		{
			UTWeap_InstagibRifle(Other).bBetrayalMode = true;
			return true;
		}
		return false;
	}
	else if ( Other.IsA('PickupFactory') )
	{
		return false;
	}
	return super.CheckRelevance(Other);
}

function ShotTeammate(UTBetrayalPRI InstigatorPRI, UTBetrayalPRI HitPRI, Pawn ShotInstigator, Pawn HitPawn)
{
	local UTBetrayalTeam Team;
	local UTBetrayalPRI PRI;
	local int i;

	if (WorldInfo.TimeSeconds - HitPawn.SpawnTime < SpawnProtectionTime )
	{
		return;
	}

	Team = InstigatorPRI.CurrentTeam;
	InstigatorPRI.Score += Team.TeamPot;

	//Increment pot stat
	InstigatorPRI.AddToEventStat('EVENT_POOLPOINTS', Team.TeamPot);
	if ( UTPlayerController(InstigatorPRI.Owner) != None )
	{
		UTPlayerController(InstigatorPRI.Owner).ClientUpdateAchievement(EUTA_UT3GOLD_CantBeTrusted, Team.TeamPot);
	}

	Team.TeamPot = 0;
	InstigatorPRI.SetRogueTimer();
	InstigatorPRI.BetrayalCount++;
	InstigatorPRI.BetrayedTeam = Team;
	HitPRI.Betrayer = InstigatorPRI;
	InstigatorPRI.PlaySound(BetrayingSound);

	for ( i=0; i<GameReplicationInfo.PRIArray.Length; i++ )
	{
		PRI = UTBetrayalPRI(GameReplicationInfo.PRIArray[i]);
		if ( (PRI != None) && (PlayerController(PRI.Owner) != None) )
		{
			if ( PRI.CurrentTeam == Team )
			{
				// big, with "assassin"
				PlayerController(PRI.Owner).ReceiveLocalizedMessage( AnnouncerMessageClass, 0, InstigatorPRI, HitPRI, Team); 
			}
			else
			{
				// smaller, no announcement
				PlayerController(PRI.Owner).ReceiveLocalizedMessage( AnnouncerMessageClass, 4, InstigatorPRI, HitPRI, Team); 
			}
		}
	}

	//Record a betrayal stat?

	RemoveFromTeam(InstigatorPRI);

	if ( !Team.bDeleteMe )
	{
		// give betrayer to other teammate
		for ( i=0; i<class'UTBetrayalTeam'.const.MAX_TEAMMATES; i++ )
		{
			if (Team.Teammates[i] != None)
			{
				Team.Teammates[i].Betrayer = InstigatorPRI;
				if ( PlayerController(Team.Teammates[i].Owner) != None )
				{
					PlayerController(Team.Teammates[i].Owner).ClientPlaySound(BetrayedSound);
				}
			}
		}
	}
}

function RemoveFromTeam(UTBetrayalPRI PRI)
{
	local UTBetrayalTeam Team;
	local int i, NumTeammates;

	//Drop the PRI from the team
	Team = PRI.CurrentTeam;
	NumTeammates = Team.LoseTeammate(PRI);

	if ( NumTeammates == 1 )
	{
		for (i=0; i<class'UTBetrayalTeam'.const.MAX_TEAMMATES; i++)
		{
			if (Team.Teammates[i] != None)
			{
				Team.Teammates[i].Score += Team.TeamPot;
				//Increment pot stat
				Team.Teammates[i].AddToEventStat('EVENT_POOLPOINTS', Team.TeamPot);

				//Disband the team
				NumTeammates = Team.LoseTeammate(Team.Teammates[i]);
				break;
			}
		}
	}

	//Destroy the team completely
	if ( NumTeammates == 0 )
	{
		Team.Destroy();
		RemoveTeam(Team);
	}
}

function RemoveTeam(UTBetrayalTeam Team)
{
	local int i;

	for (i=0; i<Teams.length; i++ )
	{
		//Remove the team we're looking for
		if ( Teams[i] == Team )
		{
			Teams.Remove(i,1);
			break;
		}

		//Remove any extraneous teams (empty or deleted)
		if ( (Teams[i] == None) || Teams[i].bDeleteMe )
		{
			Teams.Remove(i,1);
			i--;
		}
	}
}

function MaybeStartTeam()
{
	local int i, j, Count, TeamCount, MaxTeamSize;
	local UTBetrayalPRI PRI;
	local UTBetrayalTeam NewTeam;
	
	MaxTeamSize = (NumPlayers + NumBots > 6) ? 3 : 2;

	for ( i=0; i<GameReplicationInfo.PRIArray.Length; i++ )
	{
		PRI = UTBetrayalPRI(GameReplicationInfo.PRIArray[i]);
		if ( (PRI != None) && (PRI.CurrentTeam == None) && !PRI.bIsRogue && !PRI.bIsSpectator )
		{
			// first try to place on existing team - but not the one you've betrayed before, or one that has too big a pot
			for ( j=0; j<Teams.Length; j++ )
			{
				if ( Teams[j] != PRI.BetrayedTeam ) 
				{
					if (Teams[j].AddTeammate(PRI,MaxTeamSize))
					{
						//Successfully added to a team
						PRI.PlaySound(JoinTeamSound);
						return;
					}
				}
			}

			//Number of people not placed on a team during existing team forming
			Count++;
		}
	}

	// maybe form team from freelancers
	if ( Count > 1 )
	{
		NewTeam = Spawn(class'UTBetrayalTeam');
		Teams[Teams.Length] = NewTeam;
		if ( NewTeam != None )
		{
			for ( i=0; i<GameReplicationInfo.PRIArray.Length; i++ )
			{
				PRI = UTBetrayalPRI(GameReplicationInfo.PRIArray[i]);
				if ( (PRI != None) && (PRI.CurrentTeam == None) && !PRI.bIsRogue && !PRI.bIsSpectator )
				{
					if (NewTeam.AddTeammate(PRI, MaxTeamSize))
					{		
						//Successfully added to a team
						PRI.PlaySound(JoinTeamSound);
						if ( PlayerController(PRI.Owner) != None )
						{
							PlayerController(PRI.Owner).ReceiveLocalizedMessage( AnnouncerMessageClass, 1);
						}
						TeamCount++;
					}

					if ( TeamCount == MaxTeamSize )
					{
						break;
					}
				}
			}
		}
	}
}

State MatchOver
{
	function MaybeStartTeam()
	{
		ClearTimer('MaybeStartTeam');
	}
}

function Logout( Controller Exiting )
{
	local UTBetrayalPRI PRI;

	PRI = UTBetrayalPRI(Exiting.PlayerReplicationInfo);
	if ( (PRI != None) && (PRI.CurrentTeam != None) )
	{
		RemoveFromTeam(PRI);
	}

	Super.Logout(Exiting);
}

function ScoreKill(Controller Killer, Controller Other)
{
	local UTBetrayalPRI KillerPRI, OtherPRI;
	local UTBot B;
	local int i, BetrayalValue;

	if (Killer != None)
	{
		KillerPRI = UTBetrayalPRI(Killer.PlayerReplicationInfo);
	}
	
	if( (Killer == Other) || (Killer == None) )
	{
    	if ( (Other!=None) && (Other.PlayerReplicationInfo != None) )
		{
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.bForceNetUpdate = TRUE;
		}
	}
	else if ( KillerPRI != None )
	{
		OtherPRI = UTBetrayalPRI(Other.PlayerReplicationInfo);
		if ( OtherPRI != None )
		{
			KillerPRI.Score += OtherPRI.ScoreValueFor(KillerPRI);
			if ( OtherPRI.bIsRogue && (OtherPRI == KillerPRI.Betrayer) )
			{
				if ( PlayerController(KillerPRI.Owner) != None )
				{
					PlayerController(KillerPRI.Owner).ReceiveLocalizedMessage( AnnouncerMessageClass, 2);
				}
				if ( PlayerController(OtherPRI.Owner) != None )
				{
					PlayerController(OtherPRI.Owner).ReceiveLocalizedMessage( AnnouncerMessageClass, 3);
				}

				//Retribution stat
				KillerPRI.IncrementEventStat('EVENT_RETRIBUTIONS');
				if ( UTPlayerController(Killer) != None )
				{
					UTPlayerController(Killer).ClientUpdateAchievement(EUTA_UT3GOLD_Avenger, 1);
				}

				OtherPRI.RogueExpired();
			}
			KillerPRI.bForceNetUpdate = true;
			KillerPRI.Kills++;
			if ( KillerPRI.CurrentTeam != None )
			{
				KillerPRI.CurrentTeam.TeamPot++;
				if ( KillerPRI.CurrentTeam.TeamPot > 2 )
				{
					for ( i=0; i<class'UTBetrayalTeam'.const.MAX_TEAMMATES; i++ )
					{
						if (KillerPRI.CurrentTeam.Teammates[i] != None)
						{
							B = UTBot(KillerPRI.CurrentTeam.Teammates[i].Owner);
							if ( (B != None) && !B.bBetrayTeam )
							{
								BetrayalValue = KillerPRI.CurrentTeam.TeamPot + 0.3*UTBetrayalPRI(B.PlayerReplicationInfo).ScoreValueFor(KillerPRI);
								if ( (BetrayalValue > 1.5 + RogueValue - B.Aggressiveness + UTBetrayalPRI(B.PlayerReplicationInfo).GetTrustWorthiness() ) && (FRand() < 0.2) )
								{
									// `log(Instigator.Controller.ShotTarget.Controller.PlayerReplicationInfo.PlayerName$" betrayal value "$BetrayalValue$" vs "$(1.5 + RogueValue - B.Aggressiveness + UTBetrayalPRI(B.PlayerReplicationInfo).GetTrustWorthiness()));
									B.bBetrayTeam = true;
								}
							}
						}
					}
				}
			}
		}
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

    if ( (Killer != None) || (MaxLives > 0) )
	{
		CheckScore(Killer.PlayerReplicationInfo);
	}
}

defaultproperties
{
	Acronym="BET"
	InstagibRifleClassNameStr="UTGame.UTWeap_InstagibRifle"
	PlayerReplicationInfoClass=class'UTGame.UTBetrayalPRI'
	GameReplicationInfoClass=class'UTGame.UTBetrayalGRI'
	DefaultPawnClass=class'UTBetrayalPawn'
	bTempForceRespawn=true
	HUDType=class'UTBetrayalHUD'
	RogueValue=6

	// Class used to write stats to the leaderboard
	OnlineStatsWriteClass=class'UTGame.UTLeaderboardWriteBetrayal'

	OnlineGameSettingsClass=class'UTGameSettingsBetrayal'

	AnnouncerMessageClass=class'UTGame.UTBetrayalMessage'

	BetrayingSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_EnemyFlagReturn01Cue'
	BetrayedSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_EnemyFlagGrab01Cue'
	JoinTeamSound=SoundCue'A_Gameplay.CTF.Cue.A_Gameplay_CTF_TeamFlagReturn01Cue'
}
