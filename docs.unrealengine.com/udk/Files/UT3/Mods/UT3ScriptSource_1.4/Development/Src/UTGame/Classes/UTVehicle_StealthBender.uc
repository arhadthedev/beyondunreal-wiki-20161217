﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_StealthBender extends UTStealthVehicle
	native(Vehicle)
	abstract;

/** One material for each team on the 'tail' section of the stealthbender */
var MaterialInterface SecondaryTeamSkins[2];

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	PlayVehicleAnimation('Inactive');
}

simulated function CreateDamageMaterialInstance()
{
	//Damaged MIC for the 'tail'
	DamageMaterialInstance[1] = Mesh.CreateAndSetMaterialInstanceConstant(1);
	super.CreateDamageMaterialInstance();
}

/**
* This function returns the aim for the weapon
* overloaded here to take into account the stealthbender turret is not near the camera
*/
function rotator GetWeaponAim(UTVehicleWeapon VWeapon)
{
	local vector SocketLocation, CameraLocation, RealAimPoint, DesiredAimPoint, HitLocation, HitRotation, DirA, DirB;
	local rotator CameraRotation, SocketRotation, ControllerAim, AdjustedAim;
	local float DiffAngle, MaxAdjust;
	local Controller C;
	local PlayerController PC;
	local Quat Q;

	if ( VWeapon != none )
	{
		C = Seats[VWeapon.SeatIndex].SeatPawn.Controller;

		PC = PlayerController(C);
		if (PC != None)
		{
			PC.GetPlayerViewPoint(CameraLocation, CameraRotation);
			DesiredAimPoint = CameraLocation + Vector(CameraRotation) * 2.0 * VWeapon.GetTraceRange();
			if (Trace(HitLocation, HitRotation, DesiredAimPoint, CameraLocation) != None)
			{
				DesiredAimPoint = HitLocation;
			}
		}
		else if (C != None)
		{
			DesiredAimPoint = C.FocalPoint;
		}

		if ( Seats[VWeapon.SeatIndex].GunSocket.Length>0 )
		{
			GetBarrelLocationAndRotation(VWeapon.SeatIndex, SocketLocation, SocketRotation);
			if(VWeapon.bIgnoreSocketPitchRotation || ((DesiredAimPoint.Z - Location.Z)<0 && VWeapon.bIgnoreDownwardPitch))
			{
				SocketRotation.Pitch = Rotator(DesiredAimPoint - Location).Pitch;
			}
		}
		else
		{
			SocketLocation = Location;
			SocketRotation = Rotator(DesiredAimPoint - Location);
		}

		RealAimPoint = SocketLocation + Vector(SocketRotation) * VWeapon.GetTraceRange();
		DirA = normal(DesiredAimPoint - SocketLocation);
		DirB = normal(RealAimPoint - SocketLocation);
		DiffAngle = ( DirA dot DirB );
		MaxAdjust = VWeapon.GetMaxFinalAimAdjustment();
		if ( DiffAngle >= MaxAdjust )
		{
			// bit of a hack here to make bot aiming and single player autoaim work
			ControllerAim = (C != None) ? C.Rotation : Rotation;
			AdjustedAim = VWeapon.GetAdjustedAim(SocketLocation);
			if (AdjustedAim == VWeapon.Instigator.GetBaseAimRotation() || AdjustedAim == ControllerAim)
			{
				// no adjustment
				return rotator(DesiredAimPoint - SocketLocation);
			}
			else
			{
				// FIXME: AdjustedAim.Pitch = Instigator.LimitPitch(AdjustedAim.Pitch);
				return AdjustedAim;
			}
		}
		else
		{
			Q = QuatFromAxisAndAngle(Normal(DirB cross DirA), ACos(MaxAdjust));
			return Rotator( QuatRotateVector(Q,DirB));
		}
	}
	else
	{
		return Rotation;
	}
}

/**
 * function cloaks or decloaks the vehicle.
 */
simulated function ToggleCloak()
{
	//Cloak the tail piece of the vehicle
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// cloaking!
		if(bIsVehicleCloaked && Mesh.Materials[1] != CloakedBodyMIC)
		{
			//Same material as the main body
			Mesh.SetMaterial(1, CloakedBodyMIC);
			UpdateShadowSettings( FALSE );
			DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = FALSE;
		}
		// decloaking
		else if(!bIsVehicleCloaked && Mesh.Materials[1] != DamageMaterialInstance[1])
		{
			//Back to secondary material for the tail
			Mesh.SetMaterial(1, DamageMaterialInstance[1]);
			UpdateShadowSettings(!class'Engine'.static.IsSplitScreen() && class'UTPlayerController'.Default.PawnShadowMode == SHADOW_All);
			DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = TRUE;
		}
	}

	super.ToggleCloak();
}


/** Override set inputs so get direct information when deployed. */
simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
	if(IsDeployed())
	{
		Super(Vehicle).SetInputs(InForward,InStrafe,InUp);
	}
	else
	{
		Super(UTVehicle).SetInputs(InForward,InStrafe,InUp);
	}
}


simulated function TeamChanged()
{
	local MaterialInterface NewMaterial;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (Team < 2 && SecondaryTeamSkins[Team] != None)
		{
			NewMaterial = SecondaryTeamSkins[Team];
		}
		else if (SecondaryTeamSkins[0] != None)
		{
			NewMaterial = SecondaryTeamSkins[0];
		}

		//Always reparent the DamageMIC
		if (NewMaterial != None)
		{
			if (DamageMaterialInstance[1] != None)
			{
				DamageMaterialInstance[1].SetParent(NewMaterial);
			}
		}

		//If we aren't cloaked, set the 'visible' skin
		if(Mesh.Materials[1] != CloakedBodyMIC)
		{
			Mesh.SetMaterial(1, DamageMaterialInstance[1]);
		}
	}

	super.TeamChanged();
}



defaultproperties
{
	Health=600
	StolenAnnouncementIndex=5
	RespawnTime=45.0

	COMOffset=(x=0.0,y=0.0,z=-55.0)
	UprightLiftStrength=500.0
	UprightTorqueStrength=400.0
	bCanFlip=true
	bSeparateTurretFocus=true
	bHasHandbrake=true
	GroundSpeed=900
	AirSpeed=1000
	MaxSpeed=1300
	ObjectiveGetOutDist=1500.0
	LookSteerSensitivity=2.2
	LookSteerDamping=0.04
	ConsoleSteerScale=0.9
	DeflectionReverseThresh=-0.3
	bLookSteerOnNormalControls=true
	bLookSteerOnSimpleControls=true

	DeployCheckDistance=375.0

    VisibleGroundSpeed=900
	VisibleAirSpeed=1000
	VisibleMaxSpeed=1300
	CloakedSpeedModifier=0.45
	SlowSpeed=300

	Begin Object Class=UTVehicleSimHellbender Name=SimObject
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Class=UTVehicleHellbenderWheel Name=RRWheel
		BoneName="Rt_Rear_Tire"
		BoneOffset=(X=0.0,Y=42.0,Z=0.0)
		SkelControlName="Rt_Rear_Control"
		LatSlipFactor=2.0
	End Object
	Wheels(0)=RRWheel

	Begin Object Class=UTVehicleHellbenderWheel Name=LRWheel
		BoneName="Lt_Rear_Tire"
		BoneOffset=(X=0.0,Y=-42.0,Z=0.0)
		SkelControlName="Lt_Rear_Control"
		LatSlipFactor=2.0
	End Object
	Wheels(1)=LRWheel

	Begin Object Class=UTVehicleHellbenderWheel Name=RFWheel
		BoneName="Rt_Front_Tire"
		BoneOffset=(X=0.0,Y=42.0,Z=0.0)
		SteerFactor=1.0
		SkelControlName="RT_Front_Control"
		LongSlipFactor=2.0
		LatSlipFactor=2.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
	End Object
	Wheels(2)=RFWheel

	Begin Object Class=UTVehicleHellbenderWheel Name=LFWheel
		BoneName="Lt_Front_Tire"
		BoneOffset=(X=0.0,Y=-42.0,Z=0.0)
		SteerFactor=1.0
		SkelControlName="Lt_Front_Control"
		LongSlipFactor=2.0
		LatSlipFactor=2.0
		HandbrakeLongSlipFactor=0.8
		HandbrakeLatSlipFactor=0.8
	End Object
	Wheels(3)=LFWheel

	TeamBeaconOffset=(z=60.0)
	SpawnRadius=125.0

	bReducedFallingCollisionDamage=true
	ViewPitchMin=-13000
	BaseEyeheight=0
	Eyeheight=0
	bStickDeflectionThrottle=true
	HeavySuspensionShiftPercent=0.2

	MomentumMult=1.0
	NonPreferredVehiclePathMultiplier=2.0

	HornIndex=1
	VehicleIndex=12
}
