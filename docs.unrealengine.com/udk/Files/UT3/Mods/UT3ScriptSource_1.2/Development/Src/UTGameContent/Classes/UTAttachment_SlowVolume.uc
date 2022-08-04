/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTAttachment_SlowVolume extends UTWeaponAttachment;


defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_SlowVolume'
		CullDistance=5000
		Rotation=(Yaw=16384)
		Translation=(X=14.0,Z=-15.0)
	End Object

	WeapAnimType=EWAT_ShoulderRocket
	WeaponClass=class'UTDeployableSlowVolume'
}
