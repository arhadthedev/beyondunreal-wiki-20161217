/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSpawnBase extends ParticleModule
	native(Particle)
	editinlinenew
	hidecategories(Object)
	abstract;

/** 
 *	If TRUE, the SpawnRate of the RequiredModule of the emitter will be processed.
 *	If mutliple Spawn modules are 'stacked' in an emitter, if ANY of them 
 *	have this set to FALSE, it will not process the RequireModule SpawnRate.
 */
var(Spawn)	bool				bProcessSpawnRate;



defaultproperties
{
	bProcessSpawnRate=true
}
