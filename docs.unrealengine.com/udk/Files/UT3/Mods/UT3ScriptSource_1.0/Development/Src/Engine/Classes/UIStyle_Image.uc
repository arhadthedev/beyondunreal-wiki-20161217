/**
 * Contains information about how to present and format an image's appearance
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIStyle_Image extends UIStyle_Data
	native(inherit);

/** The material to use if the image material cannot be loaded or this style is not applied to an image. */
var()			Surface					DefaultImage;

/** if DefaultImage points to a texture atlas, represents the coordinates to use for rendering this image */
var()			TextureCoordinates		Coordinates;

/** Information about how to modify the way the image is rendered. */
var()			UIImageAdjustmentData	AdjustmentType[EUIOrientation.UIORIENT_MAX];



DefaultProperties
{
	UIEditorControlClass="WxStyleImagePropertiesGroup"
	DefaultImage=Texture'EngineResources.DefaultTexture'
}
