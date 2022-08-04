// EWindow by Wormbo
//=============================================================================
// EWindowPageWindow
//=============================================================================
class EWindowPageWindow extends UMenuPageWindow;

var bool bLoaded;
var string ParentPageClass;

// load settings and create controls when window is selected for first time (speeds things up)
function ShowWindow()
{
	if ( !bLoaded )
		LoadSettings();
	
	Super.ShowWindow();
}

// Called when page is selected for the first time.
// Create controls and load any settings from here.
function LoadSettings()
{
	bLoaded = True;
}

// Can be called by parent to set the position and size of controls.
function SetControls();

function GetDesiredDimensions(out float W, out float H)
{
	local int i, k;
	local string PageClassName, PageProperties;
	local float MaxW, MaxH, TW, TH;
	local PlayerPawn P;
	
	MaxW = 0;
	MaxH = 0;
	
	Super.GetDesiredDimensions(MaxW, MaxH);
	
	i = 0;
	P = GetPlayerOwner();
	P.GetNextIntDesc(ParentPageClass, 0, PageClassName, PageProperties);
	while ( PageClassName != "" ) {
		if ( PageClassName ~= string(Class) ) {
			k = InStr(PageProperties, ",");
			if ( k >= 0 ) {
				PageProperties = Mid(PageProperties, k + 1);
				k = InStr(PageProperties, ",");
				if ( k == -1 )
					MaxW = FMax(float(PageProperties), MaxW);
				else {
					MaxW = FMax(float(Left(PageProperties, k)), MaxW);
					MaxH = FMax(float(Mid(PageProperties, k + 1)), MaxH);
				}
			}
			break;
		}
		i++;
		P.GetNextIntDesc(ParentPageClass, i, PageClassName, PageProperties);
	}
	W = MaxW;
	H = MaxH;
}

defaultproperties
{
     ParentPageClass="EnhancedItems.EWindowPageWindow"
}
