﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleSpawnBase extends ParticleModule
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object)
	abstract;

var(Spawn)	bool				bProcessSpawnRate;



defaultproperties
{
	bProcessSpawnRate=true
}
