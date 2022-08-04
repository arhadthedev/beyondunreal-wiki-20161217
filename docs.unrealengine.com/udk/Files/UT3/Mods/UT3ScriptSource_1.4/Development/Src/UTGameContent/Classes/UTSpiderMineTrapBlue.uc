/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTSpiderMineTrapBlue extends UTSpiderMineTrap;

defaultproperties
{
	MineClass=class'UTProj_SpiderMineBlue'
	TeamNum=1

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		ModShadowFadeoutTime=1.0
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=ThirdPersonMesh
		Animations=MeshSequenceA
		AnimSets(0)=AnimSet'Pickups.Deployables.Anims.K_Deployables_SpiderMine'
		Materials(0)=Material'Pickups.Deployables.Materials.M_Deployables_Spidermine_VBlue'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		bUseAsOccluder=FALSE
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_SpiderMine'
		Translation=(Z=0)
		bAcceptsDecals=false
		CastShadow=true
		LightEnvironment=MyLightEnvironment
	End Object
	Components.Add(ThirdPersonMesh)
	Mesh=ThirdPersonMesh

	ActivateSound=SoundCue'A_Pickups_Deployables.SpiderMine.SpiderMine_ActivateCue'
}
