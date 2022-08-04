//=============================================================================
// EnhancedCheckbox - a checkbox
//=============================================================================
class EnhancedCheckbox extends UWindowCheckbox;

var bool bGrayed;	// unspecified state (neither checked nor unchecked)
var bool bAutoSize;	// adjust the size of the control to its Text's size

function BeforePaint(Canvas C, float X, float Y)
{
	local float TW, TH;
	
	Super.BeforePaint(C, X, Y);
	if ( bAutoSize ) {
		if ( Text == "" ) {
			TW = 0;
			TH = WinHeight;
		}
		else {
			if ( Align == TA_Left )
				TextSize(C, Text $ " ", TW, TH);
			else if ( Align == TA_Right )
				TextSize(C, " " $ Text, TW, TH);
			else
				TextSize(C, Text, TW, TH);
			TH = Max(TH, WinHeight);
		}
		
		if ( Align == TA_Left )
			WinLeft -= TW + TH - WinWidth;
		else if ( Align == TA_Center )
			WinLeft -= (TW + TH - WinWidth) / 2;
		WinWidth = TW + TH;
	}
}

function LMouseUp(float X, float Y)
{
	if ( !bDisabled )
		bGrayed = False;
	
	Super.LMouseUp(X, Y);
}

defaultproperties
{
}
