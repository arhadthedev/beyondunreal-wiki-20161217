﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_SPMACamera extends UTProjectile
	native(Vehicle)
	abstract;

/** Quick access to the Gun that contols this to save on casting */
var UTVWeap_SPMACannon InstigatorGun;

/** Has this camera been deployed? */
var repnotify bool bDeployed;

/** Has this camera been disconnected? */
var bool bDisconnected;

/** The Particle System to use when deployed. */
var ParticleSystem HoverJetsTemplate;

/** The Mesh component for this camera so we can hide it when we deploy */
var SkeletalMeshComponent Mesh;

/** Last Time the ONS Messages were updated */
var float LastMessageUpdateTime;

/** The is the maximum height a bot will let this go */
var float MaxHeight;

/** The maximum Target Range that this camera will trace to */
var float MaxTargetRange;

/** Holds the Location/Normal of the current target location.  These are used in positioning the icons */
var vector LastTargetLocation;
var vector LastTargetNormal;

/** The offest of the camera when in flight mode */
var vector CameraViewOffset;

/** Cheap and easy way to effect the slide in to the camera when deployed.  We just interpolate this down to 0 */
var float CVScale;

/** This holds the distance to which the camera will redirect avril shots to the SPMA */
var float TargetRedirectDistance;

var SoundCue DeploySound;
var SoundCue ShotDownSound;

// The component for the start point of the arc
var ParticleSystemComponent	PSC_StartPoint;
// the reference for the start point component
var ParticleSystem			PS_StartPoint;
// the trail particle component from start to end of the arc
var ParticleSystemComponent PSC_Trail;
// the team-determined template for the trail
var ParticleSystem			PS_Trail;

// the end point for the arc
var ParticleSystemComponent PSC_EndPoint;

// the team based template for the arc
var ParticleSystem			PS_EndPointOnTarget;
var ParticleSystem			PS_EndPointOffTarget;

// whether the arc is able to be displayed
var bool					bDisplayingArc;
var vector					LastTargetVelocity;

var() float  TrajectorySteps;



replication
{
	if (Role == ROLE_Authority)
		bDeployed,InstigatorGun;
}

/**
 * This function is designed to be called from the UTVWeap_SPMACannon.  It calculates
 * the current target location and then Sets the first 2 indicators to that location
 */
native final function vector GetCurrentTargetLocation(Controller C);

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(0.25, false, 'SendDeployMessage');

	if (Role == ROLE_Authority && AIController(InstigatorController) != None)
	{
		SetTimer(1.0, false, 'CheckAIDeploy');
	}
}

/** AI function that deploys the camera when it can see the AI's target */
function CheckAIDeploy()
{
	if (InstigatorController != None && !bShuttingDown)
	{
		if (FastTrace(InstigatorController.FocalPoint, Location))
		{
			Deploy();
		}
		else
		{
			SetTimer(0.1, true, 'CheckAIDeploy');
		}
	}
}

/**
 * Make sure when we shut down or get destroyed, that we disconnect */
simulated function ShutDown()
{
	// prevent projectile from being blown up/hidden until the server says so
	//@note: this will pass on client if the server tears off projectile due to it blowing up
	if (Role == ROLE_Authority)
	{
		Disconnect();
		Super.Shutdown();
	}
}

simulated event Destroyed()
{
	Disconnect();
	Super.Destroyed();
}

native simulated function SimulateTrajectory(vector TossVelocity);
native simulated function KillTrajectory();

/**
 * This is the function that will create all of the particle systems and emitters
 * needed to draw the grenade aiming arc.
 *
 * This is called each time we through and we cache the emitters and particle systems
 * so we do not have to recreate them each time.
 *
 * We want to call this set up function as we can get into the state where the last tick
 * our emitters were valid  or our virtual projectile was valid but now this tick it is not
 * (the projectile falling out of the world will cause this to occur).
 *
 */
simulated event SetUpSimulation()
{
	local Rotator rot;

	if ( !Instigator.Controller.IsLocalPlayerController() )
	{
		// no arc for AI
		return;
	}

	if(PSC_StartPoint == none)
	{
		PSC_StartPoint = new(Outer) class'UTParticleSystemComponent';
		PSC_StartPoint.bAutoActivate = false;
		PSC_StartPoint.SetTemplate(PS_StartPoint);
		PSC_StartPoint.SetAbsolute(true,true,true);
		PSC_StartPoint.SetOnlyOwnerSee(true);
		AttachComponent(PSC_StartPoint);
	}
	if(PSC_EndPoint == none)
	{
		PSC_EndPoint = new(Outer) class'UTParticleSystemComponent';
		PSC_EndPoint.bAutoActivate = false;
		PSC_EndPoint.SetTemplate(PS_EndPointOnTarget);
		PSC_EndPoint.SetAbsolute(true,true,true);
		rot.yaw=0;
		rot.pitch=16384;
		rot.roll=0;

		PSC_EndPoint.SetRotation(rot);
		PSC_EndPoint.SetOnlyOwnerSee(true);
		AttachComponent(PSC_EndPoint);


	}
	if( PSC_Trail == None )
	{
		PSC_Trail = new(Outer) class'UTParticleSystemComponent';
		PSC_Trail.bAutoActivate = false;
		PSC_Trail.SetTemplate( PS_Trail );
		PSC_Trail.SetAbsolute(true,true,true);
		PSC_Trail.SetOnlyOwnerSee(true);
		AttachComponent(PSC_Trail);
	}

	PSC_Trail.SetHidden(FALSE);
//	PSC_Trail.ActivateSystem();

	if (Instigator != None && Instigator.IsLocallyControlled())
	{
		bDisplayingArc = true;
	}
}

simulated function ResetAimEffects()
{
	if(PSC_EndPoint != none)
	{
		DetachComponent(PSC_EndPoint);
		PSC_EndPoint = none;
	}
	if(PSC_Trail != none)
	{
		DetachComponent(PSC_Trail);
		PSC_Trail = none;
	}
	bDisplayingArc=false;
	//SetupSimulation();
}

/**
 * This function server side function notifies the client and then tells the
 * camera to deploy.
 *
 * Network: ServerOnly
 */
function Deploy()
{
	bDeployed = true;
	DeployCamera();
	SetTimer(1.5, true, 'ShowSelfTimed');
}

function ShowSelfTimed()
{
	ShowSelf(true);
}

/** reveals camera to AI, giving them an opportunity to target us */
function ShowSelf(bool bCheckFOV)
{
	local UTBot B;

	if (bDisconnected)
	{
		ClearTimer('ShowSelf');
	}
	else
	{
		foreach WorldInfo.AllControllers(class'UTBot', B)
		{
			if ( B != None && B.Pawn != None && !B.Pawn.IsFiring() && !WorldInfo.GRI.OnSameTeam(B, self) &&
				(B.Enemy == None || B.Enemy == Instigator || (B.Skill > 2.0 + 2.0 * FRand() && !B.LineOfSightTo(B.Enemy))) &&
				(!bCheckFOV || Normal(B.FocalPoint - B.Pawn.Location) dot (Location - B.Pawn.Location) > B.Pawn.PeripheralVision) &&
				B.LineOfSightTo(self) )
			{
				// give B a chance to shoot at me
				B.GoalString = "Destroy Mortar Camera";
				B.Focus = self;
				B.SwitchToBestWeapon();
				if (B.Pawn.CanAttack(self))
				{
					if (B.Squad != None)
					{
						B.Squad.SetEnemy(B, Instigator);
					}
					B.FireWeaponAt(self);
					if (FRand() < 0.5)
					{
						break;
					}
				}
			}
		}
	}
}

/**
 * We use RepNotify to make sure on remote clients, that we get the deploy right
 */
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bDeployed')
	{
		if (bDeployed)
		{
			DeployCamera();
		}
		else
		{
			Disconnect();
		}
	}
	else
	{
		Super.ReplicatedEvent( VarName );
	}
}

/**
 * Deploy the camera
 *
 * Network: All
 */
simulated function DeployCamera()
{
	if ( bDisconnected )
	{
		// can't deploy if already disconnected
		return;
	}
	if (ProjEffects!=None)
	{
		ProjEffects.DeactivateSystem();
		ProjEffects.SetTemplate(HoverJetsTemplate);
		ProjEffects.ActivateSystem();
	}
	else
	{
		ProjFlightTemplate = HoverJetsTemplate;
		SpawnFlightEffects();
	}

	SetupSimulation();

	Velocity = vect(0,0,0);

	DesiredRotation = rot(-16384,0,0);
	RotationRate = rot(16384,16384,16384);
	SetPhysics(PHYS_Projectile);

	bRotationFollowsVelocity = false;
	bNeverReplicateRotation = false;

	// in case the simulated projectile already hit the ground on the client, make sure we allow the explosion again
	bSuppressExplosionFX = false;
}

event PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( NewVolume.bWaterVolume )
	{
		Disconnect();
	}
}

/**
 * This camera has been disconnected by the host SPMA
 */
simulated function Disconnect()
{
	bDisconnected = true;

	if (InstigatorGun!=none)
	{
		InstigatorGun.DisconnectCamera(Self);
		//ResetAimEffects();
	}
	if (ProjEffects!=None)
	{
		ProjEffects.DeactivateSystem();
	}

	SetPhysics(PHYS_Falling);

	Mesh.SetOwnerNoSee(false);
	if(PSC_EndPoint != none)
	{
		PSC_EndPoint.DeactivateSystem();
	}

	bDeployed = false;
	InstigatorGun = none;
}

/* epic ===============================================
* ::StopsProjectile()
*
* returns true if Projectiles should call ProcessTouch() when they touch this actor
*/
simulated function bool StopsProjectile(Projectile P)
{
	if ( UTProj_SPMAShell(P) != None )
		return false;
	return super.StopsProjectile(P);
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if ( !WorldInfo.GRI.OnSameTeam(Instigator, EventInstigator) )
	{
		Disconnect();
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (!bDeployed || !WorldInfo.GRI.OnSameTeam(Instigator, Other))
	{
		Super.ProcessTouch(Other, HitLocation, HitNormal);
	}
}

/**
 * Handle the Camera
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;

	if ( bDeployed && CVScale > 0)
	{
		CVScale -= (fDeltatime * 0.8);
		if (CVScale<=0)
		{
			CVScale = 0;
		}
		else if (CVScale < 0.25 && !Mesh.bOwnerNoSee)
		{
			Mesh.SetOwnerNoSee(true);
		}
	}
	out_CamLoc = Location + ( (CameraViewOffset * CVScale) >> out_CamRot);
	HitActor = Trace(HitLocation, HitNormal, out_CamLoc, Location, false, vect(12,12,12));
	if ( HitActor != None )
	{
		out_CamLoc = HitLocation;
	}

	return true;
}

/**
 * Look to see if any ONS SPMA Messages need to be displayed
 */
simulated function SendDeployMessage()
{
	local PlayerController PC;

	// Handling updating any needed messages
	if ( !bDeployed )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
			if (Instigator.Controller == PC && PC.ViewTarget == self)
			{
				PC.ReceiveLocalizedMessage(MessageClass, 4);
				ClearTimer('SendDeployMessage');
				return;
			}
		}
	}
}

/**
 * This function is also called from the gun.  It's used to show the proper
 * cursor.
 */
native function SetTargetIndicator(bool bCanHit);

event Actor GetHomingTarget(UTProjectile Seeker, Controller InstigatedBy)
{
	local vector HitLocation, HitNormal;
	local UTVehicle_SPMA MyVehicle;
	local UTProj_AvrilRocketBase AvrilRocket;

	if ( InstigatorGun == none )
		return self;

	MyVehicle = UTVehicle_SPMA(InstigatorGun.MyVehicle);
	AvrilRocket = UTProj_AvrilRocketBase(Seeker);

	if ( AvrilRocket != none && MyVehicle != none && (AvrilRocket.bRedirectedLock || VSize(Location  - Seeker.Location) < TargetRedirectDistance) )
	{
		AvrilRocket.bRedirectedLock = true;
		if ( Seeker.Trace(HitLocation, HitNormal, MyVehicle.Location, Seeker.Location) == MyVehicle )
		{
			// switch lock
			AvrilRocket.ForceLock(MyVehicle);
			return MyVehicle;
		}
	}
	return self;
}

simulated function Pawn GetPawnOwner()
{
	local UTVWeap_SPMACannon Cannon;

	Cannon = UTVWeap_SPMACannon(Owner);
	return (Cannon != None) ? Cannon.MyVehicle : None;
}

function bool IsStationary()
{
	return bDeployed;
}

defaultproperties
{
	Speed=4000.000000
	maxspeed=4000.0
	TerminalVelocity=4500
	LifeSpan=0.0
	bCollideWorld=true
	bProjTarget=True
	bNetTemporary=false
	Physics=PHYS_Falling
	bUpdateSimulatedPosition=true
	bRotationFollowsVelocity=true

	bCollideComplex=false

	MaxTargetRange=10240
	CameraViewOffset=(X=-256,Y=0,Z=128)

	Damage=250
	DamageRadius=660.0
	MomentumTransfer=175000
	bAlwaysRelevant=true
	CVScale=1.0

	TargetRedirectDistance=512

	MessageClass=class'UTSPMAMessage'

	TrajectorySteps=1000.0
	bSwitchToZeroCollision=false
}
