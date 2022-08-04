/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_SPMACamera_Content extends UTProj_SPMACamera;

/** Played when the camera is stationary in the air **/
var ParticleSystemComponent PSC_KeepInAirJets;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( Instigator.GetTeamNum() == 1 )
		{
			Mesh.SetMaterial( 0, MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Camera_Blue' );
		}
		else
		{
			Mesh.SetMaterial( 0, MaterialInterface'VH_SPMA.Materials.MI_VH_SPMA_Camera_Red' );
		}
	}
}


simulated function ShutDown()
{
	PSC_KeepInAirJets.DeactivateSystem();
	Super.ShutDown();
}

simulated event Destroyed()
{
	PSC_KeepInAirJets.DeactivateSystem();
	Super.Destroyed();
}

simulated function DeployCamera()
{
	Super.DeployCamera();

	if (DeploySound != none)
	{
		PlaySound(DeploySound, true);
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		Mesh.PlayAnim('MissleOpen');
		PSC_KeepInAirJets.ActivateSystem();
	}
}

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
	    AmbientGlow=(R=0.2,G=0.2,B=0.2,A=1.0)
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=ProjMesh
		SkeletalMesh=SkeletalMesh'VH_SPMA.Mesh.SK_VH_SPMA_Camera'
		AnimSets(0)=AnimSet'VH_SPMA.Anims.K_VH_SPMA_Camera'
		LightEnvironment=MyLightEnvironment
		Animations=MeshSequenceA
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=true
		Scale=0.15
		bUseAsOccluder=FALSE
		bAcceptsDecals=false
	End Object
	Mesh=ProjMesh
	Components.Add(ProjMesh)

	Begin Object Name=CollisionCylinder
		CollisionRadius=48
		CollisionHeight=32
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		CollideActors=true
	End Object

	AmbientSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_CameraAmbient'

	ProjFlightTemplate=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_Camera_Rocket'
	ProjExplosionTemplate=ParticleSystem'Envy_Effects.Tests.Effects.P_SPMA_CamImpact'

	MyDamageType=class'UTDmgType_SPMACameraCrush'

	DeploySound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_CameraDeploy'
	ShotDownSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_Collide'
	ExplosionSound=SoundCue'A_Vehicle_SPMA.SoundCues.A_Vehicle_SPMA_ShellBrakingExplode'

	PS_Trail=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_Target_ArcTrail_Red';
	PS_StartPoint=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_Target_ArcStart'
	PS_EndPointOnTarget=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_AIM_01'
	PS_EndPointOffTarget=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_AIM_02'

	Begin Object Class=ParticleSystemComponent Name=KeepInAirJets
	Template=ParticleSystem'VH_SPMA.Effects.P_VH_SPMA_Camera_Little_jets'
		bAutoActivate=false
	End Object
	PSC_KeepInAirJets=KeepInAirJets
	Components.Add(KeepInAirJets);



}
