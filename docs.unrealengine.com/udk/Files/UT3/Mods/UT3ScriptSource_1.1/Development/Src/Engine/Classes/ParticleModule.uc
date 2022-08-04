/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModule extends Object
	native(Particle)
	editinlinenew
	hidecategories(Object)
	abstract;

struct native transient ParticleCurvePair
{
	var		string	CurveName;
	var		object	CurveObject;
};

/** If TRUE, the module performs operations on particles during Spawning		*/
var				bool			bSpawnModule;
/** If TRUE, the module performs operations on particles during Updating		*/
var				bool			bUpdateModule;
/** If TRUE, the module displays vector curves as colors						*/
var				bool			bCurvesAsColor;
/** If TRUE, the module should render its 3D visualization helper				*/
var(Cascade)	bool			b3DDrawMode;
/** If TRUE, the module supports rendering a 3D visualization helper			*/
var				bool			bSupported3DDrawMode;
/** If TRUE, the module is enabled												*/
var				bool			bEnabled;
/** If TRUE, the module has had editing enabled on it							*/
var				bool			bEditable;

/** The color to draw the modules curves in the curve editor. 
 *	If bCurvesAsColor is TRUE, it overrides this value.
 */
var(Cascade)	color			ModuleEditorColor;

/** ModuleType
 *	Indicates the kind of emitter the module can be applied to.
 *	ie, EPMT_Beam - only applies to beam emitters.
 *
 *	The TypeData field is present to speed up finding the TypeData module.
 */
enum EModuleType
{
	/** General - all emitter types can use it			*/
	EPMT_General,
	/** TypeData - TypeData modules						*/
	EPMT_TypeData,
	/** Beam - only applied to beam emitters			*/
	EPMT_Beam,
	/** Trail - only applied to trail emitters			*/
	EPMT_Trail
};

/** 
 *	Particle Selection Method, for any emitters that utilize particles
 *	as the source points.
 */
enum EParticleSourceSelectionMethod
{
	/** Random		- select a particle at random		*/
	EPSSM_Random,
	/** Sequential	- select a particle in order		*/
	EPSSM_Sequential
};



defaultproperties
{
	bSupported3DDrawMode=false
	b3DDrawMode=false
	bEnabled=true
	bEditable=true
}
