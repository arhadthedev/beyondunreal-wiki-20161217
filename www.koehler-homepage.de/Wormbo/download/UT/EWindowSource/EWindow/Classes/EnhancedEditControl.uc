// EWindow by Wormbo
//=============================================================================
// EnhancedEditControl - support auto-size based on caption size
//=============================================================================
class EnhancedEditControl extends UWindowEditControl;

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
