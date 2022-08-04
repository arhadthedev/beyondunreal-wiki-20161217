/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class DecalManager extends Actor
	native(Decal)
	config(Game);

/** template to base pool components off of - should not be used for decals or attached to anything */
var protected DecalComponent DecalTemplate;
/** components currently in the pool */
var array<DecalComponent> PoolDecals;
/** maximum allowed active components - if this is greater than 0 and is exceeded, the oldest active decal is taken */
var int MaxActiveDecals;
/** default lifetime for decals */
var globalconfig float DecalLifeSpan;

/** components currently active in the world and how much longer they will be */
struct native ActiveDecalInfo
{
	var DecalComponent Decal;
	var float LifetimeRemaining;
};
var array<ActiveDecalInfo> ActiveDecals;



/** @return whether dynamic decals are enabled */
native static final function bool AreDynamicDecalsEnabled();

/** called when the given decal's lifetime has run out
 * @note: caller responsible for removing from ActiveDecals array (this is to prevent code iterating the array from having dependencies on this function)
 */
event DecalFinished(DecalComponent Decal)
{
	// clear it and return it to the pool
	Decal.ResetToDefaults();
	PoolDecals[PoolDecals.length] = Decal;
}

/** @return whether spawning decals is allowed right now */
function bool CanSpawnDecals()
{
	return AreDynamicDecalsEnabled();
}

/** spawns a decal with the given parameters, taking a component from the pool or creating as necessary
 * @note: the component is returned so the caller can perform any additional modifications (parameters, etc),
 * 	but it shouldn't keep the reference around as the component will be returned to the pool as soon as the lifetime runs out
 * @param DecalMaterial the material to use for the decal
 * @param Width decal width
 * @param Height decal height
 * @param Thickness decal thickness
 * @param bNoClip if true, use the bNoClip code path for decal generation (requires DecalMaterial to have clamped texture coordinates)
 * @param DecalRotation (opt) rotation of the decal in degrees
 * @param HitComponent (opt) if specified, will only project on this component (optimization)
 * @param bProjectOnTerrain (opt) whether decal can project on terrain (default true)
 * @param bProjectOnTerrain (opt) whether decal can project on skeletal meshes (default false)
 * @param HitBone (opt) if HitComponent is a skeletal mesh, the bone that was hit
 * @param HitNodeIndex (opt) if HitComponent is BSP, the node that was hit
 * @param HitLevelIndex (opt) if HitComponent is BSP, the index of the level whose BSP was hit
 * @return the DecalComponent that will be used (may be None if dynamic decals are disabled)
 */
function DecalComponent SpawnDecal( MaterialInterface DecalMaterial, vector DecalLocation, rotator DecalOrientation,
						float Width, float Height, float Thickness, bool bNoClip,
						optional float DecalRotation = (FRand() * 360.0),
						optional PrimitiveComponent HitComponent,
						optional bool bProjectOnTerrain = true, optional bool bProjectOnSkeletalMeshes,
						optional name HitBone, optional int HitNodeIndex = INDEX_NONE, optional int HitLevelIndex = INDEX_NONE )
{
	local int i;
	local DecalComponent Result;
	local ActiveDecalInfo DecalInfo;

	// do nothing if decals are disabled
	if (!CanSpawnDecals())
	{
		return None;
	}

	// try to grab one from the pool
	while (PoolDecals.length > 0)
	{
		i = PoolDecals.length - 1;
		Result = PoolDecals[i];
		PoolDecals.Remove(i, 1);
		if (Result != None && !Result.IsPendingKill())
		{
			break;
		}
		else
		{
			Result = None;
		}
	}

	if (Result == None)
	{
		if (MaxActiveDecals > 0 && ActiveDecals.length >= MaxActiveDecals)
		{
			// overwrite oldest decal
			Result = ActiveDecals[0].Decal;
			Result.ResetToDefaults();
			ActiveDecals.Remove(0, 1);
		}
		else
		{
			Result = new(self) DecalTemplate.Class(DecalTemplate);
		}
	}

	// set the decal's data
	Result.Location = DecalLocation;
	Result.Orientation = DecalOrientation;
	Result.DecalRotation = DecalRotation;
	Result.Width = Width;
	Result.Height = Height;
	Result.Thickness = Thickness;
	Result.FarPlane = Result.Thickness * 0.5;
	Result.NearPlane = -Result.FarPlane;
	Result.bNoClip = bNoClip;
	Result.HitComponent = HitComponent;
	Result.HitBone = HitBone;
	Result.HitNodeIndex = HitNodeIndex;
	Result.HitLevelIndex = HitLevelIndex;
	Result.DecalMaterial = DecalMaterial;
	Result.bProjectOnTerrain = bProjectOnTerrain;
	Result.bProjectOnSkeletalMeshes = bProjectOnSkeletalMeshes;
	AttachComponent(Result);

	// add to list to tick lifetime
	DecalInfo.Decal = Result;
	DecalInfo.LifetimeRemaining = DecalLifeSpan;
	ActiveDecals.AddItem(DecalInfo);

	return Result;
}

defaultproperties
{
	Begin Object Class=DecalComponent Name=BaseDecal
	End Object
	DecalTemplate=BaseDecal
}
