/**
 * Panel class that locks its position and size to match the safe region for the viewport.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UISafeRegionPanel extends UIContainer
	config(Game)
	placeable
	native(UIPrivate);

enum ESafeRegionType
{
	ESRT_FullRegion,
	ESRT_TextSafeRegion
};

/** This holds the type of region to create */
var(Safe) ESafeRegionType RegionType;

/** Holds a list of percentages that define each region */
var(Safe) config editinline array<float> RegionPercentages;

/** If true, the panel will force the 4x3 Aspect Ratio */
var(Safe) bool	bForce4x3AspectRatio;
var(Safe) bool 	bUseFullRegionIn4x3;



defaultproperties
{
}



