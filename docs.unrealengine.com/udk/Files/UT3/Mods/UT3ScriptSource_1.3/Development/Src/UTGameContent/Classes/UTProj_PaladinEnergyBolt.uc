/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTProj_PaladinEnergyBolt extends UTProjectile;

defaultproperties
{
	MyDamageType=class'UTDmgType_PaladinEnergyBolt'
	Speed=9000
	MaxSpeed=9000
	Damage=200
	DamageRadius=450
	CheckRadius=40.0
	MomentumTransfer=200000
	ProjFlightTemplate=ParticleSystem'VH_Paladin.Effects.P_VH_Paladin_PrimaryProj'
	ProjExplosionTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Explo'
	ExplosionSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_FireImpact'
	ExplosionLightClass=class'UTGame.UTShockComboExplosionLight'
}
