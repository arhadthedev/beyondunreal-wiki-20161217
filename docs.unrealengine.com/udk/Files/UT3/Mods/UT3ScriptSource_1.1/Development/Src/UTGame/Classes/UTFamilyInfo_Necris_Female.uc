/**
* Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
*/

class UTFamilyInfo_Necris_Female extends UTFamilyInfo_Necris
	abstract;

defaultproperties
{
	FamilyID="NECF"

	PhysAsset=PhysicsAsset'CH_AnimHuman.Mesh.SK_CH_BaseFemale_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	SoundGroupClass=class'UTPawnSoundGroup_HumanFemale'
	VoiceClass=class'UTGame.UTVoice_Akasha'

	NeckStumpName="SK_CH_Necris_Female_NeckStump01"

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_All_Necris_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Necris_BioDeath'

	MasterSkeleton=SkeletalMesh'CH_All.Mesh.SK_Master_Skeleton_Human_Female'
	CharEditorIdleAnimName="CC_Human_Female_Idle"
	
	bIsFemale=true
}