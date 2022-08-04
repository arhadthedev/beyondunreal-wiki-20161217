/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleAccelerationOverLifetime extends ParticleModuleAccelerationBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

var(Acceleration) rawdistributionvector	AccelOverLife;



defaultproperties
{
	bSpawnModule=false
	bUpdateModule=true

	Begin Object Class=DistributionVectorConstantCurve Name=DistributionAccelOverLife
	End Object
	AccelOverLife=(Distribution=DistributionAccelOverLife)
}
