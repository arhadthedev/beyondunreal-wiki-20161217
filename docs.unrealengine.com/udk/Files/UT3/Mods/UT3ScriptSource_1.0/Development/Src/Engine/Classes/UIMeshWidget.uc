/**
 * Class description
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UIMeshWidget extends UIObject
	native(UIPrivate)
	placeable;



var()	const	editconst	StaticMeshComponent		Mesh;



DefaultProperties
{
	bSupports3DPrimitives=true
	bSupportsPrimaryStyle=false	// no style

	bDebugShowBounds=true
	DebugBoundsColor=(R=128,G=0,B=64)

	Begin Object Class=StaticMeshComponent Name=WidgetMesh
	End Object
	Mesh=WidgetMesh
}
