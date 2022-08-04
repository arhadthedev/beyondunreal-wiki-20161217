/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_FuryBolt extends UTProjectile;

/**
attenuate damage over time
*/
function AttenuateDamage()
{
	if ( LifeSpan < 1.0 )
		Damage = 0.75 * Default.Damage;
	else
		Damage = Default.Damage * FMin(2.5, Square(MaxSpeed)/VSizeSq(Velocity));
}

simulated function HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
	AttenuateDamage();
	Super.HitWall(HitNormal, Wall, WallComp);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	AttenuateDamage();
	Super.ProcessTouch(Other, HitLocation, HitNormal);
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_Fury.Effects.P_VH_Fury_Projectile'
	ProjExplosionTemplate=ParticleSystem'VH_Fury.Effects.P_VH_Fury_Projectile_Impact'

    Speed=2000
    MaxSpeed=12500
    AccelRate=20000.0

    Damage=20
    DamageRadius=200
    MomentumTransfer=4000

    MyDamageType=class'UTDmgType_FuryBolt'
    LifeSpan=1.6

    bCollideWorld=true
    DrawScale=1.2
}

