/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_RaptorRocket extends UTProj_SeekingRocket;

defaultproperties
{
    MyDamageType=class'UTDmgType_RaptorRocket'

	ProjFlightTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_Rocket_trail_Blue'
    ProjExplosionTemplate=ParticleSystem'VH_Raptor.EffectS.P_Raptor_RocketExplosion_Blue'

    speed=2000.0
    MaxSpeed=4000.0
    AccelRate=16000.0
	bSuperSeekAirTargets=true

    Damage=100.0
    DamageRadius=150.0

    MomentumTransfer=50000
	LockWarningInterval=1.5
}
