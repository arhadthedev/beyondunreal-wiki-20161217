/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTAttachment_RocketLauncher extends UTWeaponAttachment;

/** list of anims to play for loading the RL */
var array<name> LoadUpAnimList;

simulated function FireModeUpdated(byte FiringMode, bool bViaReplication)
{
	if (FiringMode == 1 && Instigator.FlashCount == 0)
	{
		UTAnimNodeSequence(Mesh.Animations).PlayAnimationSet(LoadUpAnimList, 0.5, false);
	}
	else
	{
		Mesh.StopAnim();
	}
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{
	Super.ThirdPersonFireEffects(HitLocation);

	Mesh.StopAnim();
}

/** 
*   Optimized equivalent of calling ThirdPersonFireEffects while in splitscreen
*/
simulated function SplitScreenEffects(vector HitLocation)
{
	Super.SplitScreenEffects(HitLocation);

	//Mesh.StopAnim();
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
	Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

	Mesh.StopAnim();
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
		AnimSets[0]=AnimSet'WP_RocketLauncher.Anims.K_WP_RocketLauncher_3P'
		Translation=(X=1,Y=-1,Z=0)
		Rotation=(Roll=1000)
		Scale=1.1
	End Object

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=WP_RocketLauncher.Effects.P_WP_RockerLauncher_3P_Muzzle_Flash
	MuzzleFlashDuration=0.33;
	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'
	WeaponClass=class'UTWeap_RocketLauncher'

	LoadUpAnimList[0]=WeaponAltFireQueue1
	LoadUpAnimList[1]=WeaponAltFireQueue2
	LoadUpAnimList[2]=WeaponAltFireQueue3
	FireAnim=WeaponFire
}
