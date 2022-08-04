﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleRotationOverLifetime extends ParticleModuleRotationBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

/**
 *	The rotation to apply.
 */
var(Rotation) rawdistributionfloat	RotationOverLife;

/**
 *	If TRUE,  the particle rotation is multiplied by the value retrieved from RotationOverLife.
 *	If FALSE, the particle rotation is incremented by the value retrieved from RotationOverLife.
 */
var(Rotation)					bool				Scale;



defaultproperties
{
	bSpawnModule=false
	bUpdateModule=true

	Begin Object Class=DistributionFloatConstantCurve Name=DistributionRotOverLife
	End Object
	RotationOverLife=(Distribution=DistributionRotOverLife)
	
	// Setting to true to support existing modules...
	Scale=true
}
