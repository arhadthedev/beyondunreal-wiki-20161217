/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTActorFactoryAI extends ActorFactoryAI
	native;

;

var() bool bForceDeathmatchAI;

/** Try and use physics hardware for this spawned object. */
var() bool bUseCompartment;

defaultproperties
{
	ControllerClass=class'UTBot'
}
