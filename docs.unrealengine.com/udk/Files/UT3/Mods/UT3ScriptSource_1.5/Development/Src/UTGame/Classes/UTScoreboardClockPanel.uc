/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTScoreboardClockPanel extends UTDrawPanel;

var() Texture2D Background;
var() TextureCoordinates BackCoords;
var() LinearColor BackColor;

var() font ClockFont;
var() vector2d ClockPos;

/** Cached reference to the HUDSceneOwner */
var UTUIScene_Hud UTHudSceneOwner;

event PostInitialize()
{
	Super.PostInitialize();
	UTHudSceneOwner = UTUIScene_Hud( GetScene() );
}


event DrawPanel()
{
}



defaultproperties
{
}
