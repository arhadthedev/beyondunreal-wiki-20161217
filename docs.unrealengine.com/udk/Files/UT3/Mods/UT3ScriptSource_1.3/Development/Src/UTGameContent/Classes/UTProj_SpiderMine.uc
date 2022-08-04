/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_SpiderMine extends UTProj_SpiderMineBase;

simulated function bool ProjectileHurtRadius( float DamageAmount, float InDamageRadius, class<DamageType> DamageType, float Momentum,
						vector HurtOrigin, vector HitNormal, optional class<DamageType> ImpactedActorDamageType )
{
	// override ImpactedActorDamageType with special damagetype that does the 1P death effect
	if (ImpactedActorDamageType == None)
	{
		ImpactedActorDamageType = class'UTDmgType_SpiderMineDirectHit';
	}
	return Super.ProjectileHurtRadius(DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, HitNormal, ImpactedActorDamageType);
}

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=1.0
		AmbientGlow=(R=0.4,G=0.4,B=0.4)
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=MeshComponentA
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_Spider_3P'
		Materials(0)=Material'Pickups.Deployables.Materials.M_Deployables_Spider_VRed'
		AnimSets(0)=AnimSet'Pickups.Deployables.Anims.K_Deployables_Spider_3P'
		Animations=MeshSequenceA
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		Translation=(Z=-11.0)
		bUseAsOccluder=FALSE
		bUpdateSkelWhenNotRendered=false
		bAcceptsDecals=false
		CastShadow=true
		LightEnvironment=MyLightEnvironment
		CullDistance=6000.0
	End Object
	Mesh=MeshComponentA
	Components.Add(MeshComponentA)

	Begin Object Name=CollisionCylinder
		CollisionRadius=10
		CollisionHeight=10
		CollideActors=True
	End Object

	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	ExplosionSound=SoundCue'A_Pickups_Deployables.SpiderMine.SpiderMines_ExplodesCue'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	MyDamageType=class'UTDmgType_SpiderMine'

	Begin Object Class=AudioComponent Name=AmbientAudio
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'A_Pickups_Deployables.SpiderMine.SpiderMine_WalkLoopCue'
	End Object
	WalkingSoundComponent=AmbientAudio
	Components.Add(AmbientAudio)

	Begin Object Class=AudioComponent Name=AttackScreech
		bShouldRemainActiveIfDropped=false
		bStopWhenOwnerDestroyed=true
		bAllowSpatialization=true
		SoundCue=SoundCue'A_Pickups_Deployables.SpiderMine.SpiderMine_AttackScreechCue'
	End Object
	AttackScreechSoundComponent=AttackScreech
	Components.Add(AttackScreech)
}
