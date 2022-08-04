class WNPWindow_WinampControll extends UMenuPageWindow;

//Slider
var UWindowHSliderControl MusicSlider;
var localized string MusicText;
var localized string MusicHelp;
var int MusicSliderVolume;
var UWindowSmallButton PlayButton, PauseButton, StopButton, NextButton, PrevButton, VolUp, VolDn;
var UWindowSmallButton FastForward, FastRewind, ToggleRepeat, ToggleShuffle;
var WinampController WinampHandler;

function Created()
{
	Super.Created();

	PlayButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 5, 5, 40, 15));
	PlayButton.SetText("Play");
	PlayButton.SetFont(F_Normal);
	PlayButton.Align = TA_Right;
	PlayButton.SetHelpText("Play the music!");

	PauseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 45, 5, 40, 15));
	PauseButton.SetText("Pause");
	PauseButton.SetFont(F_Normal);
	PauseButton.Align = TA_Right;
	PauseButton.SetHelpText("Play the music!");

	StopButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 85, 5, 40, 15));
	StopButton.SetText("Stop");
	StopButton.SetFont(F_Normal);
	StopButton.Align = TA_Right;
	StopButton.SetHelpText("Stop the music!");

	NextButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 5, 25, 40, 15));
	NextButton.SetText("Prev");
	NextButton.SetFont(F_Normal);
	NextButton.Align = TA_Right;
	NextButton.SetHelpText("previous song!");

	PrevButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 45, 25, 40, 15));
	PrevButton.SetText("Next");
	PrevButton.SetFont(F_Normal);
	PrevButton.Align = TA_Right;
	PrevButton.SetHelpText("Next song!");

	VolUp = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 5, 45, 40, 15));
	VolUp.SetText("VolUp");
	VolUp.SetFont(F_Normal);
	VolUp.Align = TA_Right;
	VolUp.SetHelpText("previous song!");

	VolDn = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 45, 45, 40, 15));
	VolDn.SetText("VolDn");
	VolDn.SetFont(F_Normal);
	VolDn.Align = TA_Right;
	VolDn.SetHelpText("Next song!");
	
	FastRewind = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 5, 65, 60, 15));
	FastRewind.SetText("Rewind");
	FastRewind.SetFont(F_Normal);
	FastRewind.Align = TA_Right;
	FastRewind.SetHelpText("Next song!");

	FastForward = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 65, 65, 60, 15));
	FastForward.SetText("Forward");
	FastForward.SetFont(F_Normal);
	FastForward.Align = TA_Right;
	FastForward.SetHelpText("previous song!");

	ToggleRepeat = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 5, 85, 70, 15));
	ToggleRepeat.SetText("Toggle Repeat");
	ToggleRepeat.SetFont(F_Normal);
	ToggleRepeat.Align = TA_Right;
	ToggleRepeat.SetHelpText("previous song!");

	ToggleShuffle = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 75, 85, 70, 15));
	ToggleShuffle.SetText("Toggle Shuffle");
	ToggleShuffle.SetFont(F_Normal);
	ToggleShuffle.Align = TA_Right;
	ToggleShuffle.SetHelpText("Next song!");
}

function Notify(UWindowDialogControl C, byte E)
{
   switch(E)
   {
     case DE_Click:
       switch(C)
       {
       	   case PlayButton:
       	   	CommandWinamp("WNP_Play");
       	   break;
       	   case PauseButton:
                CommandWinamp("WNP_PlayOrPause");
       	   break;
       	   case StopButton:
                CommandWinamp("WNP_Stop");
       	   break;
       	   case NextButton:
       	   	CommandWinamp("WNP_NextTrack");
       	   break;
       	   case PrevButton:
                CommandWinamp("WNP_PreviousTrack");
       	   break;
       	   case VolUp:
       	   	CommandWinamp("WNP_RaiseVolume");
       	   break;
       	   case VolDn:
                CommandWinamp("WNP_LowerVolume");
       	   break;
       	   case FastForward:
       	   	CommandWinamp("WNP_FastForward");
       	   break;
       	   case FastRewind:
                CommandWinamp("WNP_FastRewind");
       	   break;
       	   case ToggleRepeat:
       	   	CommandWinamp("WNP_ToggleRepeat");
       	   break;
       	   case ToggleShuffle:
                CommandWinamp("WNP_ToggleShuffle");
       	   break;
       }
   break;
   }
}

function bool CommandWinamp(string command)
{
    if(!WinampHandler.static.WNP_IsActive()) return false;
    switch(command)
    {
    	case "WNP_Play":
    		WinampHandler.static.WNP_Play();
    	break;
    	case "WNP_Stop":
    		WinampHandler.static.WNP_Stop();
    	break;
    	case "WNP_PlayOrPause":
    		WinampHandler.static.WNP_PlayOrPause();
    	break;
    	case "WNP_NextTrack":
    		WinampHandler.static.WNP_NextTrack();
    	break;
    	case "WNP_PreviousTrack":
    		WinampHandler.static.WNP_PreviousTrack();
    	break;
    	case "WNP_RaiseVolume":
    		WinampHandler.static.WNP_RaiseVolume();
    	break;
    	case "WNP_LowerVolume":
    		WinampHandler.static.WNP_LowerVolume();
    	break;
    	case "WNP_ToggleRepeat":
    		WinampHandler.static.WNP_ToggleRepeat();
    	break;
    	case "WNP_ToggleShuffle":
    		WinampHandler.static.WNP_ToggleShuffle();
    	break;
    	case "WNP_FastForward":
    		WinampHandler.static.WNP_FastForward();
    	break;
    	case "WNP_FastRewind":
    		WinampHandler.static.WNP_FastRewind();
    	break;
    	default:
        	return false;
    	break;
    }
    return true;
}

defaultproperties
{
    MusicText="Music volume"
    MusicHelp="Will change music volume"
    WinampHandler=class'RWinampController.WinampController'
}
