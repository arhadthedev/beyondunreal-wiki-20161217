/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTGameUISceneClient extends GameUISceneClient
	dependson(UTSeqObj_SPMission)
	dependson(UTUIScene_SaveProfile)
	dependson(UTUIScene_TutorialMessage)
	dependson(UTUIScene_TimedTutorialMessage)
	native(UI);

/** Debug values */

var(Debug)  bool bShowRenderTimes;
var float PreRenderTime;
var float RenderTime;
var float TickTime;
var float AnimTime;
var float AvgTime;
var float AvgRenderTime;
var float FrameCount;
var float StringRenderTime;

/** Holds a copy of the current mission info */
var transient EMissionData CurrentMissionData;

/** Holds the mission briefing */
var transient string MissionText;

var UTUIScene_SaveProfile SaveProfileTemplate;
var UTUIScene_TutorialMessage TutorialTemplate;
var UTUIScene_TimedTutorialMessage TimedTutorialTemplate;

/** Toast message to display. */
var transient string ToastMessage;

/** The time the toast message was displayed at. */
var transient float	ShowStartTime;

/**
 * This is true if the first frame of the toast message has been drawn.
 * We need to know this because sometimes toast messages are shown durring movies (meaning they aren't displayed)
 * and on the first frame we need to reset ShowStartTime so that the toast message is actually displayed.
 */
var transient bool bFirstFrame;

/** Whether or not the toast is visible. */
var transient bool bToastVisible;

/** The time the toast message started hiding itself. */
var transient float	HideStartTime;

/** Whether or not we are hiding the toast. */
var transient bool bHidingToast;

/** Amount of time to display the toast for. */
var transient float ToastDuration;

/** Amount of time toast takes to transition. */
var transient float	ToastTransitionTime;

/** Toast image information. */
var transient Font		ToastFont;
var transient Texture2D	ToastImage;
var transient float		ToastImageU;
var transient float		ToastImageV;
var transient float		ToastImageUL;
var transient float		ToastImageVL;

/** Scale of toast message background image and text */
var transient float		ToastScale;

/** Toast colors */
var transient LinearColor	ToastColor;
var transient LinearColor	ToastTextColor;

/** Whether or not to dim the entire screen, used for the network dialog on ps3. */
var transient bool bDimScreen;

var transient name LastModifierCardUsed;



/**
 * Returns the WorldInfo
 */
native static  function WorldInfo GetWorldInfo();

native function bool IsInSeamlessTravel();

function NotifyGameSessionEnded()
{
	Super.NotifyGameSessionEnded();
	ChangeActiveSkin(UISkin'UI_InGameHud.UTHUDSkin');
}


/**
 * Sets the current mission data
 */

function SetCurrentMission(EMissionData NewMissionData)
{
	CurrentMissionData = NewMissionData;
}

/** @return TRUE if there are any scenes currently accepting input, FALSE otherwise. */
native function bool IsUIAcceptingInput();


/**
 * Displays the Saving Profile scene
 *
 * @param PlayerOwner	Player to save profile info for.
 *
 * @return	Returns a ref to the scene if one was shown, otherwise, returns None.
 */
function UTUIScene_SaveProfile ShowSaveProfileScene(UTPlayerController PlayerOwner)
{
	local UIScene Result;
	local UIDataStore_OnlinePlayerData	PlayerDataStore;

	Result = None;

	if(PlayerOwner != None)
	{
		// Only show the scene on consoles.
		if ( class'UIRoot'.static.IsConsole() )
		{
			OpenScene(SaveProfileTemplate,LocalPlayer(PlayerOwner.Player),Result);
		}
		else
		{
			PlayerDataStore = UIDataStore_OnlinePlayerData(DataStoreManager.FindDataStore('OnlinePlayerData', LocalPlayer(PlayerOwner.Player)));

			if(PlayerDataStore != none)
			{
				PlayerDataStore.SaveProfileData();
			}
		}
	}

	return UTUIScene_SaveProfile(Result);
}

/**
 * Sets the current message for this scene.
 *
 * @param Message		Message to display
 * @param ToastTime		How long to display the message for.  A value of < 0 will make the message stay up forever until hidden manually, and any subsequent calls wont override the existing message.
 */
function SetToastMessage(string Message, optional float ToastTime=6.0f)
{
	if(bToastVisible==false)
	{
		bToastVisible=true;
		bHidingToast=false;
		ToastDuration=ToastTime;
		ToastMessage = Message;
		ShowStartTime = GetWorldInfo().RealTimeSeconds;
		bFirstFrame = false;
	}
	else if(ToastDuration > 0.0f)
	{
		ToastMessage = Message;
		ShowStartTime = GetWorldInfo().RealTimeSeconds + ToastTransitionTime;
	}
}

/** Called when the toast is complete and ready to be hidden. */
event FinishToast()
{
	HideStartTime=GetWorldInfo().RealTimeSeconds;
	bHidingToast=true;
	bFirstFrame = false;
}


defaultproperties
{
	ToastTransitionTime = 0.125f;
	ToastColor=(R=0.95f,G=0.95f,B=0.95f,A=1.0f)
	ToastTextColor=(R=0.5f,G=0.0f,B=0.0f,A=1.0f)
	ToastImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseD'
	ToastImageU=15
	ToastImageUL=200
	ToastImageV=0
	ToastImageVL=171
	ToastFont=Font'UI_Fonts_Final.Menus.Fonts_Positec'
	ToastScale=1.5

	Begin Object Class=UIAnimationSeq Name=seqRotPitchNeg90
		SeqName=RotPitchNeg90
		SeqDuration=0.6
		Tracks(0)=(TrackType=EAT_Rotation,KeyFrames=((TimeMark=0.0,Data=(DestAsRotator=(Pitch=16384))),(TimeMArk=1.0,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqRotPitchNeg90)

	Begin Object Class=UIAnimationSeq Name=seqRotPitch90
		SeqName=RotPitch90
		SeqDuration=0.6
		Tracks(0)=(TrackType=EAT_Rotation,KeyFrames=((TimeMark=0.0,Data=(DestAsRotator=(Pitch=0))),(TimeMArk=1.0,Data=(DestAsRotator=(Pitch=16384)))))
	End Object
	AnimSequencePool.Add(seqRotPitch90)

	Begin Object Class=UIAnimationSeq Name=seqFadeIn
		SeqName=FadeIn
		SeqDuration=1.0
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
	End Object
	AnimSequencePool.Add(seqFadeIn)

	Begin Object Class=UIAnimationSeq Name=seqFadeOut
		SeqName=FadeOut
		SeqDuration=1.0
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
	End Object
	AnimSequencePool.Add(seqFadeOut)


	/** For the first time the scene is open. */
	Begin Object Class=UIAnimationSeq Name=seqSceneShowInitial
		SeqName=SceneShowInitial
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneShowInitial)

	/** For non-initial showings of the scene. */
	Begin Object Class=UIAnimationSeq Name=seqSceneShowRepeat
		SeqName=SceneShowRepeat
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneShowRepeat)

	/** For when we are hiding a scene without closing it. */
	Begin Object Class=UIAnimationSeq Name=seqSceneHide
		SeqName=SceneHide
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=0.99,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (TimeMark=0.99,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneHide)

	/** For when we are hiding a scene by closing it. */
	Begin Object Class=UIAnimationSeq Name=seqSceneHideClosing
		SeqName=SceneHideClosing
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
		Tracks(1)=( TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqSceneHideClosing)

	// Button Bar
	Begin Object Class=UIAnimationSeq Name=seqButtonBarShow
		SeqName=ButtonBarShow
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqButtonBarShow)

	Begin Object Class=UIAnimationSeq Name=seqButtonBarHide
		SeqName=ButtonBarHide
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqButtonBarHide)

	// Title Label
	Begin Object Class=UIAnimationSeq Name=seqTitleLabelShow
		SeqName=TitleLabelShow
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=-1.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqTitleLabelShow)

	Begin Object Class=UIAnimationSeq Name=seqTitleLabelHide
		SeqName=TitleLabelHide
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=-1.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqTitleLabelHide)

	// Tab Pages
	Begin Object Class=UIAnimationSeq Name=seqTabPageEnterRight
		SeqName=TabPageEnterRight
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=0.5,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((TimeMark=0.5,Data=(DestAsRotator=(Pitch=16834))),(TimeMArk=1.0,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageEnterRight)

	Begin Object Class=UIAnimationSeq Name=seqTabPageEnterLeft
		SeqName=TabPageEnterLeft
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((TimeMark=0.0,Data=(DestAsRotator=(Pitch=-16834))),(TimeMArk=1.0,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageEnterLeft)

	Begin Object Class=UIAnimationSeq Name=seqTabPageExitRight
		SeqName=TabPageExitRight
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=0.99,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (TimeMark=0.99,Data=(DestAsVector=(X=1.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((TimeMark=0.0,Data=(DestAsRotator=(Pitch=0))),(TimeMArk=0.99,Data=(DestAsRotator=(Pitch=16834))),(TimeMArk=1.0,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageExitRight)

	Begin Object Class=UIAnimationSeq Name=seqTabPageExitLeft
		SeqName=TabPageExitLeft
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=0.99,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
		//Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (TimeMark=0.99,Data=(DestAsVector=(X=-1.0,Y=0.0,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
		Tracks(1)=(TrackType=EAT_RelRotation,KeyFrames=((TimeMark=0.0,Data=(DestAsRotator=(Pitch=0))),(TimeMArk=0.99,Data=(DestAsRotator=(Pitch=-16834))),(TimeMArk=1.0,Data=(DestAsRotator=(Pitch=0)))))
	End Object
	AnimSequencePool.Add(seqTabPageExitLeft)

	// Online Toast
	Begin Object Class=UIAnimationSeq Name=seqOnlineToastShow
		SeqName=OnlineToastShow
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.0)),(TimeMark=1.0,Data=(DestAsFloat=1.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))), (TimeMark=0.9,Data=(DestAsVector=(X=0.0,Y=-0.1,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqOnlineToastShow)

	Begin Object Class=UIAnimationSeq Name=seqOnlineToastHide
		SeqName=OnlineToastHide
		SeqDuration=0.125
		Tracks(0)=(TrackType=EAT_Opacity,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=1.0)),(TimeMark=1.0,Data=(DestAsFloat=0.0))))
		Tracks(1)=(TrackType=EAT_RelPosition,KeyFrames=( (TimeMark=0.0,Data=(DestAsVector=(X=0.0,Y=0.0,Z=0.0))), (TimeMark=0.1,Data=(DestAsVector=(X=0.0,Y=-0.1,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.0,Y=1.0,Z=0.0))) ))
	End Object
	AnimSequencePool.Add(seqOnlineToastHide)

	Begin Object Class=UIAnimationSeq Name=seqBriefingSlide
		SeqName=BriefingSlide
		SeqDuration=0.3
		Tracks(0)=(TrackType=EAT_Position,KeyFrames=((TimeMark=0.0,Data=(DestAsVector=(X=0.587586,Y=0.131716,Z=0.0))), (TimeMark=1.0,Data=(DestAsVector=(X=0.046690,Y=0.131716,Z=0.0)))))
		Tracks(1)=(TrackType=EAT_Rotation,KeyFrames=((TimeMark=0.0,Data=(DestAsRotator=(Pitch=-910))),(TimeMark=1.0,Data=(DestAsRotator=(Pitch=910))) ))
	End Object
	AnimSequencePool.Add(seqBriefingSlide)

	Begin Object Class=UIAnimationSeq Name=seqExpandDetails
		SeqName=ExpandDetails
		SeqDuration=0.5
		Tracks(0)=(TrackType=EAT_Bottom,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.080291)),(TimeMark=0.5,Data=(DestAsFloat=0.520268)),(TimeMark=0.75,Data=(DestAsFloat=0.537188)),(TimeMark=0.85,Data=(DestAsFloat=0.623491)),(TimeMark=1.0,Data=(DestAsFloat=0.659028))))
		Tracks(1)=(TrackType=EAT_Right,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.344721)),(TimeMark=0.5,Data=(DestAsFloat=0.454769)),(TimeMark=0.75,Data=(DestAsFloat=0.524769)),(TimeMark=0.85,Data=(DestAsFloat=0.544769)),(TimeMark=1.0,Data=(DestAsFloat=0.554769))))
	End Object
	AnimSequencePool.Add(seqExpandDetails);

	Begin Object Class=UIAnimationSeq Name=seqContractDetails
		SeqName=ContractDetails
		SeqDuration=0.5
		Tracks(0)=(TrackType=EAT_Bottom,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.659028)),(TimeMark=0.2,Data=(DestAsFloat=0.456527)),(TimeMark=0.75,Data=(DestAsFloat=0.182490)),(TimeMark=0.85,Data=(DestAsFloat=0.1086578)),(TimeMark=1.0,Data=(DestAsFloat=0.080291))))
		Tracks(1)=(TrackType=EAT_Right,KeyFrames=((TimeMark=0.0,Data=(DestAsFloat=0.554769)),(TimeMark=0.5,Data=(DestAsFloat=0.374721)),(TimeMark=0.75,Data=(DestAsFloat=0.3684065)),(TimeMark=0.85,Data=(DestAsFloat=0.353256)),(TimeMark=1.0,Data=(DestAsFloat=0.344721))))
	End Object
	AnimSequencePool.Add(seqContractDetails);


    SaveProfileTemplate=UTUIScene_SaveProfile'UI_Scenes_Common.SaveProfile'
    TutorialTemplate=UTUIScene_TutorialMessage'UI_InGameHud.Menus.TutorialMessage'
    TimedTutorialTemplate=UTUIScene_TimedTutorialMessage'UI_InGameHud.Menus.TimedTutorialMessage'
}
