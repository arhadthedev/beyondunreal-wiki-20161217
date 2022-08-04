/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Used to affect level streaming in the game and level visibility in the editor.
 */
class LevelStreamingVolume extends Volume
	native
	hidecategories(Advanced,Attachment,Collision,Volume)
	placeable;

/** Levels affected by this level streaming volume. */
var() noimport const editconst array<LevelStreaming> StreamingLevels;

/** If TRUE, this streaming volume should only be used for editor streaming level previs. */
var() bool						bEditorPreVisOnly;

/**
 * If TRUE, this streaming volume is ignored by the streaming volume code.  Used to either
 * disable a level streaming volume without disassociating it from the level, or to toggle
 * the control of a level's streaming between Kismet and volume streaming.
 */
var() bool						bDisabled;

/** Enum for different usage cases of level streaming volumes. */
enum EStreamingVolumeUsage
{
	SVB_Loading,
	SVB_LoadingAndVisibility,
	SVB_VisibilityBlockingOnLoad,
	SVB_BlockingOnLoad,
	SVB_LoadingNotVisible
};

/** Determines what this volume is used for, e.g. whether to control loading, loading and visibility or just visibilty (blocking on load) */
var() EStreamingVolumeUsage	Usage;

/**
 * Kismet support for toggling bDisabled.
 */
simulated function OnToggle(SeqAct_Toggle action)
{
	if (action.InputLinks[0].bHasImpulse)
	{
		// "Turn On" -- mapped to enabling of volume streaming for this volume.
		bDisabled = FALSE;
	}
	else if (action.InputLinks[1].bHasImpulse)
	{
		// "Turn Off" -- mapped to disabling of volume streaming for this volume.
		bDisabled = TRUE;
	}
	else if (action.InputLinks[2].bHasImpulse)
	{
		// "Toggle"
		bDisabled = !bDisabled;
	}
}



defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
	End Object

	bCollideActors=False
	bBlockActors=False
	bProjTarget=False
	SupportedEvents.Empty
	SupportedEvents(0)=class'SeqEvent_Touch'
}
