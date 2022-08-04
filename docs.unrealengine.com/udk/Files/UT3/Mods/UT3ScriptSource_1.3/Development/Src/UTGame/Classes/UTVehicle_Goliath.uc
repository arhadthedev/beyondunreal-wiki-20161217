/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTVehicle_Goliath extends UTVehicle
	native(Vehicle)
	abstract;

var protected MaterialInstanceConstant LeftTreadMaterialInstance, RightTreadMaterialInstance, LeftTeamMaterials[2], RightTeamMaterials[2];
/** material parameter controlling tread panner speed */
var name TreadSpeedParameterName;

var repnotify	rotator	GunnerWeaponRotation;
var	repnotify	vector	GunnerFlashLocation;

var name LeftBigWheel, LeftSmallWheels[3];
var name RightBigWheel, RightSmallWheels[3];

/** ambient sound component for machine gun */
var AudioComponent MachineGunAmbient;

/** Sound to play when maching gun stops firing. */
var SoundCue MachineGunStopSound;

var AudioComponent	TrackSound;
var float			TrackSoundParamScale;

var name			VolumeParamName;
var name			PitchParamName;

var float LeftTreadSpeed, RightTreadSpeed;

var SkeletalMeshComponent AntennaMesh;

/** The Cantilever Beam that is the Antenna itself*/
var UTSkelControl_CantileverBeam AntennaBeamControl;



replication
{
	if (bNetDirty)
		GunnerFlashLocation;
	if (!IsSeatControllerReplicationViewer(1))
		GunnerWeaponRotation;
}

simulated function TeamChanged()
{
	if(LeftTreadMaterialInstance != none)
	{
		LeftTreadMaterialInstance.SetParent(LeftTeamMaterials[Team==1?1:0]);
	}
	if(RightTreadMaterialInstance != none)
	{
		RightTreadMaterialInstance.SetParent(RightTeamMaterials[Team==1?1:0]);
	}
	Super.TeamChanged();
}

/** For Antenna delegate purposes (let's turret motion be more dramatic)*/
function vector GetVelocity()
{
	return Velocity;
}

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
	Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);

	if (SeatIndex == 1 && !MachineGunAmbient.bWasPlaying)
	{
		MachineGunAmbient.Play();
	}
}

simulated function VehicleWeaponStoppedFiring(bool bViaReplication, int SeatIndex)
{
	if (SeatIndex == 1)
	{
		MachineGunAmbient.Stop();
		PlaySound(MachineGunStopSound, TRUE, FALSE, FALSE, Location, FALSE);
	}
}

simulated function StartEngineSound()
{
	Super.StartEngineSound();

	if(TrackSound != None)
	{
		TrackSound.Play();
	}
}

simulated function StopEngineSound()
{
	Super.StopEngineSound();

	if(TrackSound != None)
	{
		TrackSound.Stop();
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

simulated function GetSVehicleDebug( out Array<String> DebugInfo )
{
    DebugInfo[DebugInfo.Length] = "----Vehicle----: ";
	DebugInfo[DebugInfo.Length] = "Speed: "$VSize(Velocity)$" UUPS -- "$VSize(Velocity) * 0.0426125$" MPH";
	DebugInfo[DebugInfo.Length] = "LeftTrackTorque: "$SVehicleSimTank(SimObj).LeftTrackTorque;
	DebugInfo[DebugInfo.Length] = "RightTrackTorque: "$SVehicleSimTank(SimObj).RightTrackTorque;
	DebugInfo[DebugInfo.Length] = "LeftTrackVel: "$SVehicleSimTank(SimObj).LeftTrackVel;
	DebugInfo[DebugInfo.Length] = "RightTrackVel: "$SVehicleSimTank(SimObj).RightTrackVel;
	DebugInfo[DebugInfo.Length] = "Throttle: "$OutputGas;
	DebugInfo[DebugInfo.Length] = "Steering: "$OutputSteering;
	DebugInfo[DebugInfo.Length] = "Brake: "$OutputBrake;
}

simulated function DisplayWheelsDebug(HUD HUD, float YL)
{
    local int i;
    local vector WorldLoc, ScreenLoc, X, Y, Z, EndPoint, ScreenEndPoint;
    local Color SaveColor;

    SaveColor = HUD.Canvas.DrawColor;

	for (i=0; i<Wheels.Length; i++)
	{
	GetAxes(Rotation, X, Y, Z);
	WorldLoc =  Location + (Wheels[i].WheelPosition >> Rotation);
	ScreenLoc = HUD.Canvas.Project(WorldLoc);
	if (ScreenLoc.X >= 0 &&	ScreenLoc.X < HUD.Canvas.ClipX &&
		ScreenLoc.Y >= 0 && ScreenLoc.Y < HUD.Canvas.ClipY)
    	{
	    // Draw Text
	    HUD.Canvas.SetPos(ScreenLoc.X, ScreenLoc.Y);
	    HUD.Canvas.DrawText("SR "$Wheels[i].LongSlipRatio);

	    // Draw Lines
	    HUD.Canvas.DrawColor = HUD.RedColor;
	    EndPoint = WorldLoc + (Wheels[i].LongImpulse * 100 * Wheels[i].LongDirection) - (Wheels[i].WheelRadius * Z);
	    ScreenEndPoint = HUD.Canvas.Project(EndPoint);
	    DrawDebugLine(WorldLoc - (Wheels[i].WheelRadius * Z), EndPoint, 255, 0, 0);
	    HUD.Canvas.SetPos(ScreenEndPoint.X, ScreenEndPoint.Y);
	    HUD.Canvas.DrawText(Wheels[i].LongImpulse);

	    HUD.Canvas.DrawColor = HUD.GreenColor;
	    EndPoint = WorldLoc + (Wheels[i].LatImpulse * 100 * Wheels[i].LatDirection) - (Wheels[i].WheelRadius * Z);
	    ScreenEndPoint = HUD.Canvas.Project(EndPoint);
	    DrawDebugLine(WorldLoc - (Wheels[i].WheelRadius * Z), EndPoint, 0, 255, 0);
	    HUD.Canvas.SetPos(ScreenEndPoint.X, ScreenEndPoint.Y);
	    HUD.Canvas.DrawText(Wheels[i].LatImpulse);
	}
    }

    HUD.Canvas.DrawColor = SaveColor;
}

defaultproperties
{
	Health=800
	MaxDesireability=0.8
	MomentumMult=0.3
	bCanFlip=false
	bTurnInPlace=true
	bCanStrafe=true
	bSeparateTurretFocus=true
	GroundSpeed=520
	MaxSpeed=900

	//bStickDeflectionThrottle=true
	bLookSteerOnNormalControls=false
	bLookSteerOnSimpleControls=true
	LeftStickDirDeadZone=0.1
	LookSteerDeadZone=0.05
	LookSteerSensitivity=3.0
	ConsoleSteerScale=2.0

	TeamBeaconOffset=(z=130.0)

	COMOffset=(x=-20.0,y=0.0,z=-30.0)
	InertiaTensorMultiplier=(x=1.0,y=1.0,z=1.0)

	VolumeParamName=VolumeModulationParam
	PitchParamName=PitchModulationParam

	Begin Object Name=SVehicleMesh
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled1=TRUE,Untitled4=TRUE)
	End Object

	Begin Object Class=UTVehicleSimTank Name=SimObject
		WheelSuspensionStiffness=500.0
		WheelSuspensionDamping=40.0
		WheelSuspensionBias=0.1
		WheelLongExtremumSlip=1.5
		ChassisTorqueScale=0.0
		StopThreshold=50
		EngineDamping=4.1
		InsideTrackTorqueFactor=0.25
		TurnInPlaceThrottle=0.5
		FrontalCollisionGripFactor=0.18
		TurnMaxGripReduction=0.97
		TurnGripScaleRate=1.0
		MaxEngineTorque=7800.0
		EqualiseTrackSpeed=10.0
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Class=UTVehicleWheel Name=RRWheel
		BoneName="wheel_RHS_02"
		BoneOffset=(X=0.0,Y=20,Z=0.0)
		WheelRadius=30
		SuspensionTravel=45
		SteerFactor=1.0
		LongSlipFactor=250.0
		LatSlipFactor=20000.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		SkelControlName="wheel_RHS_02_Cont"
		Side=SIDE_Right
		bUseMaterialSpecificEffects=true
		EffectDesiredSpinDir=1.0
	End Object
	Wheels(0)=RRWheel

	Begin Object Class=UTVehicleWheel Name=RMWheel
		BoneName="wheel_RHS_04"
		BoneOffset=(X=-50.0,Y=20,Z=0.0)
		WheelRadius=30
		SuspensionTravel=45
		SteerFactor=0.0
		LongSlipFactor=250.0
		LatSlipFactor=20000.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		SkelControlName="wheel_RHS_04_Cont"
		Side=SIDE_Right
	End Object
	Wheels(1)=RMWheel

	Begin Object Class=UTVehicleWheel Name=RFWheel
		BoneName="wheel_RHS_05"
		BoneOffset=(X=0.0,Y=20,Z=0.0)
		WheelRadius=30
		SuspensionTravel=45
		SteerFactor=1.0
		LongSlipFactor=250.0
		LatSlipFactor=20000.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		SkelControlName="wheel_RHS_05_Cont"
		Side=SIDE_Right
		bUseMaterialSpecificEffects=true
		EffectDesiredSpinDir=-1.0
	End Object
	Wheels(2)=RFWheel

	Begin Object Class=UTVehicleWheel Name=LRWheel
		BoneName="wheel_LHS_02"
		BoneOffset=(X=0.0,Y=-20,Z=0.0)
		WheelRadius=30
		SuspensionTravel=45
		SteerFactor=1.0
		LongSlipFactor=250.0
		LatSlipFactor=20000.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		SkelControlName="wheel_LHS_02_Cont"
		Side=SIDE_Left
		bUseMaterialSpecificEffects=true
		EffectDesiredSpinDir=1.0
	End Object
	Wheels(3)=LRWheel

	Begin Object Class=UTVehicleWheel Name=LMWheel
		BoneName="wheel_LHS_04"
		BoneOffset=(X=-50.0,Y=-20,Z=0.0)
		WheelRadius=30
		SuspensionTravel=45
		SteerFactor=0.0
		LongSlipFactor=250.0
		LatSlipFactor=20000.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		SkelControlName="wheel_LHS_04_Cont"
		Side=SIDE_Left
	End Object
	Wheels(4)=LMWheel

	Begin Object Class=UTVehicleWheel Name=LFWheel
		BoneName="wheel_LHS_05"
		BoneOffset=(X=0.0,Y=-20,Z=0.0)
		WheelRadius=30
		SuspensionTravel=45
		SteerFactor=1.0
		LongSlipFactor=250.0
		LatSlipFactor=20000.0
		HandbrakeLongSlipFactor=250.0
		HandbrakeLatSlipFactor=1000.0
		SkelControlName="wheel_LHS_05_Cont"
		Side=SIDE_Left
		bUseMaterialSpecificEffects=true
		EffectDesiredSpinDir=-1.0
	End Object
	Wheels(5)=LFWheel

	LeftBigWheel="wheel_LHS_01_Cont"
	LeftSmallWheels(0)="wheel_LHS_03_Cont"
	LeftSmallWheels(1)="wheel_LHS_04_Cont"
	LeftSmallWheels(2)="Whell_LHS_06_07_08_Cont"

	RightBigWheel="wheel_RHS_01_Cont"
	RightSmallWheels(0)="wheel_RHS_03_Cont"
	RightSmallWheels(1)="wheel_RHS_04_Cont"
	RightSmallWheels(2)="Wheel_RHS_06_07_08_Cont"

	TurnTime=2.0

	RespawnTime=45.0

	ViewPitchMin=-13000
	HUDExtent=180.0
	NonPreferredVehiclePathMultiplier=3.0

	HornIndex=1
}
