/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtNodeEnhancement extends UTGameObjective
	native
	abstract;

var() UTOnslaughtNodeObjective ControllingNode;	/** Level designer can set, or it is auto-assigned to nearest bunker */

replication
{
	if (bNetInitial)
		ControllingNode;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( (Role == ROLE_Authority) && (ControllingNode != None) )
	{
		SetControllingNode(ControllingNode);
	}
}

simulated function string GetLocationStringFor(PlayerReplicationInfo PRI)
{
	if ( ControllingNode != None )
	{
		return ControllingNode.GetLocationStringFor(PRI);
	}
	return LocationPrefix$GetHumanReadableName()$LocationPostfix;
}

function SetControllingNode(UTOnslaughtNodeObjective NewControllingNode)
{
	ControllingNode = NewControllingNode;
	ControllingNode.Enhancements[ControllingNode.Enhancements.Length] = self;
}

simulated function UpdateTeamEffects();

function Activate()
{
	DefenderTeamIndex = GetTeamNum();
	UpdateTeamEffects();
}

function Deactivate()
{
	DefenderTeamIndex = 2;
	UpdateTeamEffects();
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'DefenderTeamIndex')
	{
		UpdateTeamEffects();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

function TarydiumBoost(float Quantity);

simulated native function byte GetTeamNum();

defaultproperties
{
	HUDMaterial=None
	IconHudTexture=None
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bMovable=false

	bStatic=false
	bHidden=false
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
}
