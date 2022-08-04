/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTBetrayalPRI extends UTPlayerReplicationInfo
	native;

/** Remaining rogue time */
var int RemainingRogueTime;

/** Rogue time penalty **/
var int RogueTimePenalty;

/** A rogue is someone who committed a betrayal less than 60 seconds ago, and has suffered retribution yet.
  * A rogue is a target for his betrayal victim(s), and cannot rejoin a team.
  */
var bool bIsRogue;

/** Current alliance */
var UTBetrayalTeam CurrentTeam;

/** Last player to betray you */
var UTBetrayalPRI Betrayer;

/** FIXME show the number of times this player has been a betrayer on the scoreboard */
var int BetrayalCount;

var UTBetrayalTeam BetrayedTeam;

/** How likely bot associated with this PRI is to betray teammates */
var float TrustWorthiness;

var bool bHasSetTrust;

replication
{
	if ( bNetDirty )
		CurrentTeam, Betrayer, BetrayalCount, bIsRogue, RemainingRogueTime;
}

function Reset()
{
	Super.Reset();
	RemainingRogueTime = 0;
	bIsRogue = false;
	CurrentTeam = None;
	Betrayer = None;
	BetrayalCount = 0;
	BetrayedTeam = None;
}

function SetRogueTimer()
{
	RemainingRogueTime = RogueTimePenalty;
	bForceNetUpdate = true;
	bIsRogue = true;
	SetTimer(1.0, true, 'RogueTimer');
}

function RogueTimer()
{
	RemainingRogueTime--;
	if ( RemainingRogueTime < 0 )
	{
		RogueExpired();
		if ( PlayerController(Owner) != None )
			PlayerController(Owner).ReceiveLocalizedMessage( UTBetrayalGame(WorldInfo.Game).AnnouncerMessageClass, 5);
	}
	else if ( RemainingRogueTime < 3 && PlayerController(Owner) != None )
	{
		PlayerController(Owner).ClientPlaySound(SoundCue'A_Interface.Menu.UT3ServerSignOutCue');
	}
}

function RogueExpired()
{
	local UTBetrayalPRI PRI;
	local int i;
	
	RemainingRogueTime = -100.0;
	bIsRogue = false;
	bForceNetUpdate = true;
	ClearTimer('RogueTimer');
	
	for ( i=0; i<WorldInfo.GRI.PRIArray.Length; i++ )
	{
		PRI = UTBetrayalPRI(WorldInfo.GRI.PRIArray[i]);
		if ( (PRI != None) && (PRI.Betrayer == self) )
		{
			PRI.Betrayer = None;
		}
	}
}

simulated function int ScoreValueFor(UTBetrayalPRI OtherPRI)
{
	local int ScoreValue;

	ScoreValue = 1 + Clamp((Score - OtherPRI.Score)/4, 0, 9);
	if ( bIsRogue && (OtherPRI.Betrayer == self) )
	{
		ScoreValue += class'UTBetrayalGame'.default.RogueValue;
	}
	return ScoreValue;
}

function float GetTrustWorthiness()
{
	local class<UTFamilyInfo> FamilyInfoClass;

	if ( !bHasSetTrust && CharacterData.FamilyID != "" && CharacterData.FamilyID != "NONE" )
	{
		// We have decent family, look in info class
		FamilyInfoClass = class'UTCustomChar_Data'.static.FindFamilyInfo(CharacterData.FamilyID);
		if (FamilyInfoClass != None)
		{
			bHasSetTrust = true;
			TrustWorthiness = FamilyInfoClass.Default.Trustworthiness;
		}
	}

	return TrustWorthiness;
}

defaultproperties
{
	RemainingRogueTime=-1000
	RogueTimePenalty=30
}
