// EWindow by Wormbo
//=============================================================================
// EnhancedRightClickMenu - handles more than one submenu
//=============================================================================
class EnhancedRightClickMenu extends EnhancedPulldownMenu;

function Created()
{
	bTransient = True;
	Super.Created();
}

function RMouseDown(float X, float Y)
{
	LMouseDown(X, Y);
}

function RMouseUp(float X, float Y)
{
	LMouseUp(X, Y);
}

function CloseUp(optional bool bByOwner)
{
	Super.CloseUp(bByOwner);
	HideWindow();
}

defaultproperties
{
}
