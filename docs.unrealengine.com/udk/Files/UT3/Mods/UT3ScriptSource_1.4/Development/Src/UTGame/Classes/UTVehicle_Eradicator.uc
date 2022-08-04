/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Eradicator extends UTVehicle
	native(Vehicle)
	abstract;

/** These values are used in positioning the weapons */
var repnotify	rotator	GunnerWeaponRotation;
var	repnotify	vector	GunnerFlashLocation;
var	repnotify	byte	GunnerFlashCount;
var repnotify	byte	GunnerFiringMode;

/** Coordinates for the Camera Fire tooltip textures */
var UIRoot.TextureCoordinates CameraFireToolTipIconCoords;



replication
{
	if (bNetDirty)
		GunnerFlashLocation;
	if (!IsSeatControllerReplicationViewer(0) || bDemoRecording)
		GunnerFlashCount, GunnerFiringMode, GunnerWeaponRotation;
}

native simulated function vector GetTargetLocation(optional Actor RequestedBy, optional bool bRequestAlternateLoc);

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if ( !bDeleteMe )
	{
		SetTimer(2.0, false, 'FixPosition');
	}
}

function FixPosition()
{
	SetPhysics(PHYS_None);
}

function bool OpenPositionFor(Pawn P)
{
	// ignore extra seat because driver controls it as well
	return !Occupied();
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
	}

	Super.SetTeamNum(T);
}

/**
*	Because WeaponRotation is used to drive seat 1 - it will be replicated when you are in the big turret because bNetOwner is FALSE.
*	We don't want it replicated though, so we discard it when we receive it.
*/
simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'WeaponRotation' && Seats[0].SeatPawn != None && Seats[0].SeatPawn.Controller != None )
	{
		return;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function DisplayHud(UTHud Hud, Canvas Canvas, vector2D HudPOS, optional int SeatIndex)
{
	local PlayerController PC;
	local UTVWeap_SPMACannon Gun;

	super.DisplayHud(HUD, Canvas, HudPOS, SeatIndex);

	PC = PlayerController(Seats[0].SeatPawn.Controller);
	Gun = UTVWeap_SPMACannon(Seats[0].Gun);
	if ( PC != none && Gun != None )
	{
		if ( Gun.RemoteCamera == None )
		{
			Hud.DrawToolTip(Canvas, PC, "GBA_Fire", Canvas.ClipX * 0.5, Canvas.ClipY * 0.92, CameraFireToolTipIconCoords.U, CameraFireToolTipIconCoords.V, CameraFireToolTipIconCoords.UL, CameraFireToolTipIconCoords.VL, Canvas.ClipY / 768);
		}
	}
}

//=================================
// AI Interface

function bool ImportantVehicle()
{
	return true;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function bool CanDeployedAttack(Actor Other)
{
	local UTVWeap_SPMACannon Gun;
	
	Gun = UTVWeap_SPMACannon(Seats[0].Gun);
	if ( Gun != None )
	{
		return Gun.CanAttack(Other);
	}
	else
	{
		return CanAttack(Other);
	}
}

function DriverLeft()
{
	local UTVWeap_SPMACannon Gun;

	Super.DriverLeft();

	Gun = UTVWeap_SPMACannon(Seats[0].Gun);
	if (Gun != None && Gun.RemoteCamera != None )
	{
		Gun.RemoteCamera.Disconnect();
	}
}

function bool IsArtillery()
{
	return true;
}

function PassengerLeave(int SeatIndex)
{
	local UTVWeap_SPMACannon Gun;

	Super.PassengerLeave(SeatIndex);

	Gun = UTVWeap_SPMACannon(Seats[0].Gun);

	if ( Gun != none && Gun.RemoteCamera != none )
	{
		Gun.RemoteCamera.Disconnect();
	}
}

defaultproperties
{
	Health=800
	MaxDesireability=0.6
	MomentumMult=0.3
	bCanFlip=false
	bTurnInPlace=true
	bCanStrafe=false
	bSeparateTurretFocus=true
	BaseEyeheight=0
	Eyeheight=0
	bHardAttach=true
	bEnteringUnlocks=false
	bBlocksNavigation=true
	bStationary=true

	COMOffset=(x=0.0,y=0.0,z=-100.0)

	RespawnTime=45.0
	HUDExtent=140.0

	SeatCameraScale=2.5

	AIPurpose=AIP_Any
	NonPreferredVehiclePathMultiplier=2.0
	bHasAlternateTargetLocation=true

	HornIndex=1
	ChargeBarPosY=7
}
