/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTDmgType_OrbReturn extends UTDamageType
	abstract;

simulated static function DrawKillIcon(Canvas Canvas, float ScreenX, float ScreenY, float HUDScaleX, float HUDScaleY)
{
	local color CanvasColor;
	local TextureCoordinates IconCoords;

	`log("DRAW ORB");

	// save current canvas color
	CanvasColor = Canvas.DrawColor;

	// draw orb shadow
	Canvas.DrawColor = class'UTHUD'.default.BlackColor;
	Canvas.DrawColor.A = CanvasColor.A;
	Canvas.SetPos( ScreenX - 2, ScreenY - 2 );

	IconCoords = class'UTOnslaughtFlag'.default.IconCoords;
	Canvas.DrawTile(class'UTHud'.default.IconHudTexture, 4 + HUDScaleX * 96, 4 + HUDScaleY * 64, IconCoords.U, IconCoords.V, IconCoords.UL, IconCoords.VL);

	// draw the orb icon
	Canvas.DrawColor =  class'UTHUD'.default.WhiteColor;
	Canvas.DrawColor.A = CanvasColor.A;
	Canvas.SetPos( ScreenX, ScreenY );
	Canvas.DrawTile(class'UTHud'.default.IconHudTexture, HUDScaleX * 96, HUDScaleY * 64, IconCoords.U, IconCoords.V, IconCoords.UL, IconCoords.VL);
	Canvas.DrawColor = CanvasColor;
}

defaultproperties
{
}
