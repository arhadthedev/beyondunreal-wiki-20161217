/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTPowerCorePanel_Content extends UTPowerCorePanel;


defaultproperties
{
	// each panel has their own LightEnvironment as they can travel pretty far through disparate lighting variations
	Begin Object Class=DynamicLightEnvironmentComponent Name=PanelLightEnvironmentComp
		bCastShadows=FALSE
		bDynamic=FALSE // we might want to change this to TRUE but it should be good to grab the light where the spawning occurs
		AmbientGlow=(R=0.8,G=0.8,B=0.8)
	End Object
	Components.Add(PanelLightEnvironmentComp)

	Begin Object Name=GibMesh Class=StaticMeshComponent
		StaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Power_Core_Panel'
		Scale=0.6
		CullDistance=8000
		BlockActors=false
		CollideActors=true
		BlockRigidBody=true
		CastShadow=false
		bCastDynamicShadow=false
		bNotifyRigidBodyCollision=true
		ScriptRigidBodyCollisionThreshold=10.0
		bUseCompartment=FALSE
		RBCollideWithChannels=(Default=true,Pawn=true,Vehicle=true,GameplayPhysics=true,EffectPhysics=true)
		bUseAsOccluder=false
		LightEnvironment=PanelLightEnvironmentComp
	End Object
	Mesh=GibMesh
	CollisionComponent=GibMesh
	Components.Add(GibMesh)

	TickGroup=TG_PostAsyncWork
	RemoteRole=ROLE_None
	Physics=PHYS_RigidBody
	bNoEncroachCheck=true
	bCollideActors=true
	bBlockActors=false
	bWorldGeometry=false
	bCollideWorld=FALSE  // we want the gib to use the rigidbody collision.  Setting this to TRUE means that unreal physics will try to control
	bProjTarget=true
	LifeSpan=8.0
	bGameRelevant=true

	BreakSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CorePanelBreakCue'
	HitSound=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CorePanelImpactCue'
}
