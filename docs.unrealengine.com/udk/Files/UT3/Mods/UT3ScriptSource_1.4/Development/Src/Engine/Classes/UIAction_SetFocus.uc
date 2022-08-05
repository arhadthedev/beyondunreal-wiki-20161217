﻿/**
 * This action gives focus to a widget in the scene.  When giving focus to a widget not contained within the
 * same scene, the scene containing that widget will become the focused scene.  If the scene which contains
 * the widget is not loaded, the scene containing the Target widget is opened.
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIAction_SetFocus extends UIAction
	native(inherit);



DefaultProperties
{
	ObjName="Set Focus"
	bAutoTargetOwner=false
}
