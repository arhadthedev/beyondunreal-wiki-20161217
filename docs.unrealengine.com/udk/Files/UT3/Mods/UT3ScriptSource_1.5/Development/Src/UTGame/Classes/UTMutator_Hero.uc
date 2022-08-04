// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
class UTMutator_Hero extends UTMutator;

function InitMutator(string Options, out string ErrorMessage)
{
	local UTGame Game;
	local class<UTPawn> HeroPawnClass;
	local class<UTPlayerReplicationInfo> HeroPRIClass;

	Game = UTGame(WorldInfo.Game);
	if ( Game != None )
	{
		HeroPawnClass = class'UTHeroPawn';
		if (!ClassIsChildOf(Game.DefaultPawnClass, HeroPawnClass))
		{
			Game.DefaultPawnClass = HeroPawnClass;
		}

		HeroPRIClass = class'UTHeroPRI';
		if (!ClassIsChildOf(Game.PlayerReplicationInfoClass, HeroPRIClass))
		{
			if ( Game.PlayerReplicationInfoClass == class'UTOnslaughtPRI' )
			{
				Game.PlayerReplicationInfoClass = class'UTOnslaughtHeroPRI';
			}
			else
			{
				Game.PlayerReplicationInfoClass = HeroPRIClass;
			}
		}
	}

	Super.InitMutator(Options, ErrorMessage);
}


function ModifyPlayer(Pawn Other)
{
	local UTHeroPRI PRI;
	local UTOnslaughtHeroPRI OnslaughtPRI;
	local UTGameReplicationInfo UTGRI;

	UTGRI = UTGameReplicationInfo(WorldInfo.GRI);
	if ( UTGRI != None )
	{
		UTGRI.bHeroesAllowed = true;
	}

	PRI = UTHeroPRI(Other.PlayerReplicationInfo);
	if ( PRI != None )
	{
		PRI.SetHeroAllowed(true);
	}
	else
	{
		OnslaughtPRI = UTOnslaughtHeroPRI(Other.PlayerReplicationInfo);
		if ( OnslaughtPRI != None )
		{
			OnslaughtPRI.SetHeroAllowed(true);
		}
	}

	Super.ModifyPlayer(Other);
}

defaultproperties
{
	GroupNames[0]="WEAPONMOD"
}
