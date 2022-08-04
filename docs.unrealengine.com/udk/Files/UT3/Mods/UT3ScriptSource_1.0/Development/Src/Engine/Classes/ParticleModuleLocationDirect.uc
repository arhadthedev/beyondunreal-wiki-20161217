/**
 *	ParticleModuleLocationDirect
 *
 *	Sets the location of particles directly.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class ParticleModuleLocationDirect extends ParticleModuleLocationBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

/** */
var(Location) rawdistributionvector	Location;
var(Location) rawdistributionvector	LocationOffset;
var(Location) rawdistributionvector	ScaleFactor;
var(Location) rawdistributionvector	Direction;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	Begin Object Class=DistributionVectorUniform Name=DistributionLocation
	End Object
	Location=(Distribution=DistributionLocation)

	Begin Object Class=DistributionVectorConstant Name=DistributionLocationOffset
		Constant=(X=0,Y=0,Z=0)
	End Object
	LocationOffset=(Distribution=DistributionLocationOffset)

	Begin Object Class=DistributionVectorConstant Name=DistributionScaleFactor
		Constant=(X=1,Y=1,Z=1)
	End Object
	ScaleFactor=(Distribution=DistributionScaleFactor)

	Begin Object Class=DistributionVectorUniform Name=DistributionDirection
	End Object
	Direction=(Distribution=DistributionDirection)
}
