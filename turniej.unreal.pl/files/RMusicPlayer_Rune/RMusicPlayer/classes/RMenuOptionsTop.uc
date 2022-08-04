//=============================================================================
// RuneMenuOptionsTop
//=============================================================================
class RMenuOptionsTop extends RuneMenuOptionsTop;

function Notify(UWindowDialogControl C, byte E)
{
	if(E == DE_Click)
	{
		switch(C)
		{
			case VideoButton:
				HideAllWindows();
				if(VideoWindow == None)
					VideoWindow = Root.CreateWindow(class'RuneMenuVideoOptionsScrollClient', 200, 100, 440, 360);
				if (VideoWindow!=None)
					VideoWindow.ShowWindow();
				break;
			case AudioButton:
				HideAllWindows();
				if(AudioWindow == None)
					AudioWindow = Root.CreateWindow(class'RMenuAudioScrollClient', 200, 100, 440, 360);
				if (AudioWindow!=None)
					AudioWindow.ShowWindow();
				break;
			case GameButton:
				HideAllWindows();
				if(GameWindow == None)
					GameWindow = Root.CreateWindow(class'RuneMenuGameOptionsScrollClient', 200, 100, 440, 360);
				if(GameWindow!=None)
					GameWindow.ShowWindow();
				break;
			case ControlsButton:
				HideAllWindows();
				if(ControlsWindow == None)
					ControlsWindow = Root.CreateWindow(class'RuneMenuCustomizeScrollClient', 200, 100, 440, 360);
				if(ControlsWindow!=None)
					ControlsWindow.ShowWindow();
				break;
			case InputButton:
				HideAllWindows();
				if(InputWindow == None)
					InputWindow = Root.CreateWindow(class'RuneMenuInputOptionsScrollClient', 200, 100, 440, 360);
				if(InputWindow!=None)
					InputWindow.ShowWindow();
				break;
		}
	}
}

function HideAllWindows()
{
	if (VideoWindow!=None)
		VideoWindow.HideWindow();
	if (AudioWindow!=None)
		AudioWindow.HideWindow();
	if (ControlsWindow!=None)
		ControlsWindow.HideWindow();
	if (InputWindow!=None)
		InputWindow.HideWindow();
	if (GameWindow!=None)
		GameWindow.HideWindow();
}

defaultproperties
{
     VideoText="Video"
     AudioText="Audio"
     GameText="Game"
     ControlsText="Controls"
     InputText="Input"
     VideoHelp="Video Options"
     AudioHelp="Audio Options"
     GameHelp="Game Options"
     ControlsHelp="Customize player controls"
     InputHelp="Choose input device(s)"
}
