/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryLensFlare extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;



var()	LensFlare		LensFlareObject;

defaultproperties
{
	MenuName="Add LensFlare"
	NewActorClass=class'Engine.LensFlareSource'
	//GameplayActorClass=class'Engine.EmitterSpawnable'
}
