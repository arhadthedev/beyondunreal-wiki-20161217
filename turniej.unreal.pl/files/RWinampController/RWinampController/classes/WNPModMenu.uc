class WNPModMenu extends UMenuModMenuItem;

var WindowConsole Console;

function Setup()
{
   MenuCaption = "Winamp controll";
   MenuHelp = "Click here to control your winamp";
}

function Execute()
{

   MenuItem.Owner.Root.CreateWindow(Class<UWindowFramedWindow>(DynamicLoadObject("RWinampController.WNPFramedWindow", class'Class')),20,20,170,180);
}

