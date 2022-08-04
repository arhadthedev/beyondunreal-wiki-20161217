/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTEmit_OnslaughtOrbExplosion_Blue extends UTReplicatedEmitter;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySound(class'UTOnslaughtFlag_Content'.default.ReturnedSound, true);
	}
}

defaultproperties
{
	EmitterTemplate=ParticleSystem'Pickups.PowerCell.Effects.P_Pickups_PowerCell_Explode_Blue'
}
