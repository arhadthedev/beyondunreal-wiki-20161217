/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
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
