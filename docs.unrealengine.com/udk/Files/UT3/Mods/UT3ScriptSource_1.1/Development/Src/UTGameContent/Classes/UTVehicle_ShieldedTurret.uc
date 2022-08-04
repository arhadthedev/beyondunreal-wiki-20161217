/**
 * Once upon a time these turrets actually had shields. Really.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicle_ShieldedTurret extends UTVehicle_TrackTurretBase
	abstract;

var GameSkelCtrl_Recoil	RecoilLeft, RecoilRight;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh)
	{
		RecoilLeft = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoil') );
		RecoilRight = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoil') );
	}
}

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
	local Name FireTriggerTag;

	Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);

	FireTriggerTag = Seats[SeatIndex].GunClass.static.GetFireTriggerTag( GetBarrelIndex(SeatIndex), SeatFiringMode(SeatIndex,,true) );

	switch(FireTriggerTag)
	{
	case 'TurretFireRight':
		RecoilRight.bPlayRecoil = TRUE;
		break;

	case 'TurretFireLeft':
		RecoilLeft.bPlayRecoil = TRUE;
		break;
	}
}

defaultproperties
{
	Begin Object Name=SVehicleMesh
		bUseSingleBodyPhysics=0
		bHasPhysicsAssetInstance=true
		SkeletalMesh=SkeletalMesh'VH_Turret.Mesh.SK_VH_TurretSmall'
		AnimTreeTemplate=AnimTree'VH_Turret.Anims.AT_VH_TurretSmall'
		PhysicsAsset=PhysicsAsset'VH_Turret.Mesh.SK_VH_TurretSmall_Physics'
		AnimSets[0]=AnimSet'VH_Turret.Anims.VH_TurretSmall_Anims'
		Translation=(Z=-55)
		Scale=3.5
	End Object

	VehicleAnims(0)=(AnimTag=EngineStart,AnimSeqs=(GetIn),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=TurretPlayer)
	VehicleAnims(1)=(AnimTag=EngineStop,AnimSeqs=(GetOut),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=TurretPlayer)

	DrivingAnim=Hellbender_Idle_Sitting

	FlagOffset=(X=0.0,Y=0.0,Z=25.0)
	FlagBone=base-piston

	Begin Object Name=CollisionCylinder
		CollisionRadius=100.000000
		CollisionHeight=80.0
		Translation=(Z=60.0)
	End Object

	TargetLocationAdjustment=(x=0.0,y=0.0,z=55.0)

	VehicleEffects(0)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'Envy_Effects.Vehicle_Damage.P_Vehicle_Damage_1_TurretSmall',EffectSocket=DamageSmoke_01)

	SpawnMaterialLists[0]=(Materials=(MaterialInterface'VH_Turret.Material.MI_VH_Turret_Spawn_Red'))
	SpawnMaterialLists[1]=(Materials=(MaterialInterface'VH_Turret.Material.MI_VH_Turret_Spawn_Blue'))

	TeamMaterials[0]=MaterialInstanceConstant'VH_Turret.Material.MI_VH_Turret_Red'
	TeamMaterials[1]=MaterialInstanceConstant'VH_Turret.Material.MI_VH_Turret_Blue'

	BurnOutMaterial[0]=MaterialInterface'VH_Turret.Material.MITV_VH_Turret_Red_BO'
	BurnOutMaterial[1]=MaterialInterface'VH_Turret.Material.MITV_VH_Turret_Blue_BO'

	// turret sounds.

	Begin Object Class=AudioComponent Name=ACTurretMoveStart
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_TrackStart01Cue'
	End Object
	TurretMoveStart=ACTurretMoveStart
	Components.Add(ACTurretMoveStart)

	Begin Object Class=AudioComponent Name=ACTurretMoveLoop
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_TrackLoop01Cue'
	End Object
	TurretMoveLoop=ACTurretMoveLoop
	Components.Add(ACTurretMoveLoop)

	Begin Object Class=AudioComponent Name=ACTurretMoveStop
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_TrackStop01Cue'
	End Object
	TurretMoveStop=ACTurretMoveStop
	Components.Add(ACTurretMoveStop)

	Begin Object Class=AudioComponent Name=TurretTwistSound
		SoundCue=SoundCue'A_Vehicle_Turret.Cue.A_Turret_Rotate'
	End Object
	Components.Add(TurretTwistSound)

	HudCoords=(U=92,V=249,UL=-92,VL=118)

	CollisionSound=SoundCue'A_Vehicle_Manta.SoundCues.A_Vehicle_Manta_Collide'
}
