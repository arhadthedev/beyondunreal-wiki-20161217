/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTAttachment_ShapedCharge extends UTWeaponAttachment;


defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_ShapeCharge_1P'
		CullDistance=5000
		Scale=0.75
		Rotation=(Yaw=14563,Roll=1820)
		Translation=(X=14.0,Z=-4.0)
	End Object

	WeapAnimType=EWAT_ShoulderRocket
	WeaponClass=class'UTDeployableShapedCharge'
}
