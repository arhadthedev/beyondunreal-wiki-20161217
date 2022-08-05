﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleOrientationAxisLock extends ParticleModuleOrientationBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);

// Flags indicating lock
enum EParticleAxisLock
{
	/** No locking to an axis...							*/
	EPAL_NONE,
	/** Lock the sprite facing towards the positive X-axis	*/
	EPAL_X,
	/** Lock the sprite facing towards the positive Y-axis	*/
	EPAL_Y,
	/** Lock the sprite facing towards the positive Z-axis	*/
	EPAL_Z,
	/** Lock the sprite facing towards the negative X-axis	*/
	EPAL_NEGATIVE_X,
	/** Lock the sprite facing towards the negative Y-axis	*/
	EPAL_NEGATIVE_Y,
	/** Lock the sprite facing towards the negative Z-axis	*/
	EPAL_NEGATIVE_Z,
	/** Lock the sprite rotation on the X-axis				*/
	EPAL_ROTATE_X,
	/** Lock the sprite rotation on the Y-axis				*/
	EPAL_ROTATE_Y,
	/** Lock the sprite rotation on the Z-axis				*/
	EPAL_ROTATE_Z
};

var(Orientation) EParticleAxisLock	LockAxisFlags;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true
}
