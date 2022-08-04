/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleMeshRotation extends ParticleModuleRotationBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

/**
 *	Initial rotation in ROTATIONS (1 = 360 degrees).
 *	The value is retrieved using the EmitterTime.
 */
var(Rotation)	rawdistributionvector	StartRotation;

/** If TRUE, apply the parents rotation as well. */
var(Rotation)	bool					bInheritParent;



defaultproperties
{
	bSpawnModule=true

	Begin Object Class=DistributionVectorUniform Name=DistributionStartRotation
		Min=(X=0.0,Y=0.0,Z=0.0)
		Max=(X=360.0,Y=360.0,Z=360.0)
	End Object
	StartRotation=(Distribution=DistributionStartRotation)
	
	bInheritParent=false
}
