/**
 *	ParticleLODLevel
 *
 *	Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleLODLevel extends Object
	native(Particle)
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** The index value of the LOD level												*/
var const				int						Level;

/** The percentage value of the slider when it was created							*/
var	const				int						LevelSetting;

/** True if the LOD level is enabled, meaning it should be updated and rendered.	*/
var						bool					bEnabled;

/** The required module for this LOD level											*/
var editinline export	ParticleModuleRequired	RequiredModule;

/** An array of particle modules that contain the adjusted data for the LOD level	*/
var editinline export	array<ParticleModule>	Modules;

// Module<SINGULAR> used for emitter type "extension".
var				export	ParticleModule			TypeDataModule;

/** SpawningModules - These are called to determine how many particles to spawn.	*/
var native				array<ParticleModuleSpawnBase>	SpawningModules;
/** SpawnModules - These are called when particles are spawned.						*/
var native				array<ParticleModule>			SpawnModules;
/** UpdateModules - These are called when particles are updated.					*/
var native				array<ParticleModule>			UpdateModules;

/** OrbitModules 
 *	These are used to do offsets of the sprite from the particle location.
 */
var native				array<ParticleModuleOrbit>		OrbitModules;

var						bool					ConvertedModules;
var						int						PeakActiveParticles;



defaultproperties
{
	bEnabled=true
	ConvertedModules=true
	PeakActiveParticles=0
}
