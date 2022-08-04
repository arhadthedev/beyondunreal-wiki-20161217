/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleColorOverLife extends ParticleModuleColorBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** The color to apply to the particle, as a function of the particle RelativeTime. */
var(Color)					rawdistributionvector	ColorOverLife;
/** The alpha to apply to the particle, as a function of the particle RelativeTime. */
var(Color)					rawdistributionfloat	AlphaOverLife;
/** If TRUE, the alpha value will be clamped to the [0..1] range. */
var(Color)					bool					bClampAlpha;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true
	bCurvesAsColor=true
	bClampAlpha=true

	Begin Object Class=DistributionVectorConstantCurve Name=DistributionColorOverLife
	End Object
	ColorOverLife=(Distribution=DistributionColorOverLife)

	Begin Object Class=DistributionFloatConstant Name=DistributionAlphaOverLife
		Constant=1.0f;
	End Object
	AlphaOverLife=(Distribution=DistributionAlphaOverLife)
}
