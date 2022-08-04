/**
* Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
*/

class UTFamilyInfo_Necris_Male extends UTFamilyInfo_Necris
	abstract;

defaultproperties
{
	FamilyID="NECM"

	PhysAsset=PhysicsAsset'CH_AnimHuman.Mesh.SK_CH_BaseMale_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	NeckStumpName="SK_CH_Necris_Male_NeckStump01"

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_All_Necris_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Necris_BioDeath'

	MasterSkeleton=SkeletalMesh'CH_All.Mesh.SK_Master_Skeleton_Human_Male'
	CharEditorIdleAnimName="CC_Human_Male_Idle"
	VoiceClass=class'UTVoice_NecrisMale'
	
	DefaultMeshScale=1.025
	BaseTranslationOffset=6.0
}