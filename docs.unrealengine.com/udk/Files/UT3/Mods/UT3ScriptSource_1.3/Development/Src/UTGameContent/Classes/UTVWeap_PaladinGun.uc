/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTVWeap_PaladinGun extends UTVehicleWeapon
	HideDropDown;

var() float MaxShieldHealth;
/** how long after the last shield activation before it starts recharging again */
var() float MaxDelayTime;
var() float ShieldRechargeRate;
var float LastShieldHitTime;

var float CurrentShieldHealth;
var float CurrentDelayTime;
var bool bPutShieldUp;

replication
{
	if (bNetOwner && Role == ROLE_Authority)
		CurrentShieldHealth;
}

function byte BestMode()
{
	local UTBot B;

	if (CurrentShieldHealth <= 0.f)
	{
		return 0;
	}
	if (Projectile(Instigator.Controller.Focus) != None)
	{
		return 1;
	}

	B = UTBot(Instigator.Controller);
	if (B == None || B.Enemy == None)
	{
		return 0;
	}

	if (bPutShieldUp || !B.LineOfSightTo(B.Enemy))
	{
		LastShieldHitTime = WorldInfo.TimeSeconds;
		bPutShieldUp = false;
		return 1;
	}

	if (VSize(B.Enemy.Location - Location) < 900.f)
	{
		return (IsInState('ShieldActive') ? 0 : 1);
	}
	if (IsInState('ShieldActive') && WorldInfo.TimeSeconds - LastShieldHitTime < 2.f)
	{
		return 1;
	}
	else if (B.Enemy != B.Focus)
	{
		return 0;
	}
	else
	{
		// check if near friendly node, and between it and enemy
		if ( B.Squad.SquadObjective != None && VSize(B.Pawn.Location - B.Squad.SquadObjective.Location) < 1000.f
			&& (Normal(B.Enemy.Location - B.Squad.SquadObjective.Location) dot Normal(B.Pawn.Location - B.Squad.SquadObjective.Location)) > 0.7 )
		{
			return 1;
		}

		// use shield if heavily damaged
		if (B.Pawn.Health < 0.3 * B.Pawn.HealthMax)
		{
			return 1;
		}

		// use shield against heavy vehicles
		if ( UTVehicle(B.Enemy) != None && UTVehicle(B.Enemy).ImportantVehicle() && B.Enemy.Controller != None
			&& (vector(B.Enemy.Controller.Rotation) dot Normal(Instigator.Location - B.Enemy.Location)) > 0.9 )
		{
			return 1;
		}

		return 0;
	}
}

function ShieldAgainstIncoming(optional Projectile P)
{
	local AIController Bot;

	Bot = AIController(Instigator.Controller);
	if (Bot != None)
	{
		if (P != None)
		{
			if (GetTimerRate('RefireCheckTimer') - GetTimerCount('RefireCheckTimer') <= VSize(P.Location - MyVehicle.Location) - 1100.f / FMax(1.0, VSize(P.Velocity)))
			{
				// put shield up if pointed in right direction
				if (Bot.Skill < 5.f || (Normal(P.Location - MyVehicle.GetPhysicalFireStartLoc(self)) dot vector(MyVehicle.GetWeaponAim(self))) >= 0.7)
				{
					LastShieldHitTime = WorldInfo.TimeSeconds;
					bPutShieldUp = true;
					Bot.FireWeaponAt(Bot.Focus);
				}
				else if (Bot.Enemy == None || Bot.Enemy == P.Instigator)
				{
					Bot.Focus = Bot.Enemy;
					LastShieldHitTime = WorldInfo.TimeSeconds;
					bPutShieldUp = true;
					Bot.FireWeaponAt(Bot.Focus);
				}
			}
		}
		else if (Bot.Enemy != None)
		{
			if (GetTimerRate('RefireCheckTimer') - GetTimerCount('RefireCheckTimer') <= 0.2 || FRand() >= 0.6)
			{
				LastShieldHitTime = WorldInfo.TimeSeconds;
				bPutShieldUp = true;
				Bot.FireWeaponAt(Bot.Focus);
			}
		}
	}
}

function NotifyShieldHit(int Damage)
{
	CurrentShieldHealth = FMax(CurrentShieldHealth - Damage, 0.f);
	LastShieldHitTime = WorldInfo.TimeSeconds;
}

simulated event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (CurrentShieldHealth < MaxShieldHealth)
	{
		if (CurrentDelayTime < MaxDelayTime)
		{
			CurrentDelayTime += DeltaTime;
		}
		else
		{
			CurrentShieldHealth = FMin(CurrentShieldHealth + ShieldRechargeRate * DeltaTime, MaxShieldHealth);
		}
	}

}

simulated event float GetPowerPerc()
{
	return CurrentShieldHealth / MaxShieldHealth;
}

simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	return (FireModeNum == 1) ? (CurrentShieldHealth > float(Amount)) : Super.HasAmmo(FireModeNum, Amount);
}

simulated state ShieldActive extends WeaponFiring
{
	simulated function bool CanHitDesiredTarget(vector SocketLocation, rotator SocketRotation, vector DesiredAimPoint, Actor TargetActor, out vector RealAimPoint)
	{
		return true;
	}

	simulated event Tick(float DeltaTime)
	{
		local UTVehicle_Paladin Paladin;

		if (Role == ROLE_Authority)
		{
			if (CurrentShieldHealth <= 0.f)
			{
				// Ran out of shield energy so turn it off
				GotoState('Active');
			}
			else
			{
				// don't allow center of shield to project through walls
				Paladin = UTVehicle_Paladin(MyVehicle);
				if (Paladin != None && Paladin.IsShieldObstructed())
				{
					EndFire(CurrentFireMode);
					ClientEndFire(CurrentFireMode);
				}
			}
		}
	}

	/** updates the shield health percent on the vehicle to be applied to the effects */
	simulated function UpdateShieldHealthPct()
	{
		local UTVehicle_Paladin Paladin;

		Paladin = UTVehicle_Paladin(MyVehicle);
		if (Paladin != None)
		{
			Paladin.ShieldHealthPct = FloatToByte(GetPowerPerc());
			Paladin.ShieldHealthUpdated();
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		bFastRepeater = true;
		UpdateShieldHealthPct();
		SetTimer(0.1, true, 'UpdateShieldHealthPct');

		Super.BeginState(PreviousStateName);

		CurrentDelayTime = 0.0;

		MyVehicle.SetShieldActive(SeatIndex, true);
	}

	simulated function EndState(name NextStateName)
	{
		bFastRepeater = false;
		ClearTimer('UpdateShieldHealthPct');

		Super.EndState(NextStateName);

		MyVehicle.SetShieldActive(SeatIndex, false);
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
 	WeaponFireTypes(1)=EWFT_Custom
	WeaponProjectiles(0)=class'UTProj_PaladinEnergyBolt'
	FiringStatesArray(1)=ShieldActive
	FireInterval(0)=2.35
	FireInterval(1)=0.1
	ShotCost(0)=0
	ShotCost(1)=0
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_Fire'

	bRecommendSplashDamage=true

	FireTriggerTags=(PrimaryFire)

	MaxShieldHealth=1200.0
	CurrentShieldHealth=1200.0
	MaxDelayTime=2.5
	ShieldRechargeRate=350.0
	VehicleClass=class'UTVehicle_Paladin'
	AmmoDisplayType=EAWDS_BarGraph
}
