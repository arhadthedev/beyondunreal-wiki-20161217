/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleColorOverLife extends ParticleModuleColorBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

var(Color)					rawdistributionvector	ColorOverLife;
var(Color)					rawdistributionfloat	AlphaOverLife;
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
