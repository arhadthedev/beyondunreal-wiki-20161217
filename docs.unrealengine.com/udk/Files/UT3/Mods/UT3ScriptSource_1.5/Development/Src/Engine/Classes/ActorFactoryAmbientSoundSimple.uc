/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryAmbientSoundSimple extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;



var()	SoundNodeWave	SoundNodeWave;

defaultproperties
{
	MenuName="Add AmbientSoundSimple"
	NewActorClass=class'Engine.AmbientSoundSimple'
}
