//=============================================================================
// RuneMenu	-> Main Rune Menu Class
//=============================================================================
class RMenu extends RuneMenu;

function Notify(UWindowDialogControl C, byte E)
{
	if(E == DE_Click)
	{
		switch(C)
		{
			case NewButton:
				HideSubmenusExcept(NewMenu);
				if(NewMenu == None)
					NewMenu = RuneMenuTopWindow(Root.Createwindow(class'RuneMenuNewTop', 0, 0, 440, 100));
				NewMenu.ShowWindow();
				if(NewMenu!=None && !NewMenu.bOpen)
					NewMenu.SlideOpen();
				break;
			case LoadButton:
				HideSubmenusExcept(LoadMenu);
				if(LoadMenu == None)
					LoadMenu = RuneMenuTopWindow(Root.CreateWindow(class'RuneMenuLoadTop', 0, 0, 440, 100));
				LoadMenu.ShowWindow();
				if(LoadMenu!=None && !LoadMenu.bOpen)
					LoadMenu.SlideOpen();
				break;
			case SaveButton:
				HideSubmenusExcept(SaveMenu);
				if(SaveMenu == None)
					SaveMenu = RuneMenuTopWindow(Root.CreateWindow(class'RuneMenuSaveTop', 0, 0, 440, 100));
				SaveMenu.ShowWindow();
				if(SaveMenu!=None && !SaveMenu.bOpen)
					SaveMenu.SlideOpen();
				break;
			case OptionsButton:
				HideSubmenusExcept(OptionsMenu);
				if(OptionsMenu == None)
					OptionsMenu = RuneMenuTopWindow(Root.CreateWindow(class'RMenuOptionsTop', 0, 0, 440, 100));
				OptionsMenu.ShowWindow();
				if(OptionsMenu!=None && !OptionsMenu.bOpen)
					OptionsMenu.SlideOpen();
				break;
			case MultiButton:
				HideSubmenusExcept(MultiMenu);
				if(MultiMenu == None)
					MultiMenu = RuneMenuTopWindow(Root.CreateWindow(class'RuneMenuMultiplayerTop', 0, 0, 440, 100));
				MultiMenu.ShowWindow();
				if(MultiMenu!=None && !MultiMenu.bOpen)
					MultiMenu.SlideOpen();
				break;
			case ExitButton:
				HideSubmenusExcept(None);
				Root.Console.ConsoleCommand("Exit");
				break;
			case HHButton:
				HideSubmenusExcept(AboutMenu);
				if (AboutMenu == None)
					AboutMenu = RuneMenuTopWindow(Root.CreateWindow(class'RuneMenuAboutTop', 0, 0, 440, 100));
				AboutMenu.ShowWindow();
				if(AboutMenu!=None && !AboutMenu.bOpen)
					AboutMenu.SlideOpen();
				break;
//			case GodButton:
//				HideSubmenusExcept(GodAboutMenu);
//				if (GodAboutMenu == None)
//					GodAboutMenu = RuneMenuTopWindow(Root.CreateWindow(class'RuneMenuGodAboutTop', 0, 0, 440, 100));
//				GodAboutMenu.ShowWindow();
//				if(GodAboutMenu!=None && !GodAboutMenu.bOpen)
//					GodAboutMenu.SlideOpen();
//				break;
		}
	}
}

function ShowWindow()
{
	Super.ShowWindow();

	HideSubmenusExcept(None);
}

function HideSubmenusExcept(RuneMenuTopWindow Exclude)
{
	local Color Col;

	if (NewMenu!=None && NewMenu!=Exclude)
	{
		NewMenu.HideWindow();
		NewMenu.HideAllWindows();
	}

	if (LoadMenu!=None && LoadMenu!=Exclude)
	{
		LoadMenu.HideWindow();
		LoadMenu.HideAllWindows();
	}

	if (SaveMenu!=None && SaveMenu!=Exclude)
	{
		SaveMenu.HideWindow();
		SaveMenu.HideAllWindows();
	}

	if (OptionsMenu!=None && OptionsMenu!=Exclude)
	{
		OptionsMenu.HideWindow();
		OptionsMenu.HideAllWindows();
	}

	if (MultiMenu!=None && MultiMenu!=Exclude)
	{
		MultiMenu.HideWindow();
		MultiMenu.HideAllWindows();
	}

	if (AboutMenu!=None && AboutMenu!=Exclude)
	{
		AboutMenu.HideWindow();
		AboutMenu.HideAllWindows();
	}

/*	if (GodAboutMenu!=None && GodAboutMenu!=Exclude)
	{
		GodAboutMenu.HideWindow();
		GodAboutMenu.HideAllWindows();
	}
*/
	// Reset all button colors
	NewButton.ResetTextColor();
	LoadButton.ResetTextColor();
	SaveButton.ResetTextColor();
	MultiButton.ResetTextColor();
	OptionsButton.ResetTextColor();
	ExitButton.ResetTextColor();
}

function Resized()
{	
	Notify(NewButton, DE_Click);
}

function SecretAction()
{
	bWalk = !bWalk;
}

function Move(UWindowWindow W)
{
	if (bWalk)
	{
		W.WinLeft += RandRange(-5,5);
		W.WinTop  += RandRange(-5,5);
		W.WinLeft = Clamp(W.WinLeft, 0, 640-W.WinWidth);
		W.WinTop  = Clamp(W.WinTop,  0, 480-W.WinHeight);
		//Root.Console.AddString("Moving"@W.name@W.WinLeft@W.WinTop);
	}
}

defaultproperties
{
     LogoOffset=(X=15.000000,Z=13.400000)
     RotFactor=(X=2000.000000,Y=4000.000000)
     NewGameText="New Game"
     LoadGameText="Load Game"
     SaveGameText="Save Game"
     MultiplayerText="Multiplayer"
     OptionsText="Options"
     ExitText="Exit"
     NewGameHelp="Start a new game"
     LoadGameHelp="Load a saved game"
     SaveGameHelp="Save the current game"
     MultiplayerHelp="Multiplayer game options"
     OptionsHelp="Set Audio, Video, Input, Control options"
     AboutHelp="Credits, Links"
     ExitHelp="Exit"
     DefaultWidth=200
     DefaultHeight=460
     bAlwaysOnTop=True
}
