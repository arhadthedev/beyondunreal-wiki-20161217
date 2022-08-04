/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/** UTVehicles with bIsOnTrack = true will only consider paths between these nodes */
class UTTrackTurretPathNode extends PathNode
	native;

defaultproperties
{
	Begin Object NAME=Sprite
		Sprite=Texture2D'EngineResources.PathNode'
	End Object
}
