/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_ScavengerBolt extends UTProj_ScavengerBoltBase;

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_Scavenger.Effects.P_Scavenger_Death_Ball'
	ProjExplosionTemplate=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_Gun_Explode'
	ExplosionSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_FireImpact_Cue'
	AmbientSound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_OrbLoop01_Cue'

	MyDamageType=class'UTDmgType_ScavengerBolt'
	BeamEffect=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam_Gold'
}
