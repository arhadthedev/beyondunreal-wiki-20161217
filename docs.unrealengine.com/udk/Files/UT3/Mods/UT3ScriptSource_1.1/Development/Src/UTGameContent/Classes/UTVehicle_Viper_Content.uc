/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Viper_Content extends UTVehicle_Viper;

defaultproperties
{
	// Initialize sound parameters.
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	IconCoords=(U=989,UL=24,V=43,VL=48)
	ViperSelfDestructToolTipIcon=(U=93,V=316,UL=46,VL=52);

	SelfDestructDamageType=class'UTDmgType_ViperSelfDestruct'
	SelfDestructSoundCue=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_SelfDestructCue'
	EjectSoundCue=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Eject_Cue'

	VehicleEffects[0]=(EffectStartTag=MantaWeapon01,EffectTemplate=ParticleSystem'VH_NecrisManta.Effects.PS_Viper_Gun_MuzzleFlash',EffectSocket=Gun_Socket_02)
	VehicleEffects[1]=(EffectStartTag=MantaWeapon02,EffectTemplate=ParticleSystem'VH_NecrisManta.Effects.PS_Viper_Gun_MuzzleFlash',EffectSocket=Gun_Socket_01)
	VehicleEffects[2]=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_NecrisManta',EffectSocket=DamageSmoke01)
	VehicleEffects[3]=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_NecrisManta.Effects.PS_Viper_Ground_FX',EffectSocket=GroundEffectSocket)
	VehicleEffects[4]=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_NecrisManta.Effects.P_VH_Viper_PowerBall',EffectTemplate_Blue=ParticleSystem'VH_NecrisManta.Effects.P_VH_Viper_PowerBall_Blue',EffectSocket=PowerBallSocket)



//Viper..(Special Case)........................................VH_NecrisManta.Effects.PS_Viper_Ground_FX............(this effect is in but needs a param set.  This will be the same effect for all surfaces except water which will use the same Param just swap PS to ...( Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Viper_Water_Ground_FX )   (Param Name: Direction,  MinINPUT: -5  MaxINPUT: 5)  0 is when the Vh is still, positive X=forward movemet 5 being max forward movement.  -X is backwards.  Y is same thing but side to side

	//Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Viper_Water_Ground_FX


	ExhaustIndex=4

	GroundEffectIndices=(3)

	Seats(0)={( GunClass=class'UTVWeap_ViperGun',
				GunSocket=(Gun_Socket_01,Gun_Socket_02),
				CameraTag=ViewSocket,
				CameraOffset=-200,
				DriverDamageMult=0.75,
				bSeatVisible=true,
				SeatBone=characterattach,
				CameraBaseOffset=(Z=-20),
				SeatIconPos=(X=0.475,Y=0.6),
				SeatOffset=(X=0,Y=0,Z=50),
				WeaponEffects=((SocketName=Gun_Socket_01,Offset=(X=-35,Y=-3),Scale3D=(X=6.0,Y=5.0,Z=5.0)),(SocketName=Gun_Socket_02,Offset=(X=-35,Y=-3),Scale3D=(X=6.0,Y=5.0,Z=5.0)))
				)}

	Begin Object Name=CollisionCylinder
		CollisionHeight=40.0
		CollisionRadius=100.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_NecrisManta.Mesh.SK_VH_NecrisManta'
		AnimTreeTemplate=AnimTree'VH_NecrisManta.Anims.AT_VH_NecrisManta'
		PhysicsAsset=PhysicsAsset'VH_NecrisManta.Mesh.SK_VH_NecrisManta_Physics'
		AnimSets.Add(AnimSet'VH_NecrisManta.Anims.K_VH_NecrisManta')
	End Object

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=MantaEngineSound
		SoundCue=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_EngineLoopCue'
	End Object
	EngineSound=MantaEngineSound
	Components.Add(MantaEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_CollisionCue'
	EnterVehicleSound=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_StartCue'
	ExitVehicleSound=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_StopCue'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	Begin Object Class=AudioComponent Name=CarveSound
		SoundCue=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_SlideCue'
	End Object
	CurveSound=CarveSound
	Components.Add(CarveSound);

	JumpSound=SoundCue'A_Vehicle_Manta.Sounds.A_Vehicle_Manta_JumpCue'
	DuckSound=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_SquishAttackCue'
	ExplosionSound=SoundCue'A_Vehicle_Viper.Cue.A_Vehicle_Viper_ExplosionCue'

	DrivingAnim=viper_idle_sitting

	SelfDestructEffectTemplate=ParticleSystem'VH_NecrisManta.Effects.P_VH_Viper_SelfDestruct_FlareUp'

	SpawnInSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeInNecris01Cue'
	SpawnOutSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeOutNecris01Cue'
	ExhaustParamName=ViperExhaust

	HoverBoardAttachSockets=(HoverAttach00)

	GlideBlendTime=0.5
	SelfDestructSpinName=SuicideSpin

	TimeToRiseForSelfDestruct=1.1
	SelfDestructReadySnd=SoundCue'A_Vehicle_Viper.SoundCues.A_Vehicle_Viper_SelfDestructReady_Cue'

	DrivingPhysicalMaterial=PhysicalMaterial'VH_NecrisManta.Material.PhysMat_VH_NecrisMantadriving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_NecrisManta.Material.PhysMat_VH_NecrisManta'

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death

	HudCoords=(U=173,V=0,UL=-77,VL=125)

	TeamMaterials[0]=MaterialInstanceConstant'VH_NecrisManta.Materials.MI_VH_Viper_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_NecrisManta.Materials.MI_VH_Viper_Blue'

	BurnOutMaterial[0]=MaterialInterface'VH_NecrisManta.Materials.MITV_VH_Viper_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_NecrisManta.Materials.MITV_VH_Viper_Blue_BO'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_NecrisManta.Materials.MI_VH_Viper_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_NecrisManta.Materials.MI_VH_Viper_Spawn_Blue'))

	DamageMorphTargets(0)=(InfluenceBone=LtFront_TopFin,MorphNodeName=none,LinkedMorphNodeName=none,Health=60,DamagePropNames=(Damage3)) //front
	DamageMorphTargets(1)=(InfluenceBone=Lt_WingB_Damage,MorphNodeName=none,LinkedMorphNodeName=none,Health=60,DamagePropNames=(Damage1))
	DamageMorphTargets(2)=(InfluenceBone=Rt_WingB_Damage,MorphNodeName=none,LinkedMorphNodeName=none,Health=60,DamagePropNames=(Damage1)) //side
	DamageMorphTargets(3)=(InfluenceBone=RearBody,MorphNodeName=none,LinkedMorphNodeName=none,Health=60,DamagePropNames=(Damage2)) // rear


	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=3.5)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=10.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=5.0)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_Reaper.BotStatus.A_BotStatus_Reaper_EnemyViper'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyViper'
}
