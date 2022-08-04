/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleTypeDataMesh extends ParticleModuleTypeDataBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);
	
var(Mesh)	StaticMesh				Mesh;			// The Base Mesh
var(Mesh)	bool					CastShadows;
var(Mesh)	bool					DoCollisions;

enum EMeshScreenAlignment
{
    PSMA_MeshFaceCameraWithRoll,
    PSMA_MeshFaceCameraWithSpin,
    PSMA_MeshFaceCameraWithLockedAxis
};

var(Mesh)	EMeshScreenAlignment	MeshAlignment;

/**
 *	If TRUE, us the emitter material when rendering, rather than the 
 *	one applied to the statis mesh used.
 */
var(Mesh)	bool					bOverrideMaterial;



defaultproperties
{
	CastShadows=false
	DoCollisions=false
	MeshAlignment=PSMA_MeshFaceCameraWithRoll
}
