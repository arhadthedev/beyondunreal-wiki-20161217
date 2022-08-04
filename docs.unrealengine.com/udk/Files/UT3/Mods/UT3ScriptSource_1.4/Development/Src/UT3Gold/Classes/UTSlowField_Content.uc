/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTSlowField_Content extends UTSlowField;

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=MeshComponentA
		StaticMesh=StaticMesh'Pickups.Udamage.Mesh.S_Pickups_UDamage'
		Materials(1)=Material'PICKUPS_2.StasisField.Materials.M_Pickups2_StasisField'
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		bAcceptsLights=true
		CollideActors=false
		BlockRigidBody=false
		Translation=(X=0.0,Y=0.0,Z=+5.0)
		Scale3D=(X=0.35,Y=0.35,Z=0.6)
		Rotation=(Pitch=0,Yaw=0,Roll=-32768)
		CullDistance=8000
		bUseAsOccluder=FALSE
	End Object
	DroppedPickupMesh=MeshComponentA
	PickupFactoryMesh=MeshComponentA

	Begin Object Class=UTParticleSystemComponent Name=PickupParticles
		Template=ParticleSystem'PICKUPS_2.Deployables.Effects.P_Pickups_SlowField_Idle'
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
		Translation=(X=0.0,Y=0.0,Z=0.0)
		Rotation=(Pitch=0,Yaw=0,Roll=-32768)
	End Object
	DroppedPickupParticles=PickupParticles

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'PICKUPS_2.Deployables.Mesh.S_Deployables_XRayVolume_Cylinder'
		Materials(0)=Material'PICKUPS_2.Deployables.Materials.M_Deployables_SlowVolume_Cube_UT3G'
		BlockActors=false
		BlockRigidBody=false
		CastShadow=false
		bUseAsOccluder=false
		CollideActors=false
		AbsoluteRotation=true
		Scale3D=(X=0.1,Y=0.1,Z=0.1)
		Translation=(X=0.0,Y=0.0,Z=-175.0)
	End Object
	SlowFieldMesh=StaticMeshComponent0

	bRenderOverlays=true
	PickupSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Invisibility_PickupCue'
	SlowFieldAmbientSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Invisibility_PowerLoopCue'
	WarningSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Invisibility_WarningCue'
	PowerupOverSound=SoundCue'A_Pickups_Powerups.PowerUps.A_Powerup_Invisibility_EndCue'
	HudIndex=0
	IconCoords=(U=792,UL=43,V=41,VL=58)
}
