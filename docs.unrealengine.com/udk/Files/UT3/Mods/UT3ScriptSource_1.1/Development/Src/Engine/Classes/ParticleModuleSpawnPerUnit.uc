/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSpawnPerUnit extends ParticleModuleSpawnBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

//=============================================================================
//	Properties
//=============================================================================
/** 
 *	The scalar to apply to the distance traveled.
 *	The value from SpawnPerUnit is divided by this value to give the actual
 *	number of particles per unit. 
 */
var(Spawn)							float						UnitScalar;
 
/** 
 *	The amount to spawn per meter distribution.
 *	The value is retrieved using the EmitterTime.
 */
var(Spawn)							rawdistributionfloat		SpawnPerUnit;

/**
 *	If TRUE, process the default spawn rate when not moving...
 *	When not moving, skip the default spawn rate.
 *	If FALSE, return the bProcessSpawnRate setting.
 */
var(Spawn)							bool						bIgnoreSpawnRateWhenMoving;

/**
 *	The tolerance for moving vs. not moving w.r.t. the bIgnoreSpawnRateWhenMoving flag.
 *	Ie, if (DistanceMoved < (UnitScalar * MovementTolerance)) then consider it not moving.
 */
var(Spawn)							float						MovementTolerance;

//=============================================================================
//	C++
//=============================================================================


//=============================================================================
//	Default properties
//=============================================================================
defaultproperties
{
	bSpawnModule=true
	bUpdateModule=false

	UnitScalar=50.0
	Begin Object Class=DistributionFloatConstant Name=RequiredDistributionSpawnPerUnit
		Constant=0.0
	End Object
	SpawnPerUnit=(Distribution=RequiredDistributionSpawnPerUnit)
	
	MovementTolerance=0.1
}
