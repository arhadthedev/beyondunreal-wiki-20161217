/**
 * ActorFactoryBreakable
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class GameActorFactoryBreakable extends ActorFactoryRigidBody;

defaultproperties
{
	MenuName="Add Breakable Actor"
	NewActorClass=class'GameFramework.GameBreakableActor'
	CollisionType=COLLIDE_BlockAll
}
