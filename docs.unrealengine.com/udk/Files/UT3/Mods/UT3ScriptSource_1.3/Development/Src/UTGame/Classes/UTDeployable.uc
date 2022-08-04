/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTDeployable extends UTWeapon
	abstract
	native;

/** the factory that spawned this deployable */
var UTDeployablePickupFactory Factory;

/** class of deployable actor to spawn */
var class<UTDeployedActor> DeployedActorClass;

/** Toss strength when throwing out deployable */
var float TossMag;

/** Scale for deployable when being scaled for a preview in a stealth vehicle*/
var float PreviewScale;

/** if true, factory delays respawn countdown until this deployable is used */
var bool bDelayRespawn;

/** Radius to check against for other deployables nearby*/
var() float DeployCheckRadiusSq;

var SoundCue DeployFailedSoundCue;

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	// players can only carry one deployable at a time
	return ClassIsChildOf(ItemClass, class'UTDeployable');
}

static function InitPickupMesh(PrimitiveComponent InMesh);

static function float BotDesireability(Actor PickupHolder, Pawn P, Controller C)
{
	return (UTDeployable(P.Weapon) != None) ? -1.0 : Super.BotDesireability(PickupHolder, P, C);
}

static function class<Actor> GetTeamDeployable(int TeamNum)
{
	return default.DeployedActorClass;
}

/** Recommend an objective for player carrying this deployable */
function UTGameObjective RecommendObjective(Controller C)
{
	return None;
}

simulated function vector GetPhysicalFireStartLoc(optional vector AimDir)
{
	return (Instigator != none) ? (Instigator.GetPawnViewLocation() + (FireOffset >> Instigator.GetViewRotation())) : Location;
}


//Given an actor, its position and a radius determine if we are near any deployables
static function bool DeployablesNearby(Actor MyActor, vector MyLocation, float CheckRadiusSq)
{
	local float DistSqr;
	local UTDeployedActor DeployedActor;
	local UTSlowVolume SlowVolume;

	if ( MyActor.Instigator == None )
	{
		return true;
	}

	//Check the area for deployables
	foreach MyActor.DynamicActors(class'UTDeployedActor', DeployedActor)
	{
		if ( MyActor.WorldInfo.GRI.OnSameTeam(MyActor.Instigator, DeployedActor) )
		{
			DistSqr = VSizeSq(DeployedActor.Location - MyLocation);
			if (DistSqr < CheckRadiusSq)
			{
				return TRUE;
			}
		}
	}

	//Check for slow volumes too (they don't derive from the same hierarchy)
	foreach MyActor.DynamicActors(class'UTSlowVolume', SlowVolume)
	{
		DistSqr = VSizeSq(SlowVolume.Location - MyLocation);
		if (DistSqr < CheckRadiusSq)
		{
			return TRUE;
		}
	}

	return FALSE;
}

/** attempts to deploy the item
 * @return whether or not deploying was successful
 */
function bool Deploy()
{
	local UTDeployedActor DeployedActor;
	local vector SpawnLocation;
	local rotator Aim, FlatAim;

	SpawnLocation = GetPhysicalFireStartLoc();
	Aim = GetAdjustedAim(SpawnLocation);
	FlatAim.Yaw = Aim.Yaw;

	DeployedActor = Spawn(DeployedActorClass, self,, SpawnLocation, FlatAim);
	if (DeployedActor != None)
	{
		if ( AmmoCount <= 0 )
		{
			if ( Factory != None )
			{
				DeployedActor.OnDeployableUsedUp = Factory.DeployableUsed;
			}
			bForceHidden = true;
			Mesh.SetHidden(true);
		}
		DeployedActor.Velocity = TossMag * vector(Aim);
		return true;
	}

	return false;
}

/** called when User tries to deploy us and fails for some reason */
function DeployFailed(optional bool bDeployablesAreNearby=false)
{
	// refund ammo
	AddAmmo(ShotCost[CurrentFireMode]);
	// call client version
	ClientDeployFailed(bDeployablesAreNearby);
}

/** called to notify client of deploy failure */
reliable client function ClientDeployFailed(bool bDeployablesAreNearby)
{
	if (DeployFailedSoundCue != None)
	{
		Instigator.PlaySound(DeployFailedSoundCue);
	}

	if (bDeployablesAreNearby)
	{
		//This is the message "unable to deploy due to close proximity"
		Instigator.ReceiveLocalizedMessage(class'UTStealthVehicleMessage', 2);
	}
	else
	{
		//This is the message "Can't deploy here"
		Instigator.ReceiveLocalizedMessage(class'UTDeployableMessage', 0);
	}
}

simulated function CustomFire()
{
	local bool bAreDeployablesNearby;

	//Deployable radius check here so UTSlowVolume uses it too
	if (Role == ROLE_Authority)
	{
		bAreDeployablesNearby = DeployablesNearby(self, GetPhysicalFireStartLoc(), DeployCheckRadiusSq);
		if (bAreDeployablesNearby)
		{
			DeployFailed(bAreDeployablesNearby);
		}
		else if (!Deploy())
		{
			DeployFailed();
		}
	}
}

/*
 * no crosshair for deployable
 */
simulated function DrawWeaponCrosshair( Hud HUD )
{
}

simulated event Destroyed()
{
	// make sure client finishes any in-progress switch away from this weapon
	if (Instigator != None && Instigator.Weapon == self && InvManager != None && InvManager.PendingWeapon != None)
	{
		Instigator.InvManager.ChangedWeapon();
	}

	if (Role == ROLE_Authority && AmmoCount > 0 && Factory != None)
	{
		Factory.DeployableUsed(self);
	}

	Super.Destroyed();
}

/** called from bot's decision logic while this deployable is its Weapon
 * @return whether bot should deploy us right now
 */
function bool ShouldDeploy(UTBot B)
{
	return B.IsRetreating();
}

function float GetAIRating()
{
	// force AI to switch to it like humans are
	return 10;
}

simulated function float MaxRange()
{
	return 200.0;
}

function bool CanAttack(Actor Other)
{
	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}

	// check that target is within range
	if (VSize(Instigator.Location - Other.Location) > MaxRange())
	{
		return false;
	}

	// check that can see target
	return Instigator.Controller.LineOfSightTo(Other);
}

simulated function bool AllowSwitchTo(Weapon NewWeapon)
{
	return ( (AmmoCount <= 0 || (UTInventoryManager(InvManager) != None && UTInventoryManager(InvManager).bInfiniteAmmo))
		&& Super.AllowSwitchTo(NewWeapon) );
}

reliable client function ClientWeaponSet(bool bOptionalSet)
{
	// force switch to deployables so you can't switch away from them until they're used
	Super.ClientWeaponSet(false);
}

auto state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		// destroy if we're out of ammo, so the player can pick up a different deployable
		if (Role == ROLE_Authority && !HasAnyAmmo())
		{
			Destroy();
		}
	}
}

/**
 * State WeaponEquipping
 * The Weapon is in this state while transitioning from Inactive to Active state.
 * Typically, the weapon will remain in this state while its selection animation is being played.
 * While in this state, the weapon cannot be fired.
 */
simulated state WeaponEquipping
{
	simulated function WeaponEquipped()
	{
		local UTPlayerController PC;

		super.WeaponEquipped();

		if ( Role == ROLE_Authority )
		{
			PC = UTPlayerController(Instigator.Controller);
			if ( PC != None )
			{
				 PC.CheckAutoObjective(true);
			}
		}
	}
}

defaultproperties
{
	WeaponFireTypes[0]=EWFT_Custom
	WeaponFireTypes[1]=EWFT_None
	ShotCost[0]=1
	AmmoCount=1
	MaxAmmoCount=1
	InventoryGroup=11
	RespawnTime=30.0
	TossMag=500.0
	bDelayRespawn=true
	AIRating=0.6

	DeployCheckRadiusSq=1440000.0;

	bExportMenuData=false
	PreviewScale=1.0

	FireInterval(0)=+0.25
	FireInterval(1)=+0.25
}
