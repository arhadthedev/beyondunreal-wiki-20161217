/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedCoin_Gold extends UTGreedCoin;

simulated function PostBeginPlay()
{
	local MaterialInstanceConstant CoinMaterialInstance;

	Super.PostBeginPlay();

	CoinMaterialInstance = StaticMeshComponent(PickupMesh).CreateAndSetMaterialInstanceConstant(0);
	CoinMaterialInstance.SetVectorParameterValue('Skull_Color', SkullColor);
}

defaultproperties
{
	Value=5
	LifeSpan=120.0
	MaxDesireability=5.000000
	DrawScale=4.5

	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00090.000000
		CollisionHeight=+00025.000000
		CollideActors=true
	End Object
	CollisionComponent=CollisionCylinder

	BounceSound=SoundCue'A_Gameplay_UT3G.Greed.A_Gameplay_UT3G_Greed_SkullImpact01_Cue'
	PickupSound=SoundCue'A_Gameplay_UT3G.Greed.A_Gameplay_UT3G_Greed_SkullPickup01_Cue'

	TrailTemplate=ParticleSystem'VH_Cicada.Effects.P_VH_Cicada_DecoyFlare'

	Begin Object Class=StaticMeshComponent Name=MeshComponentA
		StaticMesh=StaticMesh'GP_Extras.Mesh.S_GP_Extras_Skull01'
		Materials(0)=Material'GP_Extras.Materials.M_GP_Extras_Skull01'
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		bAcceptsLights=false
		CollideActors=false
		BlockRigidBody=false
		CullDistance=8000
		bUseAsOccluder=FALSE
		ScriptRigidBodyCollisionThreshold=5.0
		bDisableAllRigidBody=true
	End Object
	PickupMesh=MeshComponentA
	Components.Add(MeshComponentA)

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformPickUp
		Samples(0)=(LeftAmplitude=50,RightAmplitude=50,LeftFunction=WF_LinearDecreasing,RightFunction=WF_LinearIncreasing,Duration=0.15)
	End Object
	PickUpWaveForm=ForceFeedbackWaveformPickUp

	CoinIconCoords=(U=744,UL=35,V=0,VL=55)
	SkullColor=(R=32.0,G=16.0,B=4.0,A=1.0)
}