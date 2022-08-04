class RMp3PageWindow_VolumeControll extends UMenuPageWindow;

//Slider
var UWindowHSliderControl MusicSlider;
var localized string MusicText;
var localized string MusicHelp;
var int MusicSliderVolume;
var UWindowSmallCloseButton CloseButton;

function Created()
{
   Super.Created();

   MusicSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 5, 10, 150, 1));
   MusicSlider.SetRange(0, 255, 1);
   MusicSliderVolume = class'RMp3Player'.default.MusicVolume;
   MusicSlider.SetValue(MusicSliderVolume);
   MusicSlider.SetText(MusicText);
   MusicSlider.SetHelpText(MusicHelp);
   MusicSlider.SetFont(F_Normal);
//   CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', 114, 24, 48, 16));
}

function Notify(UWindowDialogControl C, byte E)
{
   switch(E)
   {
     case DE_Change:
       switch(C)
       {
         case MusicSlider:
              class'RMp3Player'.default.MusicVolume=MusicSlider.Value;
              class'RMp3Player'.static.StaticSaveConfig();
              ChangeMp3Volume();
         break;
       }
   break;
   }
}

simulated function ChangeMp3Volume()
{
     local RMp3Player empetri;

     ForEach GetPlayerOwner().GetEntryLevel().AllActors(class'RvMp3Player.RMp3Player', empetri)
     {
	 break;
     }
     
     if(empetri != none)
     {
        empetri.ChangeVolume(MusicSlider.Value);
     }
     else if(empetri == none)
     {
        log("Mp3Player :: Error :: cannot set your music volume because the expected Music Player 'RMp3Player' is missing.");
     }
}

defaultproperties
{
    MusicText="Music volume"
    MusicHelp="Will change music volume"
}
