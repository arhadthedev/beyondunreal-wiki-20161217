/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Eradicator_Content extends UTVehicle_Eradicator;

/** sound of the moving turret */
var SoundCue TurretMovementSound;

var MaterialInterface BurnOutMaterialTread[2];


defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=260.000000
		Translation=(X=0.0,Y=0.0,Z=100.0)
	End Object
	CylinderComponent=CollisionCylinder


	Begin Object Name=SVehicleMesh
		AnimSets(0)=AnimSet'VH_SPMA.Anims.VH_SPMA_Anims'
		SkeletalMesh=SkeletalMesh'VH_ERAD.Mesh.SK_VH_ERAD_Cannon'
		PhysicsAsset=PhysicsAsset'VH_ERAD.Mesh.SK_VH_ERAD_Cannon_Physics'
		AnimTreeTemplate=AnimTree'VH_ERAD.Anim.SK_VH_ERAD_AnimTree'
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
	End Object

	DefaultPhysicalMaterial=PhysicalMaterial'VH_ERAD.Materials.PhysMat_ERAD'

	DrawScale=1.3

	// turret twist sound.
	TurretMovementSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_CannonRotate'

	Seats(0)={(	GunClass=class'UTVWeap_EradicatorCannon_Content',
				GunSocket=(TurretFireSocket),
				GunPivotPoints=(MainTurret_Yaw),
				TurretControls=(TurretConstraint,TurretYawConstraint),
				CameraTag=DriverViewSocket,
				CameraOffset=-320,
				CameraBaseOffset=(Z=100),
				SeatIconPos=(X=0.45,Y=0.70),
				MuzzleFlashLightClass=class'UTTankMuzzleFlash',
				WeaponEffects=((SocketName=TurretFireSocket,Offset=(X=-105),Scale3D=(X=12.0,Y=12.0,Z=12.0)))
				)}

	VehicleEffects(0)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_SPMA',EffectSocket=DamageSmoke_01)

	// Muzzle Flashes
	VehicleEffects(7)=(EffectStartTag=CannonFire,EffectTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_PrimaryMuzzleFlash',EffectSocket=TurretFireSocket)
	VehicleEffects(8)=(EffectStartTag=CameraFire,EffectTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_AltMuzzleFlash',EffectSocket=TurretFireSocket)
	
	VehicleAnims(0)=(AnimTag=CannonFire,AnimSeqs=(Fire),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	VehicleAnims(1)=(AnimTag=CameraFire,AnimSeqs=(Fire),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)


	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Paladin_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dirt_Effects.P_Hellbender_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Paladin_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Paladin_Wheel_Snow')


	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=SPMAEngineSound
		SoundCue=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_EngineIdle'
	End Object
	EngineSound=SPMAEngineSound
	Components.Add(SPMAEngineSound);

	CollisionSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_EngineRampUp'
	ExitVehicleSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_EngineRampDown'

	// Initialize sound parameters.
	SquealThreshold=250.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	IconCoords=(U=918,UL=18,V=0,VL=35)

	CameraFireToolTipIconCoords=(U=2,V=371,UL=124,VL=115)

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGE_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGEL_Near')
	BigExplosionSocket=VH_Death
	ExplosionSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Explode'

	PassengerTeamBeaconOffset=(X=100.0f,Y=15.0f,Z=50.0f)
	bHasTurretExplosion=true
	DestroyedTurretTemplate=StaticMesh'VH_SPMA.Mesh.S_VH_SPMA_Top'

	TurretExplosiveForce=2000

	HudCoords=(U=493,V=103,UL=-77,VL=135)
	TeamMaterials[0]=MaterialInstanceConstant'VH_ERAD.Materials.MI_VH_ERAD_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_ERAD.Materials.MI_VH_ERAD_Blue'
	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Spawn_Blue'))
	BurnOutMaterial[0]=MaterialInterface'VH_ERAD.Materials.MITV_VH_ERAD_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_ERAD.Materials.MITV_VH_ERAD_Blue_BO'

	DamageMorphTargets(0)=(InfluenceBone=RtFrontBumper_Support,MorphNodeName=none,Health=230,DamagePropNames=(Damage2,))
	DamageMorphTargets(1)=(InfluenceBone=LtFrontLegLow,MorphNodeName=none,Health=230,DamagePropNames=(Damage1))
	DamageMorphTargets(2)=(InfluenceBone=LtFrontLegLow,MorphNodeName=none,Health=230,DamagePropNames=(Damage1))
	DamageMorphTargets(3)=(InfluenceBone=LtRearFoot,MorphNodeName=none,Health=230,DamagePropNames=(Damage3))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=1.5)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyHellfire'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyHellfire'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyHellfire'
}
