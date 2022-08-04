/**
* Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
*/

class UTFamilyInfo_Krall extends UTFamilyInfo
	abstract;

defaultproperties
{
	Faction="Krall"

	NonTeamEmissiveColor=(R=0.0,G=0.0,B=0.0)
	NonTeamTintColor=(R=4.0,G=3.0,B=2.0)

	HeadGib=(BoneName=b_Head,GibClass=class'UTGib_KrallHead',bHighDetailOnly=false)
	SoundGroupClass=class'UTPawnSoundGroup_Krall'
	VoiceClass=class'UTVoice_Krall'

	Gibs[0]=(BoneName=b_LeftForeArm,GibClass=class'UTGib_KrallArm',bHighDetailOnly=false)
	Gibs[1]=(BoneName=b_RightForeArm,GibClass=class'UTGib_KrallHand',bHighDetailOnly=true)
	Gibs[2]=(BoneName=b_LeftLeg,GibClass=class'UTGib_KrallLeg',bHighDetailOnly=false)
	Gibs[3]=(BoneName=b_RightLeg,GibClass=class'UTGib_KrallLeg',bHighDetailOnly=false)
	Gibs[4]=(BoneName=b_Spine,GibClass=class'UTGib_KrallTorso',bHighDetailOnly=false)
	Gibs[5]=(BoneName=b_RightClav,GibClass=class'UTGib_KrallBone',bHighDetailOnly=false)
	
	DefaultMeshScale=1.0
	BaseTranslationOffset=2.0
	PortraitExtraOffset=(X=35,Z=2)  //adjustment to fit the Krall head in the portrait

	// Hero camera adjustments
	CameraXOffset=0.3
	CameraYOffset=-1.6

	HeroFireOffset=(X=180.0,Y=-15.0,Z=-70.0)
	SuperHeroFireOffset=(X=420.0,Y=-15.0,Z=-100.0)

	HeroMeleeAnimSet=AnimSet'CH_AnimKrall_Hero.Anims.K_AnimKrall_Hero'

	TrustWorthiness=-2.5
}
