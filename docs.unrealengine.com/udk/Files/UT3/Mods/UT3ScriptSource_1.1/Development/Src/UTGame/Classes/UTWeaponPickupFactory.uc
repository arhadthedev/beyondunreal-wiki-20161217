/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWeaponPickupFactory extends UTPickupFactory
	native;

var() class<UTWeapon> WeaponPickupClass;
var bool bWeaponStay;
/** The glow that emits from the base while the weapon is available */
var ParticleSystemComponent BaseGlow;
/** Used to scale weapon pickup drawscale */
var float WeaponPickupScaling;



simulated function InitializePickup()
{
	local int i;

	InventoryType = WeaponPickupClass;
	if ( InventoryType == None )
	{
		GotoState('Disabled');
		return;
	}

	PivotTranslation = WeaponPickupClass.Default.PivotTranslation;

	SetWeaponStay();

	// set up location messages
	if ( WeaponPickupClass.default.bHasLocationSpeech )
	{
		bHasLocationSpeech = true;
		for ( i=0; i<WeaponPickupClass.default.LocationSpeech.Length; i++ )
		{
			LocationSpeech[i] = WeaponPickupClass.default.LocationSpeech[i];
		}
	}

	Super.InitializePickup();
}

simulated function SetPickupVisible()
{
	BaseGlow.SetActive(true);
	Super.SetPickupVisible();
}
simulated function SetPickupHidden()
{
	BaseGlow.DeactivateSystem();
	Super.SetPickupHidden();
}

simulated function SetPickupMesh()
{
	Super.SetPickupMesh();
	if ( PickupMesh != none )
	{
		PickupMesh.SetScale(PickupMesh.Scale * WeaponPickupScaling);
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'InventoryType')
	{
		if (InventoryType != WeaponPickupClass)
		{
			WeaponPickupClass = class<UTWeapon>(InventoryType);
			Super.ReplicatedEvent(VarName);
		}
	}
	else
	{

		Super.ReplicatedEvent(VarName);
	}
}

function bool CheckForErrors()
{
	if ( Super.CheckForErrors() )
		return true;

	if ( WeaponPickupClass == None )
	{
		`log(self$" no weapon pickup class");
		return true;
	}
	else if (ClassIsChildOf(WeaponPickupClass, class'UTDeployable'))
	{
		`Log(self @ "cannot hold deployables");
		return true;
	}

	return false;
}

/**
 * If our charge is not a super weapon and weaponstay is on, set weapon stay
 */

function SetWeaponStay()
{
	bWeaponStay = ( !WeaponPickupClass.Default.bSuperWeapon && UTGame(WorldInfo.Game).bWeaponStay );
}

function StartSleeping()
{
	if (!bWeaponStay)
	    GotoState('Sleeping');
}

function bool AllowRepeatPickup()
{
    return !bWeaponStay;
}

function PickedUpBy(Pawn P)
{
	local UTPlayerController PC;

	Super.PickedUpBy(P);
	if ( WeaponPickupClass.Default.bCanDestroyBarricades )
	{
		// notify any players that have this as their objective
		ForEach WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			if ( (PC.LastAutoObjective == self) && (PC != P.Controller) )
			{
				PC.CheckAutoObjective(true);
			}
		}
	}
}

function SpawnCopyFor( Pawn Recipient )
{
	local Inventory Inv;
	if ( UTInventoryManager(Recipient.InvManager)!=None )
	{
		Inv = UTInventoryManager(Recipient.InvManager).HasInventoryOfClass(WeaponPickupClass);
		if ( UTWeapon(Inv)!=none )
		{
			UTWeapon(Inv).AddAmmo(WeaponPickupClass.Default.AmmoCount);
			UTWeapon(Inv).AnnouncePickup(Recipient);
			return;
		}
	}
	Recipient.MakeNoise(0.2);
	super.SpawnCopyFor(Recipient);
}

defaultproperties
{
	bMovable=FALSE
	bStatic=FALSE

	bDoVisibilityFadeIn=FALSE // weapons are all skeletal meshes and don't do the ResIn effect. Also most weapons are always available
	bWeaponStay=true
	bRotatingPickup=true
	bCollideActors=true
	bBlockActors=true
	WeaponPickupScaling=+1.2

	RespawnSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Respawn_Cue'

	Begin Object NAME=CollisionCylinder
		BlockZeroExtent=false
	End Object

	Begin Object Name=BaseMeshComp
		StaticMesh=StaticMesh'Pickups.WeaponBase.S_Pickups_WeaponBase'
		Translation=(X=0.0,Y=0.0,Z=-44.0)
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
	End Object

	Begin Object Class=ParticleSystemComponent Name=GlowEffect
		bAutoActivate=TRUE
		Template=ParticleSystem'Pickups.WeaponBase.Effects.P_Pickups_WeaponBase_Glow'
		Translation=(X=0.0,Y=0.0,Z=-44.0)
		SecondsBeforeInactive=1.0f
	End Object
	BaseGlow=GlowEffect
	Components.Add(GlowEffect)

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformPickUp
		Samples(0)=(LeftAmplitude=90,RightAmplitude=35,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearIncreasing,Duration=0.15)
	End Object
	PickUpWaveForm=ForceFeedbackWaveformPickUp
}

