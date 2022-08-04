/**
 * WorldInfo
 *
 * Actor containing all script accessible world properties.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class WorldInfo extends ZoneInfo
	native
	config(game)
	hidecategories(Actor,Advanced,Display,Events,Object,Attachment)
	nativereplication
	notplaceable
	dependson(PostProcessEffect)
	dependson(MusicTrackDataStructures);

/** Default post process settings used by post processing volumes.									*/
var(WorldInfo)	config				PostProcessSettings		DefaultPostProcessSettings;

/** Squint mode kernel size (same as DOF). */
var(WorldInfo) config				float					SquintModeKernelSize;

/** Linked list of post processing volumes, sorted in descending order of priority.					*/
var	const noimport transient		PostProcessVolume		HighestPriorityPostProcessVolume;

/** Default reverb settings used by reverb volumes.									*/
var(WorldInfo)	config				ReverbSettings			DefaultReverbSettings;

/** Linked list of reverb volumes, sorted in descending order of priority.							*/
var	const noimport transient		ReverbVolume			HighestPriorityReverbVolume;

/** A array of portal volumes */
var	const noimport transient		array<PortalVolume>		PortalVolumes;

/** Level collection. ULevels are referenced by FName (Package name) to avoid serialized references. Also contains offsets in world units */
var(WorldInfo) const editconst editinline array<LevelStreaming> StreamingLevels;

/**
 * This is a bool on the level which is set when a light that needs to have lighting rebuilt
 * is moved.  This is then checked in CheckMap for errors to let you know that this level should
 * have lighting rebuilt.
 **/
var 					bool 					bMapNeedsLightingFullyRebuilt;

/**
 * This is a bool on the level which is set when the AI detects that paths are either not set up correctly
 * or need to be rebuilt. If set the HUD will display a warning message on the screen.
 */
var						bool					bMapHasPathingErrors;

/** Whether it was requested that the engine bring up a loading screen and block on async loading. */
var						bool					bRequestedBlockOnAsyncLoading;

var(Editor)				BookMark				BookMarks[10];			// Level bookmarks
var(Editor)	editinline	array<ClipPadEntry>		ClipPadEntries;			// Clip pad entries
var						float					TimeDilation;			// Normally 1 - scales real time passage.
var						float					TimeSeconds;			// Time in seconds since level began play, but IS paused when the game is paused, and IS dilated/clamped.
var						float					RealTimeSeconds;		// Time in seconds since level began play, but is NOT paused when the game is paused, and is NOT dilated/clamped.
var                     float                   AudioTimeSeconds;		// Time in seconds since level began play, but IS paused when the game is paused, and is NOT dilated/clamped.
var	transient const		float					DeltaSeconds;			// Frame delta time in seconds adjusted by e.g. time dilation.
var						float					PauseDelay;				// time at which to start pause
var						float					RealTimeToUnPause;		// If non-zero, when RealTimeSeconds reaches this, unpause the game.

var						PlayerReplicationInfo	Pauser;					// If paused, name of person pausing the game.
var						string					VisibleGroups;			// List of the group names which were checked when the level was last saved
var transient			string					SelectedGroups;			// A list of selected groups in the group browser (only used in editor)

var						bool					bBegunPlay;				// Whether gameplay has begun.
var						bool					bPlayersOnly;			// Only update players.
var transient					bool					bDropDetail;			// frame rate is below DesiredFrameRate, so drop high detail actors
var transient					bool					bAggressiveLOD;			// frame rate is well below DesiredFrameRate, so make LOD more aggressive
var						bool					bStartup;				// Starting gameplay.
var						bool					bPathsRebuilt;			// True if path network is valid
var						bool					bHasPathNodes;

/**
 * Bool that indicates that 'console' input is desired. This flag is mis named as it is used for a lot of gameplay related things
 * (e.g. increasing collision size, changing vehicle turning behavior, modifying put down/up weapon speed, bot behavior)
 *
 * currently set when you are running a console build (implicitly or explicitly via ?param on the commandline)
 */
var						transient bool			bUseConsoleInput;

var						Texture2D				DefaultTexture;
var						Texture2D				WireframeTexture;
var						Texture2D				WhiteSquareTexture;
var						Texture2D				LargeVertex;
var						Texture2D				BSPVertex;

/**
 * This is the array of string which will be called after a tick has occurred.  This allows
 * functions which GC and/or delete objects to be executed from .uc land!
 **/
var 					array<string>			DeferredExecs;


var transient			GameReplicationInfo		GRI;
var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;

var						string					ComputerName;			// Machine's name according to the OS.
var						string					EngineVersion;			// Engine version.
var						string					MinNetVersion;			// Min engine version that is net compatible.

var						GameInfo				Game;
var()					float					StallZ;					// vehicles stall if they reach this
var	transient			float					WorldGravityZ;			// current gravity actually being used
var	const globalconfig	float					DefaultGravityZ;		// default gravity (game specific) - set in defaultgame.ini
var()					float					GlobalGravityZ;			// optional level specific gravity override set by level designer
var globalconfig		float					RBPhysicsGravityScaling;	// used to scale gravity for rigid body physics

var transient const private	NavigationPoint		NavigationPointList;
var const private			Controller			ControllerList;
var const					Pawn				PawnList;
var transient const			CoverLink			CoverList;

var						float					MoveRepSize;

/** stores information on a viewer that actors need to be checked against for relevancy */
struct native NetViewer
{
	var PlayerController InViewer;
	var Actor Viewer;
	var vector ViewLocation;
	var vector ViewDir;

	
};
/** valid only during replication - information about the player(s) being replicated to
 * (there could be more than one in the case of a splitscreen client)
 */
var const array<NetViewer> ReplicationViewers;

var						string					NextURL;
var						float					NextSwitchCountdown;

/** Maximum size of textures for packed light and shadow maps */
var()					int						PackedLightAndShadowMapTextureSize;

/** Default color scale for the level */
var()					vector					DefaultColorScale;

/** if true, do not grant player with default inventory (presumably, the LD's will be setting it manually) */
var()					bool					bNoDefaultInventoryForPlayer;

/**
 * This is the list of GameTypes which this map can support.  This is used for SeekFree loading
 * code so the map has a reference to the game type it will be played with so it can cook
 * all of the specific assets
 **/
var() array< class<GameInfo> > GameTypesSupportedOnThisMap;

/** array of levels that were loaded into this map via PrepareMapChange() / CommitMapChange() (to inform newly joining clients) */
var const transient array<name> PreparingLevelNames;
var const transient array<name> CommittedLevelNames;

/** Kismet controlled music info (to inform newly joining clients) */
var SeqAct_CrossFadeMusicTracks LastMusicAction;
var MusicTrackStruct LastMusicTrack;

/** If true, don't add "no paths from" warnings to map error list in editor.  Useful for maps that don't need AI support, but still have a few NavigationPoint actors in them. */
var() bool bNoPathWarnings;

/** title of the map displayed in the UI */
var() localized string Title;

var() string Author;

/** when this flag is set, more time is allocated to background loading (replicated) */
var bool bHighPriorityLoading;
/** copy of bHighPriorityLoading that is not replicated, for clientside-only loading operations */
var bool bHighPriorityLoadingLocal;

/** game specific map information - access through GetMapInfo()/SetMapInfo() */
var() protected{protected} instanced MapInfo MyMapInfo;

/** particle emitter pool for gameplay effects that are spawned independent of their owning Actor */
var globalconfig string EmitterPoolClassPath;
var EmitterPool MyEmitterPool;

/** decal pool and lifetime manager */
var globalconfig string DecalManagerClassPath;
var DecalManager MyDecalManager;

/** For specifying which compartments should run on a given frame */
struct native CompartmentRunList
{
	/** The rigid body compartment will run on this frame */
	var() editconst bool RigidBody;

	/** The fluid compartment will run on this frame */
	var() editconst bool Fluid;

	/** The cloth compartment will run on this frame */
	var() editconst bool Cloth;

	/** The soft body compartment will run on this frame */
	var() editconst bool SoftBody;

	structdefaultproperties
	{
		RigidBody=true
		Fluid=true
		Cloth=true
		SoftBody=true
	}
};

/** Timing parameters used for a PhysX primary scene or compartment */
struct native PhysXTiming
{
	/**
		If true, substep sizes are fixed equal to TimeStep.
		If false, substep sizes are varied to fit an integer number of times into the frame time.
	*/
	var() editconst bool	bFixedTimeStep;

	/** The fixed or maximum substep size, depending on the value of bFixedTimeStep. */
	var() editconst float	TimeStep;

	/** The maximum number of substeps allowed per frame. */
	var() editconst int		MaxSubSteps;

	structdefaultproperties
	{
		bFixedTimeStep=false
		TimeStep=0.02
		MaxSubSteps=5
	}
};

/** Timings for primary and compartments. */
struct native PhysXSceneTimings
{
	/** Timing settings for the PhysX primary scene */
	var()	editconst editinline	PhysXTiming			PrimarySceneTiming;

	/** Timing settings for the PhysX rigid body compartment */
	var()	editconst editinline	PhysXTiming			CompartmentTimingRigidBody;

	/** Timing settings for the PhysX fluid compartment */
	var()	editconst editinline	PhysXTiming			CompartmentTimingFluid;

	/** Timing settings for the PhysX cloth compartment */
	var()	editconst editinline	PhysXTiming			CompartmentTimingCloth;

	/** Timing settings for the PhysX soft body compartment */
	var()	editconst editinline	PhysXTiming			CompartmentTimingSoftBody;

	structdefaultproperties
	{
		CompartmentTimingRigidBody=(bFixedTimeStep=false,TimeStep=0.02,MaxSubSteps=2)
		CompartmentTimingFluid=(bFixedTimeStep=false,TimeStep=0.02,MaxSubSteps=1)
		CompartmentTimingCloth=(bFixedTimeStep=true,TimeStep=0.02,MaxSubSteps=2)
		CompartmentTimingSoftBody=(bFixedTimeStep=true,TimeStep=0.02,MaxSubSteps=2)
	}
};

/** Primary PhysX scene runs on the PPU */
var(Physics)	editconst bool								bPrimarySceneHW;

/** Double buffered physics compartments enabled */
var(Physics)	editconst bool								bSupportDoubleBufferedPhysics;

/** The maximum frame time allowed for physics calculations */
var(Physics)	editconst float								MaxPhysicsDeltaTime;

/** Timing parameters for the scene, primary and compartments. */
var(Physics)	editconst editinline PhysXSceneTimings		PhysicsTimings;

/** Which compartments run on which frames (list is cyclic).  An empty list means all compartments run on all frames. */
var(Physics)	editconst array< CompartmentRunList >		CompartmentRunFrames;

enum EConsoleType
{
	CONSOLE_Any,
	CONSOLE_Xbox360,
	CONSOLE_PS3,
};



//-----------------------------------------------------------------------------
// Functions.

final function bool IsServer()
{
	return (NetMode == NM_DedicatedServer || NetMode == NM_ListenServer);
}

/**
 * Returns the Z component of the current world gravity and initializes it to the default
 * gravity if called for the first time.
 *
 * @return Z component of current world gravity.
 */
native function float GetGravityZ();

/**
 * Grabs the default game sequence and returns it.
 *
 * @return		the default game sequence object
 */
native final function Sequence GetGameSequence() const;

native final function SetLevelRBGravity(vector NewGrav);

//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL() const;

//
// Demo build flag
//
native simulated static final function bool IsDemoBuild() const;  // True if this is a demo build.

/**
 * Returns whether we are running on a console platform or on the PC.
 * @param ConsoleType - if specified, only returns true if we're running on the specified platform
 *
 * @return TRUE if we're on a console, FALSE if we're running on a PC
 */
native simulated static final function bool IsConsoleBuild(optional EConsoleType ConsoleType) const;

/** Returns whether script is executing within the editor. */
native simulated static final function bool IsPlayInEditor() const;

native simulated final function ForceGarbageCollection();

native simulated final function VerifyNavList();

//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL() const;

simulated function class<GameInfo> GetGameClass()
{
	if(WorldInfo.Game != None)
		return WorldInfo.Game.Class;

	if (GRI != None && GRI.GameClass != None)
		return GRI.GameClass;

	return None;
}

/**
 * Jumps the server to new level.  If bAbsolute is true and we are using seemless traveling, we
 * will do an absolute travel (URL will be flushed).
 */

event ServerTravel(string URL, optional bool bAbsolute)
{
	if ( InStr(url,"%")>=0 )
	{
		`log("URL Contains illegal character '%'.");
		return;
	}

	if (InStr(url,":")>=0 || InStr(url,"/")>=0 || InStr(url,"\\")>=0)
	{
		`log("URL blocked");
		return;
	}

	// Check for an error in the server's connection
	if (Game != None && Game.bHasNetworkError)
	{
		`Log("Not traveling because of network error");
		return;
	}

	// if we're not already in a level change, start one now
	if (NextURL == "" && !IsInSeamlessTravel())
	{
		NextURL = URL;
		if (Game != None)
		{
			Game.ProcessServerTravel(URL, bAbsolute);
		}
		else
		{
			NextSwitchCountdown = 0;
		}
	}
}

//
// ensure the DefaultPhysicsVolume class is loaded.
//
function ThisIsNeverExecuted(DefaultPhysicsVolume P)
{
	P = None;
}

simulated function PreBeginPlay()
{
	local class<EmitterPool> PoolClass;
	local class<DecalManager> DecalManagerClass;

	Super.PreBeginPlay();

	// create the emitter pool and decal manager
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (EmitterPoolClassPath != "")
		{
			PoolClass = class<EmitterPool>(DynamicLoadObject(EmitterPoolClassPath, class'Class'));
			if (PoolClass != None)
			{
				MyEmitterPool = Spawn(PoolClass, self,, vect(0,0,0), rot(0,0,0));
			}
		}
		if (DecalManagerClassPath != "")
		{
			DecalManagerClass = class<DecalManager>(DynamicLoadObject(DecalManagerClassPath, class'Class'));
			if (DecalManagerClass != None)
			{
				MyDecalManager = Spawn(DecalManagerClass, self,, vect(0,0,0), rot(0,0,0));
			}
		}
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (IsConsoleBuild())
	{
		bUseConsoleInput = true;
	}
}

/**
 * Reset actor to initial state - used when restarting level without reloading.
 */
function Reset()
{
	// perform garbage collection of objects (not done during gameplay)
	//ConsoleCommand("OBJ GARBAGE");
	Super.Reset();
}

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	if( bNetDirty && Role==ROLE_Authority )
		Pauser, TimeDilation, WorldGravityZ, bHighPriorityLoading;
}

/** returns all NavigationPoints in the NavigationPointList that are of the specified class or a subclass
 * @note this function cannot be used during level startup because the NavigationPointList is created in C++ ANavigationPoint::PreBeginPlay()
 * @param BaseClass the base class of NavigationPoint to return
 * @param (out) N the returned NavigationPoint for each iteration
 */
native final iterator function AllNavigationPoints(class<NavigationPoint> BaseClass, out NavigationPoint N);

/** returns all NavigationPoints whose cylinder intersects with a sphere of the specified radius at the specified point
 * this function uses the navigation octree and is therefore fast for reasonably small radii
 * @note this function cannot be used during level startup because the navigation octree is populated in C++ ANavigationPoint::PreBeginPlay()
 * @param BaseClass the base class of NavigationPoint to return
 * @param (out) N the returned NavigationPoint for each iteration
 * @param Radius the radius to search in
 */
native final iterator function RadiusNavigationPoints(class<NavigationPoint> BaseClass, out NavigationPoint N, vector Point, float Radius);

/** returns a list of NavigationPoints and ReachSpecs that intersect with the given point and extent
 * @param Point point to check
 * @param Extent box extent to check
 * @param (optional, out) Navs list of NavigationPoints that intersect
 * @param (optional, out) Specs list of ReachSpecs that intersect
 */
native final noexport function NavigationPointCheck(vector Point, vector Extent, optional out array<NavigationPoint> Navs, optional out array<ReachSpec> Specs);

/** returns all Controllers in the ControllerList that are of the specified class or a subclass
 * @note this function is only useful on the server; if you need the local player on a client, use Actor::LocalPlayerControllers()
 * @param BaseClass the base class of Controller to return
 * @param (out) C the returned Controller for each iteration
 */
native final iterator function AllControllers(class<Controller> BaseClass, out Controller C);

/** returns all Pawns in the PawnList that are of the specified class or a subclass
 * @note: useful on both client and server; pawns are added/removed from pawnlist in PostBeginPlay (on clients, only relevant pawns will be available)
 * @param BaseClass the base class of Pawn to return
 * @param (out) P the returned Pawn for each iteration
 * @param (optional) TestLocation is the world location used if
 *        TestRadius > 0
 * @param (optional) TestRadius is the radius checked against
 *        using TestLocation, skipping any pawns not within that
 *        value
 */
native final iterator function AllPawns(class<Pawn> BaseClass, out Pawn P, optional vector TestLocation, optional float TestRadius);



/**
 * Called by GameInfo.StartMatch, used to notify native classes of match startup (such as Kismet).
 */
native final function NotifyMatchStarted(optional bool bShouldActivateLevelStartupEvents=true, optional bool bShouldActivateLevelBeginningEvents=true, optional bool bShouldActivateLevelLoadedEvents=false);


/** asynchronously loads the given levels in preparation for a streaming map transition.
 * This codepath is designed for worlds that heavily use level streaming and gametypes where the game state should
 * be preserved through a transition.
 * @param LevelNames the names of the level packages to load. LevelNames[0] will be the new persistent (primary) level
 */
native final function PrepareMapChange(const out array<name> LevelNames);
/** returns whether there's a map change currently in progress */
native final function bool IsPreparingMapChange();
/** if there is a map change being prepared, returns whether that change is ready to be committed
 * (if no change is pending, always returns false)
 */
native final function bool IsMapChangeReady();
/** actually performs the map transition prepared by PrepareMapChange()
 * it happens in the next tick to avoid GC issues
 * if a map change is being prepared but isn't ready yet, the transition code will block until it is
 * wait until IsMapChangeReady() returns true if this is undesired behavior
 */
native final function CommitMapChange(optional bool bShouldSkipLevelStartupEvent=FALSE,optional bool bShouldSkipLevelBeginningEvent=FALSE);


/** seamlessly travels to the given URL by first loading the entry level in the background,
 * switching to it, and then loading the specified level. Does not disrupt network communication or disconnet clients.
 * You may need to implement GameInfo::GetSeamlessTravelActorList(), PlayerController::GetSeamlessTravelActorList(),
 * GameInfo::PostSeamlessTravel(), and/or GameInfo::HandleSeamlessTravelPlayer() to handle preserving any information
 * that should be maintained (player teams, etc)
 * This codepath is designed for worlds that use little or no level streaming and gametypes where the game state
 * is reset/reloaded when transitioning. (like UT)
 * @param URL the URL to travel to; must be relative to the current URL (same server)
 */
native final function SeamlessTravel(string URL, optional bool bAbsolute);

/** @return whether we're currently in a seamless transition */
native final function bool IsInSeamlessTravel();

/** this function allows pausing the seamless travel in the middle,
 * right before it starts loading the destination (i.e. while in the transition level)
 * this gives the opportunity to perform any other loading tasks before the final transition
 * this function has no effect if we have already started loading the destination (you will get a log warning if this is the case)
 * @param bNowPaused - whether the transition should now be paused
 */
native final function SetSeamlessTravelMidpointPause(bool bNowPaused);

/** @return the current MapInfo that should be used. May return one of the inner StreamingLevels' MapInfo if a streaming level
 *	transition has occurred via PrepareMapChange()
 */
native final function MapInfo GetMapInfo();

/** sets the current MapInfo to the passed in one */
native final function SetMapInfo(MapInfo NewMapInfo);

/**
 * @Returns the name of the current map
 */

native final function string GetMapName(optional bool bIncludePrefix);

/** @return the current detail mode */
native final function EDetailMode GetDetailMode();

/** @return whether a demo is being recorded */
native final function bool IsRecordingDemo();

defaultproperties
{
	Components.Remove(Sprite)

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	TimeDilation=1.0
	bHiddenEd=True
	DefaultTexture=Texture2D'EngineResources.DefaultTexture'
	WhiteSquareTexture=WhiteSquareTexture
	LargeVertex=Texture2D'EngineResources.LargeVertex'
	BSPVertex=Texture2D'EngineResources.BSPVertex'
	bWorldGeometry=true
	VisibleGroups="None"
	MoveRepSize=+42.0
	bBlockActors=true
	StallZ=+1000000.0
	PackedLightAndShadowMapTextureSize=1024

	DefaultColorScale=(X=1.f,Y=1.f,Z=1.f)

	MaxPhysicsDeltaTime=0.33333333
}
