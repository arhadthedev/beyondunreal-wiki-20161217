/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Scavenger_Content extends UTVehicle_Scavenger;

event ScavengerJumpEffect()
{
	PlaySound(JumpSound, true);
	VehicleEvent('BoostStart');
}

event ScavengerDuckEffect()
{
	if (bHoldingDuck)
	{
		if (DuckSound != None)
		{
			PlaySound(DuckSound);
		}
		VehicleEvent('CrushStart');
	}
	else
	{
		VehicleEvent('CrushStop');
	}
}

/**
 * Create all of the vehicle weapons
 */
function InitializeSeats()
{
	super.InitializeSeats();

	UTVWeap_ScavengerGun(Seats[0].Gun).MyScavenger = self;
}

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=+40.0
		CollisionRadius=+100.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Scavenger.Mesh.SK_VH_Scavenger_Torso'
		//AnimSets(0)=AnimSet'VH_Scavenger.Anim.K_VH_Scavenger'
		AnimTreeTemplate=AnimTree'VH_Scavenger.Anim.AT_VH_Scavenger_Body'
		PhysicsAsset=PhysicsAsset'VH_Scavenger.Mesh.SK_VH_Scavenger_Torso_Physics_Final'
	End Object

	DrawScale=0.5
	DrivingAnim=scavenger_idle_sitting

	Seats(0)={( GunClass=class'UTVWeap_ScavengerGun',
				GunSocket=(Gun_Socket_01,Gun_Socket_02),
				CameraTag=SphereCenter,
				CameraBaseOffset=(X=0,Y=0,Z=0),
				CameraOffset=-400,
				TurretVarPrefix="",
				DriverDamageMult=0.0,
				bSeatVisible=true,
				SeatSocket=LegsAttach,
				SeatOffset=(X=-28,Y=0,Z=26),
				SeatIconPos=(X=0.455,Y=0.46),
				SeatRotation=(Yaw=0))}

	//Effect played when something hits us
	begin object class=ParticleSystemComponent name=ImpactPart
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Shield_Impact'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	end object
	Components.Add(ImpactPart);
	ImpactParticle=ImpactPart;

	//Effect played when we hit something
	begin object class=ParticleSystemComponent name=BallHitEffect
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Ball_Hit'
		bAutoActivate=false
		AbsoluteRotation=true
		AbsoluteScale=true
		TickGroup=TG_PostAsyncWork
	end object
	BallHitComponent=BallHitEffect
	BallHitEffectTemplate[0]=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Ball_Hit'
	BallHitEffectTemplate[1]=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Ball_Hit_Blue'

	begin object class=ParticleSystemComponent Name=BoostingSystem
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Ball_Boost'
		bAutoActivate=false
		//SecondsBeforeInactive=1.0f;
	End Object
	Components.Add(BoostingSystem);
	BallBoostEffectTemplate[0]=ParticleSystem'VH_Scavenger.effects.P_VH_Scavenger_Ball_Boost';
	BallBoostEffectTemplate[1]=ParticleSystem'VH_Scavenger.effects.P_VH_Scavenger_Ball_Boost_Blue';
	BallBoostEffect=BoostingSystem;

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=MantaEngineSound
		SoundCue=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_OrbEngine_Cue'
	End Object
	EngineSound=MantaEngineSound
	Components.Add(MantaEngineSound);

	Begin Object Class=AudioComponent Name=BallRollSound
		SoundCue=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_BallRoll_Cue'
	End Object
	BallAudio=BallRollSound
	Components.Add(BallRollSound);

	CollisionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Enter_Cue'
	ExitVehicleSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Exit_Cue'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Collide_Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	// Blade spinning sound
    Begin Object Class=AudioComponent Name=BladeSpinningSoundComponent
		SoundCue=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_BladesSpin_Cue'
		bStopWhenOwnerDestroyed=TRUE
		bAllowSpatialization=TRUE
	End Object
	BladesSpinningAC=BladeSpinningSoundComponent
	Components.Add(BladeSpinningSoundComponent);

    //Blades retract sound
    Begin Object Class=AudioComponent Name=BladesRetractSoundComponent
		SoundCue=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_BladesRetract01_Cue'
		bStopWhenOwnerDestroyed=TRUE
		bAllowSpatialization=TRUE
	End Object
	BladesRetractAC=BladesRetractSoundComponent
	Components.Add(BladesRetractSoundComponent);

	// Initialize sound parameters.
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	BodyAttachSocketName=LegsAttach

	SpawnInSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeInNecris01Cue'
	SpawnOutSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeOutNecris01Cue'

	BladesHitFleshSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_BladesImpactFlesh_Cue'
	BladesHitSurfaceSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_BladesImpactSurface_Cue'

	HoverBoardAttachSockets=(HoverAttach00)
	bAllowTowFromAllDirections=TRUE

	BodyType=class'UTWalkerBody_Scavenger_Content'
	bCameraNeverHidesVehicle=true

	VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Thruster_Left',EffectTemplate_Blue=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Thruster_Left_Blue',EffectSocket=LeftThruster)
	VehicleEffects(1)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Thruster_Right',EffectTemplate_Blue=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Thruster_Right_Blue',EffectSocket=RightThruster)
	VehicleEffects(2)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Powerball',EffectTemplate_Blue=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Powerball_Blue',EffectSocket=Powerball)
	VehicleEffects(3)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Scavenger',EffectSocket=DamageSmoke_01)


	//Scavenger..(Special Case)............Only when in ball mode play this effect, place the emitter on the ground below the ball with the X facing forward and Z up, please make sure the emitter does not roll with the ball.........Also please stop spawning effect when the ball is not touching the ground

	//Use this emitter when in water....( Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Scavenger_Ball_Water_Ground_FX)
	//Use this emitter for everywhere else...( Envy_Level_Effects_2.Vehicle_Dust_Effects.PS_Scavenger_Ball_Dust_Ground_FX)

	//(Param Name: Spawn, MinINPUT: 0, MaxINPUT: 1)  0 for when the ball is not moving and 1 when at full speed (Param Name: Direction,  MinINPUT: -5  MaxINPUT: 5)  0 is when the Vh is still, positive X=forward movement 5 being max forward movement.  -X is backwards.  Y is same thing but side to side


	JumpSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Jump_Cue'
	DuckSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Land_Cue'
	LandSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Land_Cue'
	BounceSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_BallCollide_Cue'
	ArmExtendSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_ArmsExtend_Cue'
	ArmRetractSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_ArmsRetract_Cue'

	RollSoundList(0)=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue')
	RollSoundList(1)=(MaterialType=Foliage,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireFoliage01Cue')
	RollSoundList(2)=(MaterialType=Grass,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireGrass01Cue')
	RollSoundList(3)=(MaterialType=Metal,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMetal01Cue')
	RollSoundList(4)=(MaterialType=Mud,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireMud01Cue')
	RollSoundList(5)=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireSnow01Cue')
	RollSoundList(6)=(MaterialType=Stone,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireStone01Cue')
	RollSoundList(7)=(MaterialType=Wood,Sound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireWood01Cue')

	Begin Object Class=AudioComponent Name=TireSound
		SoundCue=SoundCue'A_Vehicle_Generic.Vehicle.VehicleSurface_TireDirt01Cue'
	End Object
	RollAudioComp=TireSound
	Components.Add(TireSound);

	DrivingPhysicalMaterial=PhysicalMaterial'VH_Scavenger.mesh.physmat_ScavengerDriving'
	DefaultPhysicalMaterial=PhysicalMaterial'VH_Scavenger.mesh.physmat_Scavenger'
	RollingPhysicalMaterial=PhysicalMaterial'VH_Scavenger.mesh.physmat_ScavengerRolling'

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Scavenger.Materials.MI_VH_Scavenger_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Scavenger.Materials.MI_VH_Scavenger_Spawn_Blue'))

	BurnOutMaterial[0]=MaterialInterface'VH_Scavenger.Materials.MITV_VH_Scavenger_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Scavenger.Materials.MITV_VH_Scavenger_Blue_BO'

	BallCollisionDamageType=class'UTDmgType_ScavengerBallCollision'

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Far',MinDistance=350)
	BigExplosionTemplates[1]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_VH_Death_SMALL_Near')
	BigExplosionSocket=VH_Death

	SpinAttackTotalTime=1.6

	TeamMaterials[0]=MaterialInterface'VH_Scavenger.Materials.MI_VH_Scavenger_Red'
	TeamMaterials[1]=MaterialInterface'VH_Scavenger.Materials.MI_VH_Scavenger_Blue'

	ShieldTeamMaterials[0]=MaterialInterface'VH_Scavenger.Materials.M_VH_Scavenger_Shield'
	ShieldTeamMaterials[1]=MaterialInterface'VH_Scavenger.Materials.M_VH_Scavenger_Shield_Blue'

	ShieldBurnoutTeamMaterials[0]=MaterialInterface'VH_Scavenger.Materials.MITV_VH_Scavenger_Shield_BO'
	ShieldBurnoutTeamMaterials[1]=MaterialInterface'VH_Scavenger.Materials.MITV_VH_Scavenger_Shield_Blue_BO'

	HudCoords=(U=393,V=0,UL=-124,VL=105)

	DamageMorphTargets(0)=(InfluenceBone=BodyRoot,MorphNodeName=none,LinkedMorphNodeName=none,Health=120,DamagePropNames=(Damage1))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=0.6)
	IconCoords=(U=934,UL=30,V=47,VL=29)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyScavenger'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyScavenger'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyScavenger'

	VehiclePieceClass=class'UTGib_VehiclePiece_Necris'
}
