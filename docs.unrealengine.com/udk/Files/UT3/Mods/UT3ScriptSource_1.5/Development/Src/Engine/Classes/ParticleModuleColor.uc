/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleColor extends ParticleModuleColorBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

/** Initial color for a particle as a function of Emitter time. Range is 0-255 for X/Y/Z, corresponding to R/G/B. */
var(Color) rawdistributionvector	StartColor;
var(Color) rawdistributionfloat		StartAlpha;
var(Color) bool						bClampAlpha;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=false
	bCurvesAsColor=true
	bClampAlpha=true

	Begin Object Class=DistributionVectorConstant Name=DistributionStartColor
	End Object
	StartColor=(Distribution=DistributionStartColor)

	Begin Object Class=DistributionFloatConstant Name=DistributionStartAlpha
		Constant=1.0f;
	End Object
	StartAlpha=(Distribution=DistributionStartAlpha)
}
