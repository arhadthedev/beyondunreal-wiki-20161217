/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTFamilyInfo_TwinSouls_Female extends UTFamilyInfo_TwinSouls
	abstract;

defaultproperties
{
	FamilyID="TWIF"

	ArmMeshPackageName="CH_TwinSouls_Arms"
	ArmMeshName="CH_TwinSouls_Arms.Mesh.SK_CH_TwinSouls_Arms_MaleA_1P"
	ArmSkinPackageName="CH_TwinSouls_Arms"
	RedArmSkinName="CH_TwinSouls_Arms.Materials.MI_CH_TwinSouls_MFirstPersonArm_VRed"
	BlueArmSkinName="CH_TwinSouls_Arms.Materials.MI_CH_TwinSouls_MFirstPersonArm_VBlue"

	NeckStumpName="SK_CH_RTeam_Female_NeckStump01"

	PhysAsset=PhysicsAsset'CH_AnimHuman.Mesh.SK_CH_BaseFemale_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_All_TwinSouls_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_TwinSouls_BioDeath'

	MasterSkeleton=SkeletalMesh'CH_All.Mesh.SK_Master_Skeleton_Human_Female'
	CharEditorIdleAnimName="CC_Human_Female_Idle"
	
	SoundGroupClass=class'UTPawnSoundGroup_HumanFemale'
	VoiceClass=class'UTGame.UTVoice_DefaultFemale'
	bIsFemale=true
}