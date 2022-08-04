/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTLeviathanShield extends UTVehicleShield;

simulated event BaseChange();

defaultproperties
{
	bIgnoreFlaggedProjectiles=true
	
	Begin Object Class=AudioComponent Name=AmbientSoundComponent
		bStopWhenOwnerDestroyed=true
		bShouldRemainActiveIfDropped=true
		SoundCue=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_ShieldAmbient'
		bAutoPlay=false
	End Object
	AmbientComponent=AmbientSoundComponent
	Components.Add(AmbientSoundComponent)

	Begin Object Class=StaticMeshComponent Name=ShieldMesh
		StaticMesh=StaticMesh'VH_Leviathan.Mesh.S_VH_Leviathan_Shield_Collision'
		Translation=(X=240,Y=-180,Z=220)
		Scale=1.0
		CollideActors=true
		BlockActors=FALSE
		BlockZeroExtent=true
		BlockNonZeroExtent=true
		HiddenGame=true
		CastShadow=false
		BlockRigidBody=false
		bAcceptsLights=false
		bUseAsOccluder=FALSE
	End Object
	CollisionComponent=ShieldMesh
	Components.Add(ShieldMesh)

	Begin Object Class=UTParticleSystemComponent Name=ShieldEffect
		Template=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_ShieldEffect'
		Scale=1.0
		Translation=(x=15,Y=50,Z=25)
		HiddenGame=true
		bAutoActivate=false
		SecondsBeforeInactive=1.0f
	End Object
	ShieldEffectComponent=ShieldEffect

	ActivatedSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_ShieldActivate'
	DeactivatedSound=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_ShieldOff'
}

