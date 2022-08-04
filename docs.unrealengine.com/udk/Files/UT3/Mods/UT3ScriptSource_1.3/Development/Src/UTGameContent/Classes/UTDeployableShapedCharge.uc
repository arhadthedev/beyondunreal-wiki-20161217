/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDeployableShapedCharge extends UTDeployable;

var array< class<UTShapedCharge> > TeamShapedChargeClasses;

static function class<Actor> GetTeamDeployable(int TeamNum)
{
	if (TeamNum >= default.TeamShapedChargeClasses.length)
	{
		TeamNum = 0;
	}
	return default.TeamShapedChargeClasses[TeamNum];
}

function bool Deploy()
{
	local UTPlayerController PC;

	DeployedActorClass = class<UTShapedCharge>(GetTeamDeployable(Instigator.GetTeamNum()));
	if ( Super.Deploy() )
	{
		PC = UTPlayerController(Instigator.Controller);
		if ( PC != None )
		{
			 PC.CheckAutoObjective(true);
		}
		return true;
	}
	else
	{
		return false;
	}
}

/** Recommend an objective for player carrying this deployable */
function UTGameObjective RecommendObjective(Controller C)
{
	local UTWarfareBarricade B, Best;
	local float NewDist, BestDist;

	if ( AmmoCount <= 0 )
	{
		return None;
	}

	// if you've got a shaped charge, you're going to want to find a barricade
	ForEach WorldInfo.AllNavigationPoints(class'UTWarfareBarricade', B)
	{
		if ( ((Best == None) || (Best.DefensePriority <= B.DefensePriority))
				&& (B.ValidTargetFor(C)) )
		{
			// prioritize by defensepriority, then proximity
			NewDist = VSize(C.Pawn.Location - B.Location);
			if ( (Best == None) || (Best.DefensePriority < B.DefensePriority) || (NewDist < BestDist) )
			{
				Best = B;
				BestDist = NewDist;
			}
		}
	}
	return Best;
}

function bool ShouldDeploy(UTBot B)
{
	return ( B.Squad != None && B.Squad.SquadObjective != None && !WorldInfo.GRI.OnSameTeam(B.Squad.SquadObjective, B) &&
		CanAttack(B.Squad.SquadObjective) );
}

function bool CanAttack(Actor Other)
{
	local float OtherRadius, OtherHeight;

	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}

	// check that target is within range
	Other.GetBoundingCylinder(OtherRadius, OtherHeight);
	if (VSize(Instigator.Location - Other.Location) > OtherRadius + 100.0)
	{
		return false;
	}

	// check that can see target
	return Instigator.Controller.LineOfSightTo(Other);
}

defaultproperties
{
	TeamShapedChargeClasses[0]=class'UTShapedCharge_Red'
	TeamShapedChargeClasses[1]=class'UTShapedCharge_Blue'
	bCanDestroyBarricades=true
	bDelayRespawn=false
	RespawnTime=60.0

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_ShapeCharge_1P'
		AnimSets[0]=AnimSet'Pickups.Deployables.Anims.K_Deployables_ShapeCharge_1P'
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

	ArmsAnimSet=AnimSet'Pickups.Deployables.Anims.K_Deployables_ShapeCharge_1P_Arms'

	// Pickup staticmesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_ShapeCharge_1P'
		Translation=(Z=-30)
	End Object

	FireOffset=(X=20.0)

	DeployedActorClass=class'UTShapedCharge'
	AttachmentClass=class'UTAttachment_ShapedCharge'
	NeedToPickUpAnnouncement=(AnnouncementSound=SoundNodeWave'A_Announcer_Status.Status.A_StatusAnnouncer_GrabTheShapedCharge')

	bHasLocationSpeech=true
	LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheShapedCharge'
	LocationSpeech(1)=SoundNodeWave'A_Character_Jester.BotStatus.A_BotStatus_Jester_HeadingForTheShapedCharge'
	LocationSpeech(2)=SoundNodeWave'A_Character_Othello.BotStatus.A_BotStatus_Othello_HeadingForTheShapedCharge'

	DeployFailedSoundCue=SoundCue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue';
}
