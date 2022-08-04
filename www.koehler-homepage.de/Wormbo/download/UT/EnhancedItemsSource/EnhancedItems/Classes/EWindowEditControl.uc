// EWindow by Wormbo
//=============================================================================
// EWindowEditControl - support auto-size based on caption size
//=============================================================================
class EWindowEditControl extends UWindowEditControl;

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
