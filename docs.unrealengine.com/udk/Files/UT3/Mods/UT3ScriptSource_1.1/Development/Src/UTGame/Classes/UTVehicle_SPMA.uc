/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_SPMA extends UTVehicle_Deployable
	native(Vehicle)
	abstract;

/** Treads */
var protected private transient	MaterialInstanceConstant TreadMaterialInstance;
/** material parameter controlling tread panner speed */
var name TreadSpeedParameterName;

/** These values are used in positioning the weapons */
var repnotify	rotator	GunnerWeaponRotation;
var	repnotify	vector	GunnerFlashLocation;
var	repnotify	byte	GunnerFlashCount;
var repnotify	byte	GunnerFiringMode;

/** Helpers for quick access to the constraint system */
var UTSkelControl_TurretConstrained GunnerConstraint;

var name LeftBigWheel, LeftSmallWheels[3];
var name RightBigWheel, RightSmallWheels[3];

/** Used to calculate small wheel rotation speed based on track speed. */
var float SmallWheelSpinFactor;

/** Used to pan the texture on the treads */
var float TreadPan;

var(DC) float DeployedCameraScale;
var(DC) vector DeployedCameraOffset;
var bool bTransitionCameraScale;

/** Controls */
var SkelControlSingleBone RightLegAdjustControl, LeftLegAdjustControl;
var SkelControlSingleBone RightFootControl, LeftFootControl;

var() float IdealLegDist;

var() float LegAdjustScaling;



replication
{
	if (bNetDirty)
		GunnerFlashLocation;
	if (!IsSeatControllerReplicationViewer(1))
		GunnerFlashCount, GunnerFiringMode, GunnerWeaponRotation;
}

native simulated function vector GetTargetLocation(optional Actor RequestedBy, optional bool bRequestAlternateLoc);

simulated function PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if(SkelComp == Mesh)
	{
		RightLegAdjustControl = SkelControlSingleBone( mesh.FindSkelControl('RightLegAdjust') );
		LeftLegAdjustControl = SkelControlSingleBone( mesh.FindSkelControl('LeftLegAdjust') );
		RightFootControl = SkelControlSingleBone( mesh.FindSkelControl('RightFoot') );
		LeftFootControl = SkelControlSingleBone( mesh.FindSkelControl('LeftFoot') );
	}
}

simulated function SwitchWeapon(byte NewGroup)
{
	if ( (DeployedState == EDS_Deployed) || (DeployedState == EDS_Deploying) )
	{
		ServerChangeSeat(NewGroup-1);
	}
}

/**
request change to adjacent vehicle seat
*/
simulated function AdjacentSeat(int Direction, Controller C)
{
	if ( (DeployedState == EDS_Deployed) || (DeployedState == EDS_Deploying) )
	{
		ServerAdjacentSeat(Direction, C);
	}
}

function bool IsDriverSeat(Vehicle TestSeatPawn)
{
	// driver gets seat 1 when deployed
	return (Seats[0].SeatPawn == TestSeatPawn || Seats[1].SeatPawn == TestSeatPawn);
}

function bool OpenPositionFor(Pawn P)
{
	// ignore extra seat because driver controls it as well
	return !Occupied();
}

/**
 * CanEnterVehicle()
 * SPMAs only let one player in even though they have two seats
 * @return true if Pawn P is allowed to enter this vehicle
 */
simulated function bool CanEnterVehicle(Pawn P)
{
	local int i;
	local bool bIsHuman;
	local PlayerReplicationInfo SeatPRI;

	if ( !super.CanEnterVehicle(P) )
	{
		return false;
	}

	// check for available seat, and no enemies in vehicle
	// allow humans to enter if full but with bots (TryToDrive() will kick one out if possible)
	bIsHuman = P.IsHumanControlled();
	for (i=0;i<Seats.Length;i++)
	{
		SeatPRI = GetSeatPRI(i);
		if ( (SeatPRI != None) && (!bIsHuman || !SeatPRI.bBot) )
		{
			return false;
		}
	}
	return true;
}

function bool AnySeatAvailable()
{
	local int i;
	local bool bSeatAvailable;

	for (i = 0; i < Seats.length; i++)
	{
		if (Seats[i].SeatPawn != None)
		{
			if (Seats[i].SeatPawn.Controller == None)
			{
				bSeatAvailable = true;
			}
			else
			{
				return false;
			}
		}
	}

	return bSeatAvailable;
}

/** If deployed, enter into main gun seat */
function bool DriverEnter(Pawn P)
{
	if ( (DeployedState == EDS_Deployed) || (DeployedState == EDS_Deploying) )
	{
		if ( (Driver == None) && (Seats[1].SeatPawn.Controller == None) )
		{
			if ( Team != P.GetTeamNum() )
			{
				//add stat tracking event/variable here?
				if ( Team != 255 && PlayerController(P.Controller) != None )
				{
					PlayerController(P.Controller).ReceiveLocalizedMessage( class'UTVehicleMessage', StolenAnnouncementIndex);
					UTPlayerReplicationInfo(P.PlayerReplicationInfo).IncrementEventStat('EVENT_HIJACKED');
					if( StolenSound != None )
						PlaySound(StolenSound);
				}
				if ( P.GetTeamNum() != 255 )
					SetTeamNum( P.GetTeamNum() );
			}
		}
		return PassengerEnter(P, 1);
	}
	return Super.DriverEnter(P);
}

simulated function DeployedStateChanged()
{
	super.DeployedStateChanged();

	switch (DeployedState)
	{
	case EDS_Deploying:
		if ( IsLocallyControlled() )
		{
			ServerChangeSeat(1);
		}
		break;

	case EDS_UnDeploying:
		if ( Seats[1].SeatPawn.IsLocallyControlled() )
		{
			UTVehicleBase(Seats[1].SeatPawn).ServerChangeSeat(0);
		}
		break;
	}
}

simulated function SetVehicleDeployed()
{
	local vector TraceStart, TraceEnd, HitLocation, HitNormal, LocalY;
	local float GroundDist, Error, FootAdjust;
	local Actor HitActor;

	Super.SetVehicleDeployed();

	// Left leg
	TraceStart = Mesh.GetBoneLocation('LtFrontLegUp', 0) + (vect(0,-35,0) >> Rotation);
	TraceEnd = TraceStart + ((150.0 * vect(0,-0.7,-1)) >> Rotation);
	//DrawDebugLine(TraceStart, TraceEnd, 255, 0, 0, TRUE);
	HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, TRUE);

	// Make unit vector for y axis in local space
	LocalY = (vect(0,1,0) >> Rotation);

	if(HitActor != None)
	{
		GroundDist = VSize(TraceStart - HitLocation);
		Error = (IdealLegDist - GroundDist);
		// Look at how much the hit normal leans along Y, and use that to tilt foot
		FootAdjust = ASin(HitNormal Dot LocalY) * 10430.2;
		//`log("L ERROR:"@Error@"FOOT"@FootAdjust);

		LeftLegAdjustControl.BoneRotation.Roll = Error * LegAdjustScaling;
		LeftLegAdjustControl.SetSkelControlActive(TRUE);
		LeftFootControl.BoneRotation.Roll = FootAdjust;
		LeftFootControl.SetSkelControlActive(TRUE);
	}

	// Right leg
	TraceStart = Mesh.GetBoneLocation('RtFrontLegUp', 0) + (vect(0,35,0) >> Rotation);
	TraceEnd = TraceStart + ((150.0 * vect(0,0.7,-1)) >> Rotation);
	//DrawDebugLine(TraceStart, TraceEnd, 255, 0, 0, TRUE);
	HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, TRUE);

	if(HitActor != None)
	{
		GroundDist = VSize(TraceStart - HitLocation);
		Error = (IdealLegDist - GroundDist);
		FootAdjust = ASin(HitNormal Dot LocalY) * 10430.2;
		//`log("R ERROR:"@Error@"FOOT"@FootAdjust);

		RightLegAdjustControl.BoneRotation.Roll = -1.0 * Error * LegAdjustScaling;
		RightLegAdjustControl.SetSkelControlActive(TRUE);
		RightFootControl.BoneRotation.Roll = FootAdjust;
		RightFootControl.SetSkelControlActive(TRUE);
	}
}

simulated function SetVehicleUndeploying()
{
	Super.SetVehicleUndeploying();

	// Turn off leg adjustment controls
	LeftLegAdjustControl.SetSkelControlActive(FALSE);
	RightLegAdjustControl.SetSkelControlActive(FALSE);
	LeftFootControl.SetSkelControlActive(FALSE);
	RightFootControl.SetSkelControlActive(FALSE);
}

/**
 * Setup the helpers
 */
simulated function PostBeginPlay()
{
	local MaterialInterface TreadMaterial;

	Super.PostBeginPlay();

	if ( bDeleteMe )
		return;

	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
	{
		// set up material instance (for overlay effects)
		TreadMaterial = Mesh.GetMaterial(1);
		if ( TreadMaterial != None )
		{
			TreadMaterialInstance = new(Outer) class'MaterialInstanceConstant';
			Mesh.SetMaterial(1, TreadMaterialInstance);
			TreadMaterialInstance.SetParent(TreadMaterial);
		}
	}
}

simulated function VehicleCalcCamera(float DeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
{
	local float RealSeatCameraScale;
	local float TimeSinceTransition;

	RealSeatCameraScale = SeatCameraScale;
	if ( DeployedState == EDS_Deployed || DeployedState == EDS_Deploying )
	{
		bTransitionCameraScale = true;
		TimeSinceTransition = WorldInfo.TimeSeconds - LastDeployStartTime;
		if ( TimeSinceTransition < DeployTime )
		{
			SeatCameraScale = (DeployedCameraScale*TimeSinceTransition + SeatCameraScale*(DeployTime-TimeSinceTransition))/DeployTime;
			Seats[1].CameraBaseOffset = DeployedCameraOffset * TimeSinceTransition/DeployTime;
		}
		else
		{
			Seats[1].CameraBaseOffset = DeployedCameraOffset;
			SeatCameraScale = DeployedCameraScale;
		}
	}
	else if ( bTransitionCameraScale )
	{
		TimeSinceTransition = WorldInfo.TimeSeconds- LastDeployStartTime;
		if ( TimeSinceTransition < UnDeployTime )
		{
			SeatCameraScale = (SeatCameraScale*TimeSinceTransition + DeployedCameraScale*(UnDeployTime-TimeSinceTransition))/UnDeployTime;
			Seats[1].CameraBaseOffset = DeployedCameraOffset * (UnDeployTime - TimeSinceTransition)/UnDeployTime;
		}
		else
		{
			bTransitionCameraScale = false;
		}
	}
	super.VehicleCalcCamera(DeltaTime, SeatIndex, out_CamLoc, out_CamRot, CamStart, bPivotOnly);
	SeatCameraScale = RealSeatCameraScale;
	Seats[1].CameraBaseOffset = vect(0,0,0);
}

native function Actor GetAlternateLockTarget();

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

function DriverLeft()
{
	local UTVWeap_SPMACannon Gun;

	Super.DriverLeft();

	Gun = UTVWeap_SPMACannon(Seats[1].Gun);
	if (Gun != None && Gun.RemoteCamera != None )
	{
		Gun.RemoteCamera.Disconnect();
	}
}

function bool CanAttack(Actor Other)
{
	local Pawn P;

	// if far away or objective, check if can hit with deployed artillery
	if ( DeployedState == EDS_Undeployed && (Controller.PlayerReplicationInfo.Team == None || Controller.PlayerReplicationInfo.Team.Size > 1) &&
		VSize(Other.Location - Location) > 1000.0 && (VSize(Velocity) > MaxDeploySpeed || CanDeploy()) && (Other.IsA('Pawn') || Other.IsA('UTGameObjective')) )
	{
		P = Pawn(Other);
		if ( (P == None || P.bStationary || (!P.bCanFly && VSize(Other.Location - Location) > 5000.0)) &&
			Seats[1].Gun.CanAttack(Other) )
		{
			SetTimer(0.01, false, 'ServerToggleDeploy');
			return true;
		}
	}

	return Super.CanAttack(Other);
}

function bool BotFire(bool bFinished)
{
	// don't let bot fire if we already decided to deploy, so it doesn't fail because of that
	return (IsTimerActive('ServerToggleDeploy') ? false : Super.BotFire(bFinished));
}

function bool IsArtillery()
{
	return true;
}

function PassengerLeave(int SeatIndex)
{
	local UTVWeap_SPMACannon Gun;

	Super.PassengerLeave(SeatIndex);

	Gun = UTVWeap_SPMACannon(Seats[1].Gun);

	if ( Gun != none && Gun.RemoteCamera != none )
	{
		Gun.RemoteCamera.Disconnect();
	}
}

simulated state UnDeploying
{
	simulated function BeginState(name PreviousStateName)
	{
		local UTVWeap_SPMACannon Gun;

		Super.BeginState(PreviousStateName);

		Gun = UTVWeap_SPMACannon(Seats[1].Gun);
		if (Gun != none && Gun.RemoteCamera != none)
		{
			Gun.RemoteCamera.Disconnect();
		}
	}
}

/**
 *	Because WeaponRotation is used to drive seat 1 - it will be replicated when you are in the big turret because bNetOwner is FALSE.
 *	We don't want it replicated though, so we discard it when we receive it.
 */
simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'WeaponRotation' && Seats[1].SeatPawn != None && Seats[1].SeatPawn.Controller != None )
	{
		return;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function bool ShouldClamp()
{
	return false;
}

defaultproperties
{
	Health=800
	MaxDesireability=0.6
	MomentumMult=0.3
	bCanFlip=false
	bTurnInPlace=false
	bCanStrafe=false
	bSeparateTurretFocus=true
	GroundSpeed=650
	MaxSpeed=1000
	BaseEyeheight=0
	Eyeheight=0
	bLookSteerOnNormalControls=true
	bLookSteerOnSimpleControls=true
	bAcceptTurretJump=true

	COMOffset=(x=0.0,y=0.0,z=-100.0)

	Begin Object Class=UTVehicleSimCar Name=SimObject
		WheelSuspensionStiffness=300.0
		WheelSuspensionDamping=7.0
		WheelSuspensionBias=0.0
		ChassisTorqueScale=0.1
		WheelInertia=0.9
		MaxSteerAngleCurve=(Points=((InVal=0,OutVal=20.0),(InVal=700.0,OutVal=15.0)))
		SteerSpeed=40
		MaxBrakeTorque=15.0
		StopThreshold=500
		TorqueVSpeedCurve=(Points=((InVal=-300.0,OutVal=0.0),(InVal=0.0,OutVal=120.0),(InVal=700.0,OutVal=0.0)))
		EngineRPMCurve=(Points=((InVal=-500.0,OutVal=2500.0),(InVal=0.0,OutVal=500.0),(InVal=599.0,OutVal=5000.0),(InVal=600.0,OutVal=3000.0),(InVal=949.0,OutVal=5000.0),(InVal=950.0,OutVal=3000.0),(InVal=1100.0,OutVal=5000.0)))
		EngineBrakeFactor=0.1
		HardTurnMotorTorque=1.0
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Class=UTVehicleWheel Name=RFWheel
		BoneName="RtFrontTire"
		BoneOffset=(X=0.0,Y=33,Z=5.0)
		WheelRadius=60
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=1.0
		SkelControlName="Rt_Ft_Tire"
		Side=SIDE_Right
	End Object
	Wheels(0)=RFWheel

	Begin Object Class=UTVehicleWheel Name=LFWheel
		BoneName="LtFrontTire"
		BoneOffset=(X=0.0,Y=-33,Z=5.0)
		WheelRadius=60
		SuspensionTravel=60
		bPoweredWheel=true
		SteerFactor=1.0
		SkelControlName="Lt_Ft_Tire"
		Side=SIDE_Left
	End Object
	Wheels(1)=LFWheel

	Begin Object Class=UTVehicleWheel Name=RRWheel
		BoneName="RtTread_Wheel3"
		BoneOffset=(X=25.0,Y=0,Z=15.0)
		WheelRadius=60
		SuspensionTravel=45
		bPoweredWheel=true
		SteerFactor=0.0
		Side=SIDE_Right
	End Object
	Wheels(2)=RRWheel

	Begin Object Class=UTVehicleWheel Name=LRWheel
		BoneName="LtTread_Wheel3"
		BoneOffset=(X=25.0,Y=0,Z=15.0)
		WheelRadius=60
		SuspensionTravel=45
		bPoweredWheel=true
		SteerFactor=0.0
		Side=SIDE_Left
	End Object
	Wheels(3)=LRWheel

	LeftBigWheel="LfFrontTire"
	LeftSmallWheels(0)="Lt_Tread_Wheels_1_4"
	LeftSmallWheels(1)="Lt_Tread_Wheel2"
	LeftSmallWheels(2)="Lt_Tread_Wheel3"

	RightBigWheel="RtFrontTire"
	RightSmallWheels(0)="Rt_Tread_Wheels_1_4"
	RightSmallWheels(1)="Rt_Tread_Wheel2"
	RightSmallWheels(2)="Rt_Tread_Wheel3"

	SmallWheelSpinFactor=800.0;

	TurnTime=2.0

	RespawnTime=45.0

	bStickDeflectionThrottle=true

	DeployedCameraScale=2.5
	DeployedCameraOffset=(Z=100)
	HUDExtent=140.0

	IdealLegDist=88.0;
	LegAdjustScaling=100.0;

	AIPurpose=AIP_Any
	NonPreferredVehiclePathMultiplier=2.0
	bHasAlternateTargetLocation=true

	HornIndex=1
}
