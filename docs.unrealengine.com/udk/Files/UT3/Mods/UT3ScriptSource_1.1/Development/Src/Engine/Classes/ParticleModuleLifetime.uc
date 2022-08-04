/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleLifetime extends ParticleModuleLifetimeBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/** The lifetime of the particle, in seconds. Retrieved using the EmitterTime at the spawn of the particle. */
var(Lifetime) rawdistributionfloat	Lifetime;



defaultproperties
{
	bSpawnModule=true

	Begin Object Class=DistributionFloatUniform Name=DistributionLifetime
	End Object
	Lifetime=(Distribution=DistributionLifetime)
}
