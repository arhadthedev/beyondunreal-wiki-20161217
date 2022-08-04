/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_NightShade extends UTStealthVehicle
	native(Vehicle)
	abstract;

/* Control visible dust underneath the nightshade */
var ParticleSystemComponent HoverDustPSC;



/**
 * function cloaks or decloaks the vehicle.
 */
simulated function Cloak(bool bIsEnabled, optional bool bForce=FALSE)
{
	super.Cloak(bIsEnabled, bForce);

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if (!bIsEnabled && bDriving)
		{
			//This param relates to back<->fwd movement (-5,0,5)
			//since the Nightshade is only visible while deployed
			//and not moving, 0 seems appropriate always
			HoverDustPSC.SetFloatParameter('Direction',0);
			HoverDustPSC.ActivateSystem();
		}
		else
		{
			HoverDustPSC.DeactivateSystem();
		}
	}
}

/**
 * Called when the vehicle is destroyed.  Clean up the seats/effects/etc
 */
simulated function Destroyed()
{
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		HoverDustPSC.DeactivateSystem();
	}
	super.Destroyed();
}

defaultproperties
{
	Health=600

	COMOffset=(x=0.0,y=0.0,z=-55.0)
	UprightLiftStrength=500.0
	UprightTorqueStrength=400.0
	bCanFlip=true
	bSeparateTurretFocus=true
	GroundSpeed=900
	AirSpeed=1000
	MaxSpeed=1300
	ObjectiveGetOutDist=1500.0
	bCanStrafe=true
	bTurnInPlace=true

	VisibleGroundSpeed=900
	VisibleAirSpeed=1000
	VisibleMaxSpeed=1300
	CloakedSpeedModifier=0.45
	SlowSpeed=300.0

	Begin Object Class=UTVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=50.0
		WheelSuspensionDamping=1.0
		WheelSuspensionBias=0.0
		MaxThrustForce=600.0
		MaxReverseForce=600.0
		LongDamping=0.3
		MaxStrafeForce=600.0
		LatDamping=1.2
		MaxRiseForce=0.0
		UpDamping=0.7
		TurnTorqueFactor=4500.0
		TurnTorqueMax=1500.0
		TurnDamping=0.5
		MaxYawRate=1.6
		PitchTorqueMax=35.0
		PitchDamping=0.1
		RollTorqueMax=50.0
		RollDamping=0.1
		MaxRandForce=0.0
		RandForceInterval=1000.0
		PitchTorqueFactor=0.0
		RollTorqueTurnFactor=0.0
		RollTorqueStrafeFactor=0.0
		bAllowZThrust=false
		bStabilizeStops=true
		StabilizationForceMultiplier=1.0
		bFullThrustOnDirectionChange=true
		bDisableWheelsWhenOff=true
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Class=UTHoverWheel Name=LFThruster
		BoneName="Base"
		BoneOffset=(X=120,Y=80,Z=-200)
		WheelRadius=20
		SuspensionTravel=120
		bPoweredWheel=false
		SteerFactor=1.0
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		bHoverWheel=true
	End Object
	Wheels(0)=LFThruster

	Begin Object Class=UTHoverWheel Name=RFThruster
		BoneName="Base"
		BoneOffset=(X=120,Y=-80,Z=-200)
		WheelRadius=20
		SuspensionTravel=120
		bPoweredWheel=false
		SteerFactor=1.0
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		bHoverWheel=true
	End Object
	Wheels(1)=RFThruster

	Begin Object Class=UTHoverWheel Name=LRThruster
		BoneName="Base"
		BoneOffset=(X=-120,Y=80,Z=-200)
		WheelRadius=20
		SuspensionTravel=120
		bPoweredWheel=false
		SteerFactor=1.0
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		bHoverWheel=true
	End Object
	Wheels(2)=LRThruster

	Begin Object Class=UTHoverWheel Name=RRThruster
		BoneName="Base"
		BoneOffset=(X=-120,Y=-80,Z=-200)
		WheelRadius=20
		SuspensionTravel=120
		bPoweredWheel=false
		SteerFactor=1.0
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		bHoverWheel=true
	End Object
	Wheels(3)=RRThruster

	TeamBeaconOffset=(z=60.0)
	SpawnRadius=125.0

	bReducedFallingCollisionDamage=true
	ViewPitchMin=-13000
	BaseEyeheight=0
	Eyeheight=0

	bStealthVehicle=true
	RespawnTime=45.0
	bStickDeflectionThrottle=true

	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=2000
	StayUprightDamping=20

	MaxDeploySpeed=500.0
	DeployCheckDistance=375.0;
	bRequireAllWheelsOnGround=false
	
	bIsNecrisVehicle=true

	HornIndex=2
}
