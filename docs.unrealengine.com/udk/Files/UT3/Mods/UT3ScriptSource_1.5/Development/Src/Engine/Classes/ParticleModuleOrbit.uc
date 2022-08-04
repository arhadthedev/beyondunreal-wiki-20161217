/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleOrbit extends ParticleModuleOrbitBase
	native(Particle)
	editinlinenew
	dontcollapsecategories
	hidecategories(Object,Orbit);

/**
 *	Chaining options
 *	Orbit modules will chain together in the order they appear in the module stack.
 *	The combination of a module with the one prior to it is defined by using one
 *	of the following enumerations:
 */
enum EOrbitChainMode
{
	/** Add the module values to the previous results						*/
	EOChainMode_Add,
	/**	Multiply the module values by the previous results					*/
	EOChainMode_Scale,
	/**	'Break' the chain and apply the values from the	previous results	*/
	EOChainMode_Link
};

var(Chaining)	EOrbitChainMode		ChainMode;
 
/**
 *	OrbitOptions structure
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

/**
 *	Offset
 *	The amount to offset the sprite from the particle positon.
 */
var(Offset)			rawdistributionvector		OffsetAmount;
var(Offset)			orbitoptions				OffsetOptions;

/**
 *	Rotation
 *	The amount to rotate the offset about the particle positon.
 *	In 'Turns'
 *		0.0 = no rotation
 *		0.5	= 180 degree rotation
 *		1.0 = 360 degree rotation
 */
var(Rotation)		rawdistributionvector		RotationAmount;
var(Rotation)		orbitoptions				RotationOptions;

/**
 *	RotationRate
 *	The rate at which to rotate the offset about the particle positon.
 *	In 'Turns'
 *		0.0 = no rotation
 *		0.5	= 180 degree rotation
 *		1.0 = 360 degree rotation
 */
var(RotationRate)	rawdistributionvector		RotationRateAmount;
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
