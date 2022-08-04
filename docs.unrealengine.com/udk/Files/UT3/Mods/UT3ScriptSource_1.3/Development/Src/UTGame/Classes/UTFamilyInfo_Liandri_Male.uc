/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTFamilyInfo_Liandri_Male extends UTFamilyInfo_Liandri
	abstract;

defaultproperties
{
	FamilyID="LIAM"

	ArmMeshPackageName="CH_Corrupt_Arms"
	ArmMeshName="CH_Corrupt_Arms.Mesh.SK_CH_Corrupt_Arms_MaleA_1P"
	ArmSkinPackageName="CH_Corrupt_Arms"
	RedArmSkinName="CH_Corrupt_Arms.Materials.MI_CH_Corrupt_FirstPersonArms_VRed"
	BlueArmSkinName="CH_Corrupt_Arms.Materials.MI_CH_Corrupt_FirstPersonArms_VBlue"

	PhysAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Corrupt_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Corrupt_BioDeath'

	MasterSkeleton=SkeletalMesh'CH_All.Mesh.Master_Skeleton_Corrupt'
	CharEditorIdleAnimName="CC_Human_Male_Idle"
}




