/**
 * This is used by the scene management to isolate lights and primitives.  For lighting and actor or component
 * use a DynamicLightEnvironmentComponent.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class LightEnvironmentComponent extends ActorComponent
	native;

/** Whether the light environment is used or treated the same as a LightEnvironment=NULL reference. */
var() const bool bEnabled;

/** The time when a primitive in the light environment was last rendered. */
var transient const float LastRenderTime;



/**
 * Changes the value of bEnabled.
 * @param bNewEnabled - The value to assign to bEnabled.
 */
native final function SetEnabled(bool bNewEnabled);

defaultproperties
{
	bEnabled=True
}
