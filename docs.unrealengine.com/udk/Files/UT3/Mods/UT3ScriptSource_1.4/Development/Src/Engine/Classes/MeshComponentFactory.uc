/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class MeshComponentFactory extends PrimitiveComponentFactory
	native
	abstract;

var(Rendering) array<MaterialInterface>	Materials;



defaultproperties
{
	CastShadow=True
}
