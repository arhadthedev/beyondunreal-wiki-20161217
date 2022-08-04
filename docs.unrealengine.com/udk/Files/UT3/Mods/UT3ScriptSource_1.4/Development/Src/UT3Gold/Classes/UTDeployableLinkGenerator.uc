/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTDeployableLinkGenerator extends UTDeployable;

var array< class<UTLinkGenerator> > TeamLinkGeneratorClasses;

static function class<Actor> GetTeamDeployable(int TeamNum)
{
	if (TeamNum >= default.TeamLinkGeneratorClasses.length)
	{
		TeamNum = 0;
	}
	return default.TeamLinkGeneratorClasses[TeamNum];
}

function bool Deploy()
{
	DeployedActorClass = class<UTLinkGenerator>(GetTeamDeployable(Instigator.GetTeamNum()));
	return Super.Deploy();
}

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_Shield'
		AnimSets[0]=AnimSet'Pickups.Deployables.Anims.K_Deployables_Shield_1P'
		Animations=MeshSequenceA
		CollideActors=false
		BlockActors=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		BlockRigidBody=false
		FOV=60.0
		bUseAsOccluder=FALSE
	End Object

	ArmsAnimSet=AnimSet'Pickups.Deployables.Anims.K_Deployables_Shield_1P_Arms'

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_Shield'
		Translation=(Z=-30)
	End Object

	FireOffset=(X=20.0)

	DeployedActorClass=class'UTLinkGenerator'
	AttachmentClass=class'UTAttachment_LinkGenerator'
	
	DeployFailedSoundCue=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue';
	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabTheEnergyShield')

	TeamLinkGeneratorClasses(0)=class'UT3Gold.UTLinkGeneratorRed'
	TeamLinkGeneratorClasses(1)=class'UT3Gold.UTLinkGeneratorBlue'
}
