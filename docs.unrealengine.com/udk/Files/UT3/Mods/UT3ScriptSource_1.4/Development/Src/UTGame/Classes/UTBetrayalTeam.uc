/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTBetrayalTeam extends ReplicationInfo;

const MAX_TEAMMATES = 3;
var UTBetrayalPRI Teammates[MAX_TEAMMATES];

//Value of the shared pot
var int TeamPot;

replication
{
	if ( bNetDirty )
			TeamPot, Teammates;
}

function bool AddTeammate(UTBetrayalPRI NewTeammate, int MaxTeamSize)
{
	local int i, NumTeammates;

	if ( TeamPot > UTBetrayalGame(WorldInfo.Game).RogueValue/2 )
	{
		// don't add to teams that already have significant pots
		return false;
	}

	//Count current team size
	for (i=0; i<MAX_TEAMMATES; i++ )
	{
		if ( Teammates[i] != None )
		{
			NumTeammates++;
		}
	}

	MaxTeamSize = Min(MaxTeamSize, MAX_TEAMMATES);
	if ( NumTeammates >= MaxTeamSize )
	{
		return false;
	}

	for (i=0; i<MAX_TEAMMATES; i++ )
	{
		if ( Teammates[i] == NewTeammate )
		{
			// already added
			return true;
		}

		if ( Teammates[i] == None || Teammates[i].bDeleteMe )
		{
			NewTeammate.CurrentTeam = self;
			Teammates[i] = NewTeammate;
			return true;
		}
	}

	return false;
}

function int LoseTeammate(UTBetrayalPRI OldTeammate)
{
	local int i, NumTeammates;

	OldTeammate.CurrentTeam = None;

	if ( UTBot(OldTeammate.Owner) != None )
	{
		UTBot(OldTeammate.Owner).bBetrayTeam = false;
	}

	bForceNetUpdate = true;
	for (i=0; i<MAX_TEAMMATES; i++ )
	{
		if ( Teammates[i] == None || Teammates[i] == OldTeammate || Teammates[i].bDeleteMe)
		{
			Teammates[i] = None;
		}
		else
		{
			NumTeammates++;
		}
	}

	//Returns number of teammates left after removing a player
	return NumTeammates;
}

defaultproperties
{
	NetUpdateFrequency=2
}
