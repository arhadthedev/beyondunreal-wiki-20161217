/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_DarkWalker_Content extends UTVehicle_DarkWalker;

/** dynamic light which moves around following primary fire beam impact point */
var UTDarkWalkerBeamLight BeamLight;

var float HornImpulseMag;
var float VehicleHornModifier;
var ParticleSystemComponent DarkwalkerHornEffect;
var repnotify bool bSpeakerReady;
var float SpeakerRadius;
var float SpeakerRechargeTime;
var SoundCue HornAttackSound;


replication
{
	if (!bNetOwner)
		bSpeakerReady;
}

event MantaDuckEffect()
{
	if (bHoldingDuck)
	{
		VehicleEvent('CrushStart');
	}
	else
	{
		VehicleEvent('CrushStop');
	}
}

function DriverLeft()
{
	Super.DriverLeft();

	if (Role == ROLE_Authority && UTVWeap_DarkWalkerTurret(Seats[0].Gun) != none)
	{
		UTVWeap_DarkWalkerTurret(Seats[0].Gun).StopBeamFiring();
	}
}

/** Overloaded so we can attach the muzzle flash light to a custom socket */
simulated function CauseMuzzleFlashLight(int SeatIndex)
{
	Super.CauseMuzzleFlashLight(SeatIndex);

	if ( (SeatIndex == 0) && Seats[SeatIndex].MuzzleFlashLight != none )
	{
		Mesh.DetachComponent(Seats[SeatIndex].MuzzleFlashLight);
		Mesh.AttachComponentToSocket(Seats[SeatIndex].MuzzleFlashLight, 'PrimaryMuzzleFlash');
	}
}

simulated function SpawnImpactEmitter(vector HitLocation, vector HitNormal, const out MaterialImpactEffect ImpactEffect, int SeatIndex)
{
	Super.SpawnImpactEmitter(HitLocation, HitNormal, ImpactEffect, SeatIndex);

	if ( SeatIndex == 0 )
	{
		if (BeamLight == None || BeamLight.bDeleteMe)
		{
			BeamLight = Spawn(class'UTDarkWalkerBeamLight');
			BeamLight.AmbientSound.Play();
		}
		BeamLight.SetLocation(HitLocation + HitNormal*128);
	}
}

simulated function KillBeamEmitter()
{
	Super.KillBeamEmitter();

	if (BeamLight != None)
	{
		BeamLight.Destroy();
	}
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (BeamLight != None)
	{
		BeamLight.Destroy();
	}
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	Super.SetBeamEmitterHidden(bHide);

	if (bHide && BeamLight != None)
	{
		BeamLight.AmbientSound.Stop();
		BeamLight.Destroy();
	}
}

simulated function bool OverrideBeginFire(byte FireModeNum)
{
	if (FireModeNum == 1)
	{
		if (bSpeakerReady)
		{
			PlayHornAttack();
		}
		return true;
	}

	return false;
}

function byte ChooseFireMode()
{
	if (Controller != None && Controller.Enemy != None && bSpeakerReady && VSize2D(Controller.Enemy.Location - Location) <= SpeakerRadius)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

function bool NeedToTurn(vector Targ)
{
	// speaker fire is a radius, so if bot wants to do that, don't need to turn
	return (ChooseFireMode() == 1) ? false : Super.NeedToTurn(Targ);
}

simulated function PlayHornAttack()
{
	local Pawn HitPawn;
	local vector HornImpulse, HitLocation, HitNormal;
	local Pawn BoardPawn;
	local UTVehicle_Scavenger UTScav;
	local UTPawn OldDriver;
	local UTVehicle UTV;

	bSpeakerReady = false;

	if (Trace(HitLocation, HitNormal, Location - vect(0,0,600), Location) != None)
	{
		DarkwalkerHornEffect.SetTranslation(HitLocation - Location);
	}
	else
	{
		HitLocation = Location;
		HitLocation.Z -= 400;
		DarkwalkerHornEffect.SetTranslation(vect(0,0,-400));
	}
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		PlaySound(HornAttackSound, true);
		DarkwalkerHornEffect.ActivateSystem();
	}

	if (Role == ROLE_Authority)
	{
		MakeNoise(1.0);

		foreach OverlappingActors(class 'Pawn', HitPawn, SpeakerRadius, HitLocation)
		{
			if ( (HitPawn.Mesh != None) && !WorldInfo.GRI.OnSameTeam(HitPawn, self))
			{
				// throw him outwards also
				HornImpulse = HitPawn.Location - HitLocation;
				HornImpulse.Z = 0;
				HornImpulse = HornImpulseMag * Normal(HornImpulse);
				HornImpulse.Z = 250.0;

				if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
				{
					HitPawn.Velocity += HornImpulse;
					UTPawn(HitPawn).ForceRagdoll();
					UTPawn(HitPawn).FeignDeathStartTime = WorldInfo.TimeSeconds + 1.5;
					HitPawn.LastHitBy = Controller;
				}
				else if( UTVehicle_Hoverboard(HitPawn) != none)
				{
					HitPawn.Velocity += HornImpulse;
					BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
					UTVehicle_Hoverboard(HitPawn).RagdollDriver();
					HitPawn = BoardPawn;
					HitPawn.LastHitBy = Controller;
				}
				else if ( HitPawn.Physics == PHYS_RigidBody )
				{
					UTV = UTVehicle(HitPawn);
					if(UTV != none)
					{
						// Special case for scavenger - force into ball mode for a bit.
						UTScav = UTVehicle_Scavenger(UTV);
						if(UTScav != None && UTScav.bDriving)
						{
							UTScav.BallStatus.bIsInBallMode = TRUE;
							UTScav.BallStatus.bBoostOnTransition = FALSE;
							UTScav.NextBallTransitionTime = WorldInfo.TimeSeconds + 2.0; // Stop player from putting legs out for 2 secs.
							UTScav.BallModeTransition();
						}
						// See if darkwalker forces this player out of vehicle.
						else if(UTV.bRagdollDriverOnDarkwalkerHorn)
						{
							OldDriver = UTPawn(UTV.Driver);
							if (OldDriver != None)
							{
								UTV.DriverLeave(true);
								OldDriver.Velocity += HornImpulse;
								OldDriver.ForceRagdoll();
								OldDriver.FeignDeathStartTime = WorldInfo.TimeSeconds + 1.5;
								OldDriver.LastHitBy = Controller;
							}
						}

						HitPawn.Mesh.AddImpulse(HornImpulse*VehicleHornModifier, HitLocation);
					}
					else
					{
						HitPawn.Mesh.AddImpulse(HornImpulse, HitLocation,, true);
					}
				}
			}
		}
	}
	SetTimer(SpeakerRechargeTime, false, 'ClearHornTimer');
}

simulated function ClearHornTimer()
{
	bSpeakerReady = true;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bSpeakerReady')
	{
		if (!bSpeakerReady)
		{
			PlayHornAttack();
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function TeamChanged()
{
	local MaterialInterface NewMaterial;

	if( Team < PowerOrbTeamMaterials.length )
	{
		NewMaterial = PowerOrbTeamMaterials[Team];
	}
	else
	{
		NewMaterial = PowerOrbTeamMaterials[0];
	}

	if (NewMaterial != None)
	{
		Mesh.SetMaterial(1, NewMaterial);

		if (DamageMaterialInstance[1] != None)
		{
			DamageMaterialInstance[1].SetParent(NewMaterial);
		}
	}

	Super.TeamChanged();
}



defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=140.0
		Translation=(X=0.0,Y=0.0,Z=50.0)
	End Object

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_DarkWalker.Mesh.SK_VH_DarkWalker_Torso'
		AnimSets(0)=AnimSet'VH_DarkWalker.Anims.K_VH_DarkWalker'
		AnimTreeTemplate=AnimTree'VH_DarkWalker.Anims.AT_VH_DarkWalker'
		PhysicsAsset=PhysicsAsset'VH_DarkWalker.Mesh.SK_VH_DarkWalker_Torso_Physics'
		MorphSets[0]=MorphTargetSet'VH_DarkWalker.Mesh.SK_VH_DarkWalker_Torso_MorphTargets'
	End Object

	Begin Object Class=AudioComponent Name=WarningSound
		SoundCue=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_Darkwalker_WarningConeLoop'
	End Object
	WarningConeSound=WarningSound
	Components.Add(WarningSound);

	Seats(0)={( GunClass=class'UTVWeap_DarkWalkerTurret',
				GunSocket=(MainGun_Fire),
				GunPivotPoints=(PrimaryTurretPitch),
				TurretVarPrefix="",
				CameraTag=DriverViewSocket,
				CameraOffset=-280,
				CameraSafeOffset=(Z=200),
				DriverDamageMult=0.0,
				SeatIconPos=(X=0.46,Y=0.2),
				TurretControls=(MainGunPitch),
				CameraBaseOffset=(X=40,Y=0,Z=0),
				MuzzleFlashLightClass=class'UTDarkWalkerMuzzleFlashLight',
				WeaponEffects=((SocketName=MainGun_00,Offset=(X=-35,Y=-3),Scale3D=(X=8.0,Y=10.0,Z=10.0)),(SocketName=MainGun_01,Offset=(X=-35,Y=-3),Scale3D=(X=8.0,Y=10.0,Z=10.0)))
				)}


	Seats(1)={( GunClass=class'UTVWeap_DarkWalkerPassGun',
				GunSocket=(TurretBarrel_00,TurretBarrel_01,TurretBarrel_02,TurretBarrel_03),
				GunPivotPoints=(SecondaryTurretYaw),
				TurretVarPrefix="Turret",
				TurretControls=(TurretYaw,TurretPitch),
				DriverDamageMult=0.0,
				CameraOffset=0,
				CameraSafeOffset=(Z=200),
				CameraTag=TurretViewSocket,
				DriverDamageMult=0.0,
				bSeatVisible=true,
				SeatIconPos=(X=0.46,Y=0.5),
				SeatBone=SecondaryTurretYaw,
				SeatOffset=(X=162,Y=0,Z=-81),
				WeaponEffects=((SocketName=TurretBarrel_00,Offset=(X=-35,Z=-12),Scale3D=(X=8.0,Y=10.0,Z=10.0)),(SocketName=TurretBarrel_01,Offset=(X=-35,Z=-12),Scale3D=(X=8.0,Y=10.0,Z=10.0)))
				)}

	// These muzzleflashes are the idle effects it seems, so start them with the engine.
	VehicleEffects(0)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_MuzzleFlash',EffectSocket=MainGun_00)
	VehicleEffects(1)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_MuzzleFlash',EffectSocket=MainGun_01)

	VehicleEffects(2)=(EffectStartTag=TurretWeapon03,EffectEndTag=STOP_TurretWeapon00,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_Secondary_MuzzleFlash',EffectSocket=TurretBarrel_00)
	VehicleEffects(3)=(EffectStartTag=TurretWeapon00,EffectEndTag=STOP_TurretWeapon01,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_Secondary_MuzzleFlash',EffectSocket=TurretBarrel_01)
	VehicleEffects(4)=(EffectStartTag=TurretWeapon01,EffectEndTag=STOP_TurretWeapon02,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_Secondary_MuzzleFlash',EffectSocket=TurretBarrel_02)
	VehicleEffects(5)=(EffectStartTag=TurretWeapon02,EffectEndTag=STOP_TurretWeapon03,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_Secondary_MuzzleFlash',EffectSocket=TurretBarrel_03)

	VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_AimBeam',EffectSocket=LT_AimBeamSocket)
	VehicleEffects(7)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_AimBeam',EffectSocket=RT_AimBeamSocket)
	VehicleEffects(8)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_PowerBall',EffectTemplate_Blue=ParticleSystem'VH_Darkwalker.Effects.P_VH_DarkWalker_PowerBall_Blue',EffectSocket=PowerBallSocket)
	VehicleEffects(9)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_DarkWalker',EffectSocket=DamageSmoke01)

	Begin Object Class=ParticleSystemComponent Name=HornEffect
		Template=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_HornEffect'
		bAutoActivate=false
		Translation=(x=0.0,y=0.0,z=-400.0)
		SecondsBeforeInactive=1.0f
	End Object
	Components.Add(HornEffect);
	DarkwalkerHornEffect=HornEffect;

	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=MantaEngineSound
		SoundCue=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_EngineLoopCue'
	End Object
	EngineSound=MantaEngineSound
	Components.Add(MantaEngineSound);

	CollisionSound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_CollideCue'
	EnterVehicleSound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_StartCue'
	ExitVehicleSound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_StopCue'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	// Initialize sound parameters.
	EngineStartOffsetSecs=2.0
	EngineStopOffsetSecs=1.0

	BodyAttachSocketName=PowerBallSocket

	BeamTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_MainGun_Beam'
	BeamSockets(0)=MainGun_00
	BeamSockets(1)=MainGun_01
	EndPointParamName=LinkBeamEnd

	Begin Object Class=AudioComponent name=BeamAmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	BeamAmbientSound=BeamAmbientSoundComponent
	Components.Add(BeamAmbientSoundComponent)

	BeamFireSound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_FireBeamCue'
	FlagBone=Head

	HornAttackSound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_HornCue'
	SpawnInSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeInNecris01Cue'
	SpawnOutSound=SoundCue'A_Vehicle_Generic.Vehicle.VehicleFadeOutNecris01Cue'
	ExplosionSound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_ExplosionCue'

	BigExplosionTemplates[0]=(Template=ParticleSystem'Envy_Effects.VH_Deaths.P_DarkWalker_Death_Main')
	BigExplosionSocket=PowerBallSocket
	BodyType=class'UTWalkerBody_DarkWalker'

	bSpeakerReady=true
	SpeakerRadius=750.0f
	SpeakerRechargeTime=7.0
	HornImpulseMag=1250.0
	VehicleHornModifier=5.3f
	PassengerTeamBeaconOffset=(X=-150.0f,Y=0.0f,Z=0.0f)
	TargetLocationAdjustment=(Z=150.0)

	ConeParam=ConeScore

	DamageMorphTargets(0)=(InfluenceBone=head,MorphNodeName=MorphNodeW_DamageFront,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage3))
	DamageMorphTargets(1)=(InfluenceBone=RtUpperTailFin,MorphNodeName=MorphNodeW_DamageRear,LinkedMorphNodeName=none,Health=300,DamagePropNames=(Damage2))
	DamageMorphTargets(2)=(InfluenceBone=LtPanel_Damage,MorphNodeName=none,LinkedMorphNodeName=none,Health=250,DamagePropNames=(Damage1))
	DamageMorphTargets(3)=(InfluenceBone=RtPanel_Damage,MorphNodeName=none,LinkedMorphNodeName=none,Health=250,DamagePropNames=(Damage1))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=1.6)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)

	HudCoords=(U=644,V=0,UL=-98,VL=129)

	TeamMaterials[0]=MaterialInstanceConstant'VH_DarkWalker.Materials.MI_VH_Darkwalker_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_DarkWalker.Materials.MI_VH_Darkwalker_Blue'
	BurnOutMaterial[0]=MaterialInterface'VH_DarkWalker.Materials.MITV_VH_Darkwalker_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_DarkWalker.Materials.MITV_VH_Darkwalker_Blue_BO'

	PowerOrbTeamMaterials[0]=MaterialInterface'VH_DarkWalker.Materials.M_VH_Darkwalker_EnergyCore_Glow'
	PowerOrbTeamMaterials[1]=MaterialInterface'VH_DarkWalker.Materials.M_VH_Darkwalker_EnergyCore_Glow_Blue'
	PowerOrbBurnoutTeamMaterials[0]=MaterialInterface'VH_DarkWalker.Materials.MITV_VH_Darkwalker_EnergyCore_Glow_BO'
	PowerOrbBurnoutTeamMaterials[1]=MaterialInterface'VH_DarkWalker.Materials.MITV_VH_Darkwalker_EnergyCore_Glow_Blue_BO'


	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_DarkWalker.Materials.MI_VH_Darkwalker_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_DarkWalker.Materials.MI_VH_Darkwalker_Spawn_Blue'))

	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_ManTheDarkwalker')

	IconCoords=(U=907,UL=26,V=36,VL=37)

	bHasEnemyVehicleSound=true
	EnemyVehicleSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyDarkwalker'
	EnemyVehicleSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyDarkwalker'
	EnemyVehicleSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyDarkwalker'
	VehicleDestroyedSound(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_EnemyDarkwalkerDestroyed'
	VehicleDestroyedSound(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_EnemyDarkwalkerDestroyed'
	VehicleDestroyedSound(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_EnemyDarkwalkerDestroyed'

	AIPurpose=AIP_Any
}
