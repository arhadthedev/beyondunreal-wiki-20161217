/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVWeap_EradicatorCannon_Content extends UTVWeap_SPMACannon_Content
	hidedropdown;

simulated function Projectile ProjectileFire()
{
	local Projectile Proj;

	Proj = Super.ProjectileFire();
	if ( (Proj != None) && ClassIsChildOf(Proj.Class, class'UTProj_SPMACamera') )
	{
		Proj.MyDamageType = class'UTDmgType_EradicatorCameraCrush';
	}
	return Proj;
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireSnd(0)=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Fire'
	WeaponProjectiles(0)=class'UTProj_EradicatorShell_Content'
	FireInterval(0)=+4.0

	WeaponFireTypes(1)=EWFT_Projectile
	WeaponFireSnd(1)=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Fire'
	WeaponProjectiles(1)=class'UTProj_SPMACamera_Content'
	FireInterval(1)=+1.5

	FireTriggerTags=(CannonFire)
	AltFireTriggertags=(CameraFire)

	BoomSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_DistantSPMA'
	IncomingSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_ShellIncoming'
	VehicleClass=class'UTVehicle_Eradicator'
	AIRating=1.5
}
