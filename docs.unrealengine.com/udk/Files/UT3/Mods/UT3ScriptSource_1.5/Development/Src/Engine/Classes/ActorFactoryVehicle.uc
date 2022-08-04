/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryVehicle extends ActorFactory
	config(Editor)
	native;

;

var() class<Vehicle>	VehicleClass;

defaultproperties
{
	VehicleClass=class'Vehicle'
	bPlaceable=false
}
