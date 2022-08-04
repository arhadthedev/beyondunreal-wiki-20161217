//=============================================================================
// Simplified version of ambient sound used to enhance workflow.
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class AmbientSoundSimple extends AmbientSound
	hidecategories(Audio)
	native(Sound);

/** Mirrored property for easier editability, set in Spawned.		*/
var()	editinline editconst	SoundNodeAmbient	AmbientProperties;
/** Dummy sound cue property to force instantiation of subobject.	*/
var		editinline export const SoundCue			SoundCueInstance;
/** Dummy sound node property to force instantiation of subobject.	*/
var		editinline export const SoundNodeAmbient	SoundNodeInstance;



defaultproperties
{
	Begin Object Class=DrawSoundRadiusComponent Name=DrawSoundRadius0
	End Object
	Components.Add(DrawSoundRadius0)
	
	Begin Object Name=AudioComponent0
		PreviewSoundRadius=DrawSoundRadius0
	End Object

	Begin Object Class=SoundNodeAmbient Name=SoundNodeAmbient0
	End Object
	SoundNodeInstance=SoundNodeAmbient0

	Begin Object Class=SoundCue Name=SoundCue0
		SoundGroup=Ambient
	End Object
	SoundCueInstance=SoundCue0
}
