/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Goliath_Content extends UTVehicle_Goliath;

var MaterialInterface BurnOutMaterialTread[2];

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bDeleteMe )
		return;

	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None)
	{
		// set up material instance (for overlay effects)
		LeftTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(1);
		RightTreadMaterialInstance = Mesh.CreateAndSetMaterialInstanceConstant(2);
	}

	Mesh.AttachComponentToSocket(AntennaMesh,'AntennaSocket');

	AntennaBeamControl = UTSkelControl_CantileverBeam(AntennaMesh.FindSkelControl('Beam'));

	if(AntennaBeamControl != none)
	{
		AntennaBeamControl.EntireBeamVelocity = GetVelocity;
	}
}

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local ParticleSystemComponent E;
	local rotator HitDir;
	local vector EffectLocation;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	if (SeatIndex == 1)
	{
		EffectLocation = GetEffectLocation(SeatIndex);

		HitDir = rotator(HitLocation - EffectLocation);

		E = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'VH_Goliath.Effects.P_MiniGun_Tracer', EffectLocation, HitDir);
		E.SetVectorParameter('BeamEndPoint', HitLocation);
	}
}

simulated function TeamChanged()
{
	local int MaterialIndex;

	Super.TeamChanged();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MaterialIndex = (Team == 1) ? 1 : 0;
		AntennaMesh.SetMaterial(0, TeamMaterials[MaterialIndex]);
	}
}

protected simulated function StartLinkedEffect()
{
	local LinearColor LinkColor;

	LinkColor = (Team == 1) ? MakeLinearColor(0,1,4,1) : MakeLinearColor(4,0.1,0,1);

	if(LeftTreadMaterialInstance != none)
	{
		LeftTreadMaterialInstance.SetVectorParameterValue('Veh_OverlayColor',LinkColor);
	}
	if(RightTreadMaterialInstance != none)
	{
		RightTreadMaterialInstance.SetVectorParameterValue('Veh_OverlayColor',LinkColor);
	}
	super.StartLinkedEffect();
}

protected simulated function StopLinkedEffect()
{
	local LinearColor Black;

	if(LeftTreadMaterialInstance != none)
	{
		LeftTreadMaterialInstance.SetVectorParameterValue('Veh_OverlayColor',Black);
	}
	if(RightTreadMaterialInstance != none)
	{
		RightTreadMaterialInstance.SetVectorParameterValue('Veh_OverlayColor',Black);
	}
	super.StopLinkedEffect();
}

simulated function CauseMuzzleFlashLight(int SeatIndex)
{
	Super.CauseMuzzleFlashLight(SeatIndex);
	if (SeatIndex==0)
		VehicleEvent('GoliathTurret');
	else if (SeatIndex==1)
		VehicleEvent('GoliathMachineGun');
}

simulated function SetBurnOut()
{
	local int TeamNum;
	local BurnOutDatum BOD;

	TeamNum = GetTeamNum();

	if( TeamNum > 1 )
	{
		TeamNum = 0;
	}

	// set our specific Tread BurnOut Material
	// material 1 = left tread, 2 = right tread
	if (BurnOutMaterialTread[TeamNum] != None)
	{
		Mesh.SetMaterial(1,BurnOutMaterialTread[TeamNum]);
		Mesh.SetMaterial(2,BurnOutMaterialTread[TeamNum]);
	}

	if (BurnOutMaterial[TeamNum] != None)
	{
		AntennaMesh.SetMaterial(0,BurnOutMaterial[TeamNum]);

		// set up the antenna BurnOut
		BOD.MITV = AntennaMesh.CreateAndSetMaterialInstanceTimeVarying(0);
		BurnOutMaterialInstances[BurnOutMaterialInstances.length] = BOD;
	}

	// sets the MIC
	super.SetBurnOut();
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=60.0
		CollisionRadius=260.0
		Translation=(X=0.0,Y=0.0,Z=0.0)
	End Object
	CylinderComponent=CollisionCylinder

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Goliath.Mesh.SK_VH_Goliath01'
		MorphSets[0]=MorphTargetSet'VH_Goliath.Mesh.SK_VH_Goliath_Morph'
		AnimTreeTemplate=AnimTree'VH_Goliath.Anims.AT_VH_Goliath'
		PhysicsAsset=PhysicsAsset'VH_Goliath.Mesh.PA_VH_Goliath'
	End Object

	// once we get the magic bones onto the goliath then we can change the InfluenceBones to be those and this should just work
	DamageMorphTargets(0)=(InfluenceBone=b_FrontDamage,MorphNodeName=MorphNodeW_Front,LinkedMorphNodeName=none,Health=190,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=b_RearDamage,MorphNodeName=MorphNodeW_Back,LinkedMorphNodeName=none,Health=190,DamagePropNames=(Damage3))
	DamageMorphTargets(2)=(InfluenceBone=Suspension_LHS_02,MorphNodeName=MorphNodeW_LHS,LinkedMorphNodeName=none,Health=190,DamagePropNames=(Damage1))
	DamageMorphTargets(3)=(InfluenceBone=Suspension_RHS_02,MorphNodeName=MorphNodeW_RHS,LinkedMorphNodeName=none,Health=190,DamagePropNames=(Damage1))
	DamageMorphTargets(4)=(InfluenceBone=Object01,MorphNodeName=MorphNodeW_Turret,LinkedMorphNodeName=none,Health=190,DamagePropNames=(Damage6))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=5.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=5.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=5.0)
	DamageParamScaleLevels(3)=(DamageParamName=Damage6,Scale=2.0)


	Begin Object Class=AudioComponent name=AmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_TurretFire_Cue'
	End Object
	MachineGunAmbient=AmbientSoundComponent
	Components.Add(AmbientSoundComponent)

	MachineGunStopSound=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_TurretFireStop_Cue'

	DrawScale=1.35

	Seats(0)={(	GunClass=class'UTVWeap_GoliathTurret',
				GunSocket=(TurretFireSocket),
				GunPivotPoints=(Object01),
				TurretVarPrefix="",
				TurretControls=(TurretPitch,TurretRotate),
				CameraTag=GunViewSocket,
				CameraOffset=-420,
				SeatIconPos=(X=0.33,Y=0.35),
				MuzzleFlashLightClass=class'UTTankMuzzleFlash',
				WeaponEffects=((SocketName=TurretFireSocket,Offset=(X=-125),Scale3D=(X=14.0,Y=10.0,Z=10.0)))
				)}

	Seats(1)={(	GunClass=class'UTVWeap_GoliathMachineGun',
				GunSocket=(GunFireSocket),
				GunPivotPoints=(Object10),
				TurretVarPrefix="Gunner",
				TurretControls=(gun_rotate,gun_pitch),
				CameraTag=GunViewSocket,
				CameraOffset=16,
				SeatIconPos=(X=0.46,Y=0.65),
				CameraBaseOffset=(Z=30.0),
				MuzzleFlashLightClass=class'UTTankeMinigunMuzzleFlashLight',
				WeaponEffects=((SocketName=GunFireSocket,Offset=(X=-36),Scale3D=(X=6.5,Y=6.0,Z=6.0)))
				)}

	// Muzzle Flashes
	VehicleEffects(0)=(EffectStartTag=GoliathTurret,EffectTemplate=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Cannon_MuzzleFlash',EffectSocket=TurretFireSocket)
	VehicleEffects(1)=(EffectStartTag=GoliathMachineGun,EffectTemplate=ParticleSystem'VH_Goliath.Effects.P_Goliath_MiniGun_MuzzleFlash',EffectSocket=GunFireSocket)

	// Exhaust smoke
	VehicleEffects(2)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Exhaust_Smoke',EffectSocket=Exhaust_Smoke01)
	VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Exhaust_Smoke',EffectSocket=Exhaust_Smoke02)

	// Damage
	VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Goliath',EffectSocket=DamageSmoke01)

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=ScorpionEngineSound
		SoundCue=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_EngineLoop'
	End Object
	EngineSound=ScorpionEngineSound
	Components.Add(ScorpionEngineSound)

	// Track sound.
	Begin Object Class=AudioComponent Name=MyTrackSound
		SoundCue=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_EngineTreadLoop'
	End Object
	TrackSound=MyTrackSound
	Components.Add(MyTrackSound)

	TrackSoundParamScale=0.000035

	CollisionSound=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_Stop'


	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Goliath_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Goliath_Wheel_Dust')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Goliath_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Goliath_Wheel_Dust')


	// Initialize sound parameters.
	SquealThreshold=250.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	IconCoords=(U=831,V=0,UL=27,VL=38)

	BigExplosionTemplates[0]=(Template=ParticleSystem'VH_Goliath.Effects.P_VH_Goliath_DeathExplode')

	TreadSpeedParameterName=Veh_Tread_Speed

	FlagBone=Object01
	FlagOffset=(X=-95.0,Y=59,Z=50)

	Begin Object Class=SkeletalMeshComponent Name=SAntennaMesh
		SkeletalMesh=SkeletalMesh'VH_Goliath.Mesh.SK_VH_Goliath_Antenna'
		AnimTreeTemplate=AnimTree'VH_Goliath.Anims.AT_VH_Goliath_Antenna'
		ShadowParent = SVehicleMesh
		BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		PhysicsWeight=0.0
		TickGroup=TG_PostASyncWork
		bUseAsOccluder=FALSE
		CullDistance=1300.0
		CollideActors=false
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bAcceptsDecals=false
	End Object
	AntennaMesh=SAntennaMesh

	ExplosionSound=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_Explode'

	HoverBoardAttachSockets=(HoverAttach00,HoverAttach01)

	TeamMaterials[0]=MaterialInstanceConstant'VH_Goliath.Materials.MI_VH_Goliath01_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Goliath.Materials.MI_VH_Goliath01_Blue'

	DrivingPhysicalMaterial=PhysicalMaterial'vh_goliath.physmat_goliathdriving'
	DefaultPhysicalMaterial=PhysicalMaterial'vh_goliath.physmat_goliath'

	BurnOutMaterial[0]=MaterialInterface'VH_Goliath.Materials.MITV_VH_Goliath01_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Goliath.Materials.MITV_VH_Goliath01_Blue_BO'
	BurnOutMaterialTread[0]=MaterialInterface'VH_Goliath.Materials.MITV_VH_Goliath01_Red_Tread_BO'
	BurnOutMaterialTread[1]=MaterialInterface'VH_Goliath.Materials.MITV_VH_Goliath01_Blue_Tread_BO'
	PassengerTeamBeaconOffset=(X=-100.0f,Y=0.0f,Z=125.0f);

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Goliath.Materials.MI_VH_Goliath01_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Goliath.Materials.MI_VH_Goliath01_Spawn_Blue'))

	BaseEyeHeight=60.0
	bHasTurretExplosion=true
	DestroyedTurretTemplate=StaticMesh'VH_Goliath.Mesh.VH_Goliath_Turret_top'

	TurretExplosiveForce=15000

	HudCoords=(U=322,V=143,UL=-90,VL=127)

	LeftTeamMaterials[0]=MaterialInstanceConstant'VH_Goliath.Materials.MI_VH_Goliath02_Treads_Red'
	LeftTeamMaterials[1]=MaterialInstanceConstant'VH_Goliath.Materials.MI_VH_Goliath02_Treads_Blue'
	RightTeamMaterials[0]=MaterialInstanceConstant'VH_Goliath.Materials.MI_VH_Goliath03_Treads_Red'
	RightTeamMaterials[1]=MaterialInstanceConstant'VH_Goliath.Materials.MI_VH_Goliath03_Treads_Blue'

	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_ManTheGoliath')

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyGoliath'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyGoliath'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyGoliath'
	VehicleDestroyedSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyGoliathDestroyed'
	VehicleDestroyedSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyGoliathDestroyed'
	VehicleDestroyedSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyGoliathDestroyed'

	AIPurpose=AIP_Any
}
