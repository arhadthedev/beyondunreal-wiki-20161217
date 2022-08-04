/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWeap_Redeemer_Content extends UTWeap_Redeemer;

simulated function PreloadTextures(bool bForcePreload)
{
	local array<Texture> Textures;
	local Texture2D CurrentTexture;
	local int i, j;

	Super.PreloadTextures(bForcePreload);

	if (WarheadClass != None)
	{
		for (i = 0; i < WarheadClass.default.TeamCameraMaterials.length; i++)
		{
			if (WarheadClass.default.TeamCameraMaterials[i] != None)
			{
				Textures = WarheadClass.default.TeamCameraMaterials[i].GetMaterial().GetTextures();
				for (j = 0; j < Textures.Length; j++)
				{
					CurrentTexture = Texture2D(Textures[j]);
					if (CurrentTexture != None)
					{
						CurrentTexture.bForceMiplevelsToBeResident = bForcePreload;
					}
				}
			}
		}
	}
}

defaultproperties
{
	WeaponColor=(R=255,G=0,B=0,A=255)
	FireInterval(0)=+0.9
	FireInterval(1)=+0.95
	PlayerViewOffset=(X=0.0,Y=0.0,Z=0.0)

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_Redeemer.Mesh.SK_WP_Redeemer_1P'
		PhysicsAsset=None
		FOV=60
		AnimSets(0)=AnimSet'WP_Redeemer.Anims.K_WP_Redeemer_1P_Base'
		Animations=MeshSequenceA
	End Object
	AttachmentClass=class'UTGameContent.UTAttachment_Redeemer'
	ArmsAnimSet=AnimSet'WP_Redeemer.Anims.K_WP_Redeemer_1P_Arms'
	ArmsEquipAnim=WeaponEquip
	ArmFireAnim(0)=WeaponFire
	ArmFireAnim(1)=WeaponFire
	ArmsPutDownAnim=WeaponPutDown

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_Redeemer.Mesh.SK_WP_Redeemer_3P_Mid'
	End Object
	PivotTranslation=(Y=0.0)

	WeaponFireSnd[0]=SoundCue'A_Weapon_Redeemer.Redeemer.A_Weapon_Redeemer_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_Redeemer.Redeemer.A_Weapon_Redeemer_FireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_Redeemer.Redeemer.A_Weapon_Redeemer_Raise01Cue'
	WeaponPutDownSnd=SoundCue'A_Weapon_Redeemer.Redeemer.A_Weapon_Redeemer_Lower01Cue'

	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile

	WeaponProjectiles(0)=class'UTProj_Redeemer'
	WeaponProjectiles(1)=class'UTProj_Redeemer'
	RedRedeemerClass=class'UTProj_RedeemerRed'

	FireOffset=(X=15,Y=5)

	MaxDesireability=1.5
	AIRating=1.5
	CurrentRating=1.5
	bInstantHit=false
	bSplashJump=true
	bRecommendSplashDamage=true
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=1
	InventoryGroup=10
	GroupWeight=0.5

	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Redeemer_Cue'

	AmmoCount=1
	LockerAmmoCount=1
	MaxAmmoCount=1
	RespawnTime=120.0
	bSuperWeapon=true
	bDelayedSpawn=true

	MuzzleFlashSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_MF' //ParticleSystem'WP_ImpactHammer.Particles.P_WP_ImpactHammer_Secondary_Hit' // TJAMES: On wirein the Redeemer PS is hard to see, this one works well for testing.
	MuzzleFlashColor=(R=200,G=64,B=64,A=255)
	MuzzleFlashDuration=.33;

	bNeverForwardPendingFire=true

	EquipTime=+2.0
	PutDownTime=+1.6
	CrossHairCoordinates=(U=320,V=64,UL=64,VL=64)
	IconCoordinates=(U=453,V=384,UL=147,VL=82)

	WarHeadClass=class'UTRemoteRedeemer_Content'
	FlickerParamName=Redeemer_Power
	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabTheRedeemer')

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheRedeemer'
	LocationSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_HeadingForTheRedeemer'
	LocationSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_HeadingForTheRedeemer'

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformShooting1
		Samples(0)=(LeftAmplitude=100,RightAmplitude=100,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearDecreasing,Duration=0.600)
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformShooting1
}
