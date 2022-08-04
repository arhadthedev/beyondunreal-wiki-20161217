/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryAmbientSound extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;



var()	SoundCue		AmbientSoundCue;

defaultproperties
{
	MenuName="Add AmbientSound"
	NewActorClass=class'Engine.AmbientSound'
}
