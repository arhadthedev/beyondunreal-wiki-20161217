//=============================================================================
// NavigationPoint.
//
// NavigationPoints are organized into a network to provide AIControllers
// the capability of determining paths to arbitrary destinations in a level
//
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class NavigationPoint extends Actor
	hidecategories(Lighting,LightColor,Force)
	dependson(ReachSpec)
	native;

const	INFINITE_PATH_COST	=	10000000;

//------------------------------------------------------------------------------
// NavigationPoint variables

var transient bool bEndPoint;	// used by C++ navigation code
var transient bool bTransientEndPoint; // set right before a path finding attempt, cleared afterward.
var transient bool bHideEditorPaths;	// don't show paths to this node in the editor
var transient bool bCanReach;		// used during paths review in editor

/** structure for inserting things into the navigation octree */
struct native NavigationOctreeObject
{
	/** the bounding box to use */
	var Box BoundingBox;
	/** cached center of that box */
	var vector BoxCenter;
	/** if this object is in the octree, pointer to the node it's in, otherwise NULL */
	var native transient const pointer OctreeNode{class FNavigationOctreeNode};
	/** UObject that owns the entry in the octree */
	var noexport const Object Owner;
	/** bitfield representing common classes of Owner so we can avoid casts */
	var noexport const byte OwnerType;

	
};
var native transient const NavigationOctreeObject NavOctreeObject;

var() bool bBlocked;			// this node is currently unuseable
var() bool bOneWayPath;			// reachspecs from this path only in the direction the path is facing (180 degrees)
var	bool bNeverUseStrafing;	// shouldn't use bAdvancedTactics going to this point
var bool bAlwaysUseStrafing;	// shouldn't use bAdvancedTactics going to this point
var const bool bForceNoStrafing;// override any LD changes to bNeverUseStrafing
var const bool bAutoBuilt;		// placed during execution of "PATHS BUILD"
var	bool bSpecialMove;			// if true, pawn will call SuggestMovePreparation() when moving toward this node
var bool bNoAutoConnect;		// don't connect this path to others except with special conditions (used by LiftCenter, for example)
var	const bool	bNotBased;		// used by path builder - if true, no error reported if node doesn't have a valid base
var const bool  bPathsChanged;	// used for incremental path rebuilding in the editor
var bool		bDestinationOnly; // used by path building - means no automatically generated paths are sourced from this node
var	bool		bSourceOnly;	// used by path building - means this node is not the destination of any automatically generated path
var bool		bSpecialForced;	// paths that are forced should call the SpecialCost() and SuggestMovePreparation() functions
var bool		bMustBeReachable;	// used for PathReview code
var bool		bBlockable;		// true if path can become blocked (used by pruning during path building)
var	bool		bFlyingPreferred;	// preferred by flying creatures
var bool		bMayCausePain;		// set in C++ if in PhysicsVolume that may cause pain
var transient bool bAlreadyVisited;	// internal use
var() bool 	bVehicleDestination;	// if true, forced paths to this node will have max width to accomodate vehicles
var() bool bMakeSourceOnly;
var	bool	bMustTouchToReach;		// if true. reach tests are based on whether pawn can move to overlap this NavigationPoint (only valid if bCollideActors=true)
/** whether walking on (being based on) this NavigationPoint counts as reaching it */
var bool bCanWalkOnToReach;
/** if true, attempt to build long range (> MAXPATHDIST) paths to/from this node */
var bool bBuildLongPaths;
/** indicates vehicles cannot use this node */
var(VehicleUsage) bool bBlockedForVehicles;
/** vehicles with bUsePreferredVehiclePaths set (large vehicles, usually) will prioritize using these nodes */
var(VehicleUsage) bool bPreferredVehiclePath;

var() editinline const editconst duplicatetransient array<ReachSpec> PathList; //index of reachspecs (used by C++ Navigation code)
/** List of navigation points to prevent paths being built to */
var duplicatetransient array<NavReference>	EditorProscribedPaths;
/** List of navigation points to force paths to be built to */
var duplicatetransient array<NavReference>	EditorForcedPaths;
/** List of volumes containing this navigation point relevant for gameplay */
var() const editconst  array<Volume>		VolumeList;
var int visitedWeight;
var const int bestPathWeight;
var const private NavigationPoint nextNavigationPoint;
var const NavigationPoint nextOrdered;	// for internal use during route searches
var const NavigationPoint prevOrdered;	// for internal use during route searches
var const NavigationPoint previousPath;
var int Cost;					// added cost to visit this pathnode
var() int ExtraCost;			// Extra weight added by level designer
var transient int TransientCost;	// added right before a path finding attempt, cleared afterward.
var	transient int FearCost;		// extra weight diminishing over time (used for example, to mark path where bot died)

/** Mapping of Cost/Description for costs of this node */
var transient native Map{FString,INT}	CostArray;

var DroppedPickup	InventoryCache;		// used to point to dropped weapons
var float	InventoryDist;
var const float LastDetourWeight;

var	CylinderComponent		CylinderComponent;

var Objective NearestObjective; // FIXMESTEVE - determine in path building
var float ObjectiveDistance;

/** path size of the largest ReachSpec in this node's PathList */
var() editconst const Cylinder MaxPathSize;

/** GUID used for linking paths across levels */
var() editconst const duplicatetransient guid NavGuid;

/** Normal editor sprite */
var const SpriteComponent GoodSprite;
/** Used to draw bad collision intersection in editor */
var const SpriteComponent BadSprite;

/** Does this nav point point to others in separate levels? */
var const bool bHasCrossLevelPaths;

/** Which navigation network does this navigation point connect to? */
var() editconst const int NetworkID;

/** Pawn that is currently anchor to this navigation point */
var transient Pawn AnchoredPawn;
/** Last time a pawn was anchored to this navigation point - set when Pawn chooses a new anchor */
var transient float LastAnchoredPawnTime;

/** Debug abbrev for hud printing */
var String	Abbrev;



native function GetBoundingCylinder(out float CollisionRadius, out float CollisionHeight) const;

native final function ReachSpec GetReachSpecTo(NavigationPoint Nav);

/** returns whether this NavigationPoint is a teleporter that can teleport the given Actor */
native function bool CanTeleport(Actor A);

event int SpecialCost(Pawn Seeker, ReachSpec Path);

// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept( actor Incoming, actor Source )
{
	local bool bResult;

	// Move the actor here.
	bResult = Incoming.SetLocation( Location );
	if (bResult)
	{
		Incoming.Velocity = vect(0,0,0);
		Incoming.SetRotation(Rotation);
	}
	Incoming.PlayTeleportEffect(true, false);
	return bResult;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
event float DetourWeight(Pawn Other,float PathWeight);

/* SuggestMovePreparation()
Optionally tell Pawn any special instructions to prepare for moving to this goal
(called by Pawn.PrepareForMove() if this node's bSpecialMove==true
*/
event bool SuggestMovePreparation( Pawn Other )
{
	// If special move was taken to get to this link
	if( Other.SpecialMoveTo( Other.Anchor, self, Other.Controller.MoveTarget ) )
	{
		return TRUE;
	}
	return FALSE;
}

/* ProceedWithMove()
Called by Controller to see if move is now possible when a mover reports to the waiting
pawn that it has completed its move
*/
function bool ProceedWithMove(Pawn Other)
{
	return true;
}

/**
 * Returns true if this point is available for chkActor to move to,
 * allowing nodes to control availability.
 */
function bool IsAvailableTo(Actor chkActor)
{
	// default to true
	return true;
}

/**
 * Returns the nearest valid navigation point to the given actor.
 */
static final function NavigationPoint GetNearestNavToActor(Actor ChkActor, optional class<NavigationPoint> RequiredClass,optional array<NavigationPoint> ExcludeList,optional float MinDist)
{
	local NavigationPoint Nav, BestNav;
	local float Dist, BestDist;
	if (ChkActor != None)
	{
		// iterate through all points in the level
		foreach ChkActor.WorldInfo.AllNavigationPoints(class'NavigationPoint',Nav)
		{
			// if no filter class specified, and
			// if nav is available to the check actor, and
			// if the nav isn't part of the excluded list,
			if ((RequiredClass == None || Nav.class == RequiredClass) &&
				Nav.IsAvailableTo(ChkActor) &&
				ExcludeList.Find(Nav) == -1)
			{
				// pick the closest
				Dist = VSize(Nav.Location-ChkActor.Location);
				if (Dist > MinDist)
				{
					if (BestNav == None ||
						Dist < BestDist)
					{
						BestNav = Nav;
						BestDist = Dist;
					}
				}
			}
		}
	}
	return BestNav;
}

/**
 * Returns the nearest valid navigation point to the given point.
 */
static final function NavigationPoint GetNearestNavToPoint(Actor ChkActor,vector ChkPoint, optional class<NavigationPoint> RequiredClass,optional array<NavigationPoint> ExcludeList)
{
	local NavigationPoint Nav, BestNav;
	local float Dist, BestDist;
	if (ChkActor != None)
	{
		// iterate through all points in the level
		foreach ChkActor.WorldInfo.AllNavigationPoints(class'NavigationPoint',Nav)
		{
			// if no filter class specified, and
			// if nav is available to the check actor, and
			// if the nav isn't part of the excluded list,
			if ((RequiredClass == None || Nav.class == RequiredClass) &&
				Nav.IsAvailableTo(ChkActor) &&
				ExcludeList.Find(Nav) == -1)
			{
				// pick the closest
				Dist = VSize(Nav.Location-ChkPoint);
				if (BestNav == None ||
					Dist < BestDist)
				{
					BestNav = Nav;
					BestDist = Dist;
				}
			}
		}
	}
	return BestNav;
}

/**
 * Returns all navigation points near the ChkPoint specified by Radius.
 */
static native final function bool GetAllNavInRadius( Actor ChkActor, Vector ChkPoint, float Radius, out array<NavigationPoint> out_NavList, optional bool bSkipBlocked, optional int inNetworkID=-1, optional Cylinder MinSize );

/**
 * Toggle the blocked state of a navigation point.
 */
function OnToggle(SeqAct_Toggle inAction)
{
	if (inAction.InputLinks[0].bHasImpulse)
	{
		bBlocked = false;
	}
	else if (inAction.InputLinks[1].bHasImpulse)
	{
		bBlocked = true;
	}
	else if (inAction.InputLinks[2].bHasImpulse)
	{
		bBlocked = !bBlocked;
	}

	WorldInfo.Game.NotifyNavigationChanged(self);
}

simulated function bool OnMatchingNetworks( NavigationPoint Nav )
{
	return (Nav == None)		||
		   (NetworkID < 0)		||
		   (Nav.NetworkID < 0)	||
		   (NetworkID == Nav.NetworkID);
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.S_NavP'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)
	GoodSprite=Sprite

	Begin Object Class=SpriteComponent Name=Sprite2
		Sprite=Texture2D'EditorResources.Bad'
		HiddenGame=true
		HiddenEditor=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		Scale=0.25
	End Object
	Components.Add(Sprite2)
	BadSprite=Sprite2

	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=0.5
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Arrow)

	Begin Object Class=CylinderComponent Name=CollisionCylinder LegacyClassName=NavigationPoint_NavigationPointCylinderComponent_Class
		CollisionRadius=+0050.000000
		CollisionHeight=+0050.000000
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	Begin Object Class=PathRenderingComponent Name=PathRenderer
	End Object
	Components.Add(PathRenderer)

	bMayCausePain=true
	bStatic=true
	bNoDelete=true

	bHidden=FALSE

	bCollideWhenPlacing=true
	bMustTouchToReach=true
	bBuildLongPaths=true

	bCollideActors=false

	// default to no network id
	NetworkID=-1

	Abbrev="NP?"
}
