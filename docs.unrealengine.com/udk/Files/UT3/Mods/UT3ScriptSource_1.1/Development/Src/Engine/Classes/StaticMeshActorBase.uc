﻿/**
 * Base class for static actors which contain StaticMeshComponents.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class StaticMeshActorBase extends Actor
	native
	abstract;



DefaultProperties
{
	bEdShouldSnap=true
	bStatic=true
	bMovable=false
	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=true
	bGameRelevant=true
	bRouteBeginPlayEvenIfStatic=false
	bCollideWhenPlacing=false
}
