/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_DarkWalker extends UTVehicle_Walker
	native(Vehicle)
	abstract;

var repnotify byte TurretFlashCount;
var repnotify rotator TurretWeaponRotation;
var byte TurretFiringMode;

var particleSystem BeamTemplate;

/** Holds the Emitter for the Beam */
var ParticleSystemComponent BeamEmitter[2];

/** Where to attach the Beam */
var name BeamSockets[2];

/** The name of the EndPoint parameter */
var name EndPointParamName;

var protected AudioComponent BeamAmbientSound;
var SoundCue BeamFireSound;

var float WarningConeMaxRadius;
var float LengthDarkWalkerWarningCone;
var AudioComponent WarningConeSound;
var name ConeParam;

var ParticleSystemComponent EffectEmitter;

var actor LastHitActor;

var bool bIsBeamActive;

/** radius to allow players under this darkwalker to gain entry */
var float CustomEntryRadius;

/** When asleep, monitor distance below darkwalker to make sure it isn't in the air. */
var float LastSleepCheckDistance;

/** Disable aggressive sleeping behaviour. */
var bool bSkipAggresiveSleep;

var float CustomGravityScaling;

/** @hack: replicated copy of bHoldingDuck for clients */
var bool bIsDucking;



replication
{
	if (!bNetOwner)
		bIsDucking;
	if (!IsSeatControllerReplicationViewer(1))
		TurretFlashCount, TurretWeaponRotation;
}

native simulated final function PlayWarningSoundIfInCone(Pawn Target);

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	AddBeamEmitter();
	SetTimer(1.0, TRUE, 'SleepCheckGroundDistance');
}

simulated event Destroyed()
{
	super.Destroyed();
	KillBeamEmitter();
	ClearTimer('SleepCheckGroundDistance');
}

simulated function SleepCheckGroundDistance()
{
	local vector HitLocation, HitNormal;
	local actor HitActor;
	local float SleepCheckDistance;

	bSkipAggresiveSleep = FALSE;

	if(!bDriving && !Mesh.RigidBodyIsAwake())
	{
		HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,1000), Location, TRUE);

		SleepCheckDistance = 1000.0;
		if(HitActor != None)
		{
			SleepCheckDistance = VSize(HitLocation - Location);
		}

		// If distance has changed, wake it
		if(Abs(SleepCheckDistance - LastSleepCheckDistance) > 10.0)
		{
			Mesh.WakeRigidBody();
			bSkipAggresiveSleep = TRUE;
			LastSleepCheckDistance = SleepCheckDistance;
		}
	}
}

simulated function AddBeamEmitter()
{
	local int i;
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		for (i=0;i<2;i++)
		{
			if (BeamEmitter[i] == None)
			{
				if (BeamTemplate != None)
				{
					BeamEmitter[i] = new(Outer) class'UTParticleSystemComponent';
					BeamEmitter[i].SetTemplate(BeamTemplate);
					BeamEmitter[i].SecondsBeforeInactive=1.0f;
					BeamEmitter[i].SetHidden(true);
					Mesh.AttachComponentToSocket( BeamEmitter[i],BeamSockets[i] );
				}
			}
			else
			{
				BeamEmitter[i].ActivateSystem();
			}
		}
	}
}

simulated function KillBeamEmitter()
{
	local int i;
	for (i=0;i<2;i++)
	{
		if (BeamEmitter[i] != none)
		{
			//BeamEmitter[i].SetHidden(true);
			BeamEmitter[i].DeactivateSystem();
		}
	}
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	local int i;

	if (bHide && EffectEmitter != None)
	{
		EffectEmitter.SetActive(false);
	}
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if (bIsBeamActive != !bHide )
		{
			for (i=0; i<2; i++)
			{
					if (BeamEmitter[i] != none)
					{
						if(!bHide)
							BeamEmitter[i].SetHidden(bHide);
						else
							BeamEmitter[i].DeactivateSystem();
					}

					if (!bHide)
					{
						BeamAmbientSound.SoundCue = BeamFireSound;
						BeamAmbientSound.Play();
						BeamEmitter[i].ActivateSystem();
					}
					else
					{
						BeamAmbientSound.FadeOut(0.3f, 0.f);
					}
			}
		}
		bIsBeamActive = !bHide;
	}
}

/**
 * Detect the transition from vehicle to ground and vice versus and handle it
 */

simulated function actor FindWeaponHitNormal(out vector HitLocation, out Vector HitNormal, vector End, vector Start, out TraceHitInfo HitInfo)
{
	local Actor NewHitActor;

	NewHitActor = Super.FindWeaponHitNormal(HitLocation, HitNormal, End, Start, HitInfo);
	if (NewHitActor != LastHitActor && EffectEmitter != None)
	{
		EffectEmitter.SetActive(false);
	}
	LastHitActor = NewHitActor;
	return NewHitActor;
}


simulated function SpawnImpactEmitter(vector HitLocation, vector HitNormal, const out MaterialImpactEffect ImpactEffect, int SeatIndex)
{
	local rotator TmpRot;

	TmpRot = rotator(HitNormal);
	TmpRot.Pitch = NormalizeRotAxis(TmpRot.Pitch - 16384);

	if (EffectEmitter == None)
	{
		EffectEmitter = new(self) class'ParticleSystemComponent';
		EffectEmitter.SetTemplate(ImpactEffect.ParticleTemplate);
		EffectEmitter.SetAbsolute(true, true, true);
		EffectEmitter.SetScale(0.7);
		AttachComponent(EffectEmitter);
	}

	EffectEmitter.SetTranslation(HitLocation);
	EffectEmitter.SetRotation(TmpRot);
	EffectEmitter.SetActive(true);
}

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local int i;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	if ( SeatIndex == 0 )
	{
		SetBeamEmitterHidden(false);
		for(i=0;i<2;i++)
		{
			BeamEmitter[i].SetVectorParameter(EndPointParamName, HitLocation);
		}
	}
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
	if (SeatIndex == 0)
	{
		SetBeamEmitterHidden(true);
	}
}

/** notification from WalkerBody that foot just landed */
function TookStep(int LegIdx)
{
	EyeStepOffset = MaxEyeStepOffset * FMin(1.0,VSize(Velocity)/AirSpeed);
}

function PassengerLeave(int SeatIndex)
{
	Super.PassengerLeave(SeatIndex);

	SetDriving(NumPassengers() > 0);
}

function bool PassengerEnter(Pawn P, int SeatIndex)
{
	local bool b;

	b = Super.PassengerEnter(P, SeatIndex);
	SetDriving(NumPassengers() > 0);
	return b;
}

simulated function VehicleCalcCamera(float DeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
{
	local UTPawn P;

	if (SeatIndex == 1)
	{
		// Handle the fixed view
		P = UTPawn(Seats[SeatIndex].SeatPawn.Driver);
		if (P != None && P.bFixedView)
		{
			out_CamLoc = P.FixedViewLoc;
			out_CamRot = P.FixedViewRot;
			return;
		}

		out_CamLoc = GetCameraStart(SeatIndex);
		CamStart = out_CamLoc;
		out_CamRot = Seats[SeatIndex].SeatPawn.GetViewRotation();
		return;
	}

	Super.VehicleCalcCamera(DeltaTime, SeatIndex, out_CamLoc, out_CamRot, CamStart, bPivotOnly);
}


/**
*  Overloading this from SVehicle to avoid torquing the walker head.
*/
function AddVelocity( vector NewVelocity, vector HitLocation, class<DamageType> DamageType, optional TraceHitInfo HitInfo )
{
	// apply hit at location, not hitlocation
	Super.AddVelocity(NewVelocity, Location, DamageType, HitInfo);
}

/**
  * Let pawns standing under me get in, if I have a driver.
  */
function bool InCustomEntryRadius(Pawn P)
{
	return ( (P.Location.Z < Location.Z) && (VSize2D(P.Location - Location) < CustomEntryRadius)
		&& FastTrace(P.Location, Location) );
}

event WalkerDuckEffect();

simulated function BlowupVehicle()
{
	local vector Impulse;
	Super.BlowupVehicle();
	Impulse = Velocity; //LastTakeHitInfo;
	Impulse.Z = 0;
	if(IsZero(Impulse))
	{
		Impulse = vector(Rotation); // forward if no velocity.
	}
	Impulse *= 4000/VSize(Impulse);
	Mesh.SetRBLinearVelocity(Impulse);
	Mesh.SetRBAngularVelocity(VRand()*5, true);
	bStayUpright = false;
	bCanFlip=true;
}

simulated function bool ShouldClamp()
{
	return false;
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

defaultproperties
{
	Begin Object Name=SVehicleMesh
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled1=TRUE)
	End Object

	Begin Object Name=RB_BodyHandle
		LinearDamping=100.0
		LinearStiffness=99000.0
		AngularDamping=100.0
		AngularStiffness=99000.0
	End Object

	Health=1000
	MeleeRange=-100.0

	LegTraceOffset=(X=0,Y=0,Z=0)
	LegTraceZUpAmount=700

	COMOffset=(x=0,y=0.0,z=150)
	bCanFlip=false

	AirSpeed=350.0
	GroundSpeed=350.0

	bFollowLookDir=true
	bCanStrafe=true
	bTurnInPlace=true
	ObjectiveGetOutDist=750.0
	ExtraReachDownThreshold=450.0
	MaxDesireability=0.75
	SpawnRadius=125.0
	bNoZSmoothing=true
	BaseBodyOffset=(Z=0.0)
	LookForwardDist=40.0
	TeamBeaconOffset=(z=350.0)

	bUseSuspensionAxis=true

	bStayUpright=true
	StayUprightRollResistAngle=0.0			// will be "locked"
	StayUprightPitchResistAngle=0.0
	//StayUprightStiffness=10
	//StayUprightDamping=100

	WheelSuspensionTravel(WalkerStance_Standing)=600
	WheelSuspensionTravel(WalkerStance_Parked)=0
	WheelSuspensionTravel(WalkerStance_Crouched)=153
	SuspensionTravelAdjustSpeed=250
	HoverAdjust(WalkerStance_Standing)=-280.0
	HoverAdjust(WalkerStance_Parked)=0.0
	HoverAdjust(WalkerStance_Crouched)=-63.0

	Begin Object Class=UTVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=100.0
		WheelSuspensionDamping=40.0
		WheelSuspensionBias=0.0
		MaxThrustForce=600.0
		MaxReverseForce=600.0
		LongDamping=0.3
		MaxStrafeForce=600.0
		LatDamping=0.3
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=9000.0
		TurnTorqueMax=10000.0
		TurnDamping=3.0
		MaxYawRate=1.6
		PitchTorqueMax=35.0
		PitchDamping=0.1
		RollTorqueMax=50.0
		RollDamping=0.1
		MaxRandForce=0.0
		RandForceInterval=1000.0
		bCanClimbSlopes=true
		PitchTorqueFactor=0.0
		RollTorqueTurnFactor=0.0
		RollTorqueStrafeFactor=0.0
		bAllowZThrust=false
		bStabilizeStops=true
		StabilizationForceMultiplier=1.0
		bFullThrustOnDirectionChange=true
		bDisableWheelsWhenOff=false
		HardLimitAirSpeedScale=1.5
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Begin Object Class=UTHoverWheel Name=RThruster
		BoneName="BodyRoot"
		BoneOffset=(X=0,Y=0,Z=-20)
		WheelRadius=70
		SuspensionTravel=20
		bPoweredWheel=false
		SteerFactor=1.0
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		bCollidesVehicles=FALSE
	End Object
	Wheels(0)=RThruster

	RespawnTime=45.0

	LengthDarkWalkerWarningCone=7500

	HoverBoardAttachSockets=(HoverAttach00,HoverAttach01)

	bHasCustomEntryRadius=true
	CustomEntryRadius=300.0

	bIgnoreStallZ=TRUE
	HUDExtent=250.0

	MaxEyeStepOffset=48.0
	EyeStepFadeRate=2.0
	EyeStepBlendRate=2.0
	BaseEyeheight=0
	Eyeheight=0

	bFindGroundExit=false
	bShouldAutoCenterViewPitch=FALSE

	bIsNecrisVehicle=true

	HornIndex=3
	CustomGravityScaling=0.9
}
