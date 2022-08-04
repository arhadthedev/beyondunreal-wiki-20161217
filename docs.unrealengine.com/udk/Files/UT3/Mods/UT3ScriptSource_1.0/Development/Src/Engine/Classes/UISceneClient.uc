/**
 * Serves as the interface between a UIScene and scene owners.  Provides scenes with all
 * data necessary for operation and routes rendering to the scenes.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UISceneClient extends UIRoot
	native(UserInterface)
	abstract
	inherits(FExec,FCallbackEventDevice)
	transient;

/** the viewport to use for rendering scenes */
var const transient	native					pointer				RenderViewport{FViewport};

/**
 * The active UISkin.  Only one UISkin can be active at a time.
 * The special data store name 'Styles' always corresponds to the ActiveSkin.
 */
var	transient 								UISkin				ActiveSkin;

/**
 * the location of the mouse
 *
 * @fixme splitscreen
 */
var const transient							IntPoint			MousePosition;

/**
 * Represents the widget/scene that is currently under the mouse cursor.
 *
 * @fixme splitscreen
 */
var	const transient							UIObject			ActiveControl;

/**
 * Manager all persistent global data stores.  Set by the object that creates the scene client.
 */
var	const transient							DataStoreClient		DataStoreManager;

/** Material instance parameter for UI widget opacity. */
var transient				MaterialInstanceConstant			OpacityParameter;

/** Name of the opacity parameter. */
var const transient			name								OpacityParameterName;

/**
 * Stores the 3D projection matrix being used to render the UI.
 */
var	const transient							matrix				CanvasToScreen;
var	const transient							matrix				InvCanvasToScreen;


/** Post process chain to be applied when rendering UI Scenes */
var transient								PostProcessChain	UIScenePostProcess;
/** if TRUE then post processing is enabled using the UIScenePostProcess */
var transient								bool				bEnablePostProcess;



/**
 * Changes the active skin to the skin specified, initializes the skin and performs all necessary cleanup and callbacks.
 * This method should only be called from script.
 *
 * @param	NewActiveScene	The skin to activate
 *
 * @return	TRUE if the skin was successfully changed.
 */
native final noexport function bool ChangeActiveSkin( UISkin NewActiveSkin );

/*
/**
 * Used to limit which scenes should be considered when determining whether the UI should be considered "active"
 */
enum ESceneFilterTypes
{
	SCENEFILTER_None				=0x00000000,

	/** Include the transient scene */
	SCENEFILTER_IncludeTransient	=0x00000001,

	/** Consider only scenes which can process input */
	SCENEFILTER_InputProcessorOnly	=0x00000002,

	/** Consider only scenes which require the game to be paused */
	SCENEFILTER_PausersOnly			=0x00000004,

	/** Consider only scenes which support 3D primitives rendering */
	SCENEFILTER_PrimitiveUsersOnly	=0x00000008,

	/** Only consider scenes which render full-screen */
	SCENEFILTER_UsesPostProcessing	=0x00000010,

	/** Include ANY scene, regardless of feature set */
	SCENEFILTER_Any = 0x00000020
};
*/

/**
 * Returns true if there is an unhidden fullscreen UI active
 *
 * @param	Flags	a bitmask of values which alter the result of this method;  the bits are derived from the ESceneFilterTypes
 *					enum (which is native-only); script callers must pass these values literally
 *
 * @return TRUE if the UI is currently active
 */
native final noexport function bool IsUIActive( optional int Flags=0 ) const;

/**
 * Returns whether the specified scene has been fully initialized.  Different from UUIScene::IsInitialized() in that this
 * method returns true only once all objects related to this scene have been created and initialized (e.g. in the UI editor
 * only returns TRUE once the editor window for this scene has finished creation).
 *
 * @param	Scene	the scene to check.
 *
 * @note: noexport because the C++ version is a pure virtual
 */
native final noexport function bool IsSceneInitialized( UIScene Scene ) const;

/**
 * Initializes the specified scene without opening it.
 *
 * @param	Scene				the scene to initialize;  if the scene specified is contained in a content package, a copy of the scene
 *								will be created, and that scene will be initialized instead.
 * @param	SceneOwner			the player that should be associated with the new scene.  Will be assigned to the scene's
 *								PlayerOwner property.
 * @param	InitializedScene	the scene that was actually initialized.  If Scene is located in a content package, InitializedScene will be
 *								the copy of the scene that was created.  Otherwise, InitializedScene will be the same as the scene passed in.
 *
 * @return	TRUE if the scene was successfully initialized
 *
 * @note - noexport to handle the optional out parameter correctly
 */
native final noexport function bool InitializeScene( UIScene Scene, optional LocalPlayer SceneOwner, optional out UIScene InitializedScene );

/**
 * Initializes and activates the specified scene.
 *
 * @param	Scene			the scene to open; if the scene specified is contained in a content package, a copy of the scene will be created
 *							and the copy will be opened instead.
 * @param	SceneOwner		the player that should be associated with the new scene.  Will be assigned to the scene's
 *							PlayerOwner property.
 * @param	OpenedScene		the scene that was actually opened.  If Scene is located in a content package, OpenedScene will be
 *							the copy of the scene that was created.  Otherwise, OpenedScene will be the same as the scene passed in.
 *
 * @return TRUE if the scene was successfully opened
 *
 * @note - noexport to handle the optional out parameter correctly
 */
native final noexport function bool OpenScene( UIScene Scene, optional LocalPlayer SceneOwner, optional out UIScene OpenedScene );

/**
 * Deactivates the specified scene, as well as all scenes which occur after the specified scene in the list of active scenes.
 *
 * @param	Scene	the scene to deactivate
 *
 * @return true if the scene was successfully deactivated
 */
native function bool CloseScene( UIScene Scene );

/**
 * Loads the skin package containing the skin with the specified tag, and sets that skin as the currently active skin.
 * @todo
 */
//native final function SetActiveSkin( Name SkinTag );

/**
 * Set the mouse position to the coordinates specified
 *
 * @param	NewX	the X position to move the mouse cursor to (in pixels)
 * @param	NewY	the Y position to move the mouse cursor to (in pixels)
 */
native final virtual function SetMousePosition( int NewMouseX, int NewMouseY );

/**
 * Changes the resource that is currently being used as the mouse cursor.  Called by widgets as they changes states, or when
 * some action occurs which affects the mouse cursor.
 *
 * @param	CursorName	the name of the mouse cursor resource to use.  Should correspond to a name from the active UISkin's
 *						MouseCursorMap
 *
 * @return	TRUE if the cursor was successfully changed.
 */
native final virtual function bool ChangeMouseCursor( name CursorName );

/**
 * Changes the matrix for projecting local (pixel) coordinates into world screen (normalized device)
 * coordinates.  This method should be called anytime the viewport size or origin changes.
 */
native final function noexport UpdateCanvasToScreen();

/**
 * Returns the current canvas to screen projection matrix.
 *
 * @param	Widget	if specified, the returned matrix will include the widget's tranformation matrix as well.
 *
 * @return	a matrix which can be used to project 2D pixel coordines into 3D screen coordinates. ??
 */
native final function matrix GetCanvasToScreen( optional const UIObject Widget ) const;

/**
 * Returns the inverse of the local to world screen projection matrix.
 *
 * @param	Widget	if specified, the returned matrix will include the widget's tranformation matrix as well.
 *
 * @return	a matrix which can be used to transform normalized device coordinates (i.e. origin at center of screen) into
 *			into 0,0 based pixel coordinates. ??
 */
native final function matrix GetInverseCanvasToScreen( optional const UIObject Widget ) const;

/**
 * Returns the currently active scene
 */
function UIScene GetActiveScene()
{
	return none;
}

DefaultProperties
{
	OpacityParameterName=UI_Opacity

	// enable post processing of UI by default
	bEnablePostProcess=True
}
