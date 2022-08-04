/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTAttachment_Redeemer extends UTWeaponAttachment;

simulated function AttachTo(UTPawn OwnerPawn)
{
	Super.AttachTo(OwnerPawn);

	Mesh.PlayAnim('WeaponEquip');
	// for some reason we need this otherwise the first frame is still in the default pose
	Mesh.ForceSkelUpdate();
}

simulated function SetPuttingDownWeapon(bool bNowPuttingDown)
{
	Mesh.PlayAnim((bNowPuttingDown) ? 'WeaponPutDown' : 'WeaponEquip');
}

defaultproperties
{
	// Pickup mesh Transform
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'WP_Redeemer.Mesh.SK_WP_Redeemer_3P_Mid'
		AnimSets(0)=AnimSet'WP_Redeemer.Anims.K_WP_Redeemer_3P_Base'
		Translation=(X=11,Y=-10,Z=5)
 		bForceRefPose=0
	End Object

	WeapAnimType=EWAT_ShoulderRocket

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=Envy_Effects.Tests.Effects.P_FX_MuzzleFlash
	MuzzleFlashColor=(R=200,G=64,B=64,A=255)
	MuzzleFlashDuration=0.33;
	MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight'

	WeaponClass=class'UTWeap_Redeemer_Content'

}
