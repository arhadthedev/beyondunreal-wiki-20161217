/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleKillHeight extends ParticleModuleKillBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

/**
 *	The height at which to kill the particle.
 */
var(Kill)		rawdistributionfloat	Height;

/**
 *	If TRUE, the height should be treated as a world-space position.
 */
var(Kill)		bool					bAbsolute;

/**
 *	If TRUE, the plane should be considered a floor - ie kill anything BELOW it.
 *	If FALSE, if is a ceiling - ie kill anything ABOVE it.
 */
var(Kill)		bool					bFloor;



defaultproperties
{
	bUpdateModule=true

	Begin Object Class=DistributionFloatConstant Name=DistributionHeight
	End Object
	Height=(Distribution=DistributionHeight)

	bSupported3DDrawMode=true
}
