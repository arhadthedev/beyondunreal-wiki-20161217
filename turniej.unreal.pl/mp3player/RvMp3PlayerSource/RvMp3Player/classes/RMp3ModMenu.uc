class RMp3ModMenu extends UMenuModMenuItem;

var RMp3Player JukeBox;
var WindowConsole Console;

function Setup()
{
   MenuCaption = "Mp3Player Volume Control";
   MenuHelp = "Cliclk to change mp3 volume";
}

function Execute()
{

   MenuItem.Owner.Root.CreateWindow(Class<UWindowFramedWindow>(DynamicLoadObject("RvMp3Player.RMp3FramedWindow", class'Class')),20,20,170,200);
}

