/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTEnergyShield extends UTDeployedActor;

/** Array of current health of each shield piece */
var int ShieldHealth;

/** shield mesh (has collision) */
var StaticMeshComponent ShieldMesh;

/** shield generation effect */
var UTParticleSystemComponent ShieldEffect;

var SkeletalMeshComponent ShieldBase;

/** sounds to play */
var SoundCue SpawnSound, DestroySound, PanelDestroySound;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( !bDeleteMe && (Role == ROLE_Authority) )
	{
		PlaySound(SpawnSound);
	}
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (Role == ROLE_Authority)
	{
		PlaySound(DestroySound);
	}
}

event Landed(vector HitNormal, Actor HitActor)
{
	PerformDeploy();
}

simulated function PerformDeploy()
{
	bDeployed = true;
	
	ShieldBase.PlayAnim('Deploy');

	ShieldMesh.SetHidden(false);
	ShieldMesh.SetActorCollision(true, false);
	ShieldEffect.SetActive(true);
	bCollideWorld = FALSE;
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if ( WorldInfo.GRI.OnSameTeam(EventInstigator, self) )
	{
		return;
	}
	ShieldHealth -= DamageAmount;
	PlaySound(PanelDestroySound);

	if ( ShieldHealth <= 0 )
	{
		destroy();
	}
	
	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	Super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

defaultproperties
{
	ShieldHealth=4000
	bProjTarget=true

	bPushedByEncroachers=FALSE
	bHardAttach=TRUE
	bBlockActors=FALSE

	Begin Object Class=AudioComponent Name=AmbientSoundComponent
		bStopWhenOwnerDestroyed=true
		bShouldRemainActiveIfDropped=true
		SoundCue=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_ShieldAmbient'
		bAutoPlay=false
	End Object
	Components.Add(AmbientSoundComponent)

    LifeSpan=90.0

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=SkeletalMeshComponent Name=DeployableMesh
		Animations=MeshSequenceA
		AnimSets(0)=AnimSet'Pickups.Deployables.Anims.K_Deployables_Shield'
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_Shield'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		Translation=(X=0,Y=0,Z=0.0)
		CastShadow=false
		bUseAsOccluder=FALSE
		bAcceptsDecals=false
	End Object
	Components.Add(DeployableMesh)
	CollisionComponent=DeployableMesh
	ShieldBase=DeployableMesh

	Begin Object Class=StaticMeshComponent Name=ShieldMesh
		StaticMesh=StaticMesh'PICKUPS.Deployables.Mesh.S_Pickups_Shield_Deployable_Whole'
		CollideActors=false
		BlockActors=false
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		CastShadow=false
		BlockRigidBody=false
		bAcceptsLights=false
		bUseAsOccluder=FALSE
		Rotation=(Roll=0)
		HiddenGame=true
		Scale=5.0
	End Object
	ShieldMesh(0)=ShieldMesh
	Components.Add(ShieldMesh)

	Begin Object Class=UTParticleSystemComponent Name=ShieldEffect
		Template=ParticleSystem'PICKUPS.Deployables.Effects.P_Deployables_Shield_Projector'
		HiddenGame=false
		bAutoActivate=false
		Rotation=(Roll=0)
		SecondsBeforeInactive=1.0f
	End Object
	ShieldEffect(0)=ShieldEffect
	Components.Add(ShieldEffect)

	SpawnSound=SoundCue'A_Pickups_Deployables.ShieldGenerator.ShieldGenerator_OpenCue'
	DestroySound=SoundCue'A_Pickups_Deployables.ShieldGenerator.ShieldGenerator_CloseCue'
	PanelDestroySound=SoundCue'A_Pickups_Deployables.ShieldGenerator.ShieldGenerator_PanelBlowCue'

	Begin Object Class=AudioComponent Name=AmbientComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		bAutoPlay=true
		SoundCue=SoundCue'A_Pickups_Deployables.ShieldGenerator.ShieldGenerator_OutsideLoopCue'
	End Object
	Components.Add(AmbientComponent)
	
	bAlwaysRelevant=true
}
