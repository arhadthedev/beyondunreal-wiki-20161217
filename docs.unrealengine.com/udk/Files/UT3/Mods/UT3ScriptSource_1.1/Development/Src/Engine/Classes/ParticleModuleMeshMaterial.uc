/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleMeshMaterial extends ParticleModuleMaterialBase
	native(Particle)
	editinlinenew
	hidecategories(Object);

//=============================================================================
//	Properties
//=============================================================================
/** The array of materials to apply to the mesh particles. */
var(MeshMaterials)	array<MaterialInterface>		MeshMaterials;

//=============================================================================
//	C++
//=============================================================================


//=============================================================================
//	Default properties
//=============================================================================
defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true
}
