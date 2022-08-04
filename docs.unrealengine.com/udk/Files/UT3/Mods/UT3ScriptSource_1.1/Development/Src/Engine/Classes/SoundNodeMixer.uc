/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SoundNodeMixer extends SoundNode
	native(Sound)
	collapsecategories
	hidecategories(Object)
	editinlinenew;

/** A volume for each input.  Automatically sized. */
var() export editfixedsize array<float>	InputVolume;



defaultproperties
{
}
