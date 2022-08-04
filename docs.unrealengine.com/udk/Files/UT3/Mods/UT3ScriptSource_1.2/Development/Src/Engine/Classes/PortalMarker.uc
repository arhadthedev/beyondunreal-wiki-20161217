/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


/** this Actor marks PortalTeleporters on the navigation network */
class PortalMarker extends NavigationPoint
	native;

/** the portal being marked by this PortalMarker */
var PortalTeleporter MyPortal;



/** returns whether this NavigationPoint is a teleporter that can teleport the given Actor */
native function bool CanTeleport(Actor A);

defaultproperties
{
	bCollideWhenPlacing=false
	bHiddenEd=true
}
