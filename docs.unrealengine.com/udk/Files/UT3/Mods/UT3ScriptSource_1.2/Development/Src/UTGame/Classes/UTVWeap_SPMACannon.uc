/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_SPMACannon extends UTVehicleWeapon
	native(Vehicle)
	abstract
	HideDropDown;

/** Holds a link to the remote camera */
var UTProj_SPMACamera RemoteCamera;
var vector TargetVelocity;
var SoundCue BoomSound;
var SoundCue IncomingSound;
var bool bCanHitTargetVector;
var vector IncomingTargetLoc;
var float LastCanAttackTime;

replication
{
	if (Role==ROLE_Authority)
		RemoteCamera;
}


/**
 * Override BeginFire and restrict firing when the vehicle isn't deployed
 *
 * @Param 	FireModeNum		0 = Fire | 1 = AltFire
 *
 */
simulated function BeginFire(byte FireModeNum)
{
	local UTVehicle_Deployable DeployableVehicle;

	DeployableVehicle = UTVehicle_Deployable(MyVehicle);
	if (DeployableVehicle != None && !DeployableVehicle.IsDeployed())
	{
		DeployableVehicle.ServerToggleDeploy();
	}
	else if ( (Role == ROLE_Authority) && (RemoteCamera != None) )
	{
		if ( !RemoteCamera.bDeployed )
		{
			// camera monitors itself for AI, don't do it here
			if (Instigator == None || AIController(Instigator.Controller) == None)
			{
				// If we have a remote camera pending, then deploy it
				RemoteCamera.Deploy();
			}
			ClearPendingFire(FireModeNum);
		}
		else if ( FireModeNum == 1 )
		{
			RemoteCamera.Disconnect();
			ClearPendingFire(1);
		}
		else
		{
			Super.BeginFire(FireModeNum);
		}
	}
	else
	{
		Super.BeginFire(FireModeNum);
	}
}

/**
 * Called by a SPMA camera projectile, this handles the disconnection in terms of the gun and
 * the vehicle/pawn.
 *
 * @Param	Camera		The remote camera to disconnect
 */
function DisconnectCamera(UTProj_SPMACamera Camera)
{
	if (Camera == RemoteCamera)
	{
		if ( PlayerController(Instigator.Controller) != none )
		{
			PlayerController(Instigator.Controller).ClientSetViewTarget( Instigator );
			PlayerController(Instigator.Controller).SetViewTarget( Instigator );
		}

		RemoteCamera = none;
	}
}

/**
 * If we do not have a camera out, force a camera
 */

function class<Projectile> GetProjectileClass()
{
	if (RemoteCamera == none)
	{
		return WeaponProjectiles[1];
	}
	else
	{
		return Super.GetProjectileClass();
	}
}

/**
 * In the case of Alt-Fire, handle the camera
 */
simulated function Projectile ProjectileFire()
{
	local Projectile Proj;
	local UTProj_SPMACamera CamProj;
	local UTProj_SPMAShell ShellProj;
	local PlayerController PC;
	local float ImpactDelay;
	local vector SpawnLoc, BarrelLoc, HitLocation, HitNormal;
	local Actor HitActor;

	// make sure gun isn't clipping through wall
	SpawnLoc = MyVehicle.GetPhysicalFireStartLoc(self);
	BarrelLoc = MyVehicle.Mesh.GetBoneLocation('MainTurret_BarrelA');
	
	HitActor = Trace(HitLocation, HitNormal, SpawnLoc, BarrelLoc, false,,,TRACEFLAG_Bullet);
	if ( HitActor != None )
	{
		// barrel was clipping
		return None;
	}

	// Tweak the projectile afterwards
	// Check to see if it's a camera.  If it is, set the view from it
	Proj = Super.ProjectileFire();
	CamProj = UTProj_SPMACamera(Proj);

	if ( CamProj == None )
	{
		ShellProj = UTProj_SPMAShell(Proj);
		if ( ShellProj != none )
		{
			if ( RemoteCamera == None )
			{
				ShellProj.SetFuse( 0.3 );
			}
			else
			{
				RemoteCamera.ShowSelf(false);
				if (bCanHitTargetVector)
				{
					Proj.Velocity = TargetVelocity;
				}
				else
				{
					Proj.Velocity = VSize(TargetVelocity) * Normal(Proj.Velocity);
				}

				// If we are viewing remotely, use the TargetVelocity
				foreach WorldInfo.AllControllers(class'PlayerController',PC)
				{
					PC.ClientPlaySound(BoomSound);
				}

				IncomingTargetLoc = RemoteCamera.GetCurrentTargetLocation(Instigator.Controller);
				ImpactDelay = VSize2D(IncomingTargetLoc - Location)/VSize2D(Proj.Velocity);
				ShellProj.SetFuse( ImpactDelay );

				SetTimer(FMax(0.01, ImpactDelay - 3.5), false, 'PlayIncomingSound');
			}
		}
	}
	else if ( Role == ROLE_Authority )
	{
		RemoteCamera = CamProj;
		RemoteCamera.InstigatorGun = self;
		if (PlayerController(Instigator.Controller) != None)
		{
			PlayerController(Instigator.Controller).SetViewTarget(RemoteCamera);
		}
		ClearPendingFire(1);
	}

	return Proj;
}

function PlayIncomingSound()
{
	local PlayerController PC;

	foreach WorldInfo.AllControllers(class'PlayerController',PC)
	{
		if ( (PC.Viewtarget != None) && (VSize(PC.ViewTarget.Location - IncomingTargetLoc) < 2200) )
			PC.ClientPlaySound(IncomingSound);
	}
}

function bool CanAttack(Actor Other)
{
	local vector Start, Extent, RequiredVelocity;
	local class<UTProjectile> ProjectileClass;
	local bool bResult;
	local UTBot B;
	local UTVehicle_Deployable DeployableVehicle;

	ProjectileClass = class<UTProjectile>(WeaponProjectiles[0]);
	Extent = ProjectileClass.default.CollisionComponent.Bounds.BoxExtent;
	Start = MyVehicle.GetPhysicalFireStartLoc(self);
	B = UTBot(Instigator.Controller);

	// Get the Suggested toss velocity
	bResult = SuggestTossVelocity( RequiredVelocity, Other.GetTargetLocation(MyVehicle), Start, ProjectileClass.default.Speed,
					ProjectileClass.default.TossZ, 0.5, Extent, ProjectileClass.default.TerminalVelocity );
	if (bResult)
	{
		if (B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = false;
		}
	}
	else if (Other.bHasAlternateTargetLocation)
	{
		bResult = SuggestTossVelocity( RequiredVelocity, Other.GetTargetLocation(MyVehicle, true), Start, ProjectileClass.default.Speed,
						ProjectileClass.default.TossZ, 0.5, Extent, ProjectileClass.default.TerminalVelocity );
		if (bResult && B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = true;
		}
	}
	if (bResult)
	{
		LastCanAttackTime = WorldInfo.TimeSeconds;
	}
	// if can't hit anything for a while and not defending, undeploy
	else if (!bResult && WorldInfo.TimeSeconds - LastCanAttackTime > 5.0)
	{
		if (B != None && !B.IsInState('Defending'))
		{
			DeployableVehicle = UTVehicle_Deployable(MyVehicle);
			if (DeployableVehicle != None && DeployableVehicle.IsDeployed())
			{
				DeployableVehicle.SetTimer(0.01, false, 'ServerToggleDeploy');
			}
		}
	}

	return bResult;
}

function byte BestMode()
{
	return 0;
}

/**
 * Calculates the velocity needed to lob a SPMA shell to a destination.  Returns true if the SPMA can
 * hit the currently target vector
 */
simulated event CalcTargetVelocity()
{
	local vector TargetLoc, StartLoc, Extent, Aim, SocketLocation;
	local rotator SocketRotation;
	local class<UTProjectile> ProjectileClass;

	ProjectileClass = class<UTProjectile>(WeaponProjectiles[0]);
	Extent = ProjectileClass.default.CollisionComponent.Bounds.BoxExtent;

	MyVehicle.GetBarrelLocationAndRotation(SeatIndex, SocketLocation, SocketRotation);
	Aim = vector(SocketRotation);

	if ( RemoteCamera != none )
	{
		// Grab the Start and End points.
		TargetLoc = RemoteCamera.GetCurrentTargetLocation(Instigator.Controller);
	}
	else
	{
		TargetLoc = GetDesiredAimPoint();
	}

	StartLoc = MyVehicle.GetPhysicalFireStartLoc(self);

	// Get the Suggested toss velocity
	bCanHitTargetVector = SuggestTossVelocity(TargetVelocity, TargetLoc, StartLoc, ProjectileClass.default.Speed, ProjectileClass.default.TossZ, 0.5, Extent, ProjectileClass.default.TerminalVelocity);

	if ( bCanHitTargetVector )
	{
		bCanHitTargetVector = ( (Aim Dot Normal(TargetVelocity)) > 0.98 );
	}
}

simulated event vector GetPhysFireStartLocation()
{
	return MyVehicle.GetPhysicalFireStartLoc(self);
}

/**
 * IsAimCorrect - Returns true if the turret associated with a given seat is aiming correctly
 *
 * @return TRUE if we can hit where the controller is aiming
 */
simulated event bool IsAimCorrect()
{
	if (WeaponProjectiles.length == 0 || WeaponProjectiles[0] == None || !ClassIsChildOf(WeaponProjectiles[0], class'UTProjectile'))
	{
		return Super.IsAimCorrect();
	}
	else
	{
		return (RemoteCamera == None || bCanHitTargetVector);
	}
}

/*
 * SPMA can't aim if no remote camera, so no crosshair
 */
simulated function DrawWeaponCrosshair( Hud HUD )
{
}

function HolderDied()
{
	Super.HolderDied();

	if (RemoteCamera != None && RemoteCamera.bDeployed)
	{
		RemoteCamera.Disconnect();
	}
}

/** Don't show the 'friendly dont shoot' indicator when aiming to fire a camera. */
simulated function bool EnableFriendlyWarningCrosshair()
{
	return false;
}

defaultproperties
{

}
