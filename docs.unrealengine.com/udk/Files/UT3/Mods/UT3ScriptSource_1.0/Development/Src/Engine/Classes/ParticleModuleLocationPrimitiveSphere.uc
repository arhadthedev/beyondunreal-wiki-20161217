//=============================================================================
// ParticleModuleLocationPrimitiveSphere
// Location primitive spawning within a Sphere.
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class ParticleModuleLocationPrimitiveSphere extends ParticleModuleLocationPrimitiveBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

var(Location) rawdistributionfloat	StartRadius;



defaultproperties
{
	Begin Object Class=DistributionFloatConstant Name=DistributionStartRadius
		Constant=50.0
	End Object
	StartRadius=(Distribution=DistributionStartRadius)

	bSupported3DDrawMode=true
}
