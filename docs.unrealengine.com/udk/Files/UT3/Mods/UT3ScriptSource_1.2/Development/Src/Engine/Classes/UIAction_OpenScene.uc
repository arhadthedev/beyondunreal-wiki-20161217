/**
 * Opens a new scene.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_OpenScene extends UIAction_Scene
	native(inherit);

/** Output variable for the scene that was opened. */
var	UIScene		OpenedScene;



DefaultProperties
{
	ObjName="Open Scene"

	VariableLinks.Add((ExpectedType=class'SeqVar_Object',LinkDesc="Opened Scene",PropertyName=OpenedScene,bWriteable=true))

}
