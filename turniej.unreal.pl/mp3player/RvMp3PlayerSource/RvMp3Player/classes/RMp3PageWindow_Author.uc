class RMp3PageWindow_Author extends UMenuPageWindow;

var UWindowCreditsControl UWCC;
const Version="0.54b";

function Created()
{
   Super.Created();

	UWCC = UWindowCreditsControl(CreateControl(class'UWindowCreditsControl', 5, 5, 150, 48));
	UWCC.AddLineText("CHMp3Player version "$Version);
	UWCC.AddLineText("Author: Raven");
	UWCC.AddLineUrl("http://turniej.unreal.pl/mp3player/");
	UWCC.AddPadding(10);
	UWCC.AddLineText("Additional Credits:");
	UWCC.AddLineText("Enigma for Unicode->ANSI");
	UWCC.AddLineText("conversion (big thx men).");
	UWCC.AddPadding(10);
	UWCC.AddLineText("UArchitect for help");
	UWCC.AddLineText("with meny problems.");
	UWCC.AddPadding(10);
	UWCC.AddLineText("[Sixpack]-Shambler he told");
	UWCC.AddLineText("me how to compile native code.");
	UWCC.AddPadding(10);
	UWCC.AddLineText("UnrealSP.org community");
	UWCC.AddLineText("for for feedback.");
	UWCC.AddPadding(10);
	UWCC.AddLineText("FMOD for because of leaving");
	UWCC.AddLineText("it free for non commercial use.");
	UWCC.DelayFade=0;
	UWCC.SpeedFade=0;
	UWCC.DelayScroll=0;
	UWCC.SpeedScroll=6;
}
