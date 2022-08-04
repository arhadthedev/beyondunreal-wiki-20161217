// EWindow by Wormbo
//=============================================================================
// EWindowDialogClientWindow - displays tooltips for its controls
//=============================================================================
class EWindowDialogClientWindow extends UWindowDialogClientWindow abstract;

var UWindowSmallCloseButton CloseButton;

function Created()
{
	Super.Created();
	CloseButton = UWindowSmallCloseButton(CreateWindow(class'UWindowSmallCloseButton', WinWidth-56, WinHeight-24, 48, 16));
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E) {
		// these are used to display tooltips
		case DE_MouseMove:
			if ( UMenuRootWindow(Root) != None && UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp(C.HelpText);
			break;
		case DE_MouseLeave:
			if ( UMenuRootWindow(Root) != None && UMenuRootWindow(Root).StatusBar != None)
				UMenuRootWindow(Root).StatusBar.SetHelp("");
			break;
	}
	Super.Notify(C, E);
}

function GetDesiredDimensions(out float W, out float H)
{	
	Super(UWindowWindow).GetDesiredDimensions(W, H);
	H += 30;
}

defaultproperties
{
}