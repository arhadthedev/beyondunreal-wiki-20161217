/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTMissionGRI extends UTGameReplicationInfo
	native;

/** The full mission list */
var array<UTSeqObj_SPMission> FullMissionList;

/** These are missions that are currently available to the Player */
var transient array<EMissionInformation> AvailMissionList;

var transient UTMissionInfo MissionData;

var string MissionInfoClassName;

enum EMenuState
{
	EMS_None,
	EMS_Selection,
	EMS_Brief,
	EMS_Launch,
};

/** The Current Mission ID */
var int CurrentMissionID;

/** We bundle these to insure they are replicated together */
struct native MissionRepData
{
	var int PendingMissionID;
	var EMenuState PendingMenuState;
};

/**
 * This list will hold the mission tags of all available missions on the client.  When
 * it gets replicated, the client will clear their AvailMissionList and rebuild it using
 * this list.
 */

CONST MAXMISSIONS = 5;

/** We replicate the Tag list as a struct to avoid repnotify on each element */

struct native TagListWrapper
{
	var int Data[MAXMISSIONS];
};

var repnotify TagListWrapper ClientMissionTagList;

var int ClientMissionTagCount;

var repnotify MissionRepData PendingMissionInfo;

/** The ID of the last mission */
var int LastMissionID;

/** Holds the result of the previous mission */
var ESinglePlayerMissionResult LastMissionResult;

/** Scene information */

var string SelectionSceneTemplate;
var transient UTUIScene_CMissionSelection SelectionScene;

var string BriefingSceneTemplate;
var transient UTUIScene_CMissionBriefing BriefingScene;

var EMenuState CurrentMenuState;

var array<UTSPGlobe> Globes;

var StaticMesh PrevMapPointSFXTemplate, MapPointSFXTemplate, SelectedMapPointSFXTemplate;

var UTMissionSelectionPRI HostPRI;

var repnotify name GameModifierCard;

/** Holds the mission tag of a bink movie to play */
var repnotify int PlayBinkMission;

/** If this is true, we are playing a bink movie */
var bool bPlayingBinkMovie;
var bool bWasPlayingBinkMovie;

var string MovieThatIsPlaying;

var repnotify int HostChapterMask;

struct native BoneMaskData
{
	var int A;
	var int B;
};

var repnotify BoneMaskData BoneMask;

var bool bBonesUpToDate;

var repnotify bool bShowCredits;

var string CreditsSceneRef;



replication
{
	if (Role == ROLE_Authority)
		PendingMissionInfo, LastMissionID, LastMissionResult,GameModifierCard,ClientMissionTagList, HostChapterMask, PlayBinkMission, BoneMask, bShowCredits;
}

/**
 * Prime the Mission List and try to find the globes.
 */
simulated function PostBeginPlay()
{
	local UTSPGlobe Globe;
	local class<UTMissionInfo> MissionInfoClass;
	local int i;
	local string s;
	local int MI;

	// Clear the client mission list

	for (i=0;i<MAXMISSIONS;i++)
	{
		ClientMissionTagList.Data[i] = INDEX_None;
	}

	MissionInfoClass = class<UTMissionInfo>(DynamicLoadObject(default.MissionInfoClassName,class'Class'));
	if ( MissionInfoClass != none )
	{
		MissionData = new(outer) MissionInfoClass;
		if ( MissionData == none )
		{
			`log("WARNING: Could not create an instance of the Mission Info. A lot will be broken!  Epic please fix");
		}
	}
	else
	{
		`log("WARNING: Could not create the mission info class ("$MissionInfoClassName$").  A lot will be broken!");
	}

	Super.PostBeginPlay();


	if ( CurrentMidGameMenu != none )
	{
		CurrentMidGameMenu.CloseScene(CurrentMidGameMenu);
	}

	FillMissionlist();

	// Find all of the globes in the map

	foreach AllActors(class'UTSPGLobe',Globe)
	{
		Globes[Globes.Length] = Globe;
	}

	// If the mission is missing a bone name or map globe tag try and add one
	for (i=0;i<FullMissionList.Length;i++)
	{
		MI = MissionData.GetMissionIndex( FullMissionList[i].MissionID );
		if ( MI != INDEX_NONE )
		{
			if (MissionData.Missions[MI].GlobeBoneName == '')
			{
				s = MissionData.Missions[MI].Map;
				s = Repl(s,"WAR-","ONS-");
				s = Repl(s,"war-","ONS-");
				s = Repl(s,"-","");
				if (s != "")
				{
					s = "B_"$s;

					`log("Fixing up Map Point Bone Name:"@s);

					MissionData.Missions[MI].GlobeBoneName = name(s);
				}
			}

			if (MissionData.Missions[MI].CameraDist <= 0.0 )
			{
				MissionData.Missions[MI].CameraDist = 384.0;
			}

			if (MissionData.Missions[MI].GlobeTag == '' )
			{
				MissionData.Missions[MI].GlobeTag = 'Taryd';
			}

		}
	}
}


/**
 * Given a mission index, look up the mission
 *
 * @param	MissionTag	Name of the mission to get
 */
simulated function UTSeqObj_SPMission GetMissionObj(int MissionID)
{
	local int i;
	for (i=0;i<FullMissionList.Length;i++)
	{
		if (FullMissionList[i].MissionID == MissionID)
		{
			return FullMissionList[i];
		}
	}

	return None;
}

/**
 * @Returns the current mission
 */
simulated function UTSeqObj_SPMission GetCurrentMissionObj()
{
	return GetMissionObj(CurrentMissionID);
}

/**
 * @Returns a mission associated with a tag
 */
simulated function bool GetMission(int MissionID, out EMissionInformation Mission)
{
	return MissionData.GetMission(MissionID, Mission);
}

simulated function bool GetCurrentMission(out EMissionInformation Mission)
{
	return GetMission(CurrentMissionID, Mission);
}

simulated function string GetMissionStyleName(EMissionStyle MissionStyle)
{
	return MissionData.MissionTypeDesc[int(MissionStyle)];
}


/**
 * @Returns a globe
 */
simulated function bool FindGlobe(name GlobeTag, out UTSPGlobe OutGlobe)
{
	local int i;
	for (i=0;i<Globes.Length;i++)
	{
		if ( Globes[i].GlobeTag == GlobeTag )
		{
			OutGlobe = Globes[i];
			return true;
		}
	}
	OutGlobe = none;
	return false;
}

simulated function SetChapterMask()
{
	local int MyChapterMask;
	local UTPlayerController PC;
	local UTProfileSettings Profile;

	foreach Worldinfo.AllControllers(class'UTPlayerController',PC)
	{
		Profile = UTProfileSettings( PC.OnlinePlayerData.ProfileProvider.Profile);
		MyChapterMask = Profile.GetChapterMask();

		if (HostChapterMask > MyChapterMask)
		{
			Profile.SetChapterMask(HostChapterMask);
			PC.SaveProfile();
		}
	}
}

function ShowCredits()
{
	bShowCredits = true;
	ReplicatedEvent('bShowCredits');	// Let the host show credits
}

simulated function ClientShowCredits()
{
	local UIScene SceneToOpenReference;
	local GameUISceneClient SC;
	SceneToOpenReference = UIScene(DynamicLoadObject(CreditsSceneRef, class'UIScene'));
	SC = class'UIRoot'.static.GetSceneClient();

	if ( SC != none && SceneToOpenReference != none )
	{
		SC.OpenScene(SceneToOpenReference);
	}
}

simulated function ReplicatedEvent(name VarName)
{
	local EMissionInformation Mission;

	if ( VarName == 'bShowCredits' )
	{
		ClientShowCredits();
	}

	if ( VarName == 'HostChapterMask' )
	{
		SetChapterMask();
	}

	if ( VarName == 'PendingMissionInfo' )
	{
		if ( PendingMissionInfo.PendingMissionID != CurrentMissionID )
		{
			ChangeMission(PendingMissionInfo.PendingMissionID);
		}
		if ( PendingMissionInfo.PendingMenuState != CurrentMenuState )
		{
			ChangeMenuState(PendingMissionInfo.PendingMenuState);
		}
	}

	if ( VarName == 'ClientMissionTagList' )
	{
		ClientSyncMissions();
	}

	if ( VarName == 'GameModifierCard' )
	{
		if ( SelectionScene != none )
		{
			SelectionScene.ModifierCardChanged(GameModifierCard,self);
		}
	}

	if ( VarName == 'PlayBinkMission')
	{
		if (PlayBinkMission > INDEX_None)
		{
			if (GetMission(PlayBinkMission,Mission) )
			{
				PlayBinkMovie(Mission.Map);
				// Clear the available mission list..
				AvailMissionList.Remove(0,AvailMissionList.Length);
			}
		}
		else
		{
			StopBinkMovie();
		}
	}

	if ( VarNAme == 'BoneMask' )
	{
		SetupBoneIndicators();
	}

	Super.ReplicatedEvent(VarName);
}

function SetModifierCard(name Card)
{
	GameModifierCard = Card;
	if (WorldInfo.NetMode != NM_Client && SelectionScene != none)
	{
		SelectionScene.ModifierCardChanged(GameModifierCard,self);
	}
}

/**
 * Note, until the menu scene is activated, this will be unused
 */
simulated function ChangeMission(int NewMissionID)
{
	local UTMissionPlayerController PC;
	local EMissionInformation Mission;
	local UTSPGlobe Globe;

	// Hide the affects for the current mission.

	if ( GetCurrentMission(Mission) )
	{
		if ( Mission.MapBeacon != none )
		{
			Mission.MapBeacon.SetStaticMesh(MapPointSFXTemplate);
		}

		if ( FindGlobe(Mission.GlobeTag, Globe) )
		{
			Globe.SetHidden(true);
		}

	}

	CurrentMissionID = NewMissionID;
	if ( SelectionScene != none )
	{
		if (ROLE == ROLE_Authority) // Setup Replication
		{
			PendingMissionInfo.PendingMissionID = NewMissionID;
		}
	}

	if ( GetCurrentMission( Mission) )
	{
		// Tell any local players to change their views
		foreach WorldInfo.AllControllers(class'UTMissionPlayerController',PC)
		{
			if ( LocalPlayer(PC.Player) != none )
			{
				if ( Mission.MapBeacon != none )
				{
					Mission.MapBeacon.SetStaticMesh(SelectedMapPointSFXTemplate);
				}
				PC.SetMissionView(Mission.GlobeBoneName, Mission.GlobeTag, Mission.CameraDist);
			}
		}

		if ( SelectionScene != none )
		{
			SelectionScene.MissionChanged(Mission);
		}

		if ( FindGlobe(Mission.GlobeTag, Globe) )
		{
			Globe.SetHidden(false);
		}

	}
}

/**
 * We need a different menu
 */
simulated function ChangeMenuState(EMenuState NewState)
{
	if (ROLE == ROLE_Authority)	// Setup Replication
	{
		PendingMissionInfo.PendingMenuState = NewState;
	}
	CurrentMenuState = NewState;
	bForceNetUpdate = TRUE;
	GotoState('MenuStateChanged');
}

/**
 * We might not have all of the needed data replicated when we get the
 * first menu state change.  So we use a state to wait for all the information
 * and then perform the action
 */
state MenuStateChanged
{
	// Set the timer to check
	simulated function BeginState(name PrevStateName)
	{
		Super.BeginState(PrevStateName);

		if ( !AttemptStateChange() )
		{
			SetTimer(0.1,true,'TryAgain');
		}
		else
		{
			GotoState('');
		}
	}

	// Check replication again
	simulated function TryAgain()
	{
		if ( AttemptStateChange() )
		{
			ClearTimer('TryAgain');
			GotoState('');
		}
	}

	// Attempt to open a given menu on the client.
	simulated function bool AttemptStateChange()
	{
		local PlayerController PC;
		local LocalPlayer LP;
		local UTMissionSelectionPRI PRI;
		local UIInteraction UIController;
		local UIScene OutScene;
		local UIScene ResolvedSceneTemplate;

//		`log("[SinglePlayer] AttemptStateChange()"@CurrentMenuState@CurrentMissionID@PendingMissionInfo.PendingMissionID);

		if (WorldInfo.GRI == self && !WorldInfo.IsInSeamlessTravel())
		{
			ForEach LocalPlayerControllers(class'PlayerController', PC)
			{
				// Check all replication conditions
				LP = LocalPlayer(PC.Player);

				PRI = UTMissionSelectionPRI(PC.PlayerReplicationInfo);
				if (PRI != none && PRI.Owner == PC && LP != none)
				{
					UIController = LP.ViewportClient.UIController;
					if ( UIController != none )
					{
						switch (CurrentMenuState)
						{
							case EMS_None:
								if ( SelectionScene != none )
								{
									UIController.CloseScene(SelectionScene);
									SelectionScene = none;
								}
								if ( BriefingScene != none )
								{
									UIController.CloseScene(BriefingScene);
									BriefingScene = none;
								}
								break;

							case EMS_Selection:

								if ( BriefingScene != none )
								{
									UIController.CloseScene(BriefingScene);
									BriefingScene = none;
								}

								if ( SelectionScene == none )
								{
									ResolvedSceneTemplate = UIScene(DynamicLoadObject(SelectionSceneTemplate, class'UIScene'));
									if(ResolvedSceneTemplate != None)
									{
										UIController.OpenScene(ResolvedSceneTemplate,LP,OutScene);
										SelectionScene = UTUIScene_CMissionSelection(OutScene);
										SelectionScene.InitializeMissionMenu(LastMissionResult, PRI.bIsHost , LastMissionID, Self);
										SelectionScene.FinishMissionChanged(CurrentMissionID);
									}
								}
								break;

							case EMS_Brief:
							case EMS_Launch:
								ResolvedSceneTemplate = UIScene(DynamicLoadObject(BriefingSceneTemplate, class'UIScene'));
								if(ResolvedSceneTemplate != None)
								{
									if (SelectionScene != none )
									{
										SelectionScene.AudioPlayer.Stop();
										UIController.CloseScene(SelectionScene);
										SelectionScene = none;
									}

									UIController.OpenScene(ResolvedSceneTemplate,LP,OutScene);
									BriefingScene = UTUIScene_CMissionBriefing(OutScene);

									// Show the final briefing menu

									if ( BriefingScene != none )
									{
										BriefingScene.Launch(self);
									}

									PRI.ServerReadyToPlay();
								}
								break;
						}
						return true;
					}
				}
			}
		}
		return false;
	}
}

/**
 * Adds a mission to the available Mission List
 */
simulated function AddAvailableMission(EMissionInformation NewMission)
{
	local int MIDX;
	local UTSPGlobe Globe;

	AvailMissionList[AvailMissionList.Length] = NewMission;

    // Added the current mission icons to the globe
	if ( FindGlobe( NewMission.GlobeTag,Globe) )
	{
		// Get the actual reference
		MIDX = MissionData.GetMissionIndex(NewMission.MissionID);
		MissionData.Missions[MIDX].MapBeacon = new(self)class'StaticMeshComponent';
		MissionData.Missions[MIDX].MapBeacon.SetStaticMesh(MapPointSFXTemplate);

		Globe.SkeletalMeshComponent.AttachComponent(MissionData.Missions[MIDX].MapBeacon,NewMission.GlobeBoneName);
	}

	if ( WorldInfo.NetMode != NM_Client )
	{
		if (ClientMissionTagCount < MAXMISSIONS)
		{
			ClientMissionTagList.Data[ClientMissionTagCount] = NewMission.MissionID;
//			`log("### Adding a Mission"@ClientMissionTagList.Data[i]);
		}
		else
		{
			`log("The Game is trying to send too many missions!");
		}
		ClientMissionTagCount++;
	}
}

/**
 * This function will take the data replicated from the server and fill out the
 * available missions array.
 */

simulated function ClientSyncMissions()
{
	local int i;
	local EMissionInformation Mission;

	// Clear any data already there
	AvailMissionList.Remove(0,AvailMissionList.Length);

	for (i=0;i<MAXMISSIONS;i++)
	{
		if ( ClientMissionTagList.Data[i] > INDEX_None && GetMission(ClientMissionTagList.Data[i],Mission) )
		{
			AddAvailableMission(Mission);
		}
	}
}


simulated function SetupBoneIndicators()
{
	local int i,j;
	local array<Name> BoneList;
	local bool bSkip;
	local StaticMeshComponent Mesh;
	local UTSPGlobe G, Worlds[2];

	// Don't do on a dedicated server
	if (bBonesUpToDate || WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}

	i = 0;
	Foreach AllActors(class'UTSPGlobe',G)
	{
		if (i<2)
		{
			Worlds[i] = G;
			i++;
		}
	}

	class'UTProfileSettings'.static.GetListOfVisitedBones(BoneMask.A, BoneMask.B, BoneList);

	for (i=0;i<BoneList.Length;i++)
	{

		bSkip = false;
		for (j=0;j<AvailMissionList.Length;j++)
		{
			if ( AvailMissionList[j].GlobeBoneName == BoneList[i] )
			{
				bSkip = true;
				break;
			}
		}

		if (!bSkip)
		{
			Mesh = 	new(self)class'StaticMeshComponent';
			Mesh.SetStaticMesh(PrevMapPointSFXTemplate);

			for (j=0;j<2;j++)
			{
				if ( Worlds[j].SkeletalMeshComponent.MatchRefBone(BoneList[i]) != INDEX_None )
				{
					Worlds[j].SkeletalMeshComponent.AttachComponent(Mesh, BoneList[i]);
					break;
				}
			}
		}
	}


	bBonesUpToDate = true;
}

/*****************************************************************
 Bink Movie Support
 *****************************************************************/
native function FillMissionList();

/** Plays a bink movie */
native function PlayBinkMovie(string MovieToPlay);
/** Stops a bink movie */
native function StopBinkMovie();

/** If assigned, this delegate will be called when the movie has been completed */
delegate OnBinkMovieFinished();

defaultproperties
{
	SelectionSceneTemplate="UI_Scenes_Campaign.Scenes.CampMissionSelection"
	BriefingSceneTemplate="UI_Scenes_Campaign.Scenes.CampMissionBriefing"

	PrevMapPointSFXTemplate=StaticMesh'UI_SinglePlayer_World.Mesh.S_SP_UI_Effect_PointRingPrevious'
	MapPointSFXTemplate=StaticMesh'UI_SinglePlayer_World.Mesh.S_SP_UI_Effect_PointRingEnabled'
	SelectedMapPointSFXTemplate=StaticMesh'UI_SinglePlayer_World.Mesh.S_SP_UI_Effect_PointRing'
 	PlayBinkMission=-1


 	MissionInfoClassName="UTGameContent.UTMissionInfo_Content"
	CreditsSceneRef="UI_Scenes_FrontEnd.Scenes.Credits"

}
