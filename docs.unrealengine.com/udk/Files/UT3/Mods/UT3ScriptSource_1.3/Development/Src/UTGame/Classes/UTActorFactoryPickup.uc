/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */


/** creates a pickup (NOT pickup factory) in the world */
class UTActorFactoryPickup extends ActorFactory
	native;

var() class<Inventory> InventoryClass;



defaultproperties
{
	NewActorClass=class'UTDroppedPickup'
	bPlaceable=false
}
