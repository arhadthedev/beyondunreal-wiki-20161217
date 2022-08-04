/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_Redeemer extends UTProj_RedeemerBase;

defaultproperties
{
	MyDamageType=class'UTDmgType_Redeemer'

	ProjFlightTemplate=ParticleSystem'WP_Redeemer.Effects.P_WP_Redeemer_SmokeTrail'
	DistanceExplosionTemplates[0]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Far',MinDistance=2200.0)
	DistanceExplosionTemplates[1]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Mid',MinDistance=1500.0)
	DistanceExplosionTemplates[2]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Near',MinDistance=0.0)

	Begin Object Class=StaticMeshComponent Name=ProjectileMesh
		StaticMesh=StaticMesh'WP_Redeemer.Mesh.S_WP_Redeemer_Missile_Open'
		CullDistance=20000
		Scale=3.0
		Translation=(X=32.0)
		CollideActors=false
		CastShadow=false
		bAcceptsLights=TRUE
		bForceDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=FALSE)
		LightEnvironment=RedeemerLightEnvironment
		BlockRigidBody=false
		BlockActors=false
		bUseAsOccluder=FALSE
	End Object
	Components.Add(ProjectileMesh)
	ProjMesh=ProjectileMesh;

	Begin Object Name=CollisionCylinder
		CollisionRadius=+020.000000
		CollisionHeight=+012.000000
		Translation=(X=40.0)
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
	End Object
	CylinderComponent=CollisionCylinder

	AmbientSound=SoundCue'A_Weapon_Redeemer.Redeemer.A_Weapon_Redeemer_FlyLoop01Cue'
	ExplosionSound=SoundCue'A_Weapon_Redeemer.Redeemer.A_Weapon_Redeemer_ExplodeCue'

	ExplosionShake=CameraAnim'Camera_FX.WP_Redeemer.C_WP_Redeemer_Shake'

	ExplosionClass=class'UTEmit_SmallRedeemerExplosion'
}
