/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactorySkeletalMesh extends ActorFactory
	config(Editor)
	native;



var()	SkeletalMesh	SkeletalMesh;
var()	AnimSet			AnimSet;
var()	name			AnimSequenceName;

defaultproperties
{
	MenuName="Add SkeletalMesh"
	NewActorClass=class'Engine.SkeletalMeshActor'
	GameplayActorClass=class'Engine.SkeletalMeshActorSpawnable'
}
