/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_Interp extends SeqAct_Latent
	native(Sequence);



/**
 * Helper type for storing actors' World-space locations/rotations.
 */
struct native export SavedTransform
{
	var vector	Location;
	var rotator	Rotation;
};

/** A map from actors to their pre-Matinee world-space positions/orientations.  Includes actors attached to Matinee-affected actors. */
var editoronly private const transient noimport native map{AActor*,FSavedTransform} SavedActorTransforms;

/** Time multiplier for playback. */
var()	float					PlayRate;

/** Time position in sequence - starts at 0.0 */
var		float					Position;

/** Time position to always start at if bForceStartPos is set to TRUE. */
var()	float					ForceStartPosition;

/** If sequence is currently playing. */
var		bool					bIsPlaying;

/** Sequence is initialised, but ticking will not increment its current position. */
var		bool					bPaused;

/** Indicates whether this SeqAct_Interp is currently open in the Matinee tool. */
var		transient bool			bIsBeingEdited;

/**
 *	If sequence should pop back to beginning when finished.
 *	Note, if true, will never get Complete/Aborted events - sequence must be explicitly Stopped.
 */
var()	bool					bLooping;

/** If true, sequence will rewind itself back to the start each time the Play input is activated. */
var()	bool					bRewindOnPlay;

/**
 *	If true, when rewinding this interpolation, reset the 'initial positions' of any RelateToInitial movements to the current location.
 *	This allows the next loop of movement to proceed from the current locations.
 */
var()	bool					bNoResetOnRewind;

/**
 *	Only used if bRewindOnPlay if true. Defines what should happen if the Play input is activated while currently playing.
 *	If true, hitting Play while currently playing will pop the position back to the start and begin playback over again.
 *	If false, hitting Play while currently playing will do nothing.
 */
var()	bool					bRewindIfAlreadyPlaying;

/** If sequence playback should be reversed. */
var		bool					bReversePlayback;

/** Whether this action should be initialised and moved to the 'path building time' when building paths. */
var()	bool					bInterpForPathBuilding;

/** Lets you force the sequence to always start at ForceStartPosition */
var()	bool					bForceStartPos;

/** Indicates that this interpolation does not affect gameplay. This means that:
 * -it is not replicated via MatineeActor
 * -it is not ticked if no affected Actors are visible
 * -on dedicated servers, it is completely ignored
 */
var() bool bClientSideOnly;

/** if bClientSideOnly is true, whether this matinee should be completely skipped if none of the affected Actors are visible */
var() bool bSkipUpdateIfNotVisible;

/** Lets you skip the matinee with the CANCELMATINEE exec command. Triggers all events to the end along the way. */
var()	bool					bIsSkippable;

/** Cover linked to this matinee that should be updated once path building time has been played */
var() array<CoverLink>			LinkedCover;

/** Actual track data. Can be shared between SeqAct_Interps. */
var		export InterpData		InterpData;

/** Instance data for interp groups. One for each variable/group combination. */
var		array<InterpGroupInst>	GroupInst;

/** on a net server, actor spawned to handle replicating relevant data to the client */
var const class<MatineeActor> ReplicatedActorClass;
var const MatineeActor ReplicatedActor;

/** sets the position of the interpolation
 * @note if the interpolation is not currently active, this function doesn't send any Kismet or UnrealScript events
 * @param NewPosition the new position to set the interpolation to
 * @param bJump if true, teleport to the new position (don't trigger any events between the old and new positions, etc)
 */
native final function SetPosition(float NewPosition, optional bool bJump = false);

/** stops playback at current position */
native final function Stop();

/** adds the passed in PlayerController to all running Director tracks so that its camera is controlled
 * all PCs that are available at playback start time are hooked up automatically, but this needs to be called to hook up
 * any that are created during playback (player joining a network game during a cinematic, for example)
 * @param PC the PlayerController to add
 */
native final function AddPlayerToDirectorTracks(PlayerController PC);

function Reset()
{
	SetPosition(0.0, false);
	// stop if currently playing
	if (bActive)
	{
		InputLinks[2].bHasImpulse = true;
	}
}

defaultproperties
{
	ObjName="Matinee"

	PlayRate=1.0

	InputLinks(0)=(LinkDesc="Play")
	InputLinks(1)=(LinkDesc="Reverse")
	InputLinks(2)=(LinkDesc="Stop")
	InputLinks(3)=(LinkDesc="Pause")
	InputLinks(4)=(LinkDesc="Change Dir")

	OutputLinks(0)=(LinkDesc="Completed")
	OutputLinks(1)=(LinkDesc="Aborted")

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'InterpData',LinkDesc="Data",MinVars=1,MaxVars=1)

	ReplicatedActorClass=class'MatineeActor'
}
