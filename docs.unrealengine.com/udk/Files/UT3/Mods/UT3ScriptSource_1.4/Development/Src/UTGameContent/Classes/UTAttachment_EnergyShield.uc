/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTAttachment_EnergyShield extends UTWeaponAttachment;


defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_Shield'
		CullDistance=5000
		Translation=(X=14.0,Z=-4.0)
	End Object

	WeapAnimType=EWAT_ShoulderRocket
	WeaponClass=class'UTDeployableEnergyShield'
}
