/*=============================================================================
	Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
=============================================================================*/
 
class SpeedTreeActorFactory extends ActorFactory
	config(Editor)
	native(SpeedTree);



var() SpeedTree	SpeedTree;

defaultproperties
{
	MenuName		= "Add SpeedTree"
	NewActorClass	= class'Engine.SpeedTreeActor'
}