/**
* Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
*/

class UTFamilyInfo_Krall_Male extends UTFamilyInfo_Krall
	abstract;

defaultproperties
{
	FamilyID="KRAM"

	ArmMeshPackageName="CH_Krall_Arms"
	ArmMeshName="CH_Krall_Arms.Mesh.SK_CH_Krall_Arms_MaleA_1P"
	ArmSkinPackageName="CH_Krall_Arms"
	RedArmSkinName="CH_Krall_Arms.Materials.MI_CH_Krall_Arms_MFirstPersonArm_VRed"
	BlueArmSkinName="CH_Krall_Arms.Materials.MI_CH_Krall_Arms_MFirstPersonArm_VBlue"

	PhysAsset=PhysicsAsset'CH_AnimKrall.Mesh.SK_CH_AnimKrall_Male01_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	AnimSets(1)=AnimSet'CH_AnimKrall.Anims.K_AnimKrall_Base'
	LeftFootBone=b_LeftFoot
	RightFootBone=b_RightFoot
	TakeHitPhysicsFixedBones[0]=b_LeftFoot
	TakeHitPhysicsFixedBones[1]=b_RightFoot

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Krall_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Krall_BioDeath'

	MasterSkeleton=SkeletalMesh'CH_All.Mesh.SK_Master_Skeleton_Krall'
	CharEditorIdleAnimName="CC_Krall_Male_Idle"

	DeathMeshSkelMesh=SkeletalMesh'CH_Skeletons.Mesh.SK_CH_Skeleton_Krall_Male'
	SkeletonBurnOutMaterials=(MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Krall_01_BO',MaterialInstanceTimeVarying'CH_Skeletons.Materials.MITV_CH_Skeletons_Krall_01_BO')

	DeathMeshNumMaterialsToSetResident=2

	//DeathMeshBreakableJoints=("b_LeftArm","b_RightArm","b_LeftLegUpper","b_RightLegUpper")

	DrivingDrawScale=0.85
}
