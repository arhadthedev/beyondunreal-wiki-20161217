﻿//=============================================================================
// DynamicSMActor.
// A non-static version of StaticMeshActor. This class is abstract, but used as a
// base class for things like KActor and InterpActor.
// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class DynamicSMActor extends Actor
	native
	abstract;



var() const editconst StaticMeshComponent	StaticMeshComponent;
var() const editconst LightEnvironmentComponent LightEnvironment;
/** Used to replicate mesh to clients */
var repnotify StaticMesh ReplicatedMesh;
/** used to replicate the material in index 0 */
var repnotify MaterialInterface ReplicatedMaterial;

/** Extra component properties to replicate */
var repnotify vector ReplicatedMeshTranslation;
var repnotify rotator ReplicatedMeshRotation;
var repnotify vector ReplicatedMeshScale3D;

/** If a Pawn can be 'based' on this KActor. If not, they will 'bounce' off when they try to. */
var() bool	bPawnCanBaseOn;
/** Pawn can base on this KActor if it is asleep -- Pawn will disable KActor physics while based */
var() bool	bSafeBaseIfAsleep;

replication
{
	if (bNetDirty)
		ReplicatedMesh, ReplicatedMaterial, ReplicatedMeshTranslation, ReplicatedMeshRotation, ReplicatedMeshScale3D;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();

	ReplicatedMesh = StaticMeshComponent.StaticMesh;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ReplicatedMesh')
	{
		StaticMeshComponent.SetStaticMesh(ReplicatedMesh);
	}
	else if (VarName == 'ReplicatedMaterial')
	{
		StaticMeshComponent.SetMaterial(0, ReplicatedMaterial);
	}
	else
	if (VarName == 'ReplicatedMeshTranslation')
	{
		StaticMeshComponent.SetTranslation(ReplicatedMeshTranslation);
	}
	else
	if (VarName == 'ReplicatedMeshRotation')
	{
		StaticMeshComponent.SetRotation(ReplicatedMeshRotation);
	}
	else
	if (VarName == 'ReplicatedMeshScale3D')
	{
		StaticmeshComponent.SetScale3D(ReplicatedMeshScale3D);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

function OnSetStaticMesh(SeqAct_SetStaticMesh Action)
{
	if( (Action.NewStaticMesh != None) &&
		(Action.NewStaticMesh != StaticMeshComponent.StaticMesh) )
	{
		StaticMeshComponent.SetStaticMesh( Action.NewStaticMesh );
		ReplicatedMesh = Action.NewStaticMesh;
		ForceNetRelevant();
	}
}

function OnSetMaterial(SeqAct_SetMaterial Action)
{
	StaticMeshComponent.SetMaterial( Action.MaterialIndex, Action.NewMaterial );
	if (Action.MaterialIndex == 0)
	{
		ReplicatedMaterial = Action.NewMaterial;
		ForceNetRelevant();
	}
}

function SetStaticMesh(StaticMesh NewMesh, optional vector NewTranslation, optional rotator NewRotation, optional vector NewScale3D)
{
	StaticMeshComponent.SetStaticMesh(NewMesh);
	StaticMeshComponent.SetTranslation(NewTranslation);
	StaticMeshComponent.SetRotation(NewRotation);
	if (!IsZero(NewScale3D))
	{
		StaticMeshComponent.SetScale3D(NewScale3D);
		ReplicatedMeshScale3D = NewScale3D;
	}
	ReplicatedMesh = NewMesh;
	ReplicatedMeshTranslation = NewTranslation;
	ReplicatedMeshRotation = NewRotation;
	ForceNetRelevant();
}

/**
 *	Query to see if this DynamicSMActor can base the given Pawn
 */
simulated function bool CanBasePawn( Pawn P )
{
	// Can base pawn if...
	//		Pawns can be based always OR
	//		Pawns can be based if physics is not awake
	if( bPawnCanBaseOn ||
			(bSafeBaseIfAsleep &&
			 StaticMeshComponent != None &&
			!StaticMeshComponent.RigidBodyIsAwake()) )
	{
		return TRUE;
	}

	return FALSE;
}

/**
 *	If pawn is attached while asleep, turn off physics while pawn is on it
 */
event Attach( Actor Other )
{
	local Pawn P;

	super.Attach( Other );

	if( bSafeBaseIfAsleep )
	{
		P = Pawn(Other);
		if( P != None )
		{
			SetPhysics( PHYS_None );
		}
	}
}

/**
 *	If pawn is detached, turn back on physics (make sure no other pawns are based on it)
 */
event Detach( Actor Other )
{
	local int Idx;
	local Pawn P, Test;
	local bool bResetPhysics;

	super.Detach( Other );

	P = Pawn(Other);
	if( P != None )
	{
		bResetPhysics = TRUE;
		for( Idx = 0; Idx < Attached.Length; Idx++ )
		{
			Test = Pawn(Attached[Idx]);
			if( Test != None && Test != P )
			{
				bResetPhysics = FALSE;
				break;
			}
		}

		if( bResetPhysics )
		{
			SetPhysics( PHYS_RigidBody );
		}
	}
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=false
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
	End Object
	CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	bEdShouldSnap=true
	bWorldGeometry=false
	bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bPathColliding=true

	// DynamicSMActor do not have collision as a default.  Having collision on them
	// can be very slow (e.g. matinees where the matinee is controlling where
	// the actors move and then they are trying to collide also!)
	// The overall idea is that it is really easy to see when something doesn't
	// collide correct and rectify it.  On the other hand, it is hard to see
	// something testing collision when it should not be while you wonder where
	// your framerate went.

	bCollideActors=false
	bPawnCanBaseOn=true
}
