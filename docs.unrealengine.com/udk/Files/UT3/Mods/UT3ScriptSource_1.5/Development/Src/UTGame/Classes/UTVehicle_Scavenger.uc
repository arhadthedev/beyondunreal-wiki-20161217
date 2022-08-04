/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Scavenger extends UTVehicle_Walker
	native(Vehicle)
	abstract;

var()	float	JumpForceMag;
var     float	JumpDelay, LastJumpTime;

/** Area of effect for spin attack */
var float SpinAttackRadius;

/** Spin attack has been activated */
var repnotify bool bSpinAttackActive;

/** Time of spin attack start */
var float	SpinAttackStartTime;

/** Total spin attack time allowed */
var float	SpinAttackTotalTime;

/** Are we officially in ball mode (legs retracted, physics off) */
var bool bStartedBallMode;

var float BallModeStartupDelay;

/** How much momentum to impart on a non-UTPawn with the arms per sec*/
var float ArmMomentum;

/** Was a jump initiated successfully by the player */
var bool bDoingJump;

struct native BallModeStatus
{
	/** Is the scavenger in (or transitioning into) ball mode */
	var bool	bIsInBallMode;

	/** Should do boost when transitioning */
	var bool	bBoostOnTransition;
};

/** Replicated struct containing information about ball transition. */
var repnotify BallModeStatus	BallStatus;

var SoundCue JumpSound;
var SoundCue DuckSound;
var SoundCue BounceSound;
var SoundCue LandSound;

var AudioComponent BladesSpinningAC;
var AudioComponent BladesRetractAC;

/** Spinning blades impact flesh \ characters */
var SoundCue BladesHitFleshSound;
/** Spinning blades impact surface \ vehicle */
var SoundCue BladesHitSurfaceSound;

var SoundCue ArmRetractSound;
var SoundCue ArmExtendSound;
var AudioComponent BallAudio;

/** holds the team color materials for the shield **/
var array<MaterialInterface> ShieldTeamMaterials;
var array<MaterialInterface> ShieldBurnoutTeamMaterials;

/** Sound to play from the ball rolling */
var(Sounds) editconst const AudioComponent RollAudioComp;
var(Sounds) array<MaterialSoundEffect> RollSoundList;
var name CurrentRollMaterial;

var() float FullHover, ReducedHover;

/** PhysicalMaterial to use while rolling */
var transient PhysicalMaterial RollingPhysicalMaterial;

var float MaxBallForce, MaxBoostForce;

var particlesystemcomponent ImpactParticle;

/** Damage type when collide with something in ball mode */
var class<UTDamageType>		BallCollisionDamageType;

/** Ball mode boost timer and effects */
var bool bBallBoostActivated;

/** The visual effect when boosting*/
var ParticleSystemComponent BallBoostEffect;
var ParticleSystem BallBoostEffectTemplate[2];

/** The visual effect when colliding */
var ParticleSystemComponent BallHitComponent;
var ParticleSystem BallHitEffectTemplate[2];

/** How long you can boost in ball mode */
var float MaxBoostDuration;
/** used to track boost duration */
var float BoostStartTime;
/** How long it takes to recharge between boosts */
var float BoostChargeDuration;
/** used to track boost recharging duration */
var float BoostChargeTime;
/** max allowed speed while boosting */
var float MaxBoostSpeed;
/** max allowed speed while in ball mode (and not boosting) */
var float MaxBallSpeed;

/** currently active seeker ball */
var UTProj_ScavengerBoltBase ActiveSeeker;

/** The next time that the ball can transition. */
var float NextBallTransitionTime;



replication
{
	if (bNetDirty)
		BallStatus;
	if (bNetOwner)
		ActiveSeeker;
	if (!bNetOwner || bDemoRecording)
		bSpinAttackActive;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Mesh.AttachComponentToSocket(BallHitComponent, 'SphereCenter');
}

simulated function CreateDamageMaterialInstance()
{
	DamageMaterialInstance[0] = Mesh.CreateAndSetMaterialInstanceConstant(1);
}

/** Ask weapon to spawn a seeker */
event SpawnSeeker()
{
	ActiveSeeker = UTProj_ScavengerBoltBase(Seats[0].Gun.ProjectileFire());
}

simulated native function ImpactEffect(Vector HitPos);

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData Collision, int ContactIndex )
{
	local int Damage;
	local Actor DamagedActor;
	local controller InstigatorController;
	local vector HitLocation;
	local vector HitDirection;

	if(health > 0)
	{
		if ( !BallStatus.bIsInBallMode )
		{
			Super.RigidBodyCollision(HitComponent, OtherComponent, Collision, ContactIndex);
			return;
		}

		HitLocation = Collision.ContactInfos[0].ContactPosition;

		if (WorldInfo.TimeSeconds - LastCollisionSoundTime > CollisionIntervalSecs)
		{
			if (BounceSound != none)
			{
				PlaySound(BounceSound, true,,,HitLocation);
			}

			if (bSpinAttackActive && BladesHitSurfaceSound != none)
			{
				DamagedActor = (OtherComponent != None) ? OtherComponent.Owner : None;

				//Play on surfaces and vehicles
				if ( (DamagedActor == None) ||
				     (DamagedActor != none && (DamagedActor.bStatic || UTPawn(DamagedActor) == none)) )
				{
					PlaySound(BladesHitSurfaceSound, true,,,HitLocation);
				}
			}

			if(ImpactParticle != none)
			{
				ImpactEffect(HitLocation);
			}

			LastCollisionSoundTime = WorldInfo.TimeSeconds;
		}
		// damage stuff you run into
		if ( LastCollisionDamageTime != WorldInfo.TimeSeconds)
		{
			DamagedActor = (OtherComponent != None) ? OtherComponent.Owner : None;

			if ( (DamagedActor != None) && !DamagedActor.bStatic )
			{
				if (EffectIsRelevant(Location, FALSE))
				{
					//Play a ball hit effect oriented at the center in the direction of the hit
					HitDirection = HitLocation - Location;
					BallHitComponent.SetRotation(rotator(HitDirection));
					BallHitComponent.ActivateSystem();
				}

				// give impact damage
				Damage = int(VSize(Mesh.GetRootBodyInstance().PreviousVelocity) * 0.1);
				if (Damage > 50)
				{
					if (Controller != None)
					{
						InstigatorController = Controller;
					}
					else if (Instigator != None)
					{
						InstigatorController = Instigator.Controller;
					}

					DamagedActor.TakeDamage(Damage, InstigatorController, HitLocation, vect(0,0,0), BallCollisionDamageType);

					LastCollisionDamageTime = WorldInfo.TimeSeconds;
				}
			}
		}
	}
}


/**
 * NOTE: this guy is doing all kinds of crazy special case stuff and does NOT call super.  Make certain that you check
 * UTVehicle.TeamChanged() when making changes here.
 *
 **/
simulated function TeamChanged()
{
	local MaterialInstanceConstant NewMaterial_Body;
	local MaterialInstanceConstant NewMaterial_Shield;
	local int i;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if( Team < TeamMaterials.length )
		{
			NewMaterial_Body = new(self) class'MaterialInstanceConstant';
			NewMaterial_Body.SetParent( TeamMaterials[Team] );
		}
		else
		{
			NewMaterial_Body = new(self) class'MaterialInstanceConstant';
			NewMaterial_Body.SetParent( TeamMaterials[0] );
		}

		if (NewMaterial_Body != None)
		{
			Mesh.SetMaterial(0, NewMaterial_Body);

			if (DamageMaterialInstance[0] != None)
			{
				DamageMaterialInstance[0].SetParent(NewMaterial_Body);
			}
		}


		if( Team < ShieldTeamMaterials.length )
		{
			NewMaterial_Shield = new(self) class'MaterialInstanceConstant';
			NewMaterial_Shield.SetParent( ShieldTeamMaterials[Team] );
		}
		else
		{
			NewMaterial_Shield = new(self) class'MaterialInstanceConstant';
			NewMaterial_Shield.SetParent( ShieldTeamMaterials[0] );
		}

		if (NewMaterial_Shield != None)
		{
			Mesh.SetMaterial(1, NewMaterial_Shield);

			if (DamageMaterialInstance[1] != None)
			{
				DamageMaterialInstance[1].SetParent(NewMaterial_Shield);
			}
		}

		//Change the hit effect particle effect (red/blue color)
		BallHitComponent.SetTemplate(BallHitEffectTemplate[(Team==1)?1:0]);

		//Change the ball boost particle effect (red/blue color)
		BallBoostEffect.SetTemplate(BallBoostEffectTemplate[(Team==1)?1:0]);

		BodyActor.TeamChanged();

		if(bPlayingSpawnEffect)
		{
			for(i=0;i<Mesh.Materials.Length && i<OriginalMaterials.Length;++i)
			{
				OriginalMaterials[i] = Mesh.Materials[i];
			}
		}

		TeamChanged_VehicleEffects();

		UpdateDamageMaterial();
	}

}

simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	if(WorldInfo.Netmode != NM_DEDICATEDSERVER && ImpactParticle != none && !ImpactParticle.bIsActive && Damage >= 5)
	{
		ImpactEffect(HitLocation);
	}
}

simulated function BlowupVehicle()
{
	//Cancel any spin attacks (hide the geometry)
	if (bSpinAttackActive)
	{
		bSpinAttackActive = false;
		StopSpinAttack();
		if (BodyActor != None)
		{
			UTWalkerBody_Scavenger(BodyActor).Cloak(true);
		}
	}

	//Stop any ball boost effect that might be happening
	if (bBallBoostActivated)
	{
		DeactivateBallBooster();
	}

	ClearTimer('InitFeet');
	Super.BlowupVehicle();
}

simulated function bool OverrideBeginFire(byte FireModeNum)
{
	if (FireModeNum == 1)
	{
		// toggle ball mode
		if (Role == ROLE_Authority && (WorldInfo.TimeSeconds >= NextBallTransitionTime))
		{
			BallStatus.bIsInBallMode = !BallStatus.bIsInBallMode;
			BallStatus.bBoostOnTransition = TRUE;
			BallModeTransition();
		}
		return true;
	}

	//Start a spin attack if already in ball mode
	if(BallStatus.bIsInBallMode)
	{
		//Ball mode doesn't officially start until the retract anim is done
		if (!bSpinAttackActive && bStartedBallMode)
		{
			bSpinAttackActive = true;
			StartSpinAttack();
		}
		return true;
	}

	return false;
}

function DriverLeft()
{
	if (Health > 0 && BallStatus.bIsInBallMode)
	{
		BallStatus.bIsInBallMode = false;
		BallStatus.bBoostOnTransition = false;
		BallModeTransition();
	}

	Super.DriverLeft();
}

/** notification from WalkerBody that foot just landed */
function TookStep(int LegIdx)
{
	if (BodyActor != None && BodyActor.LegMapping[0] != LegIdx)
	{
		//Only move on the front two legs
		EyeStepOffset = MaxEyeStepOffset * FMin(1.0,VSize(Velocity)/AirSpeed);
	}
}

/** called when doing spin attack and exceed SpinTime */
event EndBallMode()
{
	BallStatus.bIsInBallMode = FALSE;
	BallStatus.bBoostOnTransition = FALSE;
	BallModeTransition();
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C, bVehicleTransition);

	// reset jump/duck properties
	bHoldingDuck = false;
	LastJumpTime = 0;
}

/**
 * When an icon for this vehicle is needed on the hud, this function is called
 */
simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, LinearColor FinalColor)
{
	local Rotator VehicleRotation;

	VehicleRotation = (BallStatus.bIsInBallMode && (Controller != None)) ? Controller.Rotation : Rotation;
	MP.DrawRotatedTile(Canvas,Class'UTHUD'.default.IconHudTexture, HUDLocation, VehicleRotation.Yaw + 32757, MapSize, IconCoords, FinalColor);
}

simulated function float GetChargePower()
{
	return FClamp( (WorldInfo.TimeSeconds - LastJumpTime), 0, JumpDelay)/JumpDelay;
}

event ScavengerJumpEffect();

event ScavengerDuckEffect();

event SpinAttackVictim(Pawn HitPawn, float DeltaSeconds)
{
	local vector NewMomentum;
	if(HitPawn != none)
	{
		if(UTPawn(HitPawn) != none) // just kill UTPawn's
		{
			HitPawn.Died(Controller, class'UTDmgType_ScavengerStabbed',Location);
			//if(WorldInfo.NetMode != NM_DedicatedServer)
			//{
			//	UTWalkerBody_Scavenger(BodyActor).PawnGrabber[0].GrabComponent(HitPawn.Mesh, UTPawn(HitPawn).TorsoBoneName, HitPawn.Location, FALSE);
				//(UTWalkerBody_Scavenger(BodyActor).SkeletalMeshComponent).AttachComponentToSocket((HitPawn.Mesh),'LegOneRag');
			//}
		}
		else // non-UT Pawns get pushed away
		{
			NewMomentum = Normal(HitPawn.Location - Location)*ArmMomentum*DeltaSeconds;
			HitPawn.TakeDamage(0, Controller, Location, NewMomentum, class'UTDmgType_ScavengerStabbed',,self);
		}

		if (BladesHitFleshSound != none)
		{
			PlaySound(BladesHitFleshSound,,,,HitPawn.Location);
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'BallStatus' )
	{
		BallModeTransition();
	}
	else if (VarName == 'bSpinAttackActive')
	{
		StartSpinAttack();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

//When the scavenger jumps, this function is called
//to tell the feet to release its constraints and do
//something smooth
simulated event OnJump()
{
	bDoingJump = TRUE;
	if (BodyActor != None)
	{
		UTWalkerBody_Scavenger(BodyActor).OnJump();
	}

	ScavengerJumpEffect();
}

//The scavenger has landed, reacquire constraints
//and track back to walking
simulated event OnLanded()
{
	if (bDoingJump)
	{
		if (BodyActor != None)
		{
			UTWalkerBody_Scavenger(BodyActor).OnLanded();
		}

		if (LandSound != None)
		{
			PlaySound(LandSound);
		}

		bDoingJump = FALSE;
	}
}

simulated function StartSpinAttack()
{
	SpinAttackStartTime = WorldInfo.TimeSeconds;
	if (UTWalkerBody_Scavenger(BodyActor) != None)
	{
		UTWalkerBody_Scavenger(BodyActor).Cloak(false);

		if (BladesSpinningAC != none)
		{
			if (BladesSpinningAC.IsPlaying())
			{
				BladesSpinningAC.Stop();
			}

			BladesSpinningAC.Play();
		}
	}
}

simulated function StopSpinAttack()
{
	if (UTWalkerBody_Scavenger(BodyActor) != None)
	{
		if (BladesSpinningAC != none)
		{
			BladesSpinningAC.Stop();
		}

		if (BladesRetractAC != none)
		{
			BladesRetractAC.Play();
		}
	}
}

simulated function FinishedStartingBallMode()
{
	bStartedBallMode = true;
}

simulated function ActivateBallBooster()
{
	if (!bDeadVehicle)
	{
		bBallBoostActivated = TRUE;
		//Record the time we go into boost mode
		BoostStartTime = WorldInfo.TimeSeconds;

		if(EffectIsRelevant(Location, FALSE))
		{
			BallBoostEffect.ActivateSystem();
		}
	}
}

simulated event DeactivateBallBooster()
{
	bBallBoostActivated = FALSE;
	//Record the time we leave boost mode (so we can wait for a recharge)
	BoostStartTime = WorldInfo.TimeSeconds;
	BallBoostEffect.DeactivateSystem();
}

// FIXME play anim
simulated function BallModeTransition()
{
	local UTPlayerReplicationInfo PRI;
	local UTWalkerBody_Scavenger ScavengerBody;
	local vector	HitLocation;
	local vector	TraceStart, TraceEnd;

	StopFiringWeapon();
	UTVehicleSimHover(SimObj).bUnPoweredDriving = BallStatus.bIsInBallMode;
	bStartedBallMode = false;
	if ( BodyActor != None )
	{
		ScavengerBody = UTWalkerBody_Scavenger(BodyActor);
		ScavengerBody.bIsInBallMode = BallStatus.bIsInBallMode;
		if (ScavengerBody.RetractionBlend != None)
		{
			if (BallStatus.bIsInBallMode)
			{
				//Transition from walking legs to retracting legs
				ScavengerBody.RetractLegs();

				//Setup the first normals  for spinner arm alignment
				TraceStart.X = Location.X; TraceStart.Y = Location.Y;  TraceStart.Z = Location.Z;
				TraceEnd.X = Location.X; TraceEnd.Y = Location.Y;  TraceEnd.Z = Location.Z - 100;
				if (Trace(HitLocation, ScavengerBody.CurrentSurfaceNormal, TraceEnd, TraceStart, false) == None)
				{
					ScavengerBody.CurrentSurfaceNormal.X = 0.0f;
					ScavengerBody.CurrentSurfaceNormal.Y = 0.0f;
					ScavengerBody.CurrentSurfaceNormal.Z = 1.0f;
				}

				ScavengerBody.DesiredSurfaceNormal = ScavengerBody.CurrentSurfaceNormal;

				//Play some sounds
				PlaySound(ArmRetractSound, true);
				BallAudio.FadeIn(0.1f,1.0f);
				if(ScrapeSound != none)
				{
					ScrapeSound.Stop();
					ScrapeSound = none;
				}
			}
			else
			{
				ScavengerBody.ExtendLegs();

				//Play some sounds
				PlaySound(ArmExtendSound, true);
				BallAudio.FadeOut(0.1f,0.0f);
				if(ScrapeSound == none)
				{
					ScrapeSound = CreateAudioComponent(default.ScrapeSound.Soundcue, false, true);
				}
			}
		}
	}

	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if ( (PRI != None) && (PRI.GetFlag() != None) )
	{
		HoldGameObject(PRI.GetFlag());
	}

	if ( BallStatus.bIsInBallMode )
	{
		BaseEyeheight = 0;
		StayUprightConstraintInstance.TermConstraint();
		Mesh.SetPhysMaterialOverride(RollingPhysicalMaterial);

		if( BallStatus.bBoostOnTransition && !bBallBoostActivated  && (WorldInfo.TimeSeconds - BoostStartTime > BoostChargeDuration) )
		{
			ActivateBallBooster();
		}

		if (BallModeStartupDelay > 0.0)
		{
			SetTimer(BallModeStartupDelay, false, 'FinishedStartingBallMode');
		}
		else
		{
			FinishedStartingBallMode();
		}
	}
	else
	{
		BaseEyeheight = Default.BaseEyeheight;
		InitStayUpright();
		Mesh.SetPhysMaterialOverride(bDriving ? DrivingPhysicalMaterial : DefaultPhysicalMaterial);

		// turn off ball boost mode
		if ( bBallBoostActivated )
		{
			DeactivateBallBooster();
		}

		// turn off spin attack
		if (bSpinAttackActive)
		{
			bSpinAttackActive = false;
			StopSpinAttack();
		}

		ClearTimer('FinishedStartingBallMode');
	}
}

simulated function PlaySpawnEffect()
{
	Super.PlaySpawnEffect();

	if (BodyActor != None)
	{
		BodyActor.SetHidden(true);
	}
}

simulated function StopSpawnEffect()
{
	local UTWalkerBody_Scavenger ScavengerBody;

	Super.StopSpawnEffect();

	if (BodyActor != None)
	{
		BodyActor.SetHidden(false);
		if (!BallStatus.bIsInBallMode)
		{
			ScavengerBody = UTWalkerBody_Scavenger(BodyActor);
			if (ScavengerBody != None && ScavengerBody.RetractionBlend != None)
			{
				ScavengerBody.SkeletalMeshComponent.PhysicsWeight = 0.0;
				Mesh.WakeRigidBody();
				ScavengerBody.RetractionBlend.SetActiveChild(2, 0.0);
				ScavengerBody.RetractionBlend.Children[2].Anim.PlayAnim(false, 0.5);
				PlaySound(ArmExtendSound, true);
				if (WorldInfo.NetMode != NM_DedicatedServer)
				{
					SetTimer(0.3, false, 'InitFeet');
				}
			}
		}
	}
}

simulated function InitFeet()
{
	local UTWalkerBody_Scavenger ScavengerBody;
	if (!BallStatus.bIsInBallMode)
	{
		ScavengerBody = UTWalkerBody_Scavenger(BodyActor);
		if (ScavengerBody != none)
		{
			if (ScavengerBody.SkeletalMeshComponent.PhysicsWeight > 0.7)
			{
				ScavengerBody.InitFeet();
			}
			else
			{
				SetTimer(0.1, false, 'InitFeet');
			}
		}
	}
}

/**
 * HoldGameObject() Attach GameObject to mesh.
 * @param 	GameObj 	Game object to hold
 */
simulated event HoldGameObject(UTCarriedObject GameObj)
{
	super.HoldGameObject(GameObj);

	if ( BallStatus.bIsInBallMode )
	{
		GameObj.SetHardAttach(false);
		GameObj.bIgnoreBaseRotation = true;
	}
}

native function InitStayUpright();

simulated function bool GetPowerLevel(out float PowerLevel)
{
	if (BallStatus.bIsInBallMode)
	{
		if (bBallBoostActivated)
		{
			PowerLevel = 1.0 - (WorldInfo.TimeSeconds - BoostStartTime) / MaxBoostDuration;
		}
		else
		{
			PowerLevel = (WorldInfo.TimeSeconds - BoostChargeTime) / BoostChargeDuration;
		}
		PowerLevel = FClamp(PowerLevel, 0.0, 1.0);
		return true;
	}
	else
	{
		return Super.GetPowerLevel(PowerLevel);
	}
}

simulated function Vector GetPhysicalFireStartLoc(UTWeapon ForWeapon)
{
	if ( (ActiveSeeker == None) || ActiveSeeker.bDeleteMe )
	{
		return Location + vect(0,0,100);
	}
	return super.GetPhysicalFireStartLoc(ForWeapon);
}

simulated function bool ShouldClamp()
{
	return FALSE;
}


simulated function SetBurnOut()
{
	local int TeamNum;

	TeamNum = GetTeamNum();

	if( TeamNum > 1 )
	{
		TeamNum = 0;
	}

	// set our specific turret BurnOut Material
	if (ShieldBurnoutTeamMaterials[TeamNum] != None)
	{
		Mesh.SetMaterial( 1, ShieldBurnoutTeamMaterials[TeamNum] );
	}

	// sets the MIC
	super.SetBurnOut();
}

function byte ChooseFireMode()
{
	if ( Vehicle(Controller.MoveTarget) != None && Controller.MoveTarget == Controller.Focus &&
		Controller.InLatentExecution(Controller.LATENT_MOVETOWARD) && Controller.LineOfSightTo(Controller.Focus) )
	{
		if (!BallStatus.bIsInBallMode)
		{
			return 1;
		}
	}
	else if (BallStatus.bIsInBallMode)
	{
		return 1;
	}

	return 0;
}

defaultproperties
{
	Begin Object Name=RB_BodyHandle
		LinearDamping=100.0
		LinearStiffness=99000.0
		AngularDamping=100.0
		AngularStiffness=99000.0
	End Object

	Health=200
	MeleeRange=-100.0

	COMOffset=(X=0.f,Y=0.f,Z=0.f)
	bCanFlip=true
	bEjectPassengersWhenFlipped=false

	AirSpeed=700.0
	GroundSpeed=700.0

	LegTraceOffset=(X=0,Y=0,Z=0)
	LegTraceZUpAmount=200

	bFollowLookDir=true
	bCanStrafe=true
	bTurnInPlace=true
	ObjectiveGetOutDist=750.0
	MaxDesireability=0.5
	SpawnRadius=125.0
	BaseBodyOffset=(Z=-45.f)
	BaseEyeHeight=120
	EyeHeight=120

	MaxEyeStepOffset=65.0
	EyeStepFadeRate=4.0
	EyeStepBlendRate=4.0

	LookForwardDist=0.0 //causes annoying up/down movement if non-zero
	WalkableFloorZ=0.85

	bUseSuspensionAxis=true

	bStayUpright=true
	StayUprightRollResistAngle=0.0			// will be "locked"
	StayUprightPitchResistAngle=0.0

	WheelSuspensionTravel(WalkerStance_Standing)=70
	WheelSuspensionTravel(WalkerStance_Parked)=20
	SuspensionTravelAdjustSpeed=150
	MaxBallForce=250.0
	MaxBoostForce=350.0
	MaxBoostDuration=2.0
	BoostChargeDuration=4.0
	BoostChargeTime=-10.0
	MaxBoostSpeed=1900.0
	MaxBallSpeed=1600.0

	Begin Object Class=UTVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=800.f
		WheelSuspensionDamping=200.f
		WheelSuspensionBias=0.0
		MaxThrustForce=600.0
		MaxReverseForce=600.0
		LongDamping=0.3
		MaxStrafeForce=600.0
		LatDamping=0.3
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=2500.0
		TurnTorqueMax=1000.0
		TurnDamping=0.11
		MaxYawRate=1.7
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
		bDisableWheelsWhenOff=true
	End Object

	SimObj=SimObject
	Components.Add(SimObject)


	// from darkwalker
	Begin Object Class=UTHoverWheel Name=RThruster
		BoneName="BodyRoot"
		BoneOffset=(X=0,Y=0,Z=-100)
		WheelRadius=30
		SuspensionTravel=20
		bPoweredWheel=false
		SteerFactor=1.0
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
	End Object
	Wheels(0)=RThruster

	bHomingTarget=true

	JumpForceMag=9000.0
	JumpDelay=2.0

	bRotateCameraUnderVehicle=true
	BallCollisionDamageType=class'UTDmgType_VehicleCollision'
	ArmMomentum=1.0
	SpinAttackRadius=250.0
	bAnimateDeadLegs=true
	BallModeStartupDelay=0.7

	bIsNecrisVehicle=true

	HornIndex=2
	VehicleIndex=9
}
