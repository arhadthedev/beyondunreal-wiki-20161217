/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Used to associate lights with volumes.
 */
class LightVolume extends Volume
	native
	placeable;



defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
	End Object

	bCollideActors=False
	bBlockActors=False
	bProjTarget=False
	SupportedEvents.Empty
}
