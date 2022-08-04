/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_LeviathanPrimary extends UTVehicleWeapon
	HideDropDown;

/** the amount of time the same target must be kept for the shot to go off */
var float PaintTime;

/** How long after the shot does it take to recharge (should be the time of the effect) */
var float RechargeTime;

/** units/sec player can move their aim and not reset the paint timer */
var float TargetSlack;
/** current target location */
var vector TargetLocation;
/** Ambient sound played while acquiring the target */
var SoundCue AcquireSound;

reliable server function ServerStartFire(byte FireModeNum)
{
	local UTVehicle_Leviathan MyLevi;

	// can't fire while deploying in progress
	MyLevi = UTVehicle_Leviathan(MyVehicle);
	if (MyLevi == None || MyLevi.DeployedState != EDS_Deploying)
	{
		Super.ServerStartFire(FireModeNum);
	}
	else
	{
		ClientEndFire(FireModeNum);
	}
}

simulated function SendToFiringState( byte FireModeNum )
{
	local UTVehicle_Leviathan MyLevi;

	// make sure fire mode is valid
	if( FireModeNum >= FiringStatesArray.Length )
	{
		WeaponLog("Invalid FireModeNum", "Weapon::SendToFiringState");
		return;
	}

	// Ignore a none fire type
	if( WeaponFireTypes[FireModeNum] == EWFT_None )
	{
		return;
	}

	MyLevi = UTVehicle_Leviathan(MyVehicle);
	if (MyLevi != none)
	{
		// set current fire mode
		SetCurrentFireMode(FireModeNum);

		if ( MyLevi.DeployedState == EDS_Undeployed )
		{
			GotoState('WeaponFiring');
		}
		else if (MyLevi.DeployedState == EDS_Deployed )
		{
			GotoState('WeaponBeamFiring');
		}
	}
}

reliable client function ClientHasFired()
{
	GotoState('WeaponRecharge');
}

simulated state WeaponBeamFiring
{
	simulated function BeginState( Name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);

		if (Role == ROLE_Authority)
		{
			SetTimer(PaintTime,false,'FireWeapon');
		}

		InstantFire();
	}

	function FireWeapon()
	{
		local UTEmit_LeviathanExplosion Blast;
		local actor HitActor;
		local vector HitLocation, HitNormal, SpawnLoc;

		HitActor = Trace(HitLocation, HitNormal, TargetLocation + Vect(0,0,64), TargetLocation, false);
		SpawnLoc = (HitActor == None) ? TargetLocation + Vect(0,0,32) : 0.5 * (TargetLocation + HitLocation);
		Blast = Spawn(class'UTEmit_LeviathanExplosion', Instigator,, SpawnLoc);
		Blast.InstigatorController = Instigator.Controller;

		if ( !Instigator.IsLocallyControlled() )
		{
			ClientHasFired();
		}
		GotoState('WeaponRecharge');
	}

	/**
	 * When leaving the state, shut everything down
	 */
	simulated function EndState(Name NextStateName)
	{
		ClearTimer('FireWeapon');
		Super.EndState(NextStateName);
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function SetFlashLocation(vector HitLocation)
	{
		if (ROLE == ROLE_Authority)
		{
			Global.SetFlashLocation(HitLocation);
			TargetLocation = HitLocation;
		}
	}
}

simulated state WeaponRecharge
{
	simulated function BeginState( Name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);
		SetTimer(RechargeTime,false,'Charged');
		TimeWeaponFiring(0);
	}

	simulated function EndState(Name NextStateName)
	{
		ClearTimer('RefireCheckTimer');
		ClearFlashLocation();
		Super.EndState(NextStateName);
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function Charged()
	{
		GotoState('Active');
	}
}

simulated function Projectile ProjectileFire()
{
	local vector ActualStart,ActualEnd, HitLocation, HitNormal;
	local UTProj_LeviathanBolt Bolt;

	Bolt = UTProj_LeviathanBolt( super.ProjectileFire() );

	if (Bolt != none)
	{
		ActualStart = Instigator.GetWeaponStartTraceLocation();
		ActualEnd = ActualStart + vector(GetAdjustedAim(ActualStart)) * GetTraceRange();

		if ( Trace(HitLocation,HitNormal, ActualEnd, ActualStart) != none )
		{
			ActualEnd = HitLocation;
		}

		Bolt.TargetLoc = ActualEnd;
	}
	return Bolt;
}

simulated function float GetMaxFinalAimAdjustment()
{
	local UTVehicle_Leviathan MyLevi;

	MyLevi = UTVehicle_Leviathan(MyVehicle);
	if ( MyLevi != none && MyLevi.DeployedState == EDS_Deployed )
	{
		return 0.998;
	}
	else
	{
		return Super.GetMaxFinalAimAdjustment();
	}
}

function bool CanAttack(Actor Other)
{
	local bool bResult;

	bResult = Super.CanAttack(Other);
	// if deployed bot is trying to shoot enemy and can't hit it but can hit where enemy was recently, allow it to shoot anyway
	// (big nuke might still hit from there)
	if ( !bResult && UTVehicle_Deployable(MyVehicle) != None && UTVehicle_Deployable(MyVehicle).IsDeployed() &&
		UTBot(Instigator.Controller) != None && Other == Instigator.Controller.Enemy &&
		FastTrace(UTBot(Instigator.Controller).LastSeenPos, InstantFireStartTrace()) )
	{
		bResult = true;
	}

	return bResult;
}

simulated function NotifyVehicleDeployed()
{
	bInstantHit = true;
	AimTraceRange = MaxRange();
	bFastRepeater = false;
	bRecommendSplashDamage = true;
	bLockedAimWhileFiring = true;
}

simulated function NotifyVehicleUndeployed()
{
	bInstantHit = false;
	AimTraceRange = MaxRange();
	bFastRepeater = true;
	bRecommendSplashDamage = false;
	bLockedAimWhileFiring = false;
}

defaultproperties
{
 	WeaponFireTypes(0)=EWFT_Projectile
 	WeaponFireTypes(1)=EWFT_None
	WeaponProjectiles(0)=class'UTProj_LeviathanBolt'
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_TurretFire'
	FireInterval(0)=+0.3
	RechargeTime=3.0
	ShotCost(0)=0
	ShotCost(1)=0
	Spread[0]=0.015
	bCanDestroyBarricades=true
	bFastRepeater=true

	bZoomedFireMode(1)=1

	ZoomedTargetFOV=20.0
	ZoomedRate=60.0

	PaintTime=2.0
	TargetSlack=50.0

	FireTriggerTags=(DriverMF_L,DriverMF_R)

	VehicleClass=class'UTVehicle_Leviathan_Content'

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=100,RightAmplitude=90,LeftFunction=WF_LinearIncreasing,RightFunction=WF_LinearIncreasing,Duration=2.000)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}
