/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDeployableSlowVolume extends UTDeployable;

static function class<Actor> GetTeamDeployable(int TeamNum)
{
	return class'UTSlowVolume_Content';
}

function bool Deploy()
{
	local UTSlowVolume Volume;
	local vector SpawnLocation;
	local vector HitLocation, HitNormal;
	local rotator Aim;
	local float DistSqToObstacle;

	SpawnLocation = GetPhysicalFireStartLoc();

	//Get the Z location of where the visual mesh will be placed
	if (Trace(HitLocation, HitNormal, SpawnLocation, Instigator.GetPawnViewLocation(), false) != None)
	{
		DistSqToObstacle = VSizeSq(HitLocation-Location);
		if (DistSqToObstacle < (60.0 * 60.0))
		{
			//Too close to a wall or something to spawn in front of us
            //the actual deployable will do a Z line check right around here
            //and we want it to be on 'safe' ground
			return false;
		}
	}

	//Start at player height
	SpawnLocation.Z = Instigator.Location.Z;
	Aim = GetAdjustedAim(SpawnLocation);
	Aim.Pitch = 0;
	Aim.Roll = 0;
	Volume = Spawn(class'UTSlowVolume_Content',,, SpawnLocation, Aim);
	if (Volume != None)
	{
		Volume.OnDeployableUsedUp = Factory.DeployableUsed;
		bForceHidden = true;
		Mesh.SetHidden(true);
		return true;
	}
	else
	{
		return false;
	}
}

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

	//UTSlowVolume_Content says (-455,200) offset, we do 500 so we don't get stuck in the volume
	FireOffset=(X=500,Y=200.0)

	AttachmentClass=class'UTAttachment_SlowVolume'
	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabTheStasisFieldGenerator')
	DeployFailedSoundCue=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue';

}
