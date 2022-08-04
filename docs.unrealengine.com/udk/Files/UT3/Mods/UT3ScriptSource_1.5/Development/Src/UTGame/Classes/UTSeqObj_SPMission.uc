/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqObj_SPMission extends SequenceAction
	dependson(UTProfileSettings)
	native(UI);

enum EMissionResult
{
	EMResult_Any,
	EMResult_Won,
	EMResult_Lost,
};

struct native EMissionCondition
{
	var() editinline EMissionResult MissionResult;
	var() editinline string ConditionDesc;
	var() editinline array<ESinglePlayerPersistentKeys> RequiredPersistentKeys;
	var() editinline array<ESinglePlayerPersistentKeys> RestrictedPersistentKeys;

	structdefaultproperties
	{
		ConditionDesc=""
	}

};

struct native EMissionObjectiveInfo
{
	var() Texture2D BackgroundImg;
	var() string Text;
};

struct native EMissionMapInfo
{
	// The map to use
	var() editinline string	MissionMap;

	// The URL
	var() editinline string MissionURL;

	// The image to use
	var() editinlineuse surface MissionMapImage;

	// Are we using custom coordinates
	var() bool bCustomMapCoords;

	// The Map Coordinates
	var() editinline TextureCoordinates MissionMapCoords;

	// If true, this node references a cut sequence and we should automatically
	// transition.
	var() bool bCutSequence;

	// if true, this node will automatically transition to the next mission skipping
	// the selection menu.
	var() bool bAutomaticTransition;

	// Holds the BoneName of the point on the map to focus on when selecting this mission.
	var() name MapPoint;

	// Which globe does this point reside on
	var() name MapGlobeTag;

	// How far from the MapPoint should the camera end up
	var() float MapDist;

	// This holds information that will be displayed in the Map briefing dialog
	var() editinline array<EMissionObjectiveInfo> Objectives;

	// This will be set by the menus
	var transient StaticMeshComponent MapBeacon;

};


struct native EMissionData
{
	var() int MissionIndex;
	var() string MissionTitle;
	var() string MissionDescription;
	var() editinline EMissionMapInfo MissionRules;
	var() editinline array<EMissionCondition> MissionProgression;


	structdefaultproperties
	{
		MissionTitle="<Edit Me>"
		MissionDescription="<Edit Me>"
	}
};

var() bool bFirstMission;
var() EMissionData MissionInfo;

// Associated this with a mission information entry
var() int MissionID;

// If true, this node references a cut sequence and we should automatically
// transition.
var() bool bCutSequence;

/** If true, this is a bink sequence */
var() bool bIsBinkSequence;

/** if true, all of the player's cards will be removed when this mission is completed */
var() bool bClearCards;

// if true, this node will automatically transition to the next mission skipping
// the selection menu.
var() bool bAutomaticTransition;

/** If true, this mission will unlock a chapter when it's completed */
var() bool bUnlockChapterWhenCompleted;

/** The Chapter Index to unlock */
var() int UnlockChapterIndex;

// Used to layout the progression of the mission tree
var() editinline array<EMissionCondition> Progression;

/** These sounds will be played when you enter the mission depending on the mission result */
var() editinlineuse SoundCue MalcolmSounds[3];

// Used to auto-adjust the indices
var transient int OldIndex;
var transient bool bFixedup;




/**
 * Returns the number of Children
 */
function int NumChildren()
{
	return Progression.Length;
}

/**
 * Returns the Mission object associated with a child
 */

function UTSeqObj_SPMission GetChild(int ChildIndex, out EMissionCondition Condition)
{
	local UTSeqObj_SPMission Mission;

	if ( ChildIndex >= 0 && ChildIndex < Progression.Length && ChildIndex < OutputLinks.Length )
	{
		Condition = Progression[ChildIndex];
		if (OutputLinks[ChildIndex].Links.Length > 0)
		{
			Mission = UTSeqObj_SPMission( OutputLinks[ChildIndex].Links[0].LinkedOp );
		}
	}

	return Mission;
}

event ChangeItAll()
{
	local UTMissionInfo MI;

	`log("### ChangeItAll");

	MI = New(outer) class'UTMissionInfo';
	MI.Convert(self);
	MI.SaveConfig();
}

defaultproperties
{
	ObjColor=(R=255,G=0,B=0,A=255)
	InputLinks.Empty
	OutputLinks.Empty
	VariableLinks.Empty
	ObjName="Single Player Mission"
	InputLinks(0)=(LinkDesc="In")
}

