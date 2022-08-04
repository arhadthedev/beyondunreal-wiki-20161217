/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_AvrilRocket extends UTProj_AvrilRocketBase;

var array<DistanceBasedParticleTemplate> DistanceExplosionTemplates;

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	ProjExplosionTemplate = class'UTEmitter'.static.GetTemplateForDistance(DistanceExplosionTemplates, HitLocation, WorldInfo);

	Super.SpawnExplosionEffects(HitLocation, HitNormal);
}

defaultproperties
{

	DistanceExplosionTemplates[0]=(Template=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo_far',MinDistance=3500.0)
	DistanceExplosionTemplates[1]=(Template=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo_mid',MinDistance=450.0)
	DistanceExplosionTemplates[2]=(Template=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo_close',MinDistance=0.0)

	ProjFlightTemplate=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Smoke_Trail'
	ProjExplosionTemplate=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'
	speed=550.0
	MaxSpeed=2800.0
	Damage=125.0
	DamageRadius=150.0
	MomentumTransfer=150000
	MyDamageType=class'UTDmgType_AvrilRocket'
	LifeSpan=7.0
	bProjTarget=True
	CheckRadius=0.0

	AmbientSound=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRiL_Travel01Cue'
	ExplosionSound=SoundCue'A_Weapon_Avril.WAV.A_Weapon_AVRiL_Impact01Cue'

	RotationRate=(Roll=50000)
	DesiredRotation=(Roll=30000)
	bCollideWorld=true

	Begin Object Name=CollisionCylinder
		CollisionRadius=18
		CollisionHeight=18
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object

	bUpdateSimulatedPosition=true
	AccelRate=750.0
	bCollideComplex=false

	bNetTemporary=false
	bWaitForEffects=true
	bRotationFollowsVelocity=true

	LockWarningInterval=1.0
}
