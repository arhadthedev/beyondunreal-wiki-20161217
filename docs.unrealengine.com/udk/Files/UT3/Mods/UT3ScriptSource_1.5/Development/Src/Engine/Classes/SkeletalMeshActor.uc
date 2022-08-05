﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SkeletalMeshActor extends Actor
	native(Anim)
	placeable;



var()	SkeletalMeshComponent			SkeletalMeshComponent;
var() const editconst LightEnvironmentComponent LightEnvironment;

var		AudioComponent					FacialAudioComp;

/** Used to replicate mesh to clients */
var repnotify SkeletalMesh ReplicatedMesh;

replication
{
	if (Role == ROLE_Authority)
		ReplicatedMesh;
}

event PostBeginPlay()
{
	// grab the current mesh for replication
	if (SkeletalMeshComponent != None)
	{
		ReplicatedMesh = SkeletalMeshComponent.SkeletalMesh;
	}

	Super.PostBeginPlay();

	// Unfix bodies flagged as 'full anim weight'
	if( SkeletalMeshComponent != None && 
		SkeletalMeshComponent.bEnableFullAnimWeightBodies && 
		SkeletalMeshComponent.PhysicsAssetInstance != None )
	{
		SkeletalMeshComponent.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, SkeletalMeshComponent);
	}
}

simulated event ReplicatedEvent( name VarName )
{
	if (VarName == 'ReplicatedMesh')
	{
		SkeletalMeshComponent.SetSkeletalMesh(ReplicatedMesh);
	}
}

/** Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle action)
{
	local AnimNodeSequence SeqNode;

	SeqNode = AnimNodeSequence(SkeletalMeshComponent.Animations);

	// Turn ON
	if (action.InputLinks[0].bHasImpulse)
	{
		// If animation is not playing - start playing it now.
		if(!SeqNode.bPlaying)
		{
			// This starts the animation playing from the beginning. Do we always want that?
			SeqNode.PlayAnim(SeqNode.bLooping, SeqNode.Rate, 0.0);
		}
	}
	// Turn OFF
	else if (action.InputLinks[1].bHasImpulse)
	{
		// If animation is playing, stop it now.
		if(SeqNode.bPlaying)
		{
			SeqNode.StopAnim();
		}
	}
	// Toggle
	else if (action.InputLinks[2].bHasImpulse)
	{
		// Toggle current animation state.
		if(SeqNode.bPlaying)
		{
			SeqNode.StopAnim();
		}
		else
		{
			SeqNode.PlayAnim(SeqNode.bLooping, SeqNode.Rate, 0.0);
		}
	}
}

simulated event BeginAnimControl(array<AnimSet> InAnimSets)
{
	local AnimNodeSequence SeqNode;
	SeqNode = AnimNodeSequence(SkeletalMeshComponent.Animations);

	// Backup existing AnimSets
	SkeletalMeshComponent.SaveAnimSets();

	SkeletalMeshComponent.AnimSets = InAnimSets;
	SeqNode.SetAnim('');
}

simulated event SetAnimPosition(name SlotName, int ChannelIndex, name InAnimSeqName, float InPosition, bool bFireNotifies, bool bLooping)
{
	local AnimNodeSequence	SeqNode;
	/*
	local int				i;
	`log(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "PRE - InPosition:" @ InPosition @ "InAnimSeqName:" @ InAnimSeqName);
	for(i=0; i<SkeletalMeshComponent.AnimSets.Length; i++)
	{
		`log(" -" @ SkeletalMeshComponent.AnimSets[i]);
	}
	*/

	SeqNode = AnimNodeSequence(SkeletalMeshComponent.Animations);
	if( SeqNode != None )
	{
		if( SeqNode.AnimSeqName != InAnimSeqName )
		{
			SeqNode.SetAnim(InAnimSeqName);
		}

		SeqNode.bLooping = bLooping;
		SeqNode.SetPosition(InPosition, bFireNotifies);

		//`log(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "POST - CurrentTime:" @ SeqNode.CurrentTime @ "AnimSeqName:" @ SeqNode.AnimSeqName);
	}
}

simulated event SetAnimWeights(array<AnimSlotInfo> SlotInfos)
{

}

simulated event FinishAnimControl()
{
	// Restore previous AnimSets
	SkeletalMeshComponent.RestoreSavedAnimSets();
}

/** Handler for Matinee wanting to play FaceFX animations in the game. */
simulated event bool PlayActorFaceFXAnim(FaceFXAnimSet AnimSet, String GroupName, String SeqName)
{
	return SkeletalMeshComponent.PlayFaceFXAnim(AnimSet, SeqName, GroupName);
}

/** Handler for Matinee wanting to stop FaceFX animations in the game. */
simulated event StopActorFaceFXAnim()
{
	SkeletalMeshComponent.StopFaceFXAnim();
}

/** Used to let FaceFX know what component to play dialogue audio on. */
simulated event AudioComponent GetFaceFXAudioComponent()
{
	return FacialAudioComp;
}

/** Function for handling the SeqAct_PlayFaceFXAnim Kismet action working on this Actor. */
simulated function OnPlayFaceFXAnim(SeqAct_PlayFaceFXAnim inAction)
{
	local PlayerController PC;

	SkeletalMeshComponent.PlayFaceFXAnim(inAction.FaceFXAnimSetRef, inAction.FaceFXAnimName, inAction.FaceFXGroupName);

	// tell non-local players to play as well
	foreach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		if (NetConnection(PC.Player) != None)
		{
			PC.ClientPlayActorFaceFXAnim(self, inAction.FaceFXAnimSetRef, inAction.FaceFXGroupName, inAction.FaceFXAnimName);
		}
	}
}

/** Used by Matinee in-game to mount FaceFXAnimSets before playing animations. */
simulated event FaceFXAsset GetActorFaceFXAsset()
{
	if(SkeletalMeshComponent.SkeletalMesh != None)
	{
		return SkeletalMeshComponent.SkeletalMesh.FaceFXAsset;
	}
	else
	{
		return None;
	}
}

/**
 * Returns TRUE if this actor is playing a FaceFX anim.
 */
simulated function bool IsActorPlayingFaceFXAnim()
{
	return (SkeletalMeshComponent != None && SkeletalMeshComponent.IsPlayingFaceFXAnim());
}


event OnSetSkeletalMesh(SeqAct_SetSkeletalMesh Action)
{
	if (Action.NewSkeletalMesh != None && Action.NewSkeletalMesh != SkeletalMeshComponent.SkeletalMesh)
	{
		SkeletalMeshComponent.SetSkeletalMesh(Action.NewSkeletalMesh);
		ReplicatedMesh = Action.NewSkeletalMesh;
	}
}

event OnSetMaterial(SeqAct_SetMaterial Action)
{
	SkeletalMeshComponent.SetMaterial( Action.MaterialIndex, Action.NewMaterial );
}

/** Performs actual attachment. Can be subclassed for class specific behaviors. */
function DoKismetAttachment(Actor Attachment, SeqAct_AttachToActor Action)
{
	local bool	bOldCollideActors, bOldBlockActors, bValidBone, bValidSocket;

	// If a bone/socket has been specified, see if it is valid
	if( SkeletalMeshComponent != None && Action.BoneName != '' )
	{
		// See if the bone name refers to an existing socket on the skeletal mesh.
		bValidSocket	= (SkeletalMeshComponent.GetSocketByName(Action.BoneName) != None);
		bValidBone		= (SkeletalMeshComponent.MatchRefBone(Action.BoneName) != INDEX_NONE);

		// Issue a warning if we were expecting to attach to a bone/socket, but it could not be found.
		if( !bValidBone && !bValidSocket )
		{
			`log(WorldInfo.TimeSeconds @ class @ GetFuncName() @ "bone or socket" @ Action.BoneName @ "not found on actor" @ Self @ "with mesh" @ SkeletalMeshComponent);
		}
	}

	// Special case for handling relative location/rotation w/ bone or socket
	if( bValidBone || bValidSocket )
	{
		// disable collision, so we can successfully move the attachment
		bOldCollideActors	= Attachment.bCollideActors;
		bOldBlockActors		= Attachment.bBlockActors;
		Attachment.SetCollision(FALSE, FALSE);
		Attachment.SetHardAttach(Action.bHardAttach);

		// Sockets by default move the actor to the socket location.
		// This is not the case for bones! 
		// So if we use relative offsets, then first move attachment to bone's location.
		if( bValidBone && !bValidSocket )
		{
			if( Action.bUseRelativeOffset )
			{
				Attachment.SetLocation(SkeletalMeshComponent.GetBoneLocation(Action.BoneName));
			}

			if( Action.bUseRelativeRotation )
			{
				Attachment.SetRotation(QuatToRotator(SkeletalMeshComponent.GetBoneQuaternion(Action.BoneName)));
			}
		}

		// Attach attachment to base. 
		Attachment.SetBase(Self,, SkeletalMeshComponent, Action.BoneName);

		if( Action.bUseRelativeRotation )
		{
			Attachment.SetRelativeRotation(Attachment.RelativeRotation + Action.RelativeRotation);
		}

		// if we're using the offset, place attachment relatively to the target
		if( Action.bUseRelativeOffset )
		{
			Attachment.SetRelativeLocation(Attachment.RelativeLocation + Action.RelativeOffset);
		}

		// restore previous collision
		Attachment.SetCollision(bOldCollideActors, bOldBlockActors);
	}
	else
	{
		// otherwise base on location
		Super.DoKismetAttachment(Attachment, Action);
	}
}

defaultproperties
{
	Begin Object Class=AnimNodeSequence Name=AnimNodeSeq0
	End Object

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=FALSE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		Animations=AnimNodeSeq0
		CollideActors=TRUE
		BlockActors=FALSE
		BlockZeroExtent=TRUE
		BlockNonZeroExtent=FALSE
		BlockRigidBody=FALSE
		LightEnvironment=MyLightEnvironment
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE)
        bForceMeshObjectUpdates=TRUE
	End Object
	CollisionComponent=SkeletalMeshComponent0
	SkeletalMeshComponent=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)

	Begin Object Class=AudioComponent Name=FaceAudioComponent
	End Object
	FacialAudioComp=FaceAudioComponent
	Components.Add(FaceAudioComponent)

	Physics=PHYS_None
	bEdShouldSnap=TRUE
	bStatic=FALSE
	bCollideActors=TRUE
	bBlockActors=FALSE
	bWorldGeometry=FALSE
	bCollideWorld=FALSE
	bProjTarget=TRUE
	bUpdateSimulatedPosition=FALSE

	RemoteRole=ROLE_None
	bNoDelete=TRUE
}
