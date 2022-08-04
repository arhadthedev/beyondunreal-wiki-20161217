//=============================================================================
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class FracturedStaticMeshPart extends FracturedStaticMeshActor
	native(Mesh)
	notplaceable;

var() const editconst LightEnvironmentComponent		LightEnvironment;
var() const editconst ParticleSystemComponent		ParticleComponent;

;

/** Called when this part hits something else. */
event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent, const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	Explode();
}

/** Used so weapons etc move parts. */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	FracturedStaticMeshComponent.AddImpulse(Normal(momentum) * damageType.default.KDamageImpulse, HitLocation);
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Name=FracturedStaticMeshComponent0
		bCastDynamicShadow=FALSE
		bForceDirectLightMap=FALSE
		bAllowApproximateOcclusion=FALSE
		LightEnvironment=MyLightEnvironment
		BlockRigidBody=TRUE
		RBChannel=RBCC_EffectPhysics
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
		bUseVisibleVertsForBounds=TRUE
	End Object

	Begin Object Class=ParticleSystemComponent Name=PartComponent0		
		bAutoActivate=TRUE
	End Object
	ParticleComponent=PartComponent0
	//Components.Add(PartComponent0)

	bNoDelete=FALSE
	bMovable=TRUE
	bWorldGeometry=FALSE
	bPathColliding=FALSE
	TickGroup=TG_PostAsyncWork
	bNetInitialRotation=true
	bCollideActors=TRUE
	bBlockActors=FALSE
	bProjTarget=TRUE
	bNoEncroachCheck=TRUE
	Physics=PHYS_RigidBody
	RemoteRole=ROLE_None
	LifeSpan=15.0
}
