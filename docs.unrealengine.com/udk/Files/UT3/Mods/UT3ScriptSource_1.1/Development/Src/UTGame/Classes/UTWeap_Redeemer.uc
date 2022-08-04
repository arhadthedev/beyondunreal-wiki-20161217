/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_Redeemer extends UTWeapon
	abstract;

/** This is the class spawn when the redeemer is fired **/
var class<UTRemoteRedeemer> WarHeadClass;

var MaterialInstanceConstant WeaponMaterialInstance;
var name FlickerParamName;
var LinearColor PowerColors[2];
var bool bFlickerOn;
var class<Projectile> RedRedeemerClass;

function byte BestMode()
{
	return 0;
}

simulated function bool CoversScreenSpace(vector ScreenLoc, Canvas Canvas)
{
	return ( (ScreenLoc.X > (1-WeaponCanvasXPct)*Canvas.ClipX)
		|| (ScreenLoc.Y > (1-WeaponCanvasYPct)*Canvas.ClipY) );
}

simulated function EWeaponHand GetHand()
{
	// Redeemer is two handed so don't adjust based on hand setting
	return HAND_Right;
}

/**
 * Returns the type of projectile to spawn.  We use a function so subclasses can
 * override it if needed (case in point, homing rockets).
 */
function class<Projectile> GetProjectileClass()
{
	if ( (Instigator != None) && (Instigator.GetTeamNum() == 0) )
	{
		return RedRedeemerClass;
	}
	return WeaponProjectiles[CurrentFireMode];
}

simulated function Projectile ProjectileFire()
{
	local UTRemoteRedeemer Warhead;

	if (CurrentFireMode == 0 || Role<ROLE_Authority)
	{
		return super.ProjectileFire();
	}

	//@warning: remote redeemer can't have Instigator in its owner chain, because Instigator will be set to be owned by the redeemer when
	//		Instigator enters it - otherwise it would be disallowed due to creating an Owner loop, breaking clients
	WarHead = Spawn(WarHeadClass,,, GetPhysicalFireStartLoc(), Instigator.GetViewRotation());
	if (WarHead != None)
	{
		Warhead.TryToDrive(Instigator);
	}

	IncrementFlashCount();

	return None;
}

simulated function bool AllowSwitchTo(Weapon NewWeapon)
{
	local UTGameReplicationInfo GRI;

	GRI = UTGameReplicationInfo(WorldInfo.GRI);
	return ( (AmmoCount <= 0 || GRI == None || !GRI.bConsoleServer || (UTInventoryManager(InvManager) != None && UTInventoryManager(InvManager).bInfiniteAmmo))
		&& Super.AllowSwitchTo(NewWeapon) );
}

simulated event Destroyed()
{
	// make sure client finishes any in-progress switch away from this weapon
	if (Instigator != None && Instigator.Weapon == self && InvManager != None && InvManager.PendingWeapon != None)
	{
		Instigator.InvManager.ChangedWeapon();
	}

	Super.Destroyed();
}

function float SuggestAttackStyle()
{
	return -1.0;
}

function float SuggestDefenseStyle()
{
	return -1.0;
}

function float GetAIRating()
{
	local UTBot B;

	B = UTBot(Instigator.Controller);
	if ( B == None )
		return 0.4;

	// force bot to use if on console (like humans are forced to) or if required to destroy objective
	if (WorldInfo.IsConsoleBuild() || (B.Squad != None && UTWarfareBarricade(B.Squad.SquadObjective) != None))
	{
		return 10;
	}

	if ( B.IsShootingObjective() )
		return 2.0;

	if ( (B.Enemy == None) || B.Enemy.bCanFly || VSize(B.Enemy.Location - Instigator.Location) < 2400 )
		return 0.4;

	return AIRating;
}

auto state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		// destroy if we're out of ammo, since there are no Redeemer ammo pickups
		if (Role == ROLE_Authority && !HasAnyAmmo())
		{
			Destroy();
		}
	}
}

simulated function SetSkin(Material NewMaterial)
{
	Super.SetSkin(NewMaterial);
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		WeaponMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(0);
	}
}

simulated function Flicker()
{
	if(WeaponMaterialInstance != none && WorldInfo.NetMode != NM_DEDICATEDSERVER && FlickerParamName != '')
	{
		WeaponMaterialInstance.SetVectorParameterValue(FlickerParamName,MakeLinearColor(3.0,3.0,3.0,1.0));
	}
}

simulated function FlickerOff()
{
	if(WeaponMaterialInstance != none && WorldInfo.NetMode != NM_DEDICATEDSERVER && FlickerParamName != '')
	{
		WeaponMaterialInstance.SetVectorParameterValue(FlickerParamName,MakeLinearColor(0.0,0.0,0.0,1.0));
	}

}

reliable client function ClientWeaponSet(bool bOptionalSet)
{
	// force switch to Redeemer if you can't switch away from it (on console)
	Super.ClientWeaponSet(bOptionalSet && !WorldInfo.bUseConsoleInput);
}

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		bFlickerOn = true;
		Flicker();
	}
	simulated function EndState(Name NextStateName)
	{
		bFlickerOn = false;
		ClearTimer('Flicker');
		global.Flicker(); // let's make absolutely sure we're on
		super.EndState(NextStateName);
	}

	simulated function Flicker()
	{
		local float Level;
		if(WeaponMaterialInstance != none && WorldInfo.NetMode != NM_DEDICATEDSERVER && FlickerParamName != '')
		{
			Level = bFlickerOn?0.0:3.0;
			bFlickerOn = !bFlickerOn;
			WeaponMaterialInstance.SetVectorParameterValue(FlickerParamName,MakeLinearColor(Level,Level,Level,1.0));
			SetTimer(frand()/4.0+0.25f,false,'Flicker'); // from 1/4 sec to 1/2 second at random. Will be cleared on end state (or on final run out of this state)
		}
	}
}

simulated state WeaponAbortEquip
{
	simulated function BeginState(name PrevStateName)
	{
		FlickerOff();
		super.BeginState(PrevStateName);
	}
}

simulated state WeaponPuttingDown
{
	simulated function BeginState( Name PreviousStateName )
	{
		super.BeginState(PreviousStateName);
		FlickerOff();
	}
}

defaultproperties
{
	bCanDestroyBarricades=true
	bWarnIfInLocker=true
	ProjectileSpawnOffset=50.0
	SmallWeaponsOffset=(X=0.0,Y=0.0,Z=0.0)
}
