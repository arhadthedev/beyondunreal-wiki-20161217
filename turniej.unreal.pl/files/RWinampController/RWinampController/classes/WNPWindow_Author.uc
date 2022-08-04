class WNPWindow_Author extends UMenuPageWindow;

var UWindowCreditsControl UWCC;
const Version="0.1";

function Created()
{
   Super.Created();

	UWCC = UWindowCreditsControl(CreateControl(class'UWindowCreditsControl', 5, 5, 150, 48));
	UWCC.AddLineText("RWinampController version "$Version);
	UWCC.AddLineText("Author: Raven");
	UWCC.AddPadding(10);
	UWCC.AddLineText("Additional Credits:");
	UWCC.AddLineUrl("http://www.codeproject.com/KB/stl/Winamp_Controller.aspx", 0, "CodeProject.com");
	UWCC.DelayFade=0;
	UWCC.SpeedFade=0;
	UWCC.DelayScroll=0;
	UWCC.SpeedScroll=6;
}
