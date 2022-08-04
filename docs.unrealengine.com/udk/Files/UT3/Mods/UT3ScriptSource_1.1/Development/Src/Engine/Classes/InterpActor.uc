﻿/** dynamic static mesh actor intended to be used with Matinee
 *	replaces movers
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class InterpActor extends DynamicSMActor
	native
	placeable;



/** Data relevant to checkpoint save/load, see CreateCheckpointRecord/ApplyCheckpointRecord below */
struct CheckpointRecord
{
    var vector Location;
    var rotator Rotation;
    var bool bIsShutdown;
};

/** NavigationPoint associated with this actor for sending AI related notifications (could be a LiftCenter or DoorMarker) */
var NavigationPoint MyMarker;
/** true when AI is waiting for us to finish moving */
var bool bMonitorMover;
/** if true, call MoverFinished() event on all Controllers with us as their PendingMover when we reach peak Z velocity */
var bool bMonitorZVelocity;
/** set while monitoring lift movement */
var float MaxZVelocity;
/** delay after mover finishes interpolating before it notifies any mover events */
var float StayOpenTime;
/** sound played when the mover is interpolated forward */
var() SoundCue OpenSound;
/** looping sound while opening */
var() SoundCue OpeningAmbientSound;
/** sound played when mover finished moving forward */
var() SoundCue OpenedSound;
/** sound played when the mover is interpolated in reverse */
var() SoundCue CloseSound;
/** looping sound while closing */
var() SoundCue ClosingAmbientSound;
/** sound played when mover finished moving backward */
var() SoundCue ClosedSound;
/** component for looping sounds */
var AudioComponent AmbientSoundComponent;

/** if set this mover blows up projectiles when it encroaches them */
var() bool bDestroyProjectilesOnEncroach;
/** if set, this mover keeps going if it encroaches an Actor in PHYS_RigidBody.  */
var() bool bContinueOnEncroachPhysicsObject;
/** true by default, prevents mover from completing the movement that would leave it encroaching another actor */
var() bool bStopOnEncroach;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// create ambient sound component if needed
	if (OpeningAmbientSound != None || ClosingAmbientSound != None)
	{
		AmbientSoundComponent = new(self) class'AudioComponent';
		AttachComponent(AmbientSoundComponent);
	}
}

event bool EncroachingOn(Actor Other)
{
	local int i;
	local SeqEvent_Mover MoverEvent;
	local Pawn P;
	local vector Height, HitLocation, HitNormal;
	local bool bLandingPawn;

	// Allow move into rigid bodies - should just push them out of the way.
	if(bContinueOnEncroachPhysicsObject && (Other.Physics == PHYS_RigidBody))
	{
		return FALSE;
	}

	// Check if this is something that should be destroyed when mover runs into it
	if(Other.bDestroyedByInterpActor)
	{
		Other.Destroy();
		return FALSE;
	}

	// if we're moving towards the actor
	if ( (Other.Base == self) || (Normal(Velocity) Dot Normal(Other.Location - Location) >= 0.f) )
	{
		// if we're moving up into a pawn, ignore it so it can land on us instead
		P = Pawn(Other);
		if (P != None)
		{
			if (P.Physics == PHYS_Falling && Velocity.Z > 0.f)
			{
				Height = P.GetCollisionHeight() * vect(0,0,1);
				// @note: only checking against our StaticMeshComponent, assumes we have no other colliding components
				if (TraceComponent(HitLocation, HitNormal, StaticMeshComponent, P.Location - Height, P.Location + Height, P.GetCollisionExtent()))
				{
					// make sure the pawn doesn't fall through us
					if (P.Location.Z < Location.Z)
					{
						P.SetLocation(HitLocation + Height);
					}
					bLandingPawn = true;
				}
			}
			else if (P.Base != self && P.Controller != None && P.Controller.PendingMover != None && P.Controller.PendingMover == self)
			{
				P.Controller.UnderLift(LiftCenter(MyMarker));
			}
		}
		else if (bDestroyProjectilesOnEncroach && Other.IsA('Projectile'))
		{
			Projectile(Other).Explode(Other.Location, -Normal(Velocity));
			return false;
		}

		if ( !bLandingPawn )
		{
			// search for any mover events
			for (i = 0; i < GeneratedEvents.Length; i++)
			{
				MoverEvent = SeqEvent_Mover(GeneratedEvents[i]);
				if (MoverEvent != None)
				{
					// notify the event that we encroached something
					MoverEvent.NotifyEncroachingOn(Other);
				}
			}
			return bStopOnEncroach;
		}
	}

	return false;
}

/*
 * called for encroaching actors which successfully moved the other actor out of the way
 */
event RanInto( Actor Other )
{
	local int i;
	local SeqEvent_Mover MoverEvent;

	if (bDestroyProjectilesOnEncroach && Other.IsA('Projectile'))
	{
		Projectile(Other).Explode(Other.Location, -Normal(Velocity));
	}
	// Check if this is something that should be destroyed when mover runs into it
	else if(Other.bDestroyedByInterpActor)
	{
		Other.Destroy();
	}
	else
	{
		// search for any mover events
		for (i = 0; i < GeneratedEvents.Length; i++)
		{
			MoverEvent = SeqEvent_Mover(GeneratedEvents[i]);
			if (MoverEvent != None)
			{
				// notify the event that we encroached something
				MoverEvent.NotifyEncroachingOn(Other);
			}
		}
	}
}


event Attach(Actor Other)
{
	local int i;
	local SeqEvent_Mover MoverEvent;

	if (!IsTimerActive('FinishedOpen'))
	{
		// search for any mover events
		for (i = 0; i < GeneratedEvents.Length; i++)
		{
			MoverEvent = SeqEvent_Mover(GeneratedEvents[i]);
			if (MoverEvent != None)
			{
				// notify the event that an Actor has been attached
				MoverEvent.NotifyAttached(Other);
			}
		}
	}
}

event Detach(Actor Other)
{
	local int i;
	local SeqEvent_Mover MoverEvent;

	// search for any mover events
	for (i = 0; i < GeneratedEvents.Length; i++)
	{
		MoverEvent = SeqEvent_Mover(GeneratedEvents[i]);
		if (MoverEvent != None)
		{
			// notify the event that an Actor has been detached
			MoverEvent.NotifyDetached(Other);
		}
	}
}

/** checks if anything is still attached to the mover, and if so notifies Kismet so that it may restart it if desired */
function Restart()
{
	local Actor A;

	foreach BasedActors(class'Actor', A)
	{
		Attach(A);
	}
}

/** called on a timer StayOpenTime seconds after the mover has finished opening (forward matinee playback) */
function FinishedOpen()
{
	local int i;
	local SeqEvent_Mover MoverEvent;

	// search for any mover events
	for (i = 0; i < GeneratedEvents.Length; i++)
	{
		MoverEvent = SeqEvent_Mover(GeneratedEvents[i]);
		if (MoverEvent != None)
		{
			// notify the event that all opening and associated delays are finished and it may now reverse our direction
			// (or do any other actions as set up in Kismet)
			MoverEvent.NotifyFinishedOpen();
		}
	}
}

simulated function PlayMovingSound(bool bClosing)
{
	local SoundCue SoundToPlay;
	local SoundCue AmbientToPlay;

	if (bClosing)
	{
		SoundToPlay = CloseSound;
		AmbientToPlay = OpeningAmbientSound;
	}
	else
	{
		SoundToPlay = OpenSound;
		AmbientToPlay = ClosingAmbientSound;
	}
	if (SoundToPlay != None)
	{
		PlaySound(SoundToPlay, true);
	}
	if (AmbientToPlay != None)
	{
		AmbientSoundComponent.Stop();
		AmbientSoundComponent.SoundCue = AmbientToPlay;
		AmbientSoundComponent.Play();
	}
}

simulated event InterpolationStarted(SeqAct_Interp InterpAction)
{
	ClearTimer('Restart');
	ClearTimer('FinishedOpen');

	PlayMovingSound(InterpAction.bReversePlayback);
}

simulated event InterpolationFinished(SeqAct_Interp InterpAction)
{
	local DoorMarker DoorNav;
	local Controller C;
	local SoundCue StoppedSound;

	if (AmbientSoundComponent != None)
	{
		AmbientSoundComponent.Stop();
	}

	StoppedSound = InterpAction.bReversePlayback ? ClosedSound : OpenedSound;
	if (StoppedSound != None)
	{
		PlaySound(StoppedSound, true);
	}

	DoorNav = DoorMarker(MyMarker);
	if (InterpAction.bReversePlayback)
	{
		// we are done; if something is still attached, set timer to try restart
		if (Attached.length > 0)
		{
			SetTimer(StayOpenTime, false, 'Restart');
		}
		if (DoorNav != None)
		{
			DoorNav.MoverClosed();
		}
	}
	else
	{
		// set timer to notify any mover events
		SetTimer(StayOpenTime, false, 'FinishedOpen');

		if (DoorNav != None)
		{
			DoorNav.MoverOpened();
		}
	}

	if (bMonitorMover)
	{
		// notify any Controllers with us as PendingMover that we have finished moving
		foreach WorldInfo.AllControllers(class'Controller', C)
		{
			if (C.PendingMover == self)
			{
				C.MoverFinished();
			}
		}
	}

	//@hack: force location update on clients if future matinee actions rely on it
	if (InterpAction.bNoResetOnRewind && InterpAction.bRewindOnPlay)
	{
		ForceNetRelevant();
		bUpdateSimulatedPosition = true;
		bReplicateMovement = true;
	}
}

simulated event InterpolationChanged(SeqAct_Interp InterpAction)
{
	PlayMovingSound(InterpAction.bReversePlayback);
}

/** Called when this actor is being saved in a checkpoint, records pertinent information for restoration via ApplyCheckpointRecord. */
function CreateCheckpointRecord(out CheckpointRecord Record)
{
    Record.Location = Location;
    Record.Rotation = Rotation;
	//@fixme - is there a more reliable way to detect this?  maybe add a bIsShutDown flag to actor?
    Record.bIsShutdown = Physics == PHYS_Interpolating && bHidden;
}

function ApplyCheckpointRecord(const out CheckpointRecord Record)
{
    if (Record.bIsShutdown)
    {
	ShutDown();
    }
    else
    {
	//@fixme - need to fixup latentactions so that interpactors saved mid-move can be properly restored
	LatentActions.Length = 0;
	SetHidden(FALSE);
	bStasis = FALSE;
	SetCollision(TRUE,TRUE,bIgnoreEncroachers);
	SetLocation(Record.Location);
	SetRotation(Record.Rotation);
    }
}

defaultproperties
{
	Begin Object Name=MyLightEnvironment
		bEnabled=False
	End Object

	Begin Object Name=StaticMeshComponent0
		WireframeColor=(R=255,G=0,B=255,A=255)
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		RBCollideWithChannels=(Default=TRUE)
	End Object

	bStatic=false
	bWorldGeometry=false
	Physics=PHYS_Interpolating

	bNoDelete=true
	bAlwaysRelevant=true
	bSkipActorPropertyReplication=false
	bUpdateSimulatedPosition=false
	bOnlyDirtyReplication=true
	RemoteRole=ROLE_None
	NetPriority=2.7
	NetUpdateFrequency=1.0
	bDestroyProjectilesOnEncroach=true
	bStopOnEncroach=true
	bContinueOnEncroachPhysicsObject=TRUE
	bCollideWhenPlacing=FALSE
	bBlocksTeleport=true

	SupportedEvents.Add(class'SeqEvent_Mover')
	SupportedEvents.Add(class'SeqEvent_TakeDamage')
}
