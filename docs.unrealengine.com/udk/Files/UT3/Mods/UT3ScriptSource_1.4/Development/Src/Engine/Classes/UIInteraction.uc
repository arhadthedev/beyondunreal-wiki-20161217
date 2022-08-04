/**
 * Controls the UI system.
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIInteraction extends Interaction
	within GameViewportClient
	native(UserInterface)
	config(UI)
	transient
	inherits(FExec,FGlobalDataStoreClientManager);

/** the default UISkin - used whenever the skin specified by UISkinName couldn't be loaded */
const DEFAULT_UISKIN = "DefaultUISkin.DefaultSkin";

/** the class to use for the scene client */
var											class<GameUISceneClient>				SceneClientClass;

/**
 * Acts as the interface between the UIInteraction and the active scenes.
 */
var const transient							GameUISceneClient						SceneClient;

/**
 * The path name for the UISkin that should be used
 */
var	config									string									UISkinName;

/**
 * The names of all UISoundCues that can be used in the game.
 */
var	config									array<name>								UISoundCueNames;

/** list of keys that can trigger double-click events */
var	transient								array<name>								SupportedDoubleClickKeys;

/**
 * Manages all persistent global data stores.  Created when UIInteraction is initialized using the value of
 * GEngine.DataStoreClientClass.
 */
var	const transient							DataStoreClient							DataStoreManager;

/**
 * Singleton object which stores ui key mapping configuration data.
 */
var	const transient	public{private}			UIInputConfiguration					UIInputConfig;

/**
 * Runtime generated lookup table that maps a widget class to its list of input key aliases
 */
var const native transient			Map{UClass*,struct FUIInputAliasClassMap*}		WidgetInputAliasLookupTable;

/**
 * Indicates whether there are any active scenes capable of processing input.  Set in UpdateInputProcessingStatus, based
 * on whether there are any active scenes which are capable of processing input.
 */
var	const	transient						bool									bProcessInput;

/**
 * Globally enables/ disables widget tooltips.
 */
var	const	config							bool									bDisableToolTips;

/**
 * Controls whether widgets automatically receive focus when they become active.  Set TRUE to enable this behavior.
 */
var	const	config							bool									bFocusOnActive;

/**
 * Controls whether the UI system should prevent the game from recieving input whenever it's active.  For games with
 * interactive menus that remain on-screen during gameplay, you'll want to change this value to FALSE.
 */
var	const	config							bool									bCaptureUnprocessedInput;

/**
 * The amount of movement required before the UI will process a joystick's axis input.
 */
var	const	config							float									UIJoystickDeadZone;

/**
 * Mouse & joystick axis input will be multiplied by this amount in the UI system.  Higher values make the cursor move faster.
 */
var	const	config							float									UIAxisMultiplier;

/**
 * The amount of time (in seconds) to wait between generating simulated button presses from axis input.
 */
var	const	config							float									AxisRepeatDelay;

/**
 * The amount of time (in seconds) to wait between generating repeat events for mouse buttons (which are not handled by windows).
 */
var	const	config							float									MouseButtonRepeatDelay;

/**
 * The maximum amount of time (in seconds) that can pass between a key press and key release in order to trigger a double-click event
 */
var	const	config							float									DoubleClickTriggerSeconds;

/**
 * The maximum number of pixels to allow between the current mouse position and the last click's mouse position for a double-click
 * event to be triggered
 */
var	const	config							int										DoubleClickPixelTolerance;

/** determines how many seconds must pass after a tooltip has been activated before it is made visible */
var	const	config							float									ToolTipInitialDelaySeconds;

/** determines the number of seconds to display a tooltip before it will automatically be hidden */
var	const	config							float									ToolTipExpirationSeconds;

/** if this is TRUE, then focused widgets will not appear to become "active" when moused over - their appearance will remain "focused" */
var	const	config							bool									bFocusedStateRules;

/**
 * Tracks information relevant to simulating IE_Repeat input events.
 */
struct native transient UIKeyRepeatData
{
	/**
	 * The name of the axis input key that is currently being held.  Used to determine which type of input event
	 * to simulate (i.e. IE_Pressed, IE_Released, IE_Repeat)
	 */
	var	name	CurrentRepeatKey;

	/**
	 * The time (in seconds since the process started) when the next simulated input event will be generated.
	 */
	var	double	NextRepeatTime;


};

/**
 * Contains parameters for emulating button presses using axis input.
 */
struct native transient UIAxisEmulationData extends UIKeyRepeatData
{
	/**
	 * Determines whether to emulate button presses.
	 */
	var	bool	bEnabled;


};

/**
 * Tracks the mouse button that is currently being held down for simulating repeat input events.
 */
var	const			transient		UIKeyRepeatData									MouseButtonRepeatInfo;

/**
 * Runtime mapping of the axis button-press emulation configurations.  Built in UIInteraction::InitializeAxisInputEmulations() based
 * on the values retrieved from UIInputConfiguration.
 */
var	const	native	transient		Map{FName,struct FUIAxisEmulationDefinition}	AxisEmulationDefinitions;

/**
 * Tracks the axis key-press emulation data for all players in the game.
 */
var					transient		UIAxisEmulationData								AxisInputEmulation[MAX_SUPPORTED_GAMEPADS];

/** canvas scene for rendering 3d primtives/lights. Created during Init */
var const	native 	transient		pointer											CanvasScene{class FCanvasScene};

/** TRUE if the scene for rendering 3d prims on this UI has been initialized */
var const 			transient 		bool											bIsUIPrimitiveSceneInitialized;



/**
 * Returns the number of players currently active.
 */
static native noexport final function int GetPlayerCount() const;

/**
 * Retrieves the index (into the Engine.GamePlayers array) for the player which has the ControllerId specified
 *
 * @param	ControllerId	the gamepad index of the player to search for
 *
 * @return	the index [into the Engine.GamePlayers array] for the player that has the ControllerId specified, or INDEX_NONE
 *			if no players have that ControllerId
 */
static native noexport final function int GetPlayerIndex( int ControllerId );

/**
 * Retrieves the ControllerId for the player specified.
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player to retrieve the ControllerId for
 *
 * @return	the ControllerId for the player at the specified index in the GamePlayers array, or INDEX_NONE if the index is invalid
 */
static native noexport final function int GetPlayerControllerId( int PlayerIndex );

/**
 * Returns a reference to the global data store client, if it exists.
 *
 * @return	the global data store client for the game.
 */
static native noexport final function DataStoreClient GetDataStoreClient();

/**
 * Determines whether a map is the default local map.
 *
 * @param	MapName	if specified, checks whether MapName is the default local map; otherwise, checks the currently loaded map.
 *
 * @return	TRUE if the map is the default local (or front-end) map.
 */
static native noexport final function bool IsMenuLevel( optional string MapName );

/**
 * Plays the sound cue associated with the specified name
 *
 * @param	SoundCueName	the name of the UISoundCue to play; should corresond to one of the values of the UISoundCueNames array.
 * @param	PlayerIndex		allows the caller to indicate which player controller should be used to play the sound cue.  For the most
 *							part, all sounds can be played by the first player, regardless of who generated the play sound event.
 *
 * @return	TRUE if the sound cue specified was found in the currently active skin, even if there was no actual USoundCue associated
 *			with that UISoundCue.
 */
native final function bool PlayUISound( name SoundCueName, optional int PlayerIndex=0 );

/**
 * Called when a new player has been added to the list of active players (i.e. split-screen join)
 *
 * @param	PlayerIndex		the index [into the GamePlayers array] where the player was inserted
 * @param	AddedPlayer		the player that was added
 */
function NotifyPlayerAdded( int PlayerIndex, LocalPlayer AddedPlayer )
{
	local UIAxisEmulationData Empty;

	// make sure the axis emulation data for this player has been reset
	if ( PlayerIndex >=0 && PlayerIndex < MAX_SUPPORTED_GAMEPADS )
	{
		Empty.CurrentRepeatKey = 'None';
		AxisInputEmulation[PlayerIndex] = Empty;
	}

	if ( SceneClient != None )
	{
		SceneClient.NotifyPlayerAdded(PlayerIndex, AddedPlayer);
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
	local int PlayerCount, NextPlayerIndex, i;
	local UIAxisEmulationData Empty;


	// clear the axis emulation data for this player
	if ( PlayerIndex >=0 && PlayerIndex < MAX_SUPPORTED_GAMEPADS )
	{
		// if we removed a player from the middle of the list, we need to migrate all of the axis emulation data from
		// that player's previous slot into the new slot
		PlayerCount = GetPlayerCount();

		// PlayerCount has to be less that MAX_SUPPORTED_GAMEPADS if we just removed a player; if it does not, it means
		// that someone changed the order in which NotifyPlayerRemoved is called so that the player is actually removed from
		// the array after calling NotifyPlayerRemoved.  If that happens, this assertion is here to ensure that this code is
		// updated as well.
		Assert(PlayerCount < MAX_SUPPORTED_GAMEPADS);

		// we removed a player that was in a middle slot - migrate the data for all subsequence players into the correct position
		for ( i = PlayerIndex; i < PlayerCount; i++ )
		{
			NextPlayerIndex = i + 1;
			AxisInputEmulation[i].NextRepeatTime = AxisInputEmulation[NextPlayerIndex].NextRepeatTime;
			AxisInputEmulation[i].CurrentRepeatKey = AxisInputEmulation[NextPlayerIndex].CurrentRepeatKey;
			AxisInputEmulation[i].bEnabled = AxisInputEmulation[NextPlayerIndex].bEnabled;
		}

		Empty.CurrentRepeatKey = 'None';
		AxisInputEmulation[PlayerCount] = Empty;
	}

	if ( SceneClient != None )
	{
		SceneClient.NotifyPlayerRemoved(PlayerIndex, RemovedPlayer);
	}
}

/**
 * Create a temporary widget for presenting data from unrealscript
 *
 * @param	WidgetClass		the widget class to create
 * @param	WidgetTag		the tag to assign to the widget.
 * @param	Owner			the UIObject that should contain the widget
 *
 * @return	a pointer to a fully initialized widget of the class specified, contained within the transient scene
 */
native final function coerce UIObject CreateTransientWidget(class<UIObject> WidgetClass, Name WidgetTag, optional UIObject Owner);

/**
 * Set the mouse position to the coordinates specified
 *
 * @param	NewX	the X position to move the mouse cursor to (in pixels)
 * @param	NewY	the Y position to move the mouse cursor to (in pixels)
 */
final function SetMousePosition( int NewMouseX, int NewMouseY )
{
	SceneClient.SetMousePosition(NewMouseX, NewMouseY);
}

// Scene stuff
/**
 * Get a reference to the transient scene, which is used to contain transient widgets that are created by unrealscript
 *
 * @return	pointer to the UIScene that owns transient widgets
 */
final function UIScene GetTransientScene()
{
	return SceneClient.GetTransientScene();
}

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
native final function coerce UIScene CreateScene( class<UIScene> SceneClass, optional name SceneTag, optional UIScene SceneTemplate );

/**
 * Adds the specified scene to the list of active scenes, loading the scene and performing initialization as necessary.
 *
 * @param	Scene			the scene to open; if the scene specified is contained in a content package, a copy of the scene will be created
 *							and the copy will be opened instead.
 * @param	SceneOwner		the player that should be associated with the new scene.  Will be assigned to the scene's
 *							PlayerOwner property.
 * @param	OpenedScene		the scene that was actually opened.  If Scene is located in a content package, OpenedScene will be
 *							the copy of the scene that was created.  Otherwise, OpenedScene will be the same as the scene passed in.
 *
 * @return TRUE if the scene was successfully opened
 */
final function bool OpenScene( UIScene Scene, optional LocalPlayer SceneOwner, optional out UIScene OpenedScene )
{
	return SceneClient.OpenScene(Scene,SceneOwner,OpenedScene);
}

/**
 * Merge 2 existing scenes together in to one
 *
 *@param	SourceScene	The Scene to merge
 *@param	SceneTarget		This optional param is the scene to merge in to.  If it's none, the currently active scene will
 *							be used.
 *
 * RON: Fix me and remove the child version in UTGameInteraction
 */
function bool MergeScene(UIScene SourceScene, optional UIScene SceneTarget);

/**
 * Removes the specified scene from the ActiveScenes array.
 *
 * @param	Scene	the scene to deactivate
 *
 * @return true if the scene was successfully removed from the ActiveScenes array
 */
final final function bool CloseScene( UIScene Scene )
{
	return SceneClient.CloseScene(Scene);
}

/**
 * Searches through the ActiveScenes array for a UIScene with the tag specified
 *
 * @param	SceneTag	the name of the scene to locate
 * @param	SceneOwner	the player that should be associated with the new scene.  Will be assigned to the scene's
 *						PlayerOwner property.
 *
 * @return	pointer to the UIScene that has a SceneName matching SceneTag, or NULL if no scenes in the ActiveScenes
 *			stack have that name
 */
final final function UIScene FindSceneByTag( name SceneTag, optional LocalPlayer SceneOwner )
{
	return SceneClient.FindSceneByTag(SceneTag,SceneOwner);
}

/** @return Returns the current login status for the specified controller id. */
static final event ELoginStatus GetLoginStatus( int ControllerId )
{
	local ELoginStatus Result;
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Result = LS_NotLoggedIn;

	if ( ControllerId != INDEX_NONE )
	{
		// Figure out if we have an online subsystem registered
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			// Grab the player interface to verify the subsystem supports it
			PlayerInterface = OnlineSub.PlayerInterface;
			if (PlayerInterface != None)
			{
				// Get status
				Result = PlayerInterface.GetLoginStatus(ControllerId);
			}
		}
	}

	return Result;
}

/** @return Returns the current status of the platform's network connection. */
static final event bool HasLinkConnection()
{
	local bool bResult;
	local OnlineSubsystem OnlineSub;
	local OnlineSystemInterface SystemInterface;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		SystemInterface = OnlineSub.SystemInterface;
		if (SystemInterface != None)
		{
			bResult = SystemInterface.HasLinkConnection();
		}
	}

	return bResult;
}

/** @return Returns whether or not the specified player is logged in at all. */
static final event bool IsLoggedIn( int ControllerId, optional bool bRequireOnlineLogin )
{
	local bool bResult;
	local ELoginStatus LoginStatus;

	LoginStatus = GetLoginStatus(ControllerId);

	bResult = (LoginStatus == LS_LoggedIn) || (LoginStatus == LS_UsingLocalProfile && !bRequireOnlineLogin);
	return bResult;
}

/** @return Returns whether or not the specified player can play online. */
static final event bool CanPlayOnline( int ControllerId )
{
	local EFeaturePrivilegeLevel Result;
	local OnlineSubsystem OnlineSub;
	local OnlinePlayerInterface PlayerInterface;

	Result = FPL_Disabled;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		// Grab the player interface to verify the subsystem supports it
		PlayerInterface = OnlineSub.PlayerInterface;
		if (PlayerInterface != None)
		{
			Result = PlayerInterface.CanPlayOnline(ControllerId);
		}
	}

	return Result!=FPL_Disabled;
}

/**
 * Wrapper for getting the NAT type
 */
static final event ENATType GetNATType()
{
	local OnlineSubsystem OnlineSub;
	local OnlineSystemInterface SystemInterface;
	local ENATType Result;

	// Figure out if we have an online subsystem registered
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	if (OnlineSub != None)
	{
		SystemInterface = OnlineSub.SystemInterface;
		if (SystemInterface != None)
		{
			Result = SystemInterface.GetNATType();
		}
	}

	return Result;
}

/* === Interaction interface === */

/**
 * Called when the current map is being unloaded.  Cleans up any references which would prevent garbage collection.
 */
function NotifyGameSessionEnded()
{
	if ( DataStoreManager != None )
	{
		DataStoreManager.NotifyGameSessionEnded();
	}

	if ( SceneClient != None )
	{
		SceneClient.NotifyGameSessionEnded();
	}
}

DefaultProperties
{
	SceneClientClass=class'GameUISceneClient'
}
