/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_Turret extends UTVehicle_TrackTurretBase
	dependson(UTSkelControl_Turretconstrained);

/** The Template of the Beam to use */
var ParticleSystem BeamTemplate;

var color EffectColor;
var bool bFireRight;

var GameSkelCtrl_Recoil	RecoilUL, RecoilUR, RecoilLL, RecoilLR;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh)
	{
		RecoilUL = GameSkelCtrl_Recoil( mesh.FindSkelControl('RecoilUL') );
		RecoilUR = GameSkelCtrl_Recoil( mesh.FindSkelControl('RecoilUR') );
		RecoilLL = GameSkelCtrl_Recoil( mesh.FindSkelControl('RecoilLL') );
		RecoilLR = GameSkelCtrl_Recoil( mesh.FindSkelControl('RecoilLR') );
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'FlashLocation' && !IsZero(FlashLocation))
	{
		bFireRight = !bFireRight;
	}

	super.ReplicatedEvent(VarName);
}

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local ParticleSystemComponent Beam;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	// Handle Beam Effects for the shock beam
	if (!IsZero(HitLocation))
	{
		Beam = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, GetEffectLocation(SeatIndex));
		Beam.SetVectorParameter('ShockBeamEnd', HitLocation);
	}
}

function SetFlashLocation( Weapon Who, byte FireModeNum, vector NewLoc )
{
	Super.SetFlashLocation(Who,FireModeNum,NewLoc);
	bFireRight = !bFireRight;
}


simulated function SetVehicleEffectParms(name TriggerName, ParticleSystemComponent PSC)
{
	if (TriggerName == 'FireRight' || TriggerName == 'FireLeft')
	{
		PSC.SetColorParameter('MFlashColor',EffectColor);
	}
	else
	{
		Super.SetVehicleEffectParms(TriggerName, PSC);
	}
}

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
	local Name FireTriggerTag;

	Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);

	FireTriggerTag = Seats[SeatIndex].GunClass.static.GetFireTriggerTag( GetBarrelIndex(SeatIndex), SeatFiringMode(SeatIndex,,true) );

	switch(FireTriggerTag)
	{
	case 'FireUL':
		RecoilUL.bPlayRecoil = TRUE;
		break;

	case 'FireUR':
		RecoilUR.bPlayRecoil = TRUE;
		break;

	case 'FireLL':
		RecoilLL.bPlayRecoil = TRUE;
		break;

	case 'FireLR':
		RecoilLR.bPlayRecoil = TRUE;
		break;
	}
}

/**
 * We override GetCameraStart for the Turret so that it just uses the Socket Location
 */
simulated function vector GetCameraStart(int SeatIndex)
{
	local vector CamStart;

	if (Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].CameraTag, CamStart) )
	{
		return CamStart + (Seats[SeatIndex].CameraBaseOffset >> Rotation);
	}
	else
	{
		return Super.GetCameraStart(SeatIndex);
	}
}

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_Turret.Mesh.SK_VH_Turret'
		AnimTreeTemplate=AnimTree'VH_Turret.Anims.AT_VH_Turret'
		PhysicsAsset=PhysicsAsset'VH_Turret.Mesh.SK_VH_Turret_Physics'
		AnimSets.Add(AnimSet'VH_Turret.Anims.VH_Turret_anims')
		Translation=(Z=-68.0)
	End Object

	Begin Object Name=CollisionCylinder
		CollisionHeight=80.0
		CollisionRadius=100.0
	End Object

	// turret sounds.
	Begin Object Class=AudioComponent Name=TurretTwistSound
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_Rotate'
	End Object
	Components.Add(TurretTwistSound);

	Begin Object Class=AudioComponent Name=ACTurretMoveStart
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_TrackStart01Cue'
	End Object
	Components.Add(ACTurretMoveStart);
	TurretMoveStart=ACTurretMoveStart

	Begin Object Class=AudioComponent Name=ACTurretMoveLoop
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_TrackLoop01Cue'
	End Object
	Components.Add(ACTurretMoveLoop);
	TurretMoveLoop=ACTurretMoveLoop

	Begin Object Class=AudioComponent Name=ACTurretMoveStop
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_TrackStop01Cue'
	End Object
	Components.Add(ACTurretMoveStop);
	TurretMoveStop=ACTurretMoveStop

	// sound is utterly annoying and no one liked it
	// 	Begin Object Class=AudioComponent Name=PowerSound
	// 		SoundCue=SoundCue'A_Vehicle_Turret.Cue.AxonTurret_PowerLoopCue'
	// 	End Object
	// 	components.add(PowerSound);
	// 	EngineSound = PowerSound;
	
	CollisionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Collide'


	Seats(0)={(	GunClass=class'UTVWeap_TurretPrimary',
				GunSocket=(LU_Barrel,RU_Barrel,LL_Barrel,RL_Barrel),
				TurretVarPrefix="",
				TurretControls=(MegaTurret,TurretBase),
				CameraTag=CameraViewSocket,
				bSeatVisible=true,
				GunPivotPoints=(Seat),
				bDisableOffsetZAdjust=true,
				SeatMotionAudio=TurretTwistSound,
				CameraEyeHeight=5,
				SeatBone=Seat,
				SeatIconPos=(X=0.47,Y=0.65),
				SeatOffset=(X=43,Z=-7),
				CameraOffset=-120,
				DriverDamageMult=0.1,
				WeaponEffects=((SocketName=LL_Barrel,Offset=(X=-35,Y=-3),Scale3D=(X=4.0,Y=4.5,Z=4.5)),(SocketName=RL_Barrel,Offset=(X=-35,Y=-3),Scale3D=(X=4.0,Y=4.5,Z=4.5)),(SocketName=LU_Barrel,Offset=(X=-35,Y=-3),Scale3D=(X=4.0,Y=4.5,Z=4.5)),(SocketName=RU_Barrel,Offset=(X=-35,Y=-3),Scale3D=(X=4.0,Y=4.5,Z=4.5)))
				)}

	VehicleEffects(0)=(EffectStartTag=FireUL,EffectTemplate=ParticleSystem'VH_Turret.Effects.P_VH_Turret_MuzzleFlash',EffectSocket=LU_Barrel)
	VehicleEffects(1)=(EffectStartTag=FireUR,EffectTemplate=ParticleSystem'VH_Turret.Effects.P_VH_Turret_MuzzleFlash',EffectSocket=RU_Barrel)
	VehicleEffects(2)=(EffectStartTag=FireLL,EffectTemplate=ParticleSystem'VH_Turret.Effects.P_VH_Turret_MuzzleFlash',EffectSocket=LL_Barrel)
	VehicleEffects(3)=(EffectStartTag=FireLR,EffectTemplate=ParticleSystem'VH_Turret.Effects.P_VH_Turret_MuzzleFlash',EffectSocket=RL_Barrel)
	VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_Turret',EffectSocket=DamageSmoke_01)

	VehicleAnims(0)=(AnimTag=EngineStart,AnimSeqs=(GetIn),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=TurretPlayer)
	VehicleAnims(1)=(AnimTag=EngineStop,AnimSeqs=(GetOut),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=TurretPlayer)


 	EffectColor=(R=35,G=26,B=151,A=255)
	BeamTemplate=VH_Turret.Effects.P_VH_Turret_TurretBeam

	FlagOffset=(X=-45.0,Y=60.0,Z=85.0)
	FlagBone=Seat

	HudCoords=(U=92,V=249,UL=-92,VL=118)

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Turret.Material.MI_VH_Turret_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Turret.Material.MI_VH_Turret_Spawn_Blue'))

	TeamMaterials[0]=MaterialInstanceConstant'VH_Turret.Material.MI_VH_Turret_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Turret.Material.MI_VH_Turret_Blue'

	BurnOutMaterial[0]=MaterialInterface'VH_Turret.Material.MITV_VH_Turret_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Turret.Material.MITV_VH_Turret_Blue_BO'

	ExitRadius=175.0
	TargetLocationAdjustment=(Z=100.0)
}
