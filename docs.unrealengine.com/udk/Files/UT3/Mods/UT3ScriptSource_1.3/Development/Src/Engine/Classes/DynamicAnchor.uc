/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */


/** a dynamic anchor is a NavigationPoint temporarily added to the navigation network during gameplay, when the AI is trying
 * to get on the network but there is no directly reachable NavigationPoint available. It tries to find something else that is
 * reachable (for example, part of a ReachSpec) and places one of these there and connects it to the network. Doing it this way
 * allows us to handle these situations without any special high-level code; as far as script is concerned, the AI is moving
 * along a perfectly normal NavigationPoint connected to the network just like any other.
 * DynamicAnchors handle destroying themselves and cleaning up any connections when they are no longer in use.
 */
class DynamicAnchor extends NavigationPoint
	native;

/** current controller that's using us to navigate */
var Controller CurrentUser;



defaultproperties
{
	RemoteRole=ROLE_None
	bStatic=false
	bNoDelete=false
	bCollideWhenPlacing=false
}
