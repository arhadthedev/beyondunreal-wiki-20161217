/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_TrackTurretBase extends UTVehicle
	native(Vehicle)
	abstract;

var AudioComponent TurretMoveStart;
var AudioComponent TurretMoveLoop;
var AudioComponent TurretMoveStop;

/** Is true if this turret is in motion */
var bool bInMotion;

/** last bounding box of our Mesh. This is used to check encroachment when the turret animates so that players don't get stuck
 * if the animation moves a part of the turret on top of them
 */
var Box LastBoundingBox;



/**
 * When an icon for this vehicle is needed on the hud, this function is called
 */
simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, LinearColor FinalColor)
{
	local Rotator VehicleRotation;
	VehicleRotation = (Controller != None) ? Controller.Rotation : Rotation;
	MP.DrawRotatedTile(Canvas, Class'UTHUD'.default.IconHudTexture, HUDLocation, VehicleRotation.Yaw + 32767, MapSize, IconCoords, FinalColor);
}

/**
 * Notify Kismet that the turret has died
 */
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local UTVehicleFactory_TrackTurretBase PFacWhileDying;

	PFacWhileDying = UTVehicleFactory_TrackTurretBase(ParentFactory); // cache this before super.died sets it to none
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		if (Role == ROLE_Authority && PFacWhileDying != none)
		{

			SetBase( None );
			SetHardAttach(false);
			PFacWhileDying.TriggerEventClass(class'UTSeqEvent_TurretStatusChanged', PFacWhileDying, 1);
			PFacWhileDying.TurretDeathReset();
		}
		return true;
	}
	else
	{
		return false;
	}
}

/**
 * Notify Kismet that the drive left
 */
function DriverLeft()
{
	Super.DriverLeft();

	ParentFactory.TriggerEventClass(class'UTSeqEvent_TurretStatusChanged', ParentFactory, 3);

	// Set the move back to start time
	ResetTime = WorldInfo.TimeSeconds + 30;
	UTVehicleFactory_TrackTurretBase(ParentFactory).ForceTurretStop();
}

event CheckReset()
{
	local controller C;

	// If we are occupied, don't reset
	if ( Occupied() )
	{
		ResetTime = WorldInfo.TimeSeconds - 1;
		return;
	}

	// If someone is close, don't reset

	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if ( (C.Pawn != None) && WorldInfo.GRI.OnSameTeam(C,self) && (VSize(Location - C.Pawn.Location) < 512) && FastTrace(C.Pawn.Location + C.Pawn.GetCollisionHeight() * vect(0,0,1), Location + GetCollisionHeight() * vect(0,0,1)) )
		{
			ResetTime = WorldInfo.TimeSeconds + 10;
			return;
		}
	}

	UTVehicleFactory_TrackTurretBase(ParentFactory).ResetTurret();
}

function SetTeamNum(byte T)
{
	if (Controller != None && Controller.GetTeamNum() != T)
	{
		DriverLeave(true);
	}

	// restore health and return to initial position when changing hands
	if (T != GetTeamNum())
	{
		Health = HealthMax;
		if (UTVehicleFactory_TrackTurretBase(ParentFactory) != None)
		{
			UTVehicleFactory_TrackTurretBase(ParentFactory).ResetTurret();
		}
	}

	Super.SetTeamNum(T);
}

/**
 * Notify Kismet that someone has entered
 */
function bool DriverEnter(Pawn P)
{
	if (Super.DriverEnter(P))
	{
		ParentFactory.TriggerEventClass(class'UTSeqEvent_TurretStatusChanged', ParentFactory, 2);
		return true;
	}
	else
	{
		return false;
	}
}

/** @return rotation used for determining valid exit positions */
function rotator ExitRotation()
{
	return (Controller != None) ? Controller.Rotation : Rotation;
}

simulated function bool ShouldClamp()
{
	return false;
}

defaultproperties
{
	Health=400
	bHardAttach=true
	AIPurpose=AIP_Defensive
	bEnteringUnlocks=false
	RespawnTime=45.0

	BaseEyeheight=0
	Eyeheight=0
	CameraLag=0.05

	// ~ -85deg.
	ViewPitchMax=15473
	ViewPitchMin=-15473

	LookForwardDist=150
	bCameraNeverHidesVehicle=true
	bIgnoreEncroachers=True
	bSeparateTurretFocus=false
	bCanCarryFlag=true
	bCanStrafe=true
	bFollowLookDir=true
	bTurnInPlace=true

	bCollideWorld=false
	Physics=PHYS_None

	ExplosionDamage=0 // so players getting kicked out due to node control change don't get blown up

	TargetLocationAdjustment=(x=0.0,y=0.0,z=45.0)
	IconCoords=(U=895,V=0,UL=23,VL=34)
	bEjectKilledBodies=true
}
