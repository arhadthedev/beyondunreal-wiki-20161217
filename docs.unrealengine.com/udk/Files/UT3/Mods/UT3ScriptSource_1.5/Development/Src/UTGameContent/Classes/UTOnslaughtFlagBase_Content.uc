/**
 * UTOnslaughtFlagBase.
 *
 * Onslaught levels with may have a UTOnslaughtFlagBase to spawn an orb for that team
 * they may also have additional flag bases placed near nodes that the orb will return to instead if it is closer
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTOnslaughtFlagBase_Content extends UTOnslaughtFlagBase;

var() CylinderComponent	CylinderComp;
var() CylinderComponent	CylinderComp2;

defaultproperties
{
	bStatic=false
	bStasis=false
	bHidden=false
	bAlwaysRelevant=true
	NetUpdateFrequency=1
	bBlocksTeleport=true
	bBlockedForVehicles=true

	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	GoodSprite=None
	BadSprite=None

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0048.000000
		CollisionHeight=+0060.000000
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
	End Object

	Begin Object Class=ParticleSystemComponent Name=PSC
		Translation=(Z=-60)
		SecondsBeforeInactive=1.0f
	End Object
	BallEffect=PSC
	Components.Add(PSC)

	Begin Object Class=DynamicLightEnvironmentComponent Name=OnslaughtFlagBaseLightEnvironment
		bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(OnslaughtFlagBaseLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Pickups.PowerCellDispenser.Mesh.SK_Pickups_Orb_Dispenser-Optimized'
		AnimSets[0]=AnimSet'Pickups.PowerCellDispenser.Anims.Anim_Orb_Dispenser'
		AnimTreeTemplate=Pickups.PowerCellDispenser.Anims.AT_Pickups_PowerCellDispenser
		BlockActors=true
		BlockZeroExtent=true
		BlockRigidBody=true
		BlockNonzeroExtent=true
		CollideActors=true
		CastShadow=true
		bCastDynamicShadow=false
		LightEnvironment=OnslaughtFlagBaseLightEnvironment
		Translation=(X=0.0,Y=0.0,Z=-64.0)
		bUseAsOccluder=FALSE
		PhysicsAsset=PhysicsAsset'Pickups.PowerCellDispenser.Mesh.SK_Pickups_Orb_Dispenser-Optimized_Physics'
		bHasPhysicsAssetInstance=true
		bAcceptsDecals=false
		bUpdateSkelWhenNotRendered=false
		bForceRefpose=1
		bCacheAnimSequenceNodes=FALSE
	End Object
 	Components.Add(SkeletalMeshComponent0)
 	Mesh=SkeletalMeshComponent0
 	CollisionComponent=SkeletalMeshComponent0

	Begin Object Class=CylinderComponent Name=MyCylinder
		Translation=(X=99,Y=0,Z=0)
		CollisionRadius=+0060.000000
		CollisionHeight=+0078.000000
		BlockNonZeroExtent=TRUE
		BlockZeroExtent=FALSE
		BlockActors=TRUE
		CollideActors=TRUE
	End Object
	Components.Add(MyCylinder);
	CylinderComp=MyCylinder

	Begin Object Class=CylinderComponent Name=MyCylinder2
		Translation=(X=52,Y=0,Z=85)
		CollisionRadius=+0037.000000
		CollisionHeight=+0010.000000
		BlockNonZeroExtent=TRUE
		BlockZeroExtent=FALSE
		BlockActors=TRUE
		CollideActors=TRUE
		End Object
	Components.Add(MyCylinder2);
	CylinderComp2=MyCylinder2

	TeamEmitters(0)=ParticleSystem'Pickups.PowerCellDispenser.Effects.P_CellDispenser_Idle_Red'
	TeamEmitters(1)=ParticleSystem'Pickups.PowerCellDispenser.Effects.P_CellDispenser_Idle_Blue'
	TeamEmitters(2)=ParticleSystem'PICKUPS.PowerCellDispenser.Effects.P_CellDispenser_Idle_Neutral'
	BaseMaterials(0)=Pickups.PowerCellDispenser.Materials.M_Pickups_Orb_Dispenser_Red
	BaseMaterials(1)=Pickups.PowerCellDispenser.Materials.M_Pickups_Orb_Dispenser_Blue
	BaseMaterials(2)=PICKUPS.PowerCellDispenser.Materials.M_Pickups_Orb_Dispenser
	BallMaterials(0)=Pickups.PowerCellDispenser.Materials.M_Pickups_Orb_Red
	BallMaterials(1)=Pickups.PowerCellDispenser.Materials.M_Pickups_Orb_Blue
	BallMaterials(2)=PICKUPS.PowerCellDispenser.Materials.M_Pickups_Orb

	CreateSound=SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_OrbCreated'

	bEnabled=true
	FlagClass=class'UTOnslaughtFlag_Content'
}
