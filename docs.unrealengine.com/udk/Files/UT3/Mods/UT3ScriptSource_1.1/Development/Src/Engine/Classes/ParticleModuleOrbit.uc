/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleOrbit extends ParticleModuleOrbitBase
	native(Particle)
	editinlinenew
	hidecategories(Object,Orbit);

enum EOrbitChainMode
{
	/** Add the module values to the previous results						*/
	EOChainMode_Add,
	/**	Multiply the module values by the previous results					*/
	EOChainMode_Scale,
	/**	'Break' the chain and apply the values from the	previous results	*/
	EOChainMode_Link
};

/**
 *	Orbit modules will chain together in the order they appear in the module stack.
 *	The combination of a module with the one prior to it is defined by using one
 *	of the following enumerations:
 *		EOChainMode_Add		Add the values to the previous results
 *		EOChainMode_Scale	Multiply the values by the previous results
 *		EOChainMode_Link	'Break' the chain and apply the values from the	previous results
 */
var(Chaining)	EOrbitChainMode		ChainMode;
 
/**
 *	Container struct for holding options on the data updating for the module.
 */
struct native OrbitOptions
{
	/**
	 *	Whether to process the data during spawning.
	 */
	var()	bool	bProcessDuringSpawn;
	/**
	 *	Whether to process the data during updating.
	 */
	var()	bool	bProcessDuringUpdate;
	/**
	 *	Whether to use emitter time during data retrieval.
	 */
	var()	bool	bUseEmitterTime;
	
	structdefaultproperties
	{
		bProcessDuringSpawn=true
	}
};

/** The amount to offset the sprite from the particle position. */
var(Offset)			rawdistributionvector		OffsetAmount;
/** The options associated with the OffsetAmount look-up. */
var(Offset)			orbitoptions				OffsetOptions;

/**
 *	The amount (in 'turns') to rotate the offset about the particle position.
 *		0.0 = no rotation
 *		0.5	= 180 degree rotation
 *		1.0 = 360 degree rotation
 */
var(Rotation)		rawdistributionvector		RotationAmount;
/** The options associated with the RotationAmount look-up. */
var(Rotation)		orbitoptions				RotationOptions;

/**
 *	The rate (in 'turns') at which to rotate the offset about the particle positon.
 *		0.0 = no rotation
 *		0.5	= 180 degree rotation
 *		1.0 = 360 degree rotation
 */
var(RotationRate)	rawdistributionvector		RotationRateAmount;
/** The options associated with the RotationRateAmount look-up. */
var(RotationRate)	orbitoptions				RotationRateOptions;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true

	ChainMode=EOChainMode_Link
	
	Begin Object Class=DistributionVectorUniform Name=DistributionOffsetAmount
		Min=(X=0,Y=0,Z=0)
		Max=(X=0,Y=50,Z=0)
	End Object
	OffsetAmount=(Distribution=DistributionOffsetAmount)

	Begin Object Class=DistributionVectorUniform Name=DistributionRotationAmount
		Min=(X=0,Y=0,Z=0)
		Max=(X=1,Y=1,Z=1)
	End Object
	RotationAmount=(Distribution=DistributionRotationAmount)

	Begin Object Class=DistributionVectorUniform Name=DistributionRotationRateAmount
		Min=(X=0,Y=0,Z=0)
		Max=(X=1,Y=1,Z=1)
	End Object
	RotationRateAmount=(Distribution=DistributionRotationRateAmount)
}
