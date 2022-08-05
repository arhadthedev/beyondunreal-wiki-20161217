﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/** client side event triggered by power core when it wants to play its destruction effect
 * use this to make a level specific effect instead of the default
 */
class UTSeqEvent_PowerCoreDestructionEffect extends SequenceEvent;

/** skeletal mesh actor the power core spawns (for e.g. matinee control) */
var SkeletalMeshActor MeshActor;

defaultproperties
{
	bPlayerOnly=false
	bClientSideOnly=true
	MaxTriggerCount=0
	ObjName="Play Core Destruction"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Skeletal Mesh Actor",bWriteable=true,PropertyName=MeshActor)
}
