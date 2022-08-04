/**
 * Outermost container for a group of widgets.  The relationship between UIScenes and widgets is very similar to the
 * relationship between maps and the actors placed in a map, in that all UIObjects must be contained by a UIScene.
 * Widgets cannot be rendered directly.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIScene extends UIScreenObject
	native(UIPrivate);

`include(Core/Globals.uci)

/**
 * Semi-unique non-localized name for this scene which is used to reference the scene from unrealscript.
 * For scenes which are gametype specific, each scene may wish to use the same SceneName (for example, if each game
 * had a single scene which represented the HUD for that gametype, all of the HUD scenes might use "HUDScene" as their
 * SceneName, so that the current game's HUD scene can be referenced using "HUDScene" regardless of which type of hud it is)
 */
var()								name					SceneTag<ToolTip=Human-friendly name for this scene>;

/** the client for this scene - provides all global state information the scene requires for operation */
var const transient					UISceneClient			SceneClient;

/**
 * The data store that provides access to this scene's temporary data
 */
var	const 	instanced				SceneDataStore			SceneData;

/**
 * The LocalPlayer which owns this scene.  NULL if this scene is global (i.e. not owned by a player)
 */
var const transient 				LocalPlayer				PlayerOwner;

/**
 * The tool tip currently being displayed or pending display.
 */
var	const transient	private{private} UIToolTip				ActiveToolTip;

/**
 * This tooltip widget will be used to display tooltips for widgets which do not provide custom tool-tip widgets.
 */
var	const transient	private{private} UIToolTip				StandardToolTip;

/**
 * The UIToolTip class to use for the StandardToolTip
 */
var(Overlays)	const				class<UIToolTip>		DefaultToolTipClass<ToolTip=The class that should be used for tooltips in this scene>;

/**
 * The context menu currently being displayed or pending display.
 */
var	const transient private			 UIContextMenu			ActiveContextMenu;

/**
 * This context menu will be used as the context menu for widgets which do not provide their own
 */
var	const transient	private{private} UIContextMenu			StandardContextMenu;

/**
 * The UIContextMenu class to use for the StandardContextMenu
 */
var(Overlays)	const				class<UIContextMenu>	DefaultContextMenuClass<ToolTip=The class that should be used for displaying context menus in this scene>;

/**
 * Tracks the docking relationships between widgets owned by this scene.  Determines the order in which the
 * UIObject.Position values for each widget in the sceen are evaluated into UIObject.RenderBounds
 *
 * @note: this variable is not serialized (even by GC) as the widget stored in this array will be
 * serialized through the Children array.
 */
var const transient	native private	array<UIDockingNode>	DockingStack;

/**
 * Tracks the order in which widgets were rendered, for purposes of hit detection.
 */
var	const	transient	private		array<UIObject>			RenderStack;

/**
 * Tracks the widgets owned by this scene which are currently eligible to process input.
 * Maps the input keyname to the list of widgets that can process that event.
 *
 * @note: this variable is not serialized (even by GC) as the widgets stored in this map will be
 * serialized through the Children array
 */
var	const	transient	native		Map_Mirror				InputSubscriptions{TMap< FName, TArray<struct FInputEventSubscription> >};

/**
 * The index for the player that this scene last received input from.
 */
var			transient				int						LastPlayerIndex;

/**
 * Indicates that the docking stack should be rebuilt on the next Tick()
 */
var	transient bool 											bUpdateDockingStack;

/**
 * Indicates that the widgets owned by this scene should re-evaluate their screen positions
 * into absolute pixels on the next Tick().
 */
var transient bool											bUpdateScenePositions;

/**
 * Indicates that the navigation links between the widgets owned by this scene are no longer up to date.  Once this is set to
 * true, RebuildNavigationLinks() will be called on the next Tick()
 */
var	transient bool											bUpdateNavigationLinks;

/**
 * Indicates that the value of bUsesPrimitives is potentially out of date.  Normally set when a child is added or removed from the scene.
 * When TRUE, UpdatePrimitiveUsage will be called during the next tick.
 */
var	transient bool											bUpdatePrimitiveUsage;

/**
 * Indicates that the Widgets displayed need to be redrawn. Once this is set to
 * true, RefreshWidgets() will be called on the next Tick()
 */
var	transient bool											bRefreshWidgetStyles;

/**
 * Indicates that all strings contained in this scene should be reformatted.
 */
var	transient bool											bRefreshStringFormatting;

/**
 * This flag is used to detect whether or not we are updating the scene for the first time, if it is FALSE and update scene is called,
 * then we issue the PreRenderCallback for the scene so widgets have a chance to 'initialize' their positions if desired.
 */
var transient bool											bIssuedPreRenderCallback;

/**
 * Indicates that the scene is currently resolving positions for widgets in this scene
 */
var	transient const bool									bResolvingScenePositions;

/**
 * Indicates that one or more widgets in this scene are using 3D primitives.  Set to TRUE in Activate() if any children
 * of this scene have true for UIScreenObject.bSupports3DPrimitives
 */
var	transient const bool									bUsesPrimitives;

/**
 * Controls whether the cursor is shown while this scene is active.  Interactive scenes such as menus will generally want
 * this enabled, while non-interactive scenes, such as the HUD generally want it disabled.
 *
 * @todo - this bool may be unnecessary, since we can establish whether a scene should process mouse input by looking
 * at the input events for the widgets of this scene; if any process any of the mouse keys (MouseX, MouseY, RMB, LMB, MMB, etc.)
 * or if the scene can be a drop target, then this scene needs to process mouse input, and should probably display a cursor....
 * hmmm need to think about this assumption a bit more before implementing this
 */
var(Flags) 							bool					bDisplayCursor<ToolTip=Controls whether the game renders a mouse cursor while this scene is active>;

/**
 * Controls whether the scenes underneath this scene are rendered.
 */
var(Flags)							bool					bRenderParentScenes<ToolTip=Controls whether previously open scenes are rendered while this scene is active>;

/**
 * Overrides the setting of bRenderParentScenes for any scenes higher in the stack
 */
var(Flags)							bool					bAlwaysRenderScene<ToolTip=Overrides the value of bRenderScenes for any scenes which were opened after this one>;

/**
 * Indicates whether the game should be paused while this scene is active.
 */
var(Flags)							bool					bPauseGameWhileActive<ToolTip=Controls whether the game is automatically paused while this scene is active>;

/**
 * If true this scene is exempted from Auto closuer when a scene above it closes
 */
var(Flags)							bool					bExemptFromAutoClose<ToolTip=Controls whether this scene is automatically closed when one of its parent scenes is closed>;

/**
 * Indicates whether the the scene should close itself when the level changes.  This is useful for
 * when you have a main menu and want to make certain it is closed when ever you switch to a new level.
 */
var(Flags)							bool					bCloseOnLevelChange<ToolTip=Controls whether this scene is automatically closed when the level changes (recommended if this scene contains references to Actors)>;

/**
 * Indicates whether the scene should have its widgets save their values to the datastore on close.
 */
var(Flags)							bool					bSaveSceneValuesOnClose<ToolTip=Controls whether widgets automatically save their values to their data stores when the scene is closed (turn off if you handle saving manually, such as only when the scene is closed with a certain keypress)>;

/**
 * Controls whether post-processing is enabled for this scene.
 */
var(Flags)							bool					bEnableScenePostProcessing<ToolTip=Controls whether post-processing effects are enabled for this scene>;

/**
 * Controls whether depth testing is enabled for this scene.  If TRUE then the 2d ui items are depth tested against the 3d ui scene
 */
var(Flags)							bool					bEnableSceneDepthTesting<ToolTip=Controls whether depth testing with 3D ui primitives is enabled for this scene>;

/**
 * TRUE to indicate that this scene requires a valid network connection in order to be opened.  If no network connection is
 * available, the scene will be closed.
 */
var(Flags)							bool					bRequiresNetwork;

/**
 * Set to TRUE to indicate that the user must be signed into an online service (for example, Windows live) in order to
 * view this scene.  If the user is not signed into an online service, the scene will be closed.
 */
var(Flags)							bool					bRequiresOnlineService;

/**
 * TRUE indicates that this scene can be automatically reopened when the user returns to the main front-end menu.
 */
var(Flags)							bool					bMenuLevelRestoresScene;

/**
 * TRUE to flush all player input when this scene is opened.
 */
var(Flags)							bool					bFlushPlayerInput<DisplayName=Flush Input|ToolTip=Controls whether keys being held down (such as when the player is firing) should be cleared when this scene is opened>;

/**
 * TRUE to disable world rendering while this scene is active
 */
var(Flags) 							bool 					bDisableWorldRendering<DisplayName=Disable World Rendering|ToolTip=If true, the world rendering will be disabled when this scene is active>;

//var(Flags)							bool
//var(Flags)							bool

/**
 * Preview thumbnail for the generic browser.
 */
var	editoronly						Texture2D				ScenePreview;

/**
 * Controls how this scene responds to input from multiple players.
 */
var(Splitscreen)					EScreenInputMode		SceneInputMode<ToolTip=Controls how this scene responds to input from multiple players>;

/**
 * Controls how this scene will be rendered when split-screen is active.
 */
var(Splitscreen)					ESplitscreenRenderMode	SceneRenderMode<ToolTip=Controls whether this scene should be rendered when in split-screen>;

/**
 * The current aspect ratio for this scene's viewport.  For scenes modified in the UI editor, this will be set according
 * to the value of the resolution drop-down control.  In game, this will be updated anytime the resolution is changed.
 */
var									Vector2D				CurrentViewportSize;


// ===============================================
// Sounds
// ===============================================
/** this sound is played when this scene is activated */
var(Sound)				name						SceneOpenedCue;
/** this sound is played when this scene is deactivated */
var(Sound)				name						SceneClosedCue;


// ===============================================
// Editor
// ===============================================
/**
 * The root of the layer hierarchy for this scene;  only loaded in the editor.
 *
 * @todo ronp - temporarily marked this transient until I can address the bugs in layer browser which are holding references to deleted objects
 * (also commented out the creation of the layer browser).
 */
var	editoronly const	private	transient	UILayerBase		SceneLayerRoot;




/* ==========================================================================================================
	UIScene interface.
========================================================================================================== */
/* == Delegates == */
/**
 * Returns the screen input mode configured for this scene
 */
delegate EScreenInputMode GetSceneInputMode()
{
	return SceneInputMode;
}

/**
 * Allows others to be notified when this scene becomes the active scene.  Called after other activation methods have been called
 * and after focus has been set on the scene
 *
 * @param	ActivatedScene			the scene that was activated
 * @param	bInitialActivation		TRUE if this is the first time this scene is being activated; FALSE if this scene has become active
 *									as a result of closing another scene or manually moving this scene in the stack.
 */
delegate OnSceneActivated( UIScene ActivatedScene, bool bInitialActivation );

/**
 * Allows others to be notified when this scene is closed.  Called after the SceneDeactivated event, after the scene has published
 * its data to the data stores bound by the widgets of this scene.
 *
 * @param	DeactivatedScene	the scene that was deactivated
 */
delegate OnSceneDeactivated( UIScene DeactivatedScene );

/**
 * This notification is sent to the topmost scene when a different scene is about to become the topmost scene.
 * Provides scenes with a single location to perform any cleanup for its children.
 *
 * @note: this delegate is called while this scene is still the top-most scene.
 *
 * @param	NewTopScene		the scene that is about to become the topmost scene.
 */
delegate OnTopSceneChanged( UIScene NewTopScene );

/**
 * Provides scenes with a way to alter the amount of transparency to use when rendering parent scenes.
 *
 * @param	AlphaModulationPercent	the value that will be used for modulating the alpha when rendering the scene below this one.
 *
 * @return	TRUE if alpha modulation should be applied when rendering the scene below this one.
 */
delegate bool ShouldModulateBackgroundAlpha( out float AlphaModulationPercent );

/* == Natives == */
/**
 * Triggers an immediate full scene update (rebuilds docking stacks if necessary, resolves scene positions if necessary, etc.); scene
 * updates normally occur at the beginning of each scene's Tick() so this function should only be called if you must change the positions
 * and/or formatting of a widget in the scene after the scene has been ticked, but before it's been rendered.
 *
 * @note: noexport because this simply calls through to the C++ UpdateScene().
 */
native final noexport function ForceImmediateSceneUpdate();

/**
 * Clears and rebuilds the complete DockingStack.  It is not necessary to manually rebuild the DockingStack when
 * simply adding or removing widgets from the scene, since those types of actions automatically updates the DockingStack.
 */
native final function RebuildDockingStack();

/**
 * Iterates through the scene's DockingStack, and evaluates the Position values for each widget owned by this scene
 * into actual pixel values, then stores that result in the widget's RenderBounds field.
 */
native final function ResolveScenePositions();

/**
 * Gets the data store for this scene, creating one if necessary.
 */
native final function SceneDataStore GetSceneDataStore();

/**
 * Notifies all children that are bound to readable data stores to retrieve their initial value from those data stores.
 */
native final function LoadSceneDataValues();

/**
 * Notifies all children of this scene that are bound to writable data stores to publish their values to those data stores.
 *
 * @param	bUnbindSubscribers	if TRUE, all data stores bound by widgets and strings in this scene will be unbound.
 */
native final function SaveSceneDataValues( optional bool bUnbindSubscribers );

/**
 * Makes all the widgets in this scene unsubscribe from their bound datastores.
 */
native final function UnbindSubscribers();

/**
 * Find the data store that has the specified tag.  If the data store's tag is SCENE_DATASTORE_TAG, the scene's
 * data store is returned, otherwise searches through the global data stores for a data store with a Tag matching
 * the specified name.
 *
 * @param	DataStoreTag	A name corresponding to the 'Tag' property of a data store
 * @param	InPlayerOwner		The player owner to use for resolving the datastore.  If NULL, the scene's playerowner will be used instead.
 *
 * @return	a pointer to the data store that has a Tag corresponding to DataStoreTag, or NULL if no data
 *			were found with that tag.
 */
native final function UIDataStore ResolveDataStore( Name DataStoreTag, optional LocalPlayer InPlayerOwner );

/**
 * Returns the scene that is below this one in the scene client's stack of active scenes.
 *
 * @param	bRequireMatchingPlayerOwner		TRUE indicates that only a scene that has the same value for PlayerOwner as this
 *											scene may be considered the "previous" scene to this one
 */
native final function UIScene GetPreviousScene( bool bRequireMatchingPlayerOwner=true );

/**
 * Changes the screen input mode for this scene.
 */
native final function SetSceneInputMode( EScreenInputMode NewInputMode );

/**
 * Returns the current WorldInfo
 */
native function WorldInfo GetWorldInfo();

/**
 * Wrapper for easily determining whether this scene is in the scene client's list of active scenes.
 *
 * @param	bTopmostScene	specify TRUE to check whether the scene is also the scene client's topmost scene.
 */
native final function bool IsSceneActive( optional bool bTopmostScene ) const;

/**
 * Returns the scene's default tooltip widget, creating one if necessary.
 */
native final function UIToolTip GetDefaultToolTip();

/**
 * Returns the scene's default context menu widget, creating one if necessary.
 */
native final function UIContextMenu GetDefaultContextMenu();

/**
 * Returns the scene's currently active tool-tip, if there is one.
 */
native final function UIToolTip GetActiveToolTip() const;

/**
 * Changes the scene's ActiveToolTip to the one specified.
 */
native final function bool SetActiveToolTip( UIToolTip NewToolTip );

/**
 * Returns the scene's currently active context menu, if there is one.
 */
native final function UIContextMenu GetActiveContextMenu() const;

/**
 * Changes the scene's ActiveContextMenu to the one specified.
 *
 * @param	NewContextMenu	the new context menu to activate, or NULL to clear any active context menus.
 * @param	PlayerIndex		the index of the player to display the context menu for.
 *
 * @return	TRUE if the scene's ActiveContextMenu was successfully changed to the new value.
 */
native final function bool SetActiveContextMenu( UIContextMenu NewContextMenu, int PlayerIndex );

/* == Events == */

/**
 * Called just after the scene is added to the ActiveScenes array, or when this scene has become the active scene as a result
 * of closing another scene.
 *
 * @param	bInitialActivation		TRUE if this is the first time this scene is being activated; FALSE if this scene has become active
 *									as a result of closing another scene or manually moving this scene in the stack.
 */
event SceneActivated( bool bInitialActivation )
{
	local int EventIndex;
	local array<UIEvent> EventList;
	local UIEvent_SceneActivated SceneActivatedEvent;

	FindEventsOfClass( class'UIEvent_SceneActivated', EventList );
	for ( EventIndex = 0; EventIndex < EventList.Length; EventIndex++ )
	{
		SceneActivatedEvent = UIEvent_SceneActivated(EventList[EventIndex]);
		if ( SceneActivatedEvent != None )
		{
			SceneActivatedEvent.bInitialActivation = bInitialActivation;
			SceneActivatedEvent.ConditionalActivateUIEvent(LastPlayerIndex, Self, Self, bInitialActivation);
		}
	}
}

/** Called just after this scene is removed from the active scenes array */
event SceneDeactivated()
{
	ActivateEventByClass( LastPlayerIndex,class'UIEvent_SceneDeactivated', Self, true );
}

/**
 * Determines the appropriate PlayerInput mask for this scene, based on the scene's input mode.
 */
final event CalculateInputMask()
{
	local int ActivePlayers;
	local GameUISceneClient GameSceneClient;
	local byte NewMask, PlayerIndex;
	local EScreenInputMode InputMode;

	NewMask = PlayerInputMask;
	GameSceneClient = GameUISceneClient(SceneClient);
	if ( GameSceneClient != None )
	{
		InputMode = GetSceneInputMode();

		switch ( InputMode )
		{
		// if we only accept input from the player that opened this scene, our input mask should only contain the
		// gamepad id for our player owner
		case INPUTMODE_Locked:
		case INPUTMODE_MatchingOnly:
			// if we aren't associated with a player, we'll accept input from anyone
			if ( PlayerOwner == None )
			{
				NewMask = 0;
				ActivePlayers = GetActivePlayerCount();
				for ( PlayerIndex = 0; PlayerIndex < ActivePlayers; PlayerIndex++ )
				{
					NewMask = NewMask | (1 << PlayerIndex);
				}
			}
			else
			{
				PlayerIndex = GameSceneClient.GamePlayers.Find(PlayerOwner);
				if ( PlayerIndex == INDEX_NONE )
				{
					NewMask = 255;
				}
				else
				{
					NewMask = 1 << PlayerIndex;
				}
			}
			break;

		case INPUTMODE_Free:
		case INPUTMODE_ActiveOnly:
			NewMask = 255;
			break;

		case INPUTMODE_Simultaneous:
			// reset the InputMask to 0
			NewMask = 0;
			ActivePlayers = GetActivePlayerCount();
			for ( PlayerIndex = 0; PlayerIndex < ActivePlayers; PlayerIndex++ )
			{
				NewMask = NewMask | (1 << PlayerIndex);
			}
			break;

		case INPUTMODE_None:
			// input will be discarded before the InputMask is evaluated, so no need to change anything.
			// @todo ronp - or is there...?
			break;

		default:
			`warn(`location @"(" $ SceneTag $ ") unhandled ScreenInputMode '"$GetEnum(enum'EScreenInputMode', InputMode)$"'.  PlayerInputMask will be set to 0");
			break;
		}

//`if(`notdefined(ShippingPC))
//		`log(`location @ "(" $ SceneTag $ ") setting PlayerInputMask to "$NewMask@".  SceneInputMode:"$GetEnum(enum'EScreenInputMode',InputMode) @ "PlayerIndex:" $ PlayerIndex @ "ControllerID:" $ (PlayerOwner != None ? string(PlayerOwner.ControllerId) : "255") @ "PlayerCount:"$ class'UIInteraction'.static.GetPlayerCount(),,'DevUI');
//`endif
	}

	SetInputMask(NewMask, false);
}

/**
 * Changes the player input mask for this control, which controls which players this control will accept input from.
 *
 * @param	NewInputMask	the new mask that should be assigned to this control
 * @param	bRecurse		if TRUE, calls SetInputMask on all child controls as well.
 */
event SetInputMask( byte NewInputMask, optional bool bRecurse=true )
{
	local GameUISceneClient GameSceneClient;

	Super.SetInputMask(NewInputMask, bRecurse);

	GameSceneClient = GameUISceneClient(SceneClient);
	if ( GameSceneClient != None )
	{
		// changing the scene's input mask can potentially affect whether the axis emulation data for this player
		// should be processed, so request the scene client to update its input-processing status
		GameSceneClient.RequestInputProcessingUpdate();
	}
}

/**
 * Changes whether this widget is visible or not.  Should be overridden in child classes to perform additional logic or
 * abort the visibility change.
 *
 * @param	bIsVisible	TRUE if the widget should be visible; false if not.
 */
event SetVisibility( bool bIsVisible )
{
	local GameUISceneClient GameSceneClient;

	Super.SetVisibility(bIsVisible);

	GameSceneClient = GameUISceneClient(SceneClient);
	if( GameSceneClient != None )
	{
		GameSceneClient.RequestCursorRenderUpdate();
	}
}

/* == Unrealscript == */

/**
 * Default handler for the OnCreateScene delegate
 */
function SceneCreated( UIScene CreatedScene );

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	if( bCloseOnLevelChange && SceneClient != None )
	{
		CloseScene( Self, true, true );
	}
}

/**
 * Notification that the player's connection to the platform's online service is changed.
 */
function NotifyOnlineServiceStatusChanged( EOnlineServerConnectionStatus NewConnectionStatus )
{
	local UIScene ParentScene;

	ParentScene = GetPreviousScene(false);
	if ( NewConnectionStatus != OSCS_Connected && bRequiresOnlineService )
	{
		//@todo - should we always force the scene closed without allowing it to perform closing animations?
		// seems like we'd only want to do this if the this is not the last scene being closed.  but then again,
		// we will usually be displaying a message box or something to notify the user that the network status changed
		// so perhaps it's best to skip all animations
		CloseScene( Self, true, /*ParentScene == None || !ParentScene.bRequiresOnlineService*/true );
	}

	// propagate to the scene below this one
	if ( ParentScene != None )
	{
		ParentScene.NotifyOnlineServiceStatusChanged(NewConnectionStatus);
	}
}

/**
 * Called when the status of the platform's network connection changes.
 */
function NotifyLinkStatusChanged( bool bConnected )
{
	local UIScene ParentScene;

	ParentScene = GetPreviousScene(false);
	if ( !bConnected && bRequiresNetwork )
	{
		//@todo - should we always force the scene closed without allowing it to perform closing animations?
		// seems like we'd only want to do this if the this is not the last scene being closed.  but then again,
		// we will usually be displaying a message box or something to notify the user that the network status changed
		// so perhaps it's best to skip all animations
		CloseScene( Self, true, /*ParentScene == None || !ParentScene.bRequiresNetwork*/true );
	}

	// propagate to the scene below this one
	if ( ParentScene != None )
	{
		ParentScene.NotifyLinkStatusChanged(bConnected);
	}
}

/**
 * Opens a UI Scene given a reference to a scene to open.
 *
 * @param	SceneToOpen		Scene that we want to open.
 * @param	bSkipAnimation	specify TRUE to indicate that opening animations should be bypassed.
 * @param	SceneDelegate	if specified, will be called when the scene has finished opening.
 */
function UIScene OpenScene(UIScene SceneToOpen, optional bool bSkipAnimation=false, optional delegate<OnSceneActivated> SceneDelegate=None)
{
	local GameUISceneClient GameSceneClient;
	local UIScene OpenedScene;

	if ( SceneToOpen != None )
	{
		GameSceneClient = GetSceneClient();
		if ( GameSceneClient != None )
		{
			GameSceneClient.InitializeScene(SceneToOpen, GetPlayerOwner(), OpenedScene);
			if ( OpenedScene != None )
			{
				if ( SceneDelegate != None )
				{
					OpenedScene.OnSceneActivated = SceneDelegate;
				}

				GameSceneClient.OpenScene(OpenedScene, GetPlayerOwner(), OpenedScene);
			}
		}
	}

	return OpenedScene;
}

/**
 * Closes the specified scene.
 *
 * @param SceneToClose			Scene that we want to close.
 * @param bSkipKismetNotify		Whether or not to close the kismet notify for the scene.
 * @param bSkipAnimation		Whether or not to skip the close animation for this scene.
 */
function bool CloseScene ( UIScene SceneToClose, optional bool bSkipKismetNotify, optional bool bSkipAnimation )
{
	local bool bResult;

	if ( SceneClient != None && SceneToClose != None )
	{
		bResult = SceneClient.CloseScene(SceneToClose);
	}

	return bResult;
}

/* === Debug === */
event LogDockingStack()
{
`if(`notdefined(FINAL_RELEASE))
	local int i;
	local string Line;

	`log("");
	`log("Docking stack for '" $ SceneTag $ "'");
	for ( i = 0; i < DockingStack.Length; i++ )
	{
		Line = "	" $ i $ ")  Widget:" $ DockingStack[i].Widget.Name @ "Face:" $ GetEnum(enum'EUIWidgetFace', DockingStack[i].Face);
		if ( DockingStack[i].Widget.DockTargets.TargetWidget[DockingStack[i].Face] != None )
		{
			Line @= "TargetWidget:" $ DockingStack[i].Widget.DockTargets.TargetWidget[DockingStack[i].Face].Name;
			Line @= "TargetFace:" $ GetEnum(enum'EUIWidgetFace', DockingStack[i].Widget.DockTargets.TargetFace[DockingStack[i].Face]);
		}

		`log(Line);
	}
	`log("");
`endif
}

function LogRenderBounds( int Indent )
{
	local int i;

	`log("");
	`log("Render bounds for '" $ SceneTag $ "'" @ "(" $ Position.Value[0] $ "," $ Position.Value[1] $ "," $ Position.Value[2] $ "," $ Position.Value[3] $ ")");
	for ( i = 0; i < Children.Length; i++ )
	{
		Children[i].LogRenderBounds(3);
	}
}

function LogCurrentState( int Indent )
{
`if(`notdefined(FINAL_RELEASE))
	local int i;
	local UIState CurrentState;

	`log("");
	CurrentState = GetCurrentState();
	`log("Menu state for scene '" $ Name $ "':" @ CurrentState.Name);
	for ( i = 0; i < Children.Length; i++ )
	{
		Children[i].LogCurrentState(3);
	}
`endif
}


// ===============================================
// ANIMATIONS
// ===============================================

function AnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq);


DefaultProperties
{
	bUpdateDockingStack=true
	bUpdateScenePositions=true
	bUpdateNavigationLinks=true
	bUpdatePrimitiveUsage=true
	bCloseOnLevelChange=true
	bSaveSceneValuesOnClose=true
	bFlushPlayerInput=true

	DefaultToolTipClass=class'Engine.UIToolTip'
	DefaultContextMenuClass=class'Engine.UIContextMenu'

	bDisplayCursor=true
	bPauseGameWhileActive=true
	SceneInputMode=INPUTMODE_Locked
	SceneRenderMode=SPLITRENDER_PlayerOwner
	LastPlayerIndex=INDEX_NONE

	// defaults to 4:3
	CurrentViewportSize=(X=1024.f,Y=768.f)

	SceneOpenedCue=SceneOpened
	SceneClosedCue=SceneClosed

	DefaultStates.Add(class'UIState_Focused')
	DefaultStates.Add(class'UIState_Active')

	// Events
	Begin Object Class=UIEvent_Initialized Name=SceneInitializedEvent
		OutputLinks(0)=(LinkDesc="Output")
		ObjClassVersion=4
	End Object
	Begin Object Class=UIEvent_SceneActivated Name=SceneActivatedEvent
		ObjClassVersion=5
		OutputLinks(0)=(LinkDesc="Output")
	End Object
	Begin Object Class=UIEvent_SceneDeactivated Name=SceneDeactivatedEvent
		ObjClassVersion=5
		OutputLinks(0)=(LinkDesc="Output")
	End Object
	Begin Object Class=UIEvent_OnEnterState Name=EnteredStateEvent
	End Object
	Begin Object Class=UIEvent_OnLeaveState Name=LeftStateEvent
	End Object


	Begin Object Class=UIComp_Event Name=SceneEventComponent
		DefaultEvents.Add((EventTemplate=SceneInitializedEvent))
		DefaultEvents.Add((EventTemplate=SceneActivatedEvent))
		DefaultEvents.Add((EventTemplate=SceneDeactivatedEvent))
		DefaultEvents.Add((EventTemplate=EnteredStateEvent))
		DefaultEvents.Add((EventTemplate=LeftStateEvent))
	End Object

	EventProvider=SceneEventComponent
}
