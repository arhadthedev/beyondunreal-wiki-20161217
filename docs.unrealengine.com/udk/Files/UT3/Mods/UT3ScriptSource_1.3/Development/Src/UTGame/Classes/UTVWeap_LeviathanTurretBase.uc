/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTVWeap_LeviathanTurretBase extends UTVehicleWeapon
	abstract;

/** how long the shield lasts */
var float ShieldDuration;
/** how long after using the shield before it can be used again */
var float ShieldRecharge;
/** next time shield can be used */
var float ShieldAvailableTime;
/** AI flag */
var bool bPutShieldUp;

/** whether shield is currently up (can't state scope because can fire both modes simultaneously) */
var bool bShieldActive;

simulated function float GetPowerPerc()
{
	if (bShieldActive)
	{
		return FClamp(1.0 - GetTimerCount('DeactivateShield')/ShieldDuration, 0.0, 1.0);
	}
	else
	{
		return FClamp(1.0 - (ShieldAvailableTime - WorldInfo.TimeSeconds)/ShieldRecharge, 0.0, 1.0);
	}
}

function byte BestMode()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if (B == None || B.Enemy == None || WorldInfo.TimeSeconds < ShieldAvailableTime)
	{
		return 0;
	}
	// use shield if enemy is or may soon shoot at us
	else if ( WorldInfo.TimeSeconds - B.LastUnderFire < 1.0 || B.WarningProjectile != None ||
		B.InstantWarningShooter != None || vector(B.Enemy.GetViewRotation()) dot Normal(MyVehicle.Location - B.Enemy.Location) > 0.5 )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

function NotifyShieldHit(int Damage);

simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	return (FireModeNum == 1) ? (WorldInfo.TimeSeconds >= ShieldAvailableTime) : Super.HasAmmo(FireModeNum, Amount);
}	

simulated function BeginFire(byte FireModeNum)
{
	if (FireModeNum == 1)
	{
		if (WorldInfo.TimeSeconds >= ShieldAvailableTime)
		{
			bShieldActive = true;
			MyVehicle.SetShieldActive(SeatIndex, true);
			ShieldAvailableTime = WorldInfo.TimeSeconds + ShieldDuration + ShieldRecharge;
			SetTimer(ShieldDuration, false, 'DeactivateShield');
		}
	}
	else
	{
		Super.BeginFire(FireModeNum);
	}
}

simulated function DeactivateShield()
{
	bShieldActive = false;
	MyVehicle.SetShieldActive(SeatIndex, false);
}

/*********************************************************************************************
 * State WeaponFiring
 * This is the default Firing State.  It's performed on both the client and the server.
 *********************************************************************************************/
simulated state WeaponFiring
{
	/**
	 * We override BeginFire() to keep shield clicks from resetting the fire delay
	 */
	simulated function BeginFire( Byte FireModeNum )
	{
		if ( CheckZoom(FireModeNum) )
		{
			return;
		}

		Global.BeginFire(FireModeNum);
	}
}

defaultproperties
{
 	WeaponFireTypes(0)=EWFT_InstantHit
 	WeaponFireTypes(1)=EWFT_None

	AmmoDisplayType=EAWDS_BarGraph

	ShotCost(0)=0
	bInstantHit=true
	ShotCost(1)=0
	bFastRepeater=true

	ShieldDuration=4.0
	ShieldRecharge=5.0
}
