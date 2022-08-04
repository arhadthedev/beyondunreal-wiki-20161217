/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MaterialInstance extends MaterialInterface
	abstract
	native(Material);


/** Physical material to use for this graphics material. Used for sounds, effects etc.*/
var() PhysicalMaterial PhysMaterial;

var() const MaterialInterface Parent;

/** indicates whether the instance has static permutation resources (which are required when static parameters are present) */
var bool bHasStaticPermutationResource;

/** indicates whether the static permutation resource needs to be updated on PostEditChange() */
var native transient bool bStaticPermutationDirty;

/** 
* The set of static parameters that this instance will be compiled with, one for sm3 and one for sm2.
* This is indexed by EMaterialShaderPlatform.
*/
var const native duplicatetransient pointer StaticParameters[2]{FStaticParameterSet};

/** 
* The material resources for this instance, one for sm3 and one for sm2.
* This is indexed by EMaterialShaderPlatform.
*/
var const native duplicatetransient pointer StaticPermutationResources[2]{FMaterialResource};

var const native duplicatetransient pointer Resources[2]{class FMaterialInstanceResource};


var private const native bool ReentrantFlag;

/** 
 * Array of textures referenced, updated in PostLoad.  These are needed to keep the textures used by material resources 
 * from getting destroyed by realtime GC.
 */
var private const array<texture> ReferencedTextures;

;



// SetParent - Updates the parent.

native function SetParent(MaterialInterface NewParent);

// Set*ParameterValue - Updates the entry in ParameterValues for the named parameter, or adds a new entry.

native function SetVectorParameterValue(name ParameterName, LinearColor Value);
native function SetScalarParameterValue(name ParameterName, float Value);
native function SetScalarCurveParameterValue(name ParameterName, InterpCurveFloat Value);
native function SetTextureParameterValue(name ParameterName, Texture Value);

/**
* Sets the value of the given font parameter.  
*
* @param	ParameterName	The name of the font parameter
* @param	OutFontValue	New font value to set for this MIC
* @param	OutFontPage		New font page value to set for this MIC
*/
native function SetFontParameterValue(name ParameterName, Font FontValue, int FontPage);

/** Removes all parameter values */
native function ClearParameterValues();

defaultproperties
{
	bHasStaticPermutationResource=False
}