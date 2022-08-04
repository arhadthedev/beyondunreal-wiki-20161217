/**
* Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
*/
class UTOnslaughtTarydiumProcessor_Content extends UTOnslaughtTarydiumProcessor;


defaultproperties
{
	bDestinationOnly=true
	bMustTouchToReach=false
	bPathColliding=true
	OreEventThreshold=100.0

	bStatic=false
	bMovable=true
	bPushedByEncroachers=FALSE

	bBlockActors=TRUE
	bCollideActors=TRUE
	bProjTarget=TRUE

	ProcColor=(Z=1,Y=1,Z=1)

	Begin Object Class=AnimNodeSequence Name=SeqNode
		AnimSeqName=PP_Loop
		bLooping=TRUE
		bPlaying=TRUE
		Rate=0.0
	End Object

	// define here as lot of sub classes which have moving parts will utilize this
	Begin Object Class=DynamicLightEnvironmentComponent Name=ProcLightEnvironment
		bDynamic=FALSE
		bCastShadows=FALSE
	End Object
	Components.Add(ProcLightEnvironment)

	Begin Object Class=SkeletalMeshComponent Name=ProcComp
		SkeletalMesh=SkeletalMesh'GP_Conquest.Mesh.SK_GP_Con_Processing_Plant'
		PhysicsAsset=PhysicsAsset'GP_Conquest.Mesh.SK_GP_Con_Processing_Plant_Physics'
		AnimSets.Add(AnimSet'GP_Conquest.Anims.K_GP_Con_Processing_Plant')
		Animations=SeqNode
		Translation=(Z=-190.0)
		LightEnvironment=ProcLightEnvironment
		CollideActors=TRUE
		BlockActors=TRUE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=TRUE
		BlockRigidBody=TRUE
		bHasPhysicsAssetInstance=TRUE
	End Object
	CollisionComponent=ProcComp
	Components.Add(ProcComp)
	Mesh=ProcComp

	Begin Object Class=StaticMeshComponent Name=SMComp
		StaticMesh=StaticMesh'GP_Conquest.Mesh.SM_Processing_Plant'
		Translation=(X=46.9,Y=-18.64,Z=-178.0)
		LightEnvironment=ProcLightEnvironment
	End Object
	Components.Add(SMComp)
	StaticMesh=SMComp

	Begin Object Name=CollisionCylinder
		CollisionHeight=+50.0
		CollisionRadius=+300.0
	End Object

	SupportedEvents.Add(class'UTSeqEvent_MinedOre')

	MiningBotClass=class'UTOnslaughtMiningRobot_Content'
}
