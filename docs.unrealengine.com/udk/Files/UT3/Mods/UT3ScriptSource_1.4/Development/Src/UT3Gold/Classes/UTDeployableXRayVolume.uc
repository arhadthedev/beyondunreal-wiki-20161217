/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTDeployableXRayVolume extends UTDeployableXRayVolumeBase;

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_SlowVolume'
		AnimSets[0]=AnimSet'Pickups.Deployables.Anims.K_Deployables_SlowVolume_1P'
		Animations=MeshSequenceA
		CollideActors=false
		BlockActors=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		BlockRigidBody=false
		Scale=0.5
		FOV=60.0
		bUseAsOccluder=false
	End Object

	ArmsAnimSet=AnimSet'Pickups.Deployables.Anims.K_Deployables_SlowVolume_1P_Arms'

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_SlowVolume'
		Translation=(Z=-30)
	End Object

	AttachmentClass=class'UTAttachment_SlowVolume'
	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabTheStasisFieldGenerator')
	DeployFailedSoundCue=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue';

	DeployableClass=class'UTXRayVolume_Content'
}
