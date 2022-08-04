/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleVelocityOverLifetime extends ParticleModuleVelocityBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

var(Velocity) rawdistributionvector	VelOverLife;
// If Absolute is true, the velocity will be SET to the value from the above dist.
// If Absolute is false, the velocity will be modified by the above dist.
var(Acceleration) export			bool			Absolute;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	Begin Object Class=DistributionVectorConstantCurve Name=DistributionVelOverLife
	End Object
	VelOverLife=(Distribution=DistributionVelOverLife)

	Absolute=false
}
