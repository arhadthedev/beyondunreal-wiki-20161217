/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTAttachment_SpiderMineTrap extends UTWeaponAttachment;


defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_SpiderMine'
		CullDistance=5000
		Translation=(X=13.0,Z=-20.0)
	End Object

	WeapAnimType=EWAT_ShoulderRocket
	WeaponClass=class'UTDeployableSpiderMineTrap'
}
