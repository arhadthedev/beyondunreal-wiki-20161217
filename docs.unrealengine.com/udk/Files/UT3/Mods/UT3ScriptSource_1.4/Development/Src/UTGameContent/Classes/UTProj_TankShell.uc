/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_TankShell extends UTProjectile;

var array<DistanceBasedParticleTemplate> DistanceExplosionTemplates;

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	ProjExplosionTemplate = class'UTEmitter'.static.GetTemplateForDistance(DistanceExplosionTemplates, HitLocation, WorldInfo);

	Super.SpawnExplosionEffects(HitLocation, HitNormal);
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Cannon_Trail'

	DistanceExplosionTemplates[0]=(Template=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Cannon_Impact_FAR',MinDistance=3000.0)
	DistanceExplosionTemplates[1]=(Template=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Cannon_Impact_MID',MinDistance=400.0)
	DistanceExplosionTemplates[2]=(Template=ParticleSystem'VH_Goliath.Effects.PS_Goliath_Cannon_Impact_Close',MinDistance=0.0)

	MaxExplosionLightDistance=+7000.0
	speed=15000.0
	MaxSpeed=15000.0
	Damage=360
	DamageRadius=600
	MomentumTransfer=150000
	MyDamageType=class'UTDmgType_TankShell'
	LifeSpan=1.2
	AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
	ExplosionSound=SoundCue'A_Vehicle_Goliath.SoundCues.A_Vehicle_Goliath_Explode'
	RotationRate=(Roll=50000)
	DesiredRotation=(Roll=30000)
	bCollideWorld=true
	ExplosionLightClass=class'UTGame.UTTankShellExplosionLight'
	ExplosionDecal=MaterialInterface'VH_Goliath.Materials.DM_Goliath_Cannon_Decal'
	DecalWidth=350
	DecalHeight=350

	bWaitForEffects=true
	bAttachExplosionToVehicles=false
}
