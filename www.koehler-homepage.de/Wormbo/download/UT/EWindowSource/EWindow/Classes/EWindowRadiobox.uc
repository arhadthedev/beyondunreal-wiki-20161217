//=============================================================================
// EWindowRadiobox - a radio box
//=============================================================================
class EWindowRadiobox extends UWindowCheckbox;

var name Group;
var bool bAutoSize;	// adjust the size of the control to its Text's size

function BeforePaint(Canvas C, float X, float Y)
{
	local float TW, TH;
	
	if ( LookAndFeel.IsA('EWindowLookAndFeel') )
		EWindowLookAndFeel(LookAndFeel).Radiobox_SetupSizes(Self, C);
	else
		LookAndFeel.Checkbox_SetupSizes(Self, C);
	
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
	
	Super(UWindowButton).BeforePaint(C, X, Y);
}

function Paint(Canvas C, float X, float Y)
{
	if ( LookAndFeel.IsA('EWindowLookAndFeel') )
		EWindowLookAndFeel(LookAndFeel).Radiobox_Draw(Self, C);
	else
		LookAndFeel.Checkbox_Draw(Self, C);
	Super(UWindowButton).Paint(C, X, Y);
}

function LMouseUp(float X, float Y)
{
	local UWindowWindow W;
	
	if ( !bDisabled )
		For (W = ParentWindow.FirstChildWindow; W != None; W = W.NextSiblingWindow)
			if ( W.IsA('EWindowRadiobox') && EWindowRadiobox(W).Group == Group )
				EWindowRadiobox(W).bChecked = False;
	
	Super.LMouseUp(X, Y);
}

defaultproperties
{
}
