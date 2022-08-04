/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_Avril_Content extends UTWeap_Avril;


defaultproperties
{
	ReloadCue=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRiL_Reload01Cue'
	NoAmmoWeaponPutDownAnim=WeaponPutDownEmpty
	WeaponReloadAnim=WeaponReload
	WeaponPutDownSnd=SoundCue'A_Weapon_Avril.Weapons.A_Avril_LowerCue'
	WeaponEquipSnd=SoundCue'A_Weapon_Avril.Weapons.A_Avril_RaiseCue'
	WeaponFireAnim[1]=None

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_AVRiL.Mesh.SK_WP_Avril_1P'
		PhysicsAsset=None
		AnimSets(0)=AnimSet'WP_AVRiL.Anims.K_WP_Avril_1P_Base'
		Animations=MeshSequenceA
		Scale=1.0
		FoV=65
	End Object
	AttachmentClass=class'UTGameContent.UTAttachment_Avril'

	ArmsAnimSet=AnimSet'WP_AVRiL.Anims.K_WP_Avril_1P_Arms'


	// 1p targeting beam
	Begin Object Class=UTParticleSystemComponent Name=LaserComp
		Template=ParticleSystem'WP_AVRiL.Particles.P_WP_AVRiL_TargetBeam'
		DepthPriorityGroup=SDPG_Foreground
		TickGroup=TG_PostAsyncWork
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
		bUpdateComponentInTick=true
		bIgnoreOwnerHidden=TRUE
		FOV=65
	End Object
	LaserEffect=LaserComp

	TargetingLaserStartSound=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRIL_FireAltStartCue'
	TargetingLaserStopSound=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRIL_FireAltStopCue'
	TargetingLaserAmbientSound=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRIL_FireAltLoopCue'

	// Pickup staticmesh

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_AVRiL.Mesh.SK_WP_Avril_3p_Mid'
	End Object

	WeaponFireSnd[0]=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRiL_Fire01Cue'
	//WeaponFireSnd[1]=SoundCue'A_Weapon.AVRiL.Cue.A_Weapon_AVRiL_Fire_Cue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_AVRiL_Cue'
	LockAcquiredSound=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRiL_Lock01Cue'

	WeaponProjectiles(0)=class'UTProj_AvrilRocket'

}
