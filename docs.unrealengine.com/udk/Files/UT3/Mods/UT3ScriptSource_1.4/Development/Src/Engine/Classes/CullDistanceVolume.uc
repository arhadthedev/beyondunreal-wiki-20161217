/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class CullDistanceVolume extends Volume
	native
	hidecategories(Advanced,Attachment,Collision,Volume)
	placeable;

/**
 * Helper structure containing size and cull distance pair.
 */
struct native CullDistanceSizePair
{
	/** Size to associate with cull distance. */
	var() float Size;
	/** Cull distance associated with size. */
	var() float CullDistance;
};

/**
 * Array of size and cull distance pairs. The code will calculate the sphere diameter of a primitive's BB and look for a best
 * fit in this array to determine which cull distance to use.
 */
var() array<CullDistanceSizePair> CullDistances;

/**
 * Whether the volume is currently enabled or not.
 */
var() bool bEnabled;



defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
	End Object

	CullDistances(0)=(Size=0,CullDistance=0)
	CullDistances(1)=(Size=10000,CullDistance=0)
	bEnabled=TRUE

	bCollideActors=False
	bBlockActors=False
	bProjTarget=False
	SupportedEvents.Empty
}
