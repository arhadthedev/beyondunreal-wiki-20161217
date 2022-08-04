/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryDecal extends ActorFactory
	config(Editor)
	native(Decal);



var()	MaterialInterface	DecalMaterial;

defaultproperties
{
	MenuName="Add Decal"
	NewActorClass=class'Engine.DecalActor'
}
