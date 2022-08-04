/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedFlag extends UTCTFFlag;

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local Controller C;

	Super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if ( Pawn(Other) != None )
	{
		C = Pawn(Other).Controller;
		if ( C != None && !WorldInfo.GRI.OnSameTeam(self, C) )
		{
			OpposingTeamTouch(C);
		}
	}
}

function bool ValidHolder(Actor Other)
{
	// Flags in the Greed gametype should only act as a base, and cannot be carried
	return false;
}

function SameTeamTouch(Controller C)
{
}

function OpposingTeamTouch(Controller C)
{
	UTGreedGame(WorldInfo.Game).ScoreCoinReturn(C);
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0080.000000
		CollisionHeight=+0085.000000
		CollideActors=true
	End Object
}
