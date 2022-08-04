/**
 *	ParticleModuleUberBase
 *
 *	Base-class for 'uber' modules, which combine other modules together.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
 
class ParticleModuleUberBase extends ParticleModule
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object)
	abstract;

//------------------------------------------------------------------------------------------------
// Members
//------------------------------------------------------------------------------------------------
/** Required modules																			*/
var				const								array<name>				RequiredModules;

//------------------------------------------------------------------------------------------------
// C++ Text
//------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------
// Default Properties
//------------------------------------------------------------------------------------------------
defaultproperties
{
	// Required modules
	//RequiredModules
}
