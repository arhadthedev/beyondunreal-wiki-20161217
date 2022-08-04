/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTProj_SPMAShell_Content extends UTProj_SPMAShell;

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_PrimaryProjectile'
	ProjExplosionTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_Primary_Shell_InAir_Explo'

	MyDamageType=class'UTDmgType_SPMAShell'

	DrawScale=0.7

	ExplosionSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_ShellBrakingExplode'

	ChildProjectileClass=class'UTProj_SPMAShellChild'
}
