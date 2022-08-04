class WNPClientWindow extends UWindowDialogClientWindow;

var UWindowSmallCloseButton CloseButton;
var UWindowPageControl Settings;
var localized string WinampControll;
var localized string PageAuthor;

function Created()
{
  local class<UWindowPageWindow> PageClass;

  Super.Created();
  SetSize(170, 180);
  WinWidth=170;
  WinHeight=180;
  CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-42, 48, 16));

  Settings = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth-5, WinHeight-50));
  Settings.SetMultiLine(True);
  Settings.AddPage(WinampControll, class'RWinampController.WNPWindow_WinampControll');
  Settings.AddPage(PageAuthor, class'RWinampController.WNPWindow_Author');

}

defaultproperties{
  WinampControll="Control Winamp"
  PageAuthor="Author"
}

