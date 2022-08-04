class InterpTrackAnimControl extends InterpTrackFloatBase
	native(Interpolation);
	
/** 
 * InterpTrackAnimControl
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
 
 


/** 
 *	DEPRECATED! USE UInterpGroup::GroupAnimSets instead now.
 */
var		array<AnimSet>			AnimSets;

/** 
 *	Name of slot to use when playing animation. Passed to Actor. 
 *	When multiple tracks use the same slot name, they are each given a different ChannelIndex when SetAnimPosition is called. 
 */
var()	editconst name			SlotName;

/** Structure used for holding information for one animation played on the Anim Control track. */
struct native AnimControlTrackKey
{
	/** Position in the Matinee sequence to start playing this animation. */
	var		float	StartTime;
	
	/** Name of AnimSequence to play. */
	var		name	AnimSeqName;
	
	/** Time to start playing AnimSequence at. */
	var		float	AnimStartOffset;
	
	/** Time to end playing the AnimSequence at. */
	var		float	AnimEndOffset;

	/** Playback speed of this animation. */
	var		float	AnimPlayRate;
	
	/** Should this animation loop. */
	var		bool	bLooping;

	/** Whether to play the animation in reverse or not. */
	var		bool	bReverse;
};	

/** Track of different animations to play and when to start playing them. */
var	array<AnimControlTrackKey>	AnimSeqs;

defaultproperties
{
	TrackInstClass=class'Engine.InterpTrackInstAnimControl'
	TrackTitle="Anim"
	bIsAnimControlTrack=true
}
