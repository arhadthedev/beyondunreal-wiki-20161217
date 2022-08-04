/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDeployableSpiderMineTrap extends UTDeployable;

var array< class<UTSpiderMineTrap> > TeamSpiderTrapClasses;

static function class<Actor> GetTeamDeployable(int TeamNum)
{
	if (TeamNum >= default.TeamSpiderTrapClasses.length)
	{
		TeamNum = 0;
	}
	return default.TeamSpiderTrapClasses[TeamNum];
}

function bool Deploy()
{
	DeployedActorClass = class<UTSpiderMineTrap>(GetTeamDeployable(Instigator.GetTeamNum()));
	return Super.Deploy();
}

function bool CanAttack(Actor Other)
{
	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}

	// check that target is within range
	if (VSize(Instigator.Location - Other.Location) > (Pawn(Other) != None ? 2000.0 : MaxRange()))
	{
		return false;
	}

	// check that can see target
	return Instigator.Controller.LineOfSightTo(Other);
}

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	TeamSpiderTrapClasses[0]=class'UTSpiderMineTrapRed'
	TeamSpiderTrapClasses[1]=class'UTSpiderMineTrapBlue'

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_SpiderMine'
		AnimSets[0]=AnimSet'Pickups.Deployables.Anims.K_Deployables_SpiderMine_1P'
		Animations=MeshSequenceA
		CollideActors=false
		BlockActors=false
		CastShadow=false
		bForceDirectLightMap=true
		bCastDynamicShadow=false
		BlockRigidBody=false
		Scale=0.5
		FOV=60.0
		bUseAsOccluder=FALSE
	End Object

	ArmsAnimSet=AnimSet'Pickups.Deployables.Anims.K_Deployables_SpiderMine_1P_Arms'

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_SpiderMine'
		Translation=(Z=-30)
	End Object
	AttachmentClass=class'UTAttachment_SpiderMineTrap'

	DroppedPickupOffsetZ=15.0

	FireOffset=(X=25.0)

	WeaponFireSnd[0]=SoundCue'A_Pickups_Deployables.SpiderMine.SpiderMine_DropCue'
	DeployFailedSoundCue=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue';
	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabTheSpiderMineTrap')
}
