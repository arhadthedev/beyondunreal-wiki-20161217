/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class StaticMeshComponentFactory extends MeshComponentFactory
	native
	hidecategories(Object)
	collapsecategories
	editinlinenew;

var() StaticMesh	StaticMesh;



defaultproperties
{
	CollideActors=True
	BlockActors=True
	BlockZeroExtent=True
	BlockNonZeroExtent=True
	BlockRigidBody=True
}
