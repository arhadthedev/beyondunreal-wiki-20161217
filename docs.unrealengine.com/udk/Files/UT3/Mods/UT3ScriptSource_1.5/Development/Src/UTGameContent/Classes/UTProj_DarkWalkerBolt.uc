/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_DarkWalkerBolt extends UTProjectile;

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_Darkwalker_Secondary_Projectile'
	ProjExplosionTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_Darkwalker_Secondary_Impact'

    Speed=4000
    MaxSpeed=10000
    AccelRate=20000.0

    Damage=40
	DamageRadius=0
    MomentumTransfer=4000
	CheckRadius=40.0

    MyDamageType=class'UTDmgType_DarkWalkerBolt'
    LifeSpan=1.6

    bCollideWorld=true
    DrawScale=1.2
}
