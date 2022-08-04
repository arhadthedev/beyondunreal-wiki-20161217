//=============================================================================
// Ambient sound, sits there and emits its sound.
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class AmbientSound extends Keypoint
	native(Sound);

/** Should the audio component automatically play on load? */
var() bool bAutoPlay;

/** Audio component to play */
var(Audio) editconst const AudioComponent AudioComponent;

/** Is the audio component currently playing? */
var private bool bIsPlaying;



defaultproperties
{
	Begin Object NAME=Sprite
		Sprite=Texture2D'EngineResources.S_Ambient'
	End Object

	Begin Object Class=AudioComponent Name=AudioComponent0
		bAutoPlay=false
		bStopWhenOwnerDestroyed=true
		bShouldRemainActiveIfDropped=true
	End Object
	AudioComponent=AudioComponent0
	Components.Add(AudioComponent0)

	bAutoPlay=TRUE
	
	RemoteRole=ROLE_None
}
