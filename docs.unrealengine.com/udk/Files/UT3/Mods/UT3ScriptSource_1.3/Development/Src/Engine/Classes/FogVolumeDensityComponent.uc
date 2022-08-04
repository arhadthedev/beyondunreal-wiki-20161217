/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class FogVolumeDensityComponent extends ActorComponent
	native(FogVolume)
	collapsecategories
	hidecategories(Object)
	abstract
	editinlinenew;

/** True if the fog is enabled. */
var()	const	bool			bEnabled;

/** Color used to approximate fog material color on transparency. */
var()	const	interp	LinearColor	ApproxFogLightColor;

/** Array of actors that will define the shape of the fog volume. */
var()	const	array<Actor>	FogVolumeActors;



/**
 * Changes the enabled state of the height fog component.
 * @param bSetEnabled - The new value for bEnabled.
 */
final native function SetEnabled(bool bSetEnabled);

defaultproperties
{
	bEnabled=TRUE
	ApproxFogLightColor=(R=0.5,G=0.5,B=0.7,A=1.0)
}
