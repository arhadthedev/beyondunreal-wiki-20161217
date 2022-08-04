/**
 * UISceneClient used for rendering scenes in the editor.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class EditorUISceneClient extends UISceneClient
	native
	transient;

/** the scene associated with this scene client.  Always valid, even when the scene is currently being edited */
var const			transient		UIScene					Scene;

/** pointer to the UISceneManager singleton.  set by the scene manager when an EditorUISceneClient is created */
var const			transient		UISceneManager			SceneManager;

/** pointer to the editor window for the scene associated with this scene client.  Only valid while the scene is being edited */
var const	native	transient		pointer					SceneWindow{class WxUIEditorBase};

/** canvas scene for rendering 3d primtives/lights. Created during Init */
var const	native 	transient		pointer					ClientCanvasScene{class FCanvasScene};

/** TRUE if the scene for rendering 3d prims on this UI has been initialized */
var const 			transient 		bool					bIsUIPrimitiveSceneInitialized;



exec function ShowDockingStacks()
{
	if ( Scene != None )
	{
		Scene.LogDockingStack();
	}
}


DefaultProperties
{
}
