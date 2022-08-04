/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_StealthBender_Content extends UTVehicle_StealthBender;

/** MIs for the turret **/
var MaterialInterface BurnOutTurret[2];


simulated function SetBurnOut()
{
	local int TeamNum;

	TeamNum = GetTeamNum();

	if( TeamNum > 1 )
	{
		TeamNum = 0;
	}

	// set our specific turret BurnOut Material
	if (BurnOutTurret[TeamNum] != None)
	{
		Mesh.SetMaterial( 1, BurnOutTurret[TeamNum] );
	}

	// sets the MIC
	super.SetBurnOut();
}



defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+40.0
		CollisionRadius=+140.0
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_StealthBender.Mesh.SK_VH_StealthBender'
		PhysicsAsset=PhysicsAsset'VH_StealthBender.Mesh.SK_VH_StealthBender_Physics'
		AnimTreeTemplate=AnimTree'VH_StealthBender.Anims.AT_VH_StealthBender'
		AnimSets(0)=AnimSet'VH_StealthBender.Anims.K_VH_StealthBender'
		Materials(0)=MaterialInstanceConstant'VH_Hellbender.Materials.MI_VH_Hellbender_Red'
		Materials(1)=Material'VH_StealthBender.Materials.M_VH_Stealthbender'
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE,Untitled4=TRUE)
	End Object


	Begin Object Class=AudioComponent Name=ArmSound
		SoundCue=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_ArmsMove01_Cue'
	End Object
	Components.Add(ArmSound);
	TurretArmMoveSound=ArmSound

	EnterVehicleSound=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_EngineStart01_Cue'
	ExitVehicleSound=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_EngineStop01_Cue'


	DrawScale=1.2

	BeamSockets=GunnerFireSocket

	Seats(0)={(	GunClass=class'UTVWeap_StealthbenderGun',
				GunSocket=(GunnerFireSocket),
				TurretControls=(GunnerConstraint,DeployYaw),
				SeatIconPos=(X=0.42,Y=0.48),
				CameraTag=DriverViewSocket,
				CameraOffset=-400,
				CameraBaseOffset=(X=-90.0,Z=20.0),
				DriverDamageMult=0.0,
				WeaponEffects=((SocketName=GunnerFireSocket,Offset=(X=-35),Scale3D=(X=4.0,Y=6.5,Z=6.5)))
			 )}

	Begin Object Class=AudioComponent name=BeamAmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	BeamAmbientSound=BeamAmbientSoundComponent
	Components.Add(BeamAmbientSoundComponent)

	BeamFireSound=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_FireLoop01_Cue'
	BeamStartSound=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_FireStart01_Cue'
	BeamStopSound=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_FireStop01_Cue'

	SkinTranslucencyName=skintranslucency
	HitEffectName=HitEffect
	OverlayColorName=Veh_OverlayColor

	// Sounds

	Begin Object Class=AudioComponent Name=ScorpionTireSound
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	TireAudioComp=ScorpionTireSound
	Components.Add(ScorpionTireSound);

	TireSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	TireSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	TireSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	TireSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	TireSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	TireSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	TireSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	TireSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')
	TireSoundList(8)=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWater01Cue')

	// Engine sound.
	Begin Object Class=AudioComponent Name=HellBenderEngineSound
		SoundCue=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_EngineLoop01_Cue'
	End Object
	EngineSound=HellBenderEngineSound
	Components.Add(HellBenderEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_Impact_Cue'

	// Stealth Res Sound
	Begin Object Class=AudioComponent Name=StealthBenderStealthResSound
		SoundCue=SoundCue'A_Gameplay.Portal.Portal_WalkThrough01Cue'
		bStopWhenOwnerDestroyed=TRUE
		bAllowSpatialization=TRUE
	End Object
	StealthResSound=StealthBenderStealthResSound
	Components.Add(StealthBenderStealthResSound);

	// Initialize sound parameters.
	SquealThreshold=250.0
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	VehicleEffects(0)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_StealthBender',EffectSocket=DamageSmoke_01)
	VehicleEffects(1)=(EffectStartTag=ShockTurretFire,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_DriverPrimMuzzleFlash',EffectSocket=GunnerFireSocket)
	VehicleEffects(2)=(EffectStartTag=ShockTurretAltFire,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_DriverAltMuzzleFlash',EffectSocket=GunnerFireSocket)

	//VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_GenericExhaust',EffectSocket=ExhaustLeft)
	//VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_GenericExhaust',EffectSocket=ExhaustRight)

	//VehicleAnims(0)=(AnimTag=EngineStart,AnimSeqs=(GetIn),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	//VehicleAnims(2)=(AnimTag=EngineStop,AnimSeqs=(GetOut),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	//VehicleAnims(3)=(AnimTag=Inactive,AnimSeqs=(InactiveIdle),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=AnimPlayer)

	//DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=3.0)
	//DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.0)
	//DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=3.0)


	BeamTemplate=ParticleSystem'VH_StealthBender.Effects.P_VH_StealthBender_Beam'

	ExplosionSound=SoundCue'A_Vehicle_Hellbender.SoundCues.A_Vehicle_Hellbender_Explode'
	ExhaustEffectName=ExhaustVel

	// deploy functionality
	IdleAnim(0)=InactiveIdle
	IdleAnim(1)=Idle
	DeployAnim(0)=ArmExtend
	DeployAnim(1)=ArmRetract
	GetInAnim(0)=GetIn
	GetOutAnim(0)=GetOut

	DeploySound=SoundCue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_ArmsExtend01_Cue'
	UndeploySound=Soundcue'A_Vehicle_Stealthbender.Stealthbender.A_Vehicle_Stealthbender_ArmsRetract01_Cue'


	DeployTime = 1.3;
	UnDeployTime = 1.3;

	HoverBoardAttachSockets=(HoverAttach00)

	EndPointParamName=LinkBeamEnd

	LinkBeamColors(0)=(R=255,G=64,B=64,A=255)
	LinkBeamColors(1)=(R=64,G=64,B=255,A=255)
	LinkBeamColors(2)=(R=32,G=255,B=32,A=255)
	TurretName=DeployYaw

	DrivingPhysicalMaterial=PhysicalMaterial'vh_hellbender.materials.physmat_hellbenderdriving'
	DefaultPhysicalMaterial=PhysicalMaterial'vh_hellbender.materials.physmat_hellbender'

	TeamMaterials[0]=MaterialInterface'VH_StealthBender.Materials.MI_VH_StealthBenderMain_Red'
	TeamMaterials[1]=MaterialInterface'VH_StealthBender.Materials.MI_VH_StealthBenderMain_Blue'

	SecondaryTeamSkins[0]=MaterialInterface'VH_StealthBender.Materials.MI_VH_Stealthbender_Red'
	SecondaryTeamSkins[1]=MaterialInterface'VH_StealthBender.Materials.MI_VH_Stealthbender_Blue'

	CloakedSkin=MaterialInterface'VH_StealthBender.Materials.M_VH_StealthBender_Skin';

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_StealthBender.Materials.MI_VH_StealthBenderMain_Spawn_Red',MaterialInterface'VH_Hellbender.Materials.MI_VH_Hellbender_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_StealthBender.Materials.MI_VH_StealthBenderMain_Spawn_Blue',MaterialInterface'VH_Hellbender.Materials.MI_VH_Hellbender_Spawn_Blue'))

	BurnOutMaterial[0]=MaterialInterface'VH_StealthBender.Materials.MITV_VH_StealthBenderMain_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_StealthBender.Materials.MITV_VH_StealthBenderMain_Blue_BO'

	BurnOutTurret[0]=MaterialInterface'VH_StealthBender.Materials.MITV_VH_Stealthbender_Red_BO'
	BurnOutTurret[1]=MaterialInterface'VH_StealthBender.Materials.MITV_VH_Stealthbender_Blue_BO'

	TeamSkinParamName=SkinColor

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGE_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_LARGEL_Near')
	BigExplosionSocket=VH_Death

	HudCoords=(U=826,V=0,UL=-81,VL=115)
	IconCoords=(U=886,UL=19,V=35,VL=30)

	DeployablePositionOffsets(0)=(X=-10,Y=0,Z=-10) //Spider Mine
	DeployablePositionOffsets(1)=(X=-5,Y=0,Z=-10)  //Slow Volume
	DeployablePositionOffsets(2)=(X=-5,Y=0,Z=-5)   //EMP Mine
	DeployablePositionOffsets(3)=(X=-5,Y=0,Z=-10)  //Energy Shield

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyStealthbender'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyStealthbender'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyStealthbender'

	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_ManTheStealthBender')

	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dust_Effects.P_Hellbender_Wheel_Dust')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Dirt_Effects.P_Hellbender_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Hellbender_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Hellbender_Wheel_Snow')

    ToolTipIconCoords=(U=359,V=241,UL=126,VL=58)
}
