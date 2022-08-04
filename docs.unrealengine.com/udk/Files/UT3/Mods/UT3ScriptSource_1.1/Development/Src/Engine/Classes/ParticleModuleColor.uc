/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleColor extends ParticleModuleColorBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** Initial color for a particle as a function of Emitter time. */
var(Color) rawdistributionvector	StartColor;
/** Initial alpha for a particle as a function of Emitter time. */
var(Color) rawdistributionfloat		StartAlpha;
/** If TRUE, the alpha value will be clamped to the [0..1] range. */
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
