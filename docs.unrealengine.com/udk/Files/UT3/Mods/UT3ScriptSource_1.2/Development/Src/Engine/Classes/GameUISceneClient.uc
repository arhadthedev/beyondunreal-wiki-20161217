/**
 * UISceneClient used when playing a game.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class GameUISceneClient extends UISceneClient
	within UIInteraction
	native(UIPrivate)
	config(UI);

`include(Core/Globals.uci)

/**
 * the list of scenes currently open.  A scene corresponds to a top-level UI construct, such as a menu or HUD
 * There is always at least one scene in the stack - the transient scene.  The transient scene is used as the
 * container for all widgets created by unrealscript and is always rendered last.
 */
var	const	transient 							array<UIScene>		ActiveScenes;

/**
 * The mouse cursor that is currently being used.  Updated by scenes & widgets as they change states by calling ChangeMouseCursor.
 */
var	const	transient							UITexture			CurrentMouseCursor;

/**
 * Determines whether the cursor should be rendered.  Set by UpdateMouseCursor()
 */
var	const	transient							bool				bRenderCursor;

/** Cached DeltaTime value from the last Tick() call */
var	const	transient							float				LatestDeltaTime;

/** The time (in seconds) that the last "key down" event was recieved from a key that can trigger double-click events */
var	const	transient							double				DoubleClickStartTime;

/**
 * The location of the mouse the last time a key press was received.  Used to determine when to simulate a double-click
 * event.
 */
var const	transient							IntPoint			DoubleClickStartPosition;

/** Textures for general use by the UI */
var	const	transient							Texture				DefaultUITexture[EUIDefaultPenColor];

/**
 * map of controllerID to list of keys which were pressed when the UI began processing input
 * used to ignore the initial "release" key event from keys which were already pressed when the UI began processing input.
 */
var	const	transient	native					Map_Mirror			InitialPressedKeys{TMap<INT,TArray<FName> >};

/**
 * Indicates that the input processing status of the UI has potentially changed; causes UpdateInputProcessingStatus to be called
 * in the next Tick().
 */
var	const	transient							bool				bUpdateInputProcessingStatus;

/**
* Indicates that the input processing status of the UI has potentially changed; causes UpdateCursorRenderStatus to be called
* in the next Tick().
*/
var const	transient							bool				bUpdateCursorRenderStatus;

/** Controls whether debug input commands are accepted */
var			config								bool				bEnableDebugInput;
/** Controls whether debug information about the scene is rendered */
var			config								bool				bRenderDebugInfo;
/** Controls whether debug information is rendered at the top or bottom of the screen */
var	globalconfig								bool				bRenderDebugInfoAtTop;
/** Controls whether debug information is rendered about the active control */
var	globalconfig								bool				bRenderActiveControlInfo;
/** Controls whether debug information is rendered about the currently focused control */
var	globalconfig								bool				bRenderFocusedControlInfo;
/** Controls whether debug information is rendered about the targeted control */
var	globalconfig								bool				bRenderTargetControlInfo;
/** Controls whether a widget must be visible to become the debug target */
var	globalconfig								bool				bSelectVisibleTargetsOnly;
var	globalconfig								bool				bInteractiveMode;
var	globalconfig								bool				bDisplayFullPaths;
var	globalconfig								bool				bShowWidgetPath;
var	globalconfig								bool				bShowRenderBounds;
var	globalconfig								bool				bShowCurrentState;
var	globalconfig								bool				bShowMousePos;

/**
 * A multiplier value (between 0.0 and 1.f) used for adjusting the transparency of scenes rendered behind scenes which have
 * bRenderParentScenes set to TRUE.  The final alpha used for rendering background scenes is cumulative.
 */
var	config										float				OverlaySceneAlphaModulation;

/**
 * Controls whether a widget can become the scene client's ActiveControl if it isn't in the top-most/focused scene.
 * False allows widgets in background scenes to become the active control.
 */
var	config										bool				bRestrictActiveControlToFocusedScene;

/**
 * For debugging - the widget that is currently being watched.
 */
var	const	transient							UIScreenObject		DebugTarget;

/** Holds a list of all available animations for an object */
var transient array<UIAnimationSeq> AnimSequencePool;

/** Holds a list of UIObjects that have animations being applied to them */
var transient array<UIObject> AnimSubscribers;

/** Will halt the restoring of the menu progression */
var transient bool bKillRestoreMenuProgression;



/* == Delegates == */

/* == Natives == */
/**
 * @return	the current netmode, or NM_MAX if there is no valid world
 */
native static final function WorldInfo.ENetMode GetCurrentNetMode();

/**
 * Get a reference to the transient scene, which is used to contain transient widgets that are created by unrealscript
 *
 * @return	pointer to the UIScene that owns transient widgets
 */
native final function UIScene GetTransientScene() const;

/**
 * Creates an instance of the scene class specified.  Used to create scenes from unrealscript.  Does not initialize
 * the scene - you must call OpenScene, passing in the result of this function as the scene to be opened.
 *
 * @param	SceneClass		the scene class to open
 * @param	SceneTag		if specified, the scene will be given this tag when created
 * @param	SceneTemplate	if specified, will be used as the template for the newly created scene if it is a subclass of SceneClass
 *
 * @return	a UIScene instance of the class specified
 */
native final noexport function coerce UIScene CreateScene( class<UIScene> SceneClass, optional name SceneTag, optional UIScene SceneTemplate );

/**
 * Create a temporary widget for presenting data from unrealscript
 *
 * @param	WidgetClass		the widget class to create
 * @param	WidgetTag		the tag to assign to the widget.
 * @param	Owner			the UIObject that should contain the widget
 *
 * @return	a pointer to a fully initialized widget of the class specified, contained within the transient scene
 * @todo - add support for metacasting using a property flag (i.e. like spawn auto-casts the result to the appropriate type)
 */
native final function coerce UIObject CreateTransientWidget( class<UIObject> WidgetClass, Name WidgetTag, optional UIObject Owner );

/**
 * Searches through the ActiveScenes array for a UIScene with the tag specified
 *
 * @param	SceneTag	the name of the scene to locate
 * @param	SceneOwner	if specified, only scenes that have the specified SceneOwner will be considered.
 *
 * @return	pointer to the UIScene that has a SceneName matching SceneTag, or NULL if no scenes in the ActiveScenes
 *			stack have that name
 */
native final function UIScene FindSceneByTag( name SceneTag, optional LocalPlayer SceneOwner ) const;

/**
 * Triggers a call to UpdateInputProcessingStatus on the next Tick().
 */
native final function RequestInputProcessingUpdate();

/**
 * Triggers a call to UpdateCursorRenderStatus on the next Tick().
 */
native final function RequestCursorRenderUpdate();

/**
 * Callback which allows the UI to prevent unpausing if scenes which require pausing are still active.
 * @see PlayerController.SetPause
 */
native final function bool CanUnpauseInternalUI();

/**
 * Changes this scene client's ActiveControl to the specified value, which might be NULL.  If there is already an ActiveControl
 *
 * @param	NewActiveControl	the widget that should become to ActiveControl, or NULL to clear the ActiveControl.
 *
 * @return	TRUE if the ActiveControl was updated successfully.
 */
native function bool SetActiveControl( UIObject NewActiveControl );

/* == Events == */

/**
 * Toggles the game's paused state if it does not match the desired pause state.
 *
 * @param	bDesiredPauseState	TRUE indicates that the game should be paused.
 */
event ConditionalPause( bool bDesiredPauseState )
{
	local PlayerController PlayerOwner;

	if ( GamePlayers.Length > 0 )
	{
		PlayerOwner = GamePlayers[0].Actor;
		if ( PlayerOwner != None )
		{
			if ( bDesiredPauseState != PlayerOwner.IsPaused() )
			{
				PlayerOwner.SetPause(bDesiredPauseState, CanUnpauseInternalUI);
			}
		}
	}
}

/**
 * Returns whether widget tooltips should be displayed.
 */
event bool CanShowToolTips()
{
	// if tooltips are disabled globally, can't show them
	if ( bDisableToolTips )
		return false;

	// the we're currently dragging a slider or resizing a list column or something, don't display tooltips
//	if ( ActivePage != None && ActivePage.bCaptureMouse )
//		return false;
//
	// if we're currently in the middle of a drag-n-drop operation, don't show tooltips
//	if ( DropSource != None || DropTarget != None )
//		return false;

	return true;
}

/* == Unrealscript == */

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	local int i;
	local array<UIScene> CurrentlyActiveScenes;

	// bPendingLevelChange = true;
	SaveMenuProgression();

	// copy the list of active scenes into a temporary array in case scenes start removing themselves when
	// they receive this notification
	CurrentlyActiveScenes = ActiveScenes;

	// starting with the most recently opened scene (or the top-most, anyway), notify them all that the
	// map is about to change
	for ( i = CurrentlyActiveScenes.Length - 1; i >= 0; i-- )
	{
		if ( CurrentlyActiveScenes[i] != None )
		{
			CurrentlyActiveScenes[i].NotifyGameSessionEnded();
		}
		else
		{
			CurrentlyActiveScenes.Remove(i,1);
		}
	}

	// if any scenes are still open (usually due to not calling Super.NotifyGameSessionEnded()) try to close them again
	for ( i = CurrentlyActiveScenes.Length - 1; i >= 0; i-- )
	{
		if ( CurrentlyActiveScenes[i].bCloseOnLevelChange )
		{
			CurrentlyActiveScenes[i].CloseScene(CurrentlyActiveScenes[i], true, true);
		}
	}
}


/**
 * Called when a system level connection change notification occurs.
 *
 * @param ConnectionStatus the new connection status.
 */
function NotifyOnlineServiceStatusChanged( EOnlineServerConnectionStatus NewConnectionStatus )
{
	local UIScene Scene;

	Scene = GetActiveScene();
	if ( Scene != None )
	{
		Scene.NotifyOnlineServiceStatusChanged(NewConnectionStatus);
	}
}

/**
 * Called when the status of the platform's network connection changes.
 */
function NotifyLinkStatusChanged( bool bConnected )
{
	local UIScene Scene;

	Scene = GetActiveScene();
	if ( Scene != None )
	{
		Scene.NotifyLinkStatusChanged(bConnected);
	}
}

/**
 * Called when a new player has been added to the list of active players (i.e. split-screen join)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
 * @param	AddedPlayer		the player that was added
 */
function NotifyPlayerAdded( int PlayerIndex, LocalPlayer AddedPlayer )
{
	local int SceneIndex;

	// notify all currently active scenes about the new player
	for ( SceneIndex = 0; SceneIndex < ActiveScenes.Length; SceneIndex++ )
	{
		ActiveScenes[SceneIndex].CreatePlayerData(PlayerIndex, AddedPlayer);
	}
}

/**
 * Called when a player has been removed from the list of active players (i.e. split-screen players)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was located
 * @param	RemovedPlayer	the player that was removed
 */
function NotifyPlayerRemoved( int PlayerIndex, LocalPlayer RemovedPlayer )
{
	local int SceneIndex;

	// notify all currently active scenes about the player removal
	for ( SceneIndex = 0; SceneIndex < ActiveScenes.Length; SceneIndex++ )
	{
		ActiveScenes[SceneIndex].RemovePlayerData(PlayerIndex, RemovedPlayer);
	}
}

/**
 * Returns the currently active scene
 */
function UIScene GetActiveScene()
{
	local UIScene TopmostScene;

	if (ActiveScenes.Length > 0)
	{
		TopmostScene = ActiveScenes[ActiveScenes.Length-1];
	}

	return TopmostScene;
}

/**
 * Stores the list of currently active scenes which are restorable to the Registry data store for retrieval when
 * returning back to the front end menus.
 */
function SaveMenuProgression()
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;
	local int i;
	local UIScene SceneResource, CurrentScene, NextScene;
	local string ScenePathName;

	// can only restore menu progression in the front-end
	if ( class'UIInteraction'.static.IsMenuLevel() )
	{
		DSClient = class'UIInteraction'.static.GetDataStoreClient();
		if ( DSClient != None )
		{
			RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
			if ( RegistryDS != None )
			{
				RegistryProvider = RegistryDS.GetDataProvider();
				if ( RegistryProvider != None )
				{
					// clear out any existing values.
					RegistryProvider.ClearCollectionValueArray('MenuProgression');

					`log("Storing menu progression (" $ ActiveScenes.Length @ "open scenes)",,'DevUI');
					for ( i = 0; i < ActiveScenes.Length - 1; i++ )
					{
						// for each open scene, check to see if the next scene in the stack is configured to be restored
						//@todo - this assumes that the scene stack is completely linear; this code may need to be altered
						// if your game doesn't have a linear scene progression.
						CurrentScene = ActiveScenes[i];
						NextScene = ActiveScenes[i + 1];

						if ( CurrentScene != None && NextScene != None && CurrentScene != NextScene )
						{
							// for each scene, we use the scene's tag as the "key" or CellTag in the Registry's 'MenuProgression'
							// collection array.  if the next scene in the stack can be restored, store the path name of its
							// archetype as the value for this scene's entry in the menu progression.  Basically we just want to
							// remember which scene should be opened next when this scene is opened.
							if ( NextScene.bMenuLevelRestoresScene )
							{
								SceneResource = UIScene(NextScene.ObjectArchetype);
								if ( SceneResource != None )
								{
									ScenePathName = PathName(SceneResource);
									if ( RegistryProvider.InsertCollectionValue(
										'MenuProgression', ScenePathName, INDEX_NONE, false, false, CurrentScene.SceneTag) )
									{
										`log("Storing" @ ScenePathName @ "as next menu in progression for" @ CurrentScene.SceneTag,,'DevUI');

										//@todo - call a function in NextScene to notify it that it has been placed in the list of
										// scenes that will be restored.  This allows the scene to store additional information,
										// such as the currently active tab page [for scenes which have tab controls].
									}
									else
									{
										`warn("Failed to store scene '" $ ScenePathName $ "' menu progression in Registry");
										break;
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

/**
 * Clears out any existing stored menu progression values.
 */
function ClearMenuProgression()
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;

	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
		if ( RegistryDS != None )
		{
			RegistryProvider = RegistryDS.GetDataProvider();
			if ( RegistryProvider != None )
			{
				// clear out the stored menu progression
				RegistryProvider.ClearCollectionValueArray('MenuProgression');
			}
		}
	}
}

/**
 * Re-opens the scenes which were saved off to the Registry data store.  Should be called from your game's main front-end
 * menu.
 *
 * @param	BaseScene	the scene to use as the starting point for restoring scenes; if not specified, uses the currently
 *						active scene.
 */
function RestoreMenuProgression( optional UIScene BaseScene )
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;
	local UIScene CurrentScene, NextSceneTemplate, SceneInstance;
	local string ScenePathName;
	local bool bHasValidNetworkConnection;

	bKillRestoreMenuProgression = false;

	// can only restore menu progression in the front-end
	if ( class'UIInteraction'.static.IsMenuLevel() )
	{
		// if no BaseScene was specified, use the currently active scene.
		if ( BaseScene == None && IsUIActive() )
		{
			BaseScene = ActiveScenes[ActiveScenes.Length - 1];
		}

		if ( BaseScene != None )
		{
			DSClient = class'UIInteraction'.static.GetDataStoreClient();
			if ( DSClient != None )
			{
				RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
				if ( RegistryDS != None )
				{
					RegistryProvider = RegistryDS.GetDataProvider();
					if ( RegistryProvider != None )
					{
						`log("Restoring menu progression from '" $ PathName(BaseScene) $ "'",,'DevUI');
						bHasValidNetworkConnection = class'UIInteraction'.static.HasLinkConnection();

						CurrentScene = BaseScene;
						while ( CurrentScene != None && !bKillRestoreMenuProgression )
						{
							ScenePathName = "";

							// get the path name of the scene that should come after CurrentScene
							if ( RegistryProvider.GetCollectionValue('MenuProgression', 0, ScenePathName, false, CurrentScene.SceneTag) )
							{
								if ( ScenePathName != "" )
								{
									// found it - open the scene.
									NextSceneTemplate = UIScene(DynamicLoadObject(ScenePathName, class'UIScene'));
									if ( NextSceneTemplate != None )
									{
										// if this scene requires a network connection and we don't have one,
										if ( NextSceneTemplate.bRequiresNetwork && !bHasValidNetworkConnection )
										{
											break;
										}

										SceneInstance = CurrentScene.OpenScene(NextSceneTemplate, true);
										if ( SceneInstance != None )
										{
											CurrentScene = SceneInstance;

											//@todo - notify the scene that it has been restored.  This allows the scene to perform
											// additional custom initialization, such as activating a specific page in a tab control, for example.
										}
										else
										{
											`warn("Failed to restore scene '" $ PathName(NextSceneTemplate) $ "': call to OpenScene failed.");
											break;
										}
									}
									else
									{
										`warn("Failed to restore scene '" $ ScenePathName $ "' by name: call to DynamicLoadObject() failed.");
										break;
									}
								}
								else
								{
									`log(`location@"'MenuProgression' value was empty for '" $ PathName(CurrentScene) $ "'",,'DevUI');
									break;
								}
							}
							else
							{
								`log(`location@"No 'MenuProgression' found in the Registry data store for '" $ CurrentScene.SceneTag $ "'",,'DevUI');
								break;
							}
						}

						// clear out the stored menu progression
						RegistryProvider.ClearCollectionValueArray('MenuProgression');
					}
				}
			}
		}
	}
}

exec function ShowDockingStacks()
{
	local int i;

	for ( i = 0; i < ActiveScenes.Length; i++ )
	{
		ActiveScenes[i].LogDockingStack();
	}
}

exec function ShowRenderBounds()
{
	local int i;

	for ( i = 0; i < ActiveScenes.Length; i++ )
	{
		ActiveScenes[i].LogRenderBounds(0);
	}
}

exec function ShowMenuStates()
{
	local int i;

	for ( i = 0; i < ActiveScenes.Length; i++ )
	{
		ActiveScenes[i].LogCurrentState(0);
	}
}

exec function ToggleDebugInput( optional bool bEnable=!bEnableDebugInput )
{
	bEnableDebugInput = bEnable;
	`log( (bEnableDebugInput ? "Enabling" : "Disabling") @ "debug input processing");
}

`if(`notdefined(ShippingPC))
exec function CreateMenu( class<UIScene> SceneClass, optional int PlayerIndex=INDEX_NONE )
{
	local UIScene Scene;
	local LocalPlayer SceneOwner;

	`log("Attempting to create script menu '" $ SceneClass $"'");

	Scene = CreateScene(SceneClass);
	if ( Scene != None )
	{
		if ( PlayerIndex != INDEX_NONE )
		{
			SceneOwner = GamePlayers[PlayerIndex];
		}

		OpenScene(Scene, SceneOwner);
	}
	else
	{
		`log("Failed to create menu '" $ SceneClass $"'");
	}
}

exec function OpenMenu( string MenuPath, optional int PlayerIndex=INDEX_NONE )
{
	local UIScene Scene;
	local LocalPlayer SceneOwner;

	`log("Attempting to load menu by name '" $ MenuPath $"'");
	Scene = UIScene(DynamicLoadObject(MenuPath, class'UIScene'));
	if ( Scene != None )
	{
		if ( PlayerIndex != INDEX_NONE )
		{
			SceneOwner = GamePlayers[PlayerIndex];
		}

		OpenScene(Scene,SceneOwner);
	}
	else
	{
		`log("Failed to load menu '" $ MenuPath $"'");
	}
}

exec function CloseMenu( name SceneName )
{
	local int i;
	for ( i = 0; i < ActiveScenes.Length; i++ )
	{
		if ( ActiveScenes[i].SceneTag == SceneName )
		{
			`log("Closing scene '"$ ActiveScenes[i].GetWidgetPathName() $ "'");
			CloseScene(ActiveScenes[i]);
			return;
		}
	}

	`log("No scenes found in ActiveScenes array with name matching '"$SceneName$"'");
}

exec function ShowDataStoreField( string DataStoreMarkup )
{
	local string Value;

	if ( class'UIRoot'.static.GetDataStoreStringValue(DataStoreMarkup, Value) )
	{
		`log("Successfully retrieved value for markup string (" $ DataStoreMarkup $ "): '" $ Value $ "'");
	}
	else
	{
		`log("Failed to resolve value for data store markup (" $ DataStoreMarkup $ ")");
	}
}

exec function RefreshFormatting()
{
	local UIScene ActiveScene;

	ActiveScene = GetActiveScene();
	if ( ActiveScene != None )
	{
		`log("Forcing a formatting update and scene refresh for" @ ActiveScene);
		ActiveScene.RequestFormattingUpdate();
	}
}

/**
 * Debug console command for dumping all registered data stores to the log
 *
 * @param	bFullDump	specify TRUE to show detailed information about each registered data store.
 */
exec function ShowDataStores( optional bool bVerbose )
{
	`log("Dumping data store info to log - if you don't see any results, you probably need to unsuppress DevDataStore");

	if ( DataStoreManager != None )
	{
		DataStoreManager.DebugDumpDataStoreInfo(bVerbose);
	}
	else
	{
		`log(Self @ "has a NULL DataStoreManager!",,'DevDataStore');
	}
}
`endif

exec function ShowMenuProgression()
{
	local DataStoreClient DSClient;
	local UIDataStore_Registry RegistryDS;
	local UIDynamicFieldProvider RegistryProvider;
	local array<string> Values;
	local array<name> SceneTags;
	local int SceneIndex, MenuIndex;

	`log("Current stored menu progression:");
	DSClient = class'UIInteraction'.static.GetDataStoreClient();
	if ( DSClient != None )
	{
		RegistryDS = UIDataStore_Registry(DSClient.FindDataStore('Registry'));
		if ( RegistryDS != None )
		{
			RegistryProvider = RegistryDS.GetDataProvider();
			if ( RegistryProvider != None )
			{
				if ( RegistryProvider.GetCollectionValueSchema('MenuProgression', SceneTags) )
				{
					for ( SceneIndex = 0; SceneIndex < SceneTags.Length; SceneIndex++ )
					{
						if ( RegistryProvider.GetCollectionValueArray('MenuProgression', Values, false, SceneTags[SceneIndex]) )
						{
							for ( MenuIndex = 0; MenuIndex < Values.Length; MenuIndex++ )
							{
								`log("    Scene:" @ SceneTags[SceneIndex] @ "Menu" @ MenuIndex $ ":" @ Values[MenuIndex]);
							}
						}
						else
						{
							`log("No menu progression data found for scene" @ SceneIndex $ ":" @ SceneTags[SceneIndex]);
						}
					}
				}
				else
				{
					`log("No menu progression data found in the Registry data store");
				}
			}
		}
	}
}

// ===============================================
// ANIMATIONS
// ===============================================


/**
 * Subscribes a UIObject so that it will receive TickAnim calls
 */
function AnimSubscribe(UIObject Target)
{
	local int i;
	i = AnimSubscribers.Find(Target);
	if (i == INDEX_None )
	{
		`log(">>> Subscribing"@ PathName(Target) @ "at index" @ AnimSubscribers.Length - 1 @ "(" $ AnimSubscribers.Length $ ")",,'DevUIAnimation');
		AnimSubscribers[AnimSubscribers.Length] = Target;
	}
	else
	{
		`log(">>> Subscribing " $ PathName(Target) @ "failed because it was already in the stack at" @ i @ "(" $ AnimSubscribers.Length $ ")",,'DevUIAnimation');
	}
}

/**
 * UnSubscribe a UIObject so that it will receive TickAnim calls
 */
function AnimUnSubscribe(UIObject Target)
{
	local int i;
	i = AnimSubscribers.Find(Target);
	if (i != INDEX_None )
	{
		`log("<<< UnSubscribing"@ PathName(Target) @ "from position" @ i @ "(" $ AnimSubscribers.Length $ ")",,'DevUIAnimation');
		AnimSubscribers.Remove(i,1);
	}
	else
	{
		`log("<<< UnSubscribing" @ PathName(Target) @ "failed because it wasn't in the AnimSubscribers list" @ "(" $ AnimSubscribers.Length $ ")",,'DevUIAnimation');
	}
}

/**
 * Attempt to find an animation in the AnimSequencePool.
 *
 * @Param SequenceName		The sequence to find
 * @returns the sequence if it was found otherwise returns none
 */
function UIAnimationSeq AnimLookupSequence(name SequenceName)
{
	local int i;
	for (i=0;i<AnimSequencePool.Length;i++)
	{
		if ( AnimSequencePool[i].SeqName == SequenceName )
		{
			return AnimSequencePool[i];
		}
	}
	return none;
}

DefaultProperties
{
	DefaultUITexture(UIPEN_White)=Texture2D'EngineResources.White'
	DefaultUITexture(UIPEN_Black)=Texture2D'EngineResources.Black'
	DefaultUITexture(UIPEN_Grey)=Texture2D'EngineResources.Gray'
}
