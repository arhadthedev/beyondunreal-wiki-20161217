//=============================================================================
// ParticleEmitter
// The base class for any particle emitter objects.
// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class ParticleEmitter extends Object
	native(Particle)
	dependson(ParticleLODLevel)
	collapsecategories
	hidecategories(Object)
	editinlinenew
	abstract;

//=============================================================================
//	General variables
//=============================================================================
var(Particle)							name						EmitterName;
var										bool						UseLocalSpace;
var										bool						KillOnDeactivate;
var										bool						bKillOnCompleted;

var										rawdistributionfloat		SpawnRate;
var										float						EmitterDuration;
var										int							EmitterLoops; // 0 indicates loop continuously

var(RequiredData) transient editinline	ParticleModuleRequired		RequiredModule;

//=============================================================================
//	Burst emissions
//=============================================================================
enum EParticleBurstMethod
{
	EPBM_Instant,
	EPBM_Interpolated
};

struct native ParticleBurst
{
	var()				int		Count;		// The number of particles to emit
	var()				int		CountLow;	// If > 0, use as a range [CountLow..Count]
	var()				float	Time;		// The time at which to emit them (0..1 - emitter lifetime)
};

var										EParticleBurstMethod		ParticleBurstMethod;
var						export noclear	array<ParticleBurst>		BurstList;

//=============================================================================
//	SubUV-related
//=============================================================================
enum EParticleSubUVInterpMethod
{
	PSUVIM_None,
    PSUVIM_Linear,
    PSUVIM_Linear_Blend,
    PSUVIM_Random,
    PSUVIM_Random_Blend
};

var										EParticleSubUVInterpMethod	InterpolationMethod;
var										int							SubImages_Horizontal;
var										int							SubImages_Vertical;
var										bool						ScaleUV;
var										float						RandomImageTime;
var										int							RandomImageChanges;
var										bool						DirectUV;
var	transient							int							SubUVDataOffset;

//=============================================================================
//	Cascade-related
//=============================================================================
enum EEmitterRenderMode
{
	ERM_Normal,
	ERM_Point,
	ERM_Cross,
	ERM_None
};

var									EEmitterRenderMode				EmitterRenderMode;
var									color							EmitterEditorColor;
var									bool							bEnabled;

//=============================================================================
//	'Private' data - not required by the editor
//=============================================================================
var editinline export				array<ParticleLODLevel>			LODLevels;
var editinline export				array<ParticleModule>			Modules;

// Module<SINGULAR> used for emitter type "extension".
var export							ParticleModule					TypeDataModule;
// Modules used for initialization.
var native							array<ParticleModule>			SpawnModules;
// Modules used for ticking.
var native							array<ParticleModule>			UpdateModules;
var									bool							ConvertedModules;
var									int								PeakActiveParticles;

//=============================================================================
//	Performance/LOD Data
//=============================================================================

/**
 *	Initial allocation count - overrides calculated peak count if > 0
 */
var(Particle)						int								InitialAllocationCount;

//=============================================================================
//	C++
//=============================================================================


//=============================================================================
//	Default properties
//=============================================================================
defaultproperties
{
	EmitterName="Particle Emitter"

	EmitterRenderMode=ERM_Normal

	ConvertedModules=true
	PeakActiveParticles=0

	EmitterDuration=1.0
	EmitterLoops=0

	EmitterEditorColor=(R=0,G=150,B=150)

	bEnabled=true
	
	Begin Object Class=DistributionFloatConstant Name=DistributionSpawnRate
	End Object
	SpawnRate=(Distribution=DistributionSpawnRate)

	InterpolationMethod=PSUVIM_None
	SubImages_Horizontal=1
	SubImages_Vertical=1
	RandomImageTime=1.0
	RandomImageChanges=0
	ScaleUV=true
	DirectUV=false
}
