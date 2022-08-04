/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_TrackTurretBase extends UTVehicleFactory
	native(Vehicle)
	abstract
	hidecategories(Attachment);

/** Defines the directions to which the turret can move */
enum ETurretMoveDir
{
	TMD_Stop,
	TMD_Forward,
	TMD_Reverse
};

/** Used to base this on a mover */
var(UTTurret) InterpActor MoverBase;

/** Holds the initial position - the turret track action will be moved to this position whenever the turret is reset */
var(UTTurret) float InitialPosition;

/** If true, this turret will ignore the rotation provided by Matinee */
var(UTTurret) bool bIgnoreMatineeRotation;

/** How long does the turret take to get moving full speed */
var(UTTurret) float TurretAccelRate;

/** previous interpolation position - used to cancel moves when the turret collides with something */
var float LastPosition;

/** Holds the current movement time modifier */
var transient float MovementModifier;

/** Defines the last movement direction */
var ETurretMoveDir LastMoveDir;

/** This is true if the turret is in motion */
var transient bool bInMotion;

/** stores last inputs used to adjust movement, so that if they have not changed we continue in the direction we were going
 * regardless of how the matinee and/or the player's view turns
 */
var transient float LastSteering, LastThrottle;

/** whether we have a track (passed to vehicle for AI) */
var bool bHasTrack;

/** @hack: offset for spawned vehicle rotation to work around issue with some turret meshes that
 * causes them to be offset from the rotation in UnrealEd
 */
var rotator SpawnRotationOffset;



native function TurretDeathReset();
/**
 * Reset the Turret by Heading back towards the start position
 */

native function ResetTurret();

/**
 * This function is called when a player Enters a turret that is in the process of resetting.
 */

native function ForceTurretStop();

simulated function PostBeginPlay()
{
	if ( MoverBase != none )
	{
		SetBase(MoverBase);
		bHasTrack = true;
	}

	Super.PostBeginPlay();
}

function Deactivate()
{
	local int i;

	// kick players out of turrets instead of killing them
	if (ChildVehicle != None)
	{
		for (i = 0; i < ChildVehicle.Seats.length; i++)
		{
			if (ChildVehicle.Seats[i].SeatPawn != None && ChildVehicle.Seats[i].SeatPawn.bDriving)
			{
				ChildVehicle.Seats[i].SeatPawn.DriverLeave(true);
			}
		}
	}

	Super.Deactivate();
}

function rotator GetSpawnRotation()
{
	return (Super.GetSpawnRotation() + SpawnRotationOffset);
}

state Active
{
	function SpawnVehicle()
	{
		Super.SpawnVehicle();
		if (ChildVehicle != None)
		{
			ChildVehicle.bAlwaysRelevant = true; // needed because collision while interpolating depends on turret
			if (bHasTrack)
			{
				ChildVehicle.bIsOnTrack = true;
			}
			else
			{
				ChildVehicle.bStationary = true;
			}
			ChildVehicle.SetBase(self);
			TriggerEventClass(class'UTSeqEvent_TurretStatusChanged', self, 0);
		}
	}
}

simulated event InterpolationChanged(SeqAct_Interp InterpAction)
{
	MovementModifier=0.0;
}

simulated event InterpolationStarted(SeqAct_Interp InterpAction)
{
	MovementModifier=0.0;
	bHasTrack = true;
	if (ChildVehicle != None)
	{
		ChildVehicle.bIsOnTrack = true;
		ChildVehicle.bStationary = false;
	}
}

simulated event InterpolationFinished(SeqAct_Interp InterpAction)
{
	MovementModifier=0.0;
}

defaultproperties
{
	Physics=PHYS_Interpolating
	bHidden=true
	bHardAttach=true
	InitialPosition=0.0
	bIgnoreMatineeRotation=true
	LastMoveDir=TMD_Stop
	TurretAccelRate=3.5
	bDestinationOnly=true
	bReplicateChildVehicle=true
	bIgnoreEncroachers=True
	NetPriority=1.5
	NetUpdateFrequency=15
	SupportedEvents.Add(class'UTSeqEvent_TurretSpawn')
	SupportedEvents.Add(class'UTSeqEvent_TurretStatusChanged')
}
