/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTWalkerBody_Scavenger_Content extends UTWalkerBody_Scavenger;

/** The template for the leg orb connectors*/
var ParticleSystem OrbConTemplate[2];

function PostBeginPlay()
{
	local int Idx;

	super.PostBeginPlay();
	// attach leg attach beam emitters to the leg
	for (Idx=0; Idx<NUM_WALKER_LEGS; ++Idx)
	{
		SkeletalMeshComponent.AttachComponentToSocket(LegAttachBeams[Idx], TopLegSocketName[Idx]);
		OrbConnectionEffect[Idx].SetAbsolute(true,true,true);
		SkeletalMeshComponent.AttachComponentToSocket(OrbConnectionEffect[Idx], TopLegSocketName[Idx]);
	}
}

simulated function TeamChanged()
{
	local int i;
	local MaterialInstanceConstant Instance;


	for(i=0;i<3;++i)
	{
		OrbConnectionEffect[i].DeactivateSystem();
		OrbConnectionEffect[i].SetTemplate(OrbConTemplate[WalkerVehicle.Team==1?1:0]);
		OrbConnectionEffect[i].ActivateSystem();
	}

	// Create the material instance for the legs
	Instance = new(self) class'MaterialInstanceConstant';
	Instance.SetParent( SkeletalMeshComponent.GetMaterial( 0 ) );
	SkeletalMeshComponent.SetMaterial( 0, Instance );

	super.TeamChanged();
}



defaultproperties
{
	DrawScale=0.7

	// @fixme, scavenger-specific effects needed?
	FootStepEffects[0]=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Footstep_Cue',ParticleTemplate=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_FootImpact_Default')
	FootStepEffects[1]=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Footstep_Cue',ParticleTemplate=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_FootImpact_Default')
	FootStepEffects[2]=(MaterialType=Water,Sound=SoundCue'A_Vehicle_Scavenger.Scavenger.A_Vehicle_Scavenger_Footstep_Cue',ParticleTemplate=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_FootImpact_Default')

	FootWaterEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_DarkWalker_Water_Splash'

	Begin Object Name=LegMeshComponent
		SkeletalMesh=SkeletalMesh'VH_Scavenger.Mesh.SK_VH_Scavenger_Legs'
		PhysicsAsset=PhysicsAsset'VH_Scavenger.Mesh.SK_VH_Scavenger_Legs_Physics'
		AnimSets(0)=AnimSet'VH_Scavenger.Anim.K_VH_Scavenger_Legs'
		AnimTreeTemplate=AnimTree'VH_Scavenger.Anim.AT_VH_Scavenger_Legs'
		bUpdateJointsFromAnimation=TRUE
		bForceDiscardRootMotion=TRUE
	End Object

	Begin Object Class=ParticleSystemComponent Name=LegAttachPSC_0
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink'
		bAutoActivate=TRUE
		SecondsBeforeInactive=1.0f
	End Object
	LegAttachBeams[0]=LegAttachPSC_0

	Begin Object Class=ParticleSystemComponent Name=LegAttachPSC_1
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink'
		bAutoActivate=TRUE
		SecondsBeforeInactive=1.0f
	End Object
	LegAttachBeams[1]=LegAttachPSC_1

	Begin Object Class=ParticleSystemComponent Name=LegAttachPSC_2
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink'
		bAutoActivate=TRUE
		SecondsBeforeInactive=1.0f
	End Object
	LegAttachBeams[2]=LegAttachPSC_2

	Begin Object Class=ParticleSystemComponent Name=AttachmentPSC_0
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink_Endpoint'
		bAutoActivate=true
		SecondsBeforeInactive=1.0f
	End Object
	OrbConnectionEffect[0]=AttachmentPSC_0

	Begin Object Class=ParticleSystemComponent Name=AttachmentPSC_1
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink_Endpoint'
		bAutoActivate=true
		SecondsBeforeInactive=1.0f
	End Object
	OrbConnectionEffect[1]=AttachmentPSC_1

	Begin Object Class=ParticleSystemComponent Name=AttachmentPSC_2
		Template=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink_Endpoint'
		bAutoActivate=true
		SecondsBeforeInactive=1.0f
	End Object
	OrbConnectionEffect[2]=AttachmentPSC_2

	OrbConTemplate[0]=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink_Endpoint'
	OrbConTemplate[1]=ParticleSystem'VH_Scavenger.Effects.P_VH_Scavenger_LegLink_Endpoint_Blue'

	TopLegSocketName[0]=Leg1Socket
	TopLegSocketName[1]=Leg2Socket
	TopLegSocketName[2]=Leg3Socket
	LegAttachBeamEndPointParamName=ScavengerLegEnd
	ShieldRadius = 75.0f
	RetractionBlendName=Retracted
	SphereCenterName=SphereCenter
}
