/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Raptor_Content extends UTVehicle_Raptor;

var color EffectColor[2];

simulated function SetVehicleEffectParms(name TriggerName, ParticleSystemComponent PSC)
{
	if (TriggerName == 'RaptorWeapon01' || TriggerName == 'RaptorWeapon02')
	{
		PSC.SetColorParameter('MFlashColor',EffectColor[GetTeamNum()]);
	}
	else
	{
		Super.SetVehicleEffectParms(TriggerName, PSC);
	}
}

simulated function vector GetPhysicalFireStartLoc(UTWeapon ForWeapon)
{
	local vector RocketSocketL;
	local rotator RocketSocketR;

	if (ForWeapon.CurrentFireMode == 1)
	{
		Mesh.GetSocketWorldLocationAndRotation('RocketSocket',RocketSocketL, RocketSocketR);
		return RocketSocketL;
	}
	else
		return Super.GetPhysicalFireStartLoc(ForWeapon);
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=70.0
		CollisionRadius=140.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Raptor.Mesh.SK_VH_Raptor'
		AnimTreeTemplate=AnimTree'VH_Raptor.Anims.AT_VH_Raptor'
		PhysicsAsset=PhysicsAsset'VH_Raptor.Anims.SK_VH_Raptor_Physics'
		MorphSets[0]=MorphTargetSet'VH_Raptor.Mesh.SK_VH_Raptor_MorphTargets'
	End Object

	DrawScale=1.3

	Seats(0)={(	GunClass=class'UTVWeap_RaptorGun',
				GunSocket=(Gun_Socket_01,Gun_Socket_02),
				GunPivotPoints=(left_gun,rt_gun),
				SeatIconPos=(X=0.45,Y=0.4),
				TurretControls=(gun_rotate_lt,gun_rotate_rt),
				CameraTag=ViewSocket,
				CameraOffset=-384,
				WeaponEffects=((SocketName=Gun_Socket_01,Offset=(X=-55,Y=-3),Scale3D=(X=6.0,Y=6.0,Z=6.0)),(SocketName=Gun_Socket_02,Offset=(X=-55,Y=-3),Scale3D=(X=6.0,Y=6.0,Z=6.0)))
				)}

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=RaptorEngineSound
		SoundCue=SoundCue'A_Vehicle_Raptor.SoundCues.A_Vehicle_Raptor_EngineLoop'
	End Object
	EngineSound=RaptorEngineSound
	Components.Add(RaptorEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Raptor.SoundCues.A_Vehicle_Raptor_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Raptor.SoundCues.A_Vehicle_Raptor_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Raptor.SoundCues.A_Vehicle_Raptor_Stop'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	// Initialize sound parameters.
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	TeamMF[0]=ParticleSystem'VH_Raptor.Effects.PS_Raptor_MF';
	TeamMF[1]=ParticleSystem'VH_Raptor.Effects.PS_Raptor_MF_Blue';

	VehicleEffects(0)=(EffectStartTag=RaptorWeapon01,EffectTemplate=ParticleSystem'VH_Raptor.Effects.PS_Raptor_MF',EffectSocket=Gun_Socket_02)
	VehicleEffects(1)=(EffectStartTag=RaptorWeapon02,EffectTemplate=ParticleSystem'VH_Raptor.Effects.PS_Raptor_MF',EffectSocket=Gun_Socket_01)
 	VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Raptor',EffectSocket=DamageSmoke_01)

	VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_Contrail',EffectSocket=LeftTip,bHighDetailOnly=true)
	VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_Contrail',EffectSocket=RightTip,bHighDetailOnly=true)
	VehicleEffects(5)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_Contrail',EffectSocket=RearRtContrail,bHighDetailOnly=true)
	VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_Contrail',EffectSocket=RearLtContrail,bHighDetailOnly=true)

	VehicleEffects(7)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_Exhaust',EffectSocket=ExhaustL)
	VehicleEffects(8)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_Exhaust',EffectSocket=ExhaustR)
	VehicleEffects(9)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Raptor.EffectS.P_VH_Raptor_GroundEffect',EffectSocket=GroundEffectBase)

	ContrailEffectIndices=(3,4,5,6)
	GroundEffectIndices=(9)

	TeamMaterials[0]=MaterialInstanceConstant'VH_Raptor.Materials.MI_VH_Raptor_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Raptor.Materials.MI_VH_Raptor_Blue'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Raptor.Materials.MI_VH_Raptor_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Raptor.Materials.MI_VH_Raptor_Spawn_Blue'))

	BurnOutMaterial[0]=MaterialInterface'VH_Raptor.Materials.MITV_VH_Raptor_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Raptor.Materials.MITV_VH_Raptor_Blue_BO'

 	EffectColor(0)=(R=151,G=26,B=35,A=255)
 	EffectColor(1)=(R=35,G=26,B=151,A=255)

	IconCoords=(U=859,UL=25,V=27,VL=46)

	ExplosionSound=SoundCue'A_Vehicle_Raptor.SoundCues.A_Vehicle_Raptor_Explode'
	TurretPivotSocketName=TurretPiv
	HoverBoardAttachSockets=(HoverAttach00)

	ReferenceMovementMesh=StaticMesh'Envy_Effects.Mesh.S_Air_Wind_Ball'

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death

	DamageMorphTargets(0)=(InfluenceBone=Rudder_Rt,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=105,DamagePropNames=(Damage2,Damage1))
	DamageMorphTargets(1)=(InfluenceBone=Rudder_Left,MorphNodeName=MorphNodeW_Rear,LinkedMorphNodeName=none,Health=105,DamagePropNames=(Damage2,Damage1))
	DamageMorphTargets(2)=(InfluenceBone=Lft_Wing_Damage2,MorphNodeName=MorphNodeW_Left,LinkedMorphNodeName=none,Health=140,DamagePropNames=(Damage3))
	DamageMorphTargets(3)=(InfluenceBone=Rt_Wing_Damage1,MorphNodeName=MorphNodeW_Right,LinkedMorphNodeName=none,Health=140,DamagePropNames=(Damage3))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=4.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)

	HudCoords=(U=571,V=129,UL=-75,VL=137)

	DrivingPhysicalMaterial=PhysicalMaterial'VH_Raptor.materials.physmat_Raptor_driving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_Raptor.materials.physmat_Raptor'

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyRaptor'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyRaptor'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyRaptor'
}
