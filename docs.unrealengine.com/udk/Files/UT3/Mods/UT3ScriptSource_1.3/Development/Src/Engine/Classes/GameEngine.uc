//=============================================================================
// GameEngine: The game subsystem.
// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class GameEngine extends Engine
	native(GameEngine)
	config(Engine)
	transient;

// URL structure.
struct transient native URL
{
	var		string			Protocol;	// Protocol, i.e. "unreal" or "http".
	var		string			Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var		int				Port;		// Optional host port.
	var		string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var		array<string>	Op;			// Options.
	var		string			Portal;		// Portal to enter through, default is "".
	var		int 			Valid;

};

var			PendingLevel	GPendingLevel;
/** URL the last time we travelled */
var			URL				LastURL;
/** last server we connected to (for "reconnect" command) */
var URL LastRemoteURL;
var config	array<string>	ServerActors;

var			string			TravelURL;
var			byte			TravelType;

/** The singleton online interface for all game code to use */
var OnlineSubsystem OnlineSubsystem;

/**
 * Array of package/ level names that need to be loaded for the pending map change. First level in that array is
 * going to be made a fake persistent one by using ULevelStreamingPersistent.
 */
var const	array<name>		LevelsToLoadForPendingMapChange;
/** Array of already loaded levels. The ordering is arbitrary and depends on what is already loaded and such.	*/
var	const	array<level>	LoadedLevelsForPendingMapChange;
/** Human readable error string for any failure during a map change request. Empty if there were no failures.	*/
var const	string			PendingMapChangeFailureDescription;
/** If TRUE, commit map change the next frame.																	*/
var const	bool			bShouldCommitPendingMapChange;
/** Whether to skip triggering the level startup event on the next map commit.									*/
var const	bool			bShouldSkipLevelStartupEventOnMapCommit;
/** Whether to skip triggering the level begin event on the next map commit.									*/
var const	bool			bShouldSkipLevelBeginningEventOnMapCommit;
/** Whether to enable framerate smoothing.																		*/
var config	bool			bSmoothFrameRate;
/** Maximum framerate to smooth. Code will try to not go over via waiting.										*/
var config	float			MaxSmoothedFrameRate;
/** Minimum framerate smoothing will kick in.																	*/
var config	float			MinSmoothedFrameRate;
/** 
 *	If true - clear all AnimSet LinkupCaches during map load. 
 *	You need to do this is the set of skeletal meshes that you are playing anims on is not bounded.
 */
var config	bool			bClearAnimSetLinkupCachesOnLoadMap;

/** level streaming updates that should be applied immediately after committing the map change */
struct native LevelStreamingStatus
{
	var name PackageName;
	var bool bShouldBeLoaded, bShouldBeVisible;

	
};
var const array<LevelStreamingStatus> PendingLevelStreamingStatusUpdates;

/** Handles to object references; used by the engine to e.g. the prevent objects from being garbage collected.	*/
var const	array<ObjectReferencer>	ObjectReferencers;

enum EFullyLoadPackageType
{
	/** Load the packages when the map in Tag is loaded */
	FULLYLOAD_Map,
	/** Load the packages before the game class in Tag is loaded. The Game name MUST be specified in the URL (game=Package.GameName). Useful for loading packages needed to load the game type (a DLC game type, for instance) */
	FULLYLOAD_Game_PreLoadClass,
	/** Load the packages after the game class in Tag is loaded. Will work no matter how game is specified in UWorld::SetGameInfo. Useful for modifying shipping gametypes by loading more packages (mutators, for instance) */
	FULLYLOAD_Game_PostLoadClass,
	/** Fully load the package as long as the DLC is loaded */
	FULLYLOAD_Always,
};

/** Struct to help hold information about packages needing to be fully-loaded for DLC, etc */
struct native FullyLoadedPackagesInfo
{
	/** When to load these packages */
	var EFullyLoadPackageType FullyLoadType;

	/** When this map or gametype is loaded, the packages in the following array will be loaded and added to root, then removed from root when map is unloaded */
	var string Tag;

	/** The list of packages that will be fully loaded when the above Map is loaded */
	var array<name> PackagesToLoad;

	/** List of objects that were loaded, for faster cleanup */
	var array<object> LoadedObjects;
};

/** A list of tag/array pairs that is used at LoadMap time to fully load packages that may be needed for the map/game with DLC, but we can't use DynamicLoadObject to load from the packages */
var array<FullyLoadedPackagesInfo> PackagesToFullyLoad;


/** Returns the global online subsytem pointer. This will be null for PIE */
native static final noexport function OnlineSubsystem GetOnlineSubsystem();


