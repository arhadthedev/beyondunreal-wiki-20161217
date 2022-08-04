/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTMissionInfo extends Object
	native;

enum EMissionStyle
{
	EMT_Duel,				// Duel
	EMT_Infiltration,		// DM
	EMT_DefendAndHold,		// TDM
	EMT_Extraction,			// CTF
	EMT_Battle,				// Warfare
};

/** Holds descriptions for all of the mission types */
var localized array<string> MissionTypeDesc;

/** Holds all of the information to describe a single objective in a mission */
struct native EObjectiveInformation
{
	/**  The Background image will be set to this */
	var() editinlineuse Texture2D Image;

	/**  Are we using custom coordinates */
	var() bool bCustomCoords;

	/**  The Map Coordinates */
	var() editinline TextureCoordinates ImageCoords;

	/**  	The Objective's Text */
	var() string Text;	//LOCALIZEME

	/**  The sound that get's played when this objective is highlighted */
	var() editinlineuse SoundCue AudioCue;

	/**  How long should the briefing menu focus on this objective? */
	var() float FocusTime;

};

/** Holds the information regarding a single mission */
struct native EMissionInformation
{
	// ------- Control

	/** A tag that defines the mission.  Can be used for quick lookup */
	var() int MissionID;

	// ------- General

    /** Title of the Mission */
	var() string Title;

	// ------- Gameplay Data

	/** The map to use */
	var() string Map;

	/** The URL */
	var() string URL;

	/** The faction of the opponent */
	var() string OpponentFaction;

	/** Teammates that are required on your team */
	var() array<string> RequiredTeammates;

	/** Teammates that are required to be against you */
	var() array<string> RequiredOpponents;

	/** bots that are precached for spawning through Kismet */
	var() array<string> PrecachedTeammates;
	var() array<string> PrecachedOpponents;

	// ------- Quick Info

	/** What type of match is this */
	var() EMissionStyle Style;

	/** Holds the Location name */
	var() string  Location;

	// ------- Globe / Selection

	/** Holds the BoneName of the point on the map to focus on when selecting this mission. */
	var() name GlobeBoneName;

	/** Which globe does this point reside on */
	var() name GlobeTag;

	/** How far from the Bone should the camera end up */
	var() float CameraDist;

	// ------- Mission Briefing

	/** The image to use */
	var() editinlineuse surface BriefingImage;

	/** Are we using custom coordinates */
	var() bool bCustomBriefingCoords;

	/** The Map Coordinates */
	var() TextureCoordinates BriefingCoords;

	/** The text to display at the briefing */
	var() string BriefingText;

	/** The sound to play when you enter the briefing menu */
	var() editinlineuse soundcue BriefingAudioCue;

	/** The text that will be set when we display objectives */
	var() string ObjectiveText;

	/** This holds information that will be displayed during travel */
	var() editinline array<EObjectiveInformation> Objectives;

	// ------- Transients

	/** This will be set by the menus */
	var transient StaticMeshComponent MapBeacon;
};

/** Holds all of the missions */
var() array<EMissionInformation> Missions;

/*********************************************************************************************
 Natives
********************************************************************************************* */

/**
 * Using a mission tag, find the assoicated mission index and return it.
 *
 * @Returns the mission index if the MissionTag is valid, otherwise returns INDEX_NONE
 */

native function int GetMissionIndex(int MissionID);
native function bool GetMission(int MissionID, out EMissionInformation Mission);

/*********************************************************************************************
 General functions
********************************************************************************************* */

function Convert(UTSeqObj_SPMission Mission)
{
/*
	local int i,j,o;
	local string s;
	local UTSeqObj_SPMission ChildMission;

	i = Missions.Length;

	Missions.Length = Missions.Length+1;

	S = string(i);
	Missions[i].MissionID = i;

	// Set the reverse link
	Mission.MissionID = i;

	Missions[i].Title = Mission.MissionInfo.MissionTitle;
	Mission.bCutSequence = Mission.MissionInfo.MissionRules.bCutSequence;
	Mission.bAutomaticTransition = Mission.MissionInfo.MissionRules.bAutomaticTransition;
	Missions[i].Map = Mission.MissionInfo.MissionRules.MissionMap;
	Missions[i].URL = Mission.MissionInfo.MissionRules.MissionURL;

	if ( Mission.MissionInfo.MissionRules.MapPoint == '' )
	{
		s = Mission.MissionInfo.MissionRules.MissionMap;
		s = Repl(s," ","_");
		s = "B_"$s;

		Missions[i].GlobeBoneName = name(s);

	}
	else
	{
		Missions[i].GlobeBoneName = Mission.MissionInfo.MissionRules.MapPoint;
	}

	if (Mission.MissionInfo.Missionrules.MapGlobeTag == '')
	{
		Missions[i].GlobeTag = 'Taryd';
	}
	else
	{
		Missions[i].GlobeTag = Mission.MissionInfo.MissionRules.MapGlobeTag;
	}


	Missions[i].CameraDist = Mission.MissionInfo.MissionRules.MapDist;
	Missions[i].BriefingImage = Mission.MissionInfo.MissionRules.MissionMapImage;
	Missions[i].bCustomBriefingCoords = Mission.MissionInfo.MissionRules.bCustomMapCoords;
	Missions[i].BriefingCoords = Mission.MissionInfo.MissionRules.MissionMapCoords;
	Missions[i].BriefingText = Mission.MissionInfo.MissionDescription;

	for (j=0;j<Mission.MissionInfo.Missionrules.Objectives.Length;j++)
	{
		o = Missions[i].Objectives.Length;
		Missions[i].Objectives.Length = Missions[i].Objectives.Length+1;

		Missions[i].Objectives[o].Image = Mission.MissionInfo.MissionRules.Objectives[j].BackgroundImg;
		Missions[i].Objectives[o].Text = Mission.MissionInfo.MissionRules.Objectives[j].Text;
	}

	`log("### Added:"@Missions[i].Title@Missions[i].MissionID@Mission.OutputLinks.Length);

	j = 0;
	for (i=0;i<Mission.MissionInfo.MissionProgression.Length;i++)
	{
		j = Mission.Progression.Length;
		Mission.Progression.Length = j + 1;

		Mission.Progression[j] = Mission.MissionInfo.MissionProgression[i];
	}

    Mission.bFixedup = true;
	for (j=0;j<Mission.OutputLinks.Length;j++)
	{
		if (Mission.OutputLinks[j].Links.Length >= 1 && Mission.OutputLinks[j].Links[0].LinkedOp != Mission )
		{
			ChildMission = UTSeqObj_SPMission( Mission.OutputLinks[j].Links[0].LinkedOp );
			if ( ChildMission != none && !ChildMission.bFixedup )
			{
				Convert(ChildMission);
			}
		}
	}
*/
}

defaultproperties
{
}
