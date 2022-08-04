/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_NightShade_Content extends UTVehicle_NightShade;

defaultproperties
{
	LinkBeamColors(0)=(R=255,G=64,B=64,A=255)
	LinkBeamColors(1)=(R=64,G=64,B=255,A=255)
	LinkBeamColors(2)=(R=32,G=255,B=32,A=255)

	SkinTranslucencyName=skintranslucency
	HitEffectName=HitEffect
	OverlayColorName=Veh_OverlayColor

	Begin Object Name=CollisionCylinder
		CollisionHeight=+40.0
		CollisionRadius=+140.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_NightShade.Mesh.SK_VH_NightShade'
		PhysicsAsset=PhysicsAsset'VH_NightShade.Mesh.SK_VH_NightShade_Physics'
		AnimTreeTemplate=AnimTree'VH_NightShade.Anims.AT_VH_NightShade'
		AnimSets(0)=AnimSet'VH_NightShade.Anims.K_VH_NightShade';
		Materials(0)=Material'VH_NightShade.Materials.M_VH_NightShade'
	End Object

	TeamMaterials[0]=MaterialInstanceConstant'VH_NightShade.Materials.MI_VH_NightShade_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_NightShade.Materials.MI_VH_NightShade_Blue'

	CloakedSkin=MaterialInterface'VH_NightShade.Materials.M_VH_NightShade_Skin';

	Seats(0)={(	GunClass=class'UTVWeap_NightshadeGun_Content',
				GunSocket=(TurretFireSocket),
				TurretVarPrefix="",
				TurretControls=(TurretConstraintPitch,TurretConstraintYaw,DeployYaw),
				GunPivotPoints=(Turret_Pitch),
				CameraTag=DriverViewSocket,
				CameraOffset=-400,
				CameraBaseOffset=(X=-70.0,Z=20.0),
				SeatIconPos=(X=0.49,Y=0.5),
				DriverDamageMult=0.0,
				WeaponEffects=((SocketName=TurretFireSocket,Offset=(X=50),Scale3D=(X=6.0,Y=6.0,Z=6.0)))
				)}

	//Hovering Nightshade dust effect
	Begin Object class=ParticleSystemComponent name=HoverDust
		Template=ParticleSystem'VH_Nightshade.Effects.P_VH_Nightshade_Ground_Effect'
		Translation=(Z=-70) //no socket for this effect
		TickGroup=TG_PostAsyncWork
		bAutoActivate=false
	End Object
	HoverDustPSC=HoverDust
	Components.Add(HoverDust)

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=NightShadeEngineSound
		SoundCue=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_EngineLoop01_Cue'
	End Object
	EngineSound=NightShadeEngineSound
	Components.Add(NightShadeEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_Impact_Cue'

	Begin Object Class=AudioComponent Name=ArmSound
		SoundCue=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_ArmsMove01_Cue'
	End Object
	Components.Add(ArmSound);
	TurretArmMoveSound=ArmSound

	// Stealth Res sound
	Begin Object Class=AudioComponent Name=NightShadeStealthResSound
		SoundCue=SoundCue'A_Gameplay.Portal.Portal_WalkThrough01Cue'
		bStopWhenOwnerDestroyed=TRUE
		bAllowSpatialization=TRUE
	End Object
	StealthResSound=NightShadeStealthResSound
	Components.Add(NightShadeStealthResSound);

	EnterVehicleSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_EngineStart01_Cue'
	ExitVehicleSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_EngineStop01_Cue'

	// Initialize sound parameters.
	SquealThreshold=250.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	VehicleEffects(0)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_NightShade',EffectSocket=DamageSmoke_01)
	VehicleEffects(1)=(EffectStartTag=BackTurretFire,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_SecondMuzzleFlash',EffectSocket=TurretFireSocket)

	VehicleAnims(0)=(AnimTag=Deployed,AnimSeqs=(ArmExtendIdle),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=AnimPlayer);

	BeamTemplate=ParticleSystem'VH_Nightshade.Effects.P_VH_Nightshade_Maingun_Beam'
	BeamSockets=TurretFireSocket
	EndPointParamName=LinkBeamEnd

	Begin Object Class=AudioComponent name=BeamAmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	BeamAmbientSound=BeamAmbientSoundComponent
	Components.Add(BeamAmbientSoundComponent)

	BeamFireSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_FireLoop01_Cue'
	BeamStartSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_FireStart01_Cue'
	BeamStopSound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_FireStop01_Cue'

	SpawnInSound = SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeInNecris01Cue'
	SpawnOutSound = SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeOutNecris01Cue'

	IdleAnim(0)=Idle
	IdleAnim(1)=Idle //ArmExtendIdle
	DeployAnim(0)=ArmExtend
	DeployAnim(1)=ArmRetract

	DeploySound=SoundCue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_ArmsExtend01_Cue'
	UndeploySound=Soundcue'A_Vehicle_Nightshade.Nightshade.A_Vehicle_Nightshade_ArmsRetract01_Cue'

	DeployTime=3.2
	UnDeployTime=0.7

	HoverBoardAttachSockets=(HoverAttach00)

	TurretName=DeployYaw
	TeamSkinParamName=SkinColor

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGE_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGEL_Near')
	BigExplosionSocket=VH_Death

	HudCoords=(U=95,V=0,UL=-95,VL=119)

	BurnOutMaterial[0]=MaterialInterface'VH_NightShade.Materials.MITV_VH_NightShade_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_NightShade.Materials.MITV_VH_NightShade_Blue_BO'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_NightShade.Materials.MI_VH_NightShade_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_NightShade.Materials.MI_VH_NightShade_Spawn_Blue'))


	DamageMorphTargets(0)=(InfluenceBone=LtFrontArm2,MorphNodeName=none,LinkedMorphNodeName=none,Health=175,DamagePropNames=(Damage1,Damage2))
	DamageMorphTargets(1)=(InfluenceBone=RtFrontArm2,MorphNodeName=none,LinkedMorphNodeName=none,Health=175,DamagePropNames=(Damage1,Damage2))
	DamageMorphTargets(2)=(InfluenceBone=UpperArm_LtPaddle,MorphNodeName=none,LinkedMorphNodeName=none,Health=175,DamagePropNames=(Damage1,Damage3))
	DamageMorphTargets(3)=(InfluenceBone=UpperArm_RtPaddle,MorphNodeName=none,LinkedMorphNodeName=none,Health=175,DamagePropNames=(Damage1,Damage3))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=6.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.5)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=3.0)
	IconCoords=(U=909,V=76,UL=27,VL=39)

	DeployablePositionOffsets(0)=(X=0,Y=0,Z=0) //Spider Mine
	DeployablePositionOffsets(1)=(X=0,Y=0,Z=0) //Slow Volume
	DeployablePositionOffsets(2)=(X=0,Y=0,Z=0) //EMP Mine
	DeployablePositionOffsets(3)=(X=0,Y=0,Z=0) //Energy Shield

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyNightshade'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyNightshade'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyNightshade'

	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_ManTheNightShade')

    ToolTipIconCoords=(U=146,V=317,UL=140,VL=60)
}
