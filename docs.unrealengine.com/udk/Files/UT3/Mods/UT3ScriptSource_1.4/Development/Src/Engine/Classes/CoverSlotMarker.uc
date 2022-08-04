/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
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

simulated function int ExtraPathCost( Controller AI )
{
	if( !OwningSlot.Link.IsValidClaim( AI, OwningSlot.SlotIdx, TRUE ) )
	{
		return class'ReachSpec'.const.BLOCKEDPATHCOST;
	}
	return 0;
}

simulated function Vector GetSlotLocation()
{
	if( OwningSlot.Link != None )
	{
		return OwningSlot.Link.GetSlotLocation(OwningSlot.SlotIdx);
	}

	return vect(0,0,0);
}

simulated function Rotator GetSlotRotation()
{
	if( OwningSlot.Link != None )
	{
		return OwningSlot.Link.GetSlotRotation(OwningSlot.SlotIdx);
	}

	return rot(0,0,0);
}

defaultproperties
{
	bCollideWhenPlacing=FALSE
	bSpecialMove=TRUE

	// Jump up cost so AI tends to pathfind through open areas
	// instead of along walls
	Cost=300

//test
	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	Components.Remove(Arrow)

	Begin Object Name=CollisionCylinder
		CollisionRadius=40.f
		CollisionHeight=40.f
	End Object
}
