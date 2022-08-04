// EWindow by Wormbo
//=============================================================================
// EnhancedComboControl - support auto-size based on caption size
//=============================================================================
class EnhancedComboControl extends UWindowComboControl;

var	bool bAutoSize;

function BeforePaint(Canvas C, float X, float Y)
{
	local float TW, TH;
	
	if ( bAutoSize ) {
		TextSize(C, Text, TW, TH);
		EditBoxWidth = WinWidth - TW;
	}
	Super.BeforePaint(C, X, Y);
}

defaultproperties
{
}
