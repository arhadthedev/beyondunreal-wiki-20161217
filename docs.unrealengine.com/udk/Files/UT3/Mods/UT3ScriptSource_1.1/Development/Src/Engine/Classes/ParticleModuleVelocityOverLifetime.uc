/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleVelocityOverLifetime extends ParticleModuleVelocityBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	The scaling  value applied to the velocity.
 *	Value is retrieved using the RelativeTime of the particle.
 */
var(Velocity) rawdistributionvector	VelOverLife;
/**
 *	If true, the velocity will be SET to the value from the above dist.
 *	If false, the velocity will be modified by the above dist.
 */
var(Velocity) export			bool			Absolute;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	Begin Object Class=DistributionVectorConstantCurve Name=DistributionVelOverLife
	End Object
	VelOverLife=(Distribution=DistributionVelOverLife)

	Absolute=false
}
