/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class CoverSlotMarker extends NavigationPoint
	native;



var() editconst CoverInfo OwningSlot;

event PostBeginPlay()
{
	super.PostBeginPlay();

	if (OwningSlot.Link != None)
	{
		bBlocked = OwningSlot.Link.bBlocked;
	}
}

simulated native function Vector  GetSlotLocation();
simulated native function Rotator GetSlotRotation();

/** Returns true if the specified controller is able to claim this slot. */
final native function bool IsValidClaim( Controller ChkClaim, optional bool bSkipTeamCheck, optional bool bSkipOverlapCheck );

defaultproperties
{
	bCollideWhenPlacing=FALSE
	bSpecialMove=TRUE

	// Jump up cost so AI tends to pathfind through open areas
	// instead of along walls
	Cost=300

	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	Components.Remove(Arrow)

	Begin Object Name=CollisionCylinder
		CollisionRadius=40.f
		CollisionHeight=40.f
	End Object

	Abbrev="CSM"
}
