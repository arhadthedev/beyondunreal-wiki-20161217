/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class LeviathanBlockingVolume extends BlockingVolume
	placeable;

defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=true
		RBChannel=RBCC_Untitled2
		RBCollideWithChannels=(Default=false)
	End Object

	bColored=true
	BrushColor=(R=32,G=200,B=128,A=255)

	bWorldGeometry=true
	bCollideActors=false
	bBlockActors=false
	bClampFluid=false
}