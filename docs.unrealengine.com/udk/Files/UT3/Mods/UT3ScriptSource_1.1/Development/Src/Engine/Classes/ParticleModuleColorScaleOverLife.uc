/**
 *	ParticleModuleColorScaleOverLife
 *
 *	The base class for all Beam modules.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class ParticleModuleColorScaleOverLife extends ParticleModuleColorBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** The scale factor for the color.													*/
var(Color)				rawdistributionvector	ColorScaleOverLife;

/** The scale factor for the alpha.													*/
var(Color)				rawdistributionfloat	AlphaScaleOverLife;

/** Whether it is EmitterTime or ParticleTime related.								*/
var(Color)				bool					bEmitterTime;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	Begin Object Class=DistributionVectorConstantCurve Name=DistributionColorScaleOverLife
	End Object
	ColorScaleOverLife=(Distribution=DistributionColorScaleOverLife)

	Begin Object Class=DistributionFloatConstant Name=DistributionAlphaScaleOverLife
		Constant=1.0f;
	End Object
	AlphaScaleOverLife=(Distribution=DistributionAlphaScaleOverLife)
}
