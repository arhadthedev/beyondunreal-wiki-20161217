/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTDeployablePickupFactory extends UTPickupFactory;

var() class<UTDeployable> DeployablePickupClass;

var bool bDelayRespawn;

simulated function InitializePickup()
{
	InventoryType = DeployablePickupClass;

	Super.InitializePickup();

	bIsSuperItem = true;
}

simulated function SetPickupMesh()
{
	Super.SetPickupMesh();

	if ( PickupMesh != none )
	{
		DeployablePickupClass.static.InitPickupMesh(PickupMesh);
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'DeployablePickupClass')
	{
		if (InventoryType != DeployablePickupClass)
		{
			DeployablePickupClass = class<UTDeployable>(InventoryType);
			Super.ReplicatedEvent(VarName);
		}
	}
	else
	{

		Super.ReplicatedEvent(VarName);
	}
}

function PickedUpBy(Pawn P)
{
	local UTPlayerController PC;

	Super.PickedUpBy(P);
	if ( DeployablePickupClass.Default.bCanDestroyBarricades )
	{
		// notify any players that have this as their objective
		ForEach WorldInfo.AllControllers(class'UTPlayerController', PC)
		{
			if  ( (PC.LastAutoObjective == self) && (PC != P.Controller) )
			{
				PC.CheckAutoObjective(true);
			}
		}
	}
}

function SpawnCopyFor( Pawn Recipient )
{
	local Inventory Inv;
	local UTDeployable Deployable;

	Inv = Spawn(InventoryType);
	if ( Inv != None )
	{
		Recipient.MakeNoise(0.5);
		Inv.GiveTo(Recipient);
		Inv.AnnouncePickup(Recipient);
		Deployable = UTDeployable(Inv);
		if ( (Deployable != None) && Deployable.bDelayRespawn )
		{
			bDelayRespawn = true;
			Deployable.Factory = self;
		}
		else
		{
			bDelayRespawn = false;
		}
	}
}

function StartSleeping()
{
	if ( bDelayRespawn )
	{
		GotoState('WaitingForDeployable');
	}
	else
	{
		super.StartSleeping();
	}
}

/** called when the deployable spawned by this factory has been used up */
function DeployableUsed(actor ChildDeployable)
{
	`warn("called when not waiting for deployable in state "$GetStateName());
}

state WaitingForDeployable
{
	ignores Touch;

	function StartSleeping() {}

	function BeginState(name PrevStateName)
	{
		SetPickupHidden();

		Super.BeginState(PrevStateName);
		bPulseBase=false;
		StartPulse( BaseDimEmissive );
	}

	function DeployableUsed(actor ChildDeployable)
	{
		// now start normal respawn process
		GotoState('Sleeping');
	}

	function bool ReadyToPickup(float MaxWait)
	{
		return false;
	}

Begin:
}

function OnToggle(SeqAct_Toggle InAction)
{
	if (InAction.InputLinks[1].bHasImpulse || InAction.InputLinks[2].bHasImpulse)
	{
		GotoState('SleepInfinite');
	}
}

state SleepInfinite extends Sleeping
{
	function PulseThresholdMet() {}

	function OnToggle(SeqAct_Toggle InAction)
	{
		if (InAction.InputLinks[0].bHasImpulse || InAction.InputLinks[2].bHasImpulse)
		{
			GotoState('SleepInfinite', 'Respawn');
		}
	}

Begin:
	while (true)
	{
		Sleep(100000.0);
	}
}

defaultproperties
{
	bMovable=FALSE
	bStatic=FALSE
	bIsSuperItem=true

	bRotatingPickup=true
	bCollideActors=true
	bBlockActors=true

	Begin Object NAME=CollisionCylinder
		BlockZeroExtent=false
	End Object

	// @content move me
	Begin Object Name=BaseMeshComp
		StaticMesh=StaticMesh'Pickups.Base_Deployable.Mesh.S_Pickups_Base_Deployable'
		Translation=(X=0.0,Y=0.0,Z=-44.0)
	End Object

	BaseBrightEmissive=(R=1.0,G=25.0,B=1.0)
	BaseDimEmissive=(R=0.25,G=5.0,B=0.25)
}
