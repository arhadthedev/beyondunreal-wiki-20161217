/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTFamilyInfo_TwinSouls_Male extends UTFamilyInfo_TwinSouls
	abstract;

static function class<UTVoice> GetVoiceClass(CustomCharData CharacterData)
{
	local class<UTVoice> Result;
	Result = Default.VoiceClass;

	if ( CharacterData.BasedOnCharID == "A" )
		Result = class'UTGame.UTVoice_Reaper';
	else if ( CharacterData.BasedOnCharID == "B" )
		Result = class'UTGame.UTVoice_Bishop';
	else if ( CharacterData.BasedOnCharID == "C" )
		Result = class'UTGame.UTVoice_Othello';

	return Result;
}

defaultproperties
{
	FamilyID="TWIM"

	ArmMeshPackageName="CH_TwinSouls_Arms"
	ArmMeshName="CH_TwinSouls_Arms.Mesh.SK_CH_TwinSouls_Arms_MaleA_1P"
	ArmSkinPackageName="CH_TwinSouls_Arms"
	RedArmSkinName="CH_TwinSouls_Arms.Materials.MI_CH_TwinSouls_MFirstPersonArm_VRed"
	BlueArmSkinName="CH_TwinSouls_Arms.Materials.MI_CH_TwinSouls_MFirstPersonArm_VBlue"

	NeckStumpName="SK_CH_RTeam_Male_NeckStump01"

	PhysAsset=PhysicsAsset'CH_AnimHuman.Mesh.SK_CH_BaseMale_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	BaseMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_All_TwinSouls_Base'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_TwinSouls_BioDeath'

	MasterSkeleton=SkeletalMesh'CH_All.Mesh.SK_Master_Skeleton_Human_Male'
	CharEditorIdleAnimName="CC_Human_Male_Idle"
}
