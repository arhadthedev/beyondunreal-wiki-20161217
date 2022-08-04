/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTDeployableEMPMine extends UTDeployable;

function bool ShouldDeploy(UTBot B)
{
	local UTVehicle V;

	if (B.IsRetreating() && UTVehicleBase(B.Enemy) != None)
	{
		return true;
	}
	else
	{
		// deploy if any enemy vehicles nearby, even if not being driven
		foreach VisibleCollidingActors(class'UTVehicle', V, 1024.0)
		{
			if (!WorldInfo.GRI.OnSameTeam(V, B))
			{
				return true;
			}
		}

		return false;
	}
}

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_EMP_Mine'
		AnimSets[0]=AnimSet'Pickups.Deployables.Anims.K_Deployables_EMP_Mine_1P'
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

	ArmsAnimSet=AnimSet'Pickups.Deployables.Anims.K_Deployables_EMP_Mine_1P_Arms'

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_EMP_Mine'
		Translation=(Z=-30)
	End Object

	FireOffset=(X=20.0)

	DeployedActorClass=class'UTEMPMine'

	AttachmentClass=class'UTAttachment_EMPMine'

	WeaponFireSnd[0]=SoundCue'A_Pickups_Deployables.EMPMine.EMPMine_DropCue'
	DeployFailedSoundCue=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue';
}
