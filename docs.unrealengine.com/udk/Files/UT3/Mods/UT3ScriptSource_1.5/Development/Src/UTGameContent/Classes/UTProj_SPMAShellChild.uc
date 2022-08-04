/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_SPMAShellChild extends UTProjectile;

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_MiniProjectile'
	ProjExplosionTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_Primary_Shell_Ground_Explo'
	ExplosionLightClass=class'UTGame.UTCicadaRocketExplosionLight'
	
	Speed=4000.0
	MaxSpeed=4000.0
	MaxEffectDistance=10000.0

	Damage=220
	DamageRadius=500
	MomentumTransfer=175000

	MyDamageType=class'UTDmgType_SPMASmallShell'
	LifeSpan=8.0

	bCollideWorld=true
	DrawScale=0.7
	
	bNetTemporary=false
	ExplosionSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_ShellFragmentExplode'
	Physics=PHYS_Falling
	bRotationFollowsVelocity=true	
}
