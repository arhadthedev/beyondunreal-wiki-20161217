/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_CMissionBriefing extends UTUIScene_Campaign
	native(UI);

/** UI Controls we adjust */
var transient UILabel MissionName;
var transient UIImage CloseInMap;
var transient UIPanel BriefBar;
var transient UIPanel ObjectiveBar;

var transient UILabel ObjectiveText;
var transient UIImage ObjectiveImage;
var transient UILabel LoadingLabel;
var transient UIImage LoadingLogo;
var transient UIImage LoadingImage;

var transient UILabelButton StartGameButton;

var transient UIImage PlayerBox;
var transient UILabel PlayerLabels[4];
var transient UIImage PlayerReady[4];


var transient EMissionInformation FinalMission;

var transient bool bFinalStage;
var transient int ObjectiveDisplayIndex;
var transient float ObjectiveTimer;

var editconst AudioComponent AudioPlayer;
var editconst AudioComponent NotificationAudioPlayer;



/** Setup */
event PostInitialize()
{
	local int i;

	Super.PostInitialize();

	MissionName = UILabel(FindChild('MissionName',true));
	CloseInMap = UIImage(FindChild('CloseInMap',true));

	ObjectiveBar = UIPanel(FindChild('ObjectiveBar',true));

    StartGameButton = UILabelButton(FindChild('StartButton',true));
    StartGameButton.OnClicked=StartGameClick;

    // if we're on the console, don't allow the start button to receive focus
    if ( IsConsole() )
    {
    	StartGameButton.SetPrivateBehavior(PRIVATE_NotFocusable, true);
    }

	ObjectiveText = UILabel(FindChild('ObjectiveText',true));
	ObjectiveImage = UIIMage(FindChild('Objective_Image',true));

    LoadingLabel = UILabel(FindChild('Connecting',true));
    LoadingImage = UIImage(FindChild('ConnectingImage',true));
    LoadingLogo	 = UIImage(FindChild('ConnectingImageULogo',true));


    PlayerBox = UIImage (FindChild('PlayerBox',true));
    PlayerBox.SetVisibility(true);

	for (i=0;i<4;i++)
	{
	    PlayerLabels[i] = UILabel( FindChild(name("PlayerLabel"$i),true));
	    PlayerReady[i] = UIImage (FindChild(name("ReadyU"$i),true));
	}
}

function Launch(UTMissionGRI MGRI)
{
	if ( MGRI.GetCurrentMission(FinalMission) )
	{
		// Make sure to clear the reference to the actor object that is hanging around
		// so the game doesn't crash.

		FinalMission.MapBeacon = none;
		MissionName.SetDatastoreBinding(FinalMission.Title$" -<Strings:UTGameUI.Campaign.Objectives>");

		if ( FinalMission.ObjectiveText != "" )
		{
			ObjectiveText.SetDataStoreBinding(FinalMission.ObjectiveText);
		}

		// Set the background image

		if ( CloseInMap != none && FinalMission.BriefingImage != none )
		{
			CloseInMap.Imagecomponent.SetImage( FinalMission.BriefingImage );
			if ( FinalMission.bCustomBriefingCoords )
			{
				CloseInMap.ImageComponent.SetCoordinates( FinalMission.BriefingCoords );
			}
		}

		if ( FinalMission.BriefingAudioCue != none )
		{
			PlaySound(FinalMission.BriefingAudioCue);
		}

	}

	NextObjective();
	LoadingLabel.SetVisibility(true);
	LoadingImage.SetVisibility(true);
	LoadingLogo.SetVisibility(true);
}

event SceneDeactivated()
{
	Super.SceneDeactivated();
}


/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_A')
		{
			if ( StartGameButton != none && StartGameButton.IsVisible() )
			{
				StartGame();
			}
			return true;
		}
	}

	return true;
}


/**
 * Called by UTUI_SinglePlayer when on the objectives/loading screen after loading finishes and we're waiting
 * waiting for the user to press the 'Begin Mission' button to start the game.
 */
event MissionReadyToStart()
{
	PlayObjectiveSound(soundcue'A_interface.Menu.UT3MenuMatchReady01Cue');
}


function bool StartGameClick(UIScreenObject EventObject, int PlayerIndex)
{
	StartGame();
	return true;
}

function StartGame()
{
	local WorldInfo WI;
	local UTGame G;
	if ( StartGameButton != none && StartGameButton.IsVisible() )
	{
		// DB: When the user has clicks the 'Begin Mission' button, make sure
		// DB: that any mission briefing audio that's still playing gets stopped,
		// DB: so that it won't continue to play in game.
		AudioPlayer.Stop();

		SceneClient.CloseScene(self);

		WI = GetWorldInfo();

		// Have the host start the match

		if ( WI != none && WI.Role == ROLE_Authority )
		{
			G = UTGame(WI.Game);
			if (G!=none)
			{
			 	G.StartMatch();
			}
		}
	}
}

event NextObjective()
{
	local string s;
	local int i;
	local string colorcode;
	if (FinalMission.Objectives.Length > 0)
	{
		ObjectiveDisplayIndex++;
		if (ObjectiveDisplayIndex == FinalMission.Objectives.Length)
		{
			ObjectiveDisplayIndex = -1;
			return;
		}

		ObjectiveTimer = FinalMission.Objectives[ObjectiveDisplayIndex].FocusTime;

		PlayObjectiveSound(soundcue'A_interface.Menu.UT3MenuMatchFocus01Cue');

		for (i=0;i<FinalMission.Objectives.Length;i++)
		{

			// Add the carriage return

			if (s != "")
			{
				S = S $ "\n ";
			}
			else
			{
				S = " ";
			}

			ColorCode = (i == ObjectiveDisplayIndex) ? "<color:R=0.9,G=0.9,B=0.9>" : "<color:R=0.3,G=0.3,B=0.3>";

			s = S $ ColorCode $ "-" @ finalMission.Objectives[i].Text;
		}
		ObjectiveText.SetDatastoreBinding(s);

		if ( FinalMission.Objectives[ObjectiveDisplayIndex].Image != none )
		{
			ObjectiveImage.SetVisibility(true);
			ObjectiveImage.ImageComponent.SetImage(FinalMission.Objectives[ObjectiveDisplayIndex].Image);
			if ( FinalMission.Objectives[ObjectiveDisplayIndex].bCustomCoords )
			{
				ObjectiveImage.ImageComponent.SetCoordinates( FinalMission.Objectives[ObjectiveDisplayIndex].ImageCoords);
			}
			else
			{
				ObjectiveImage.ImageComponent.DisableCustomCoordinates();
			}
		}
		else
		{
			ObjectiveImage.SetVisibility(false);
		}
	}
}

function PlaySound(SoundCue SoundToPlay)
{
	//`log( "!!!!!!!!!!!!!!!!!!!!!!!MISSIONBRIEFING PLAYSOUND:" @ SoundToPlay );
	AudioPlayer.SoundCue = SoundToPlay;
	// Set bIgnoreForFlushing to TRUE so that the audio won't be stopped
	// by the audio device flush issued from the seamless travel handler.
	AudioPlayer.bIgnoreForFlushing=TRUE;
	AudioPlayer.Play();
}

/**
 * This function allows you to play various objective notification sounds on top of the briefing music which is played through PlaySound().
 */
function PlayObjectiveSound(SoundCue SoundToPlay)
{
	//`log( "!!!!!!!!!!!!!!!!!!!!!!!MISSIONBRIEFING PLAY OBJECTIVE SOUND:" @ SoundToPlay );
	NotificationAudioPlayer.SoundCue = SoundToPlay;
	// Set bIgnoreForFlushing to TRUE so that the audio won't be stopped
	// by the audio device flush issued from the seamless travel handler.
	NotificationAudioPlayer.bIgnoreForFlushing=TRUE;
	NotificationAudioPlayer.Play();
}

defaultproperties
{
	Begin Object class=AudioComponent Name=ACPlayer
		bAllowSpatialization=false
	End Object
	AudioPlayer=ACPlayer

	Begin Object class=AudioComponent Name=ObjectivePlayer
		bAllowSpatialization=false
	End Object
	NotificationAudioPlayer = ObjectivePlayer

	bExemptFromAutoClose=true
	bCloseOnLevelChange=false
	ObjectiveDisplayIndex=-1
}
