/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryEmitter extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;



var()	ParticleSystem		ParticleSystem;

defaultproperties
{
	MenuName="Add Emitter"
	NewActorClass=class'Engine.Emitter'
	GameplayActorClass=class'Engine.EmitterSpawnable'
}
