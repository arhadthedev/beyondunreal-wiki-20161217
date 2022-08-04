/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTXRayVolume_Content extends UTXRayVolume;

defaultproperties
{
	DamageType=class'UTDmgType_XRay'

	Components.Remove(BrushComponent0)
	BrushComponent=None

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'PICKUPS_2.Deployables.Mesh.S_Deployables_XRayVolume_Cylinder'
		BlockActors=false
		CollideActors=true
		BlockRigidBody=false
		CastShadow=false
		bUseAsOccluder=false
		Scale3D=(X=1.8,Y=1.8,Z=1.30)
	End Object
	Components.Add(StaticMeshComponent0)
	//CollisionComponent=StaticMeshComponent0

	Begin Object Class=CylinderComponent Name=CollisionCylinder0
		CollisionHeight=150.0
		CollisionRadius=230.000000
		Translation=(X=0.0,Y=0.0,Z=150.0)
		CollideActors=true
	End Object
	Components.Add(CollisionCylinder0)
	CollisionComponent=CollisionCylinder0


	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=1.0
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=VisualMesh
		Animations=MeshSequenceA
		AnimSets(0)=AnimSet'Pickups.Deployables.Anims.K_Deployables_SlowVolume'
		Materials(0)=Material'PICKUPS_2.Deployables.Materials.M_Deployables_XRAY'
		SkeletalMesh=SkeletalMesh'PICKUPS_2.Deployables.Mesh.SK_Deployables_XRAY'
		BlockActors=false
		CollideActors=false
		BlockRigidBody=false
		bUseAsOccluder=false
		CastShadow=true
		LightEnvironment=MyLightEnvironment
		bUpdateSkelWhenNotRendered=false
	End Object
	Components.Add(VisualMesh)
	GeneratorMesh=VisualMesh;

	/*
	Begin Object Class=ParticleSystemComponent Name=VisualEffect
		Template=ParticleSystem'Pickups.Deployables.Effects.P_Deployables_SlowVolume_Spawn_Idle'
		bAutoActivate=false
	End Object
	Components.Add(VisualEffect)
	SlowEffect=VisualEffect
	*/

	Begin Object Class=ParticleSystemComponent Name=VisualEffect
		Template=ParticleSystem'PICKUPS_2.Deployables.Effects.P_Deployables_XRAY_Projector'
		bAutoActivate=false
	End Object
	Components.Add(VisualEffect)
	GeneratorEffect=VisualEffect

	ActivateSound=SoundCue'A_Pickups_Deployables.SlowVolume.SlowVolume_OpenCue'
	DestroySound=SoundCue'A_Pickups_Deployables.SlowVolume.SlowVolume_CloseCue'
	EnterSound=SoundCue'A_Pickups_Deployables.SlowVolume.SlowVolume_EnterCue'
	ExitSound=SoundCue'A_Pickups_Deployables.SlowVolume.SlowVolume_ExitCue'
	OutsideAmbientSound=SoundCue'A_Pickups_Deployables.SlowVolume.SlowVolume_LoopOutsideCue'
	InsideAmbientSound=SoundCue'A_Pickups_Deployables.SlowVolume.SlowVolume_LoopInsideCue'

	Begin Object Class=AudioComponent Name=AmbientAudio
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	AmbientSoundComponent=AmbientAudio
	Components.Add(AmbientAudio)

	XRayInvisMaterial=Material'Pickups.Invis.M_Invis_01'

	//InsideCameraEffect=class'UTEmitCameraEffect_SlowVolume'
}
