/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MeshComponentFactory extends PrimitiveComponentFactory
	native
	abstract;

var(Rendering) array<MaterialInterface>	Materials;



defaultproperties
{
	CastShadow=True
}
