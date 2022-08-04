class RMp3ClientWindow extends UWindowDialogClientWindow;

var UWindowSmallCloseButton CloseButton;
var UWindowPageControl Settings;
var localized string VolumeControll;
var localized string PageAuthor;

function Created()
{
  local class<UWindowPageWindow> PageClass;

  Super.Created();
  SetSize(170, 128);
  WinWidth=170;
  WinHeight=128;
  CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, 86, 48, 16));

  Settings = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth-5, WinHeight-50));
  Settings.SetMultiLine(True);
  Settings.AddPage(VolumeControll, class'RMp3PageWindow_VolumeControll');
  Settings.AddPage(PageAuthor, class'RMp3PageWindow_Author');

}

defaultproperties{
  VolumeControll="Volume Control"
  PageAuthor="Author"
} 

