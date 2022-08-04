/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryFracturedStaticMesh extends ActorFactory
	config(Editor)
	native;



var()	FracturedStaticMesh		FracturedStaticMesh;
var()	vector			DrawScale3D;

defaultproperties
{
	DrawScale3D=(X=1,Y=1,Z=1)

	MenuName="Add FracturedStaticMesh"
	NewActorClass=class'Engine.FracturedStaticMeshActor'
}
