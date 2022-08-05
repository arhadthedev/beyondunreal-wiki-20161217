﻿//=============================================================================
// ParticleModuleLocationEmitter
//
// A location module that uses particles from another emitters particles as
// spawn points for its particles.
//
// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class ParticleModuleLocationEmitter extends ParticleModuleLocationBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

//=============================================================================
// Variables
//=============================================================================
// LocationEmitter

// The source emitter for spawn locations
var(Location)						export		noclear	name					EmitterName;

// The method to use when selecting a spawn target particle from the emitter
enum ELocationEmitterSelectionMethod
{
	ELESM_Random,
	ELESM_Sequential
};
var(Location)	ELocationEmitterSelectionMethod									SelectionMethod;

var(Location)	bool															InheritSourceVelocity;
var(Location)	float															InheritSourceVelocityScale;
var(Location)	bool															bInheritSourceRotation;
var(Location)	float															InheritSourceRotationScale;

//=============================================================================
// C++ functions
//=============================================================================


//=============================================================================
// Script functions
//=============================================================================

//=============================================================================
// Default properties
//=============================================================================
defaultproperties
{
	bSpawnModule=true

	SelectionMethod=ELESM_Random
	EmitterName=None
	InheritSourceVelocity=false
	InheritSourceVelocityScale=1.0
	bInheritSourceRotation=false
	InheritSourceRotationScale=1.0
}
