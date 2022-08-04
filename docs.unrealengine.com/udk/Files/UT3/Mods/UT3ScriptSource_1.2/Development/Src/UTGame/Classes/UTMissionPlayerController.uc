/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTMissionPlayerController extends UTEntryPlayerController
	native;

enum ETransitionState
{
	ETS_None,
	ETS_Fly,
};

var ETransitionState CameraTransitionState;

struct native ECameraTransitionPoint
{
	/** The name of the bone we want to move towards */
	var name BoneName;

	/** The SkeletalMesh of the Globe we are moving to */
	var SkeletalMeshActor DestGlobe;

	/** How far off of the map do we sit */
	var float MapDist;
};

var vector  	CameraLocation;
var rotator  	CameraLook;

var ECameraTransitionPoint NewCameraTransitionPoint;
var ECameraTransitionPoint CameraStartPoint, CameraEndPoint;
var vector FlyOutLocation, FlyOutCamera;
var bool bOverrideTransition;

var float CameraTransitionTime;
var float CameraOutTransitionDuration;
var float CameraInTransitionDuration;

var float Tanmod;

var int GlobeIndex;
var bool bInitialSet;
var bool bNoUI;

var float CameraPullBackDistance;

var bool bTest;
var float TestFloat;



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

}

exec function ToggleCampaignUI()
{
	local UTMissionGRI GRI;
	GRI = UTMissionGRI(WorldInfo.GRI);
	if ( GRI != none && GRI.SelectionScene != none )
	{
		if ( bNoUI )
		{
			GRI.SelectionScene.SetSceneInputMode(INPUTMODE_Locked);
			GRI.SelectionScene.SetVisibility(true);
			bNoUI = false;
		}
		else
		{
			GRI.SelectionScene.SetSceneInputMode(INPUTMODE_None);
			GRI.SelectionScene.SetVisibility(false);
			bNoUI = true;
		}
	}
}

exec function MissionTest(int MissionID)
{
	UTMissionGRI(WorldInfo.GRI).ChangeMission(MissionID);
}

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	// See if we can find out destination
	if ( bNoUI )
	{
		out_CamLoc = Location;
		out_CamRot = rotation;
	}
	else
	{
		out_CamLoc = CameraLocation;
		out_CamRot = CameraLook;
	}
	return false;
}

function SetMissionView(name BoneName, name MapGlobe, float MapDist)
{
	local UTSPGlobe Globe;

	// See if we can find out destination
	if ( UTMissionGRI(WorldInfo.GRI).FindGlobe(MapGlobe,Globe) )
	{
		// Set the new final destination

		NewCameraTransitionPoint.BoneName = BoneName;
		NewCameraTransitionPoint.DestGlobe = Globe;
		NewCameraTransitionPoint.MapDist = MapDist;

		// Now, what we do depends on what we are doing.

	    if (bInitialSet)
	    {
	    	// Calculate the first position and fly in from there

	    	bInitialSet = false;

			CameraStartPoint.BoneName = '';
			CameraStartPoint.DestGlobe = Globe;
			CameraStartPoint.MapDist = CameraPullBackDistance;

			CameraEndPoint = NewCameraTransitionPoint;
			CameraTransitionState = ETS_Fly;

		}

		else if ( CameraTransitionState == ETS_None )
		{
			// We are at rest on a current point so start a fly out

			CameraStartPoint = CameraEndPoint;
			CameraEndPoint = NewCameraTransitionPoint;

			CameraTransitionTime = CameraInTransitionDuration;
			CameraTransitionState = ETS_Fly;
		}
		else
		{
			if (CameraStartPoint.BoneName == NewCameraTransitionPoint.BoneNAme && CameraEndPoint.BoneName != '' )
			{
				CameraStartPoint = CameraEndPoint;
				CameraTransitionTime = CameraInTransitionDuration - CameraTransitionTime;
			}

			CameraEndPoint = NewCameraTransitionPoint;
		}

		// Otherwise we are all set :)

	}
	else
	{
		`log("Attempting to view a globe that doesn't exist"@MapGlobe$"."$BoneName);
	}
}

event CameraTransitionDone()
{
	local UTMissionGRI GRI;
	GRI = UTMissionGRI(WorldInfo.GRI);
	if ( GRI != none && GRI.SelectionScene != none )
	{
		GRI.SelectionScene.FinishMissionChanged(GRI.CurrentMissionID);
	}

	CameraTransitionState = ETS_None;
}
`if(`notdefined(ShippingPC))

exec function SetInRate(float NewRate)
{
	CameraInTransitionDuration = NewRate;
}

exec function SetOutRate(float NewRate)
{
	CameraOutTransitionDuration = NewRate;
}


exec function SetDist(float NewDist)
{
	CameraPullBackDistance = NewDist;
}

exec function SetTanMod(float NewTanMod)
{
	TanMod = NewTanMod;
}

`endif

event InitInputSystem()
{
	// Need to bypass the UTPlayerController since it initializes voice and we do not want to do that in the menus.
	Super(GamePlayerController).InitInputSystem();

	AddOnlineDelegates(false);
}

function LoadCharacterFromProfile(UTProfileSettings Profile)
{
	Super(UTPlayerController).LoadCharacterFromProfile(Profile);
}

function SetPawnConstructionScene(bool bShow)
{
	Super(UTPlayerController).SetPawnConstructionScene(bShow);
}

exec function ShowMap();
exec function ShowMenu();
exec function ToggleMinimap();
exec function ShowQuickPick();
exec function ShowCommandMenu();
exec function HideQuickPick();

function QuitToMainMenu()
{
	Super(UTPlayerController).QuitToMainMenu();
}

client reliable function ClientUnlockChapter(int ChapterIndex)
{
	local UTProfileSettings Profile;
	Profile = UTProfileSettings( OnlinePlayerData.ProfileProvider.Profile);
	if ( Profile != none )
	{
		Profile.UnlockChapter(ChapterIndex);
		SaveProfile();
	}
}


exec function AddCard(string CardName)
{
	local UTProfileSettings Profile;
	local int i,cnt;

	Profile = UTProfileSettings( OnlinePlayerData.ProfileProvider.Profile);
	if ( Profile != none )
	{
		cnt = Rand(3);
		for (i=0;i<Cnt;i++)
		{
			Profile.AddModifierCard(name(CardName));
		}
	}

}

defaultproperties
{
	CameraInTransitionDuration=2.0
	Tanmod=32
	bInitialSet=true
	CameraPullBackDistance=400
}
