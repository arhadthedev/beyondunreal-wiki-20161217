// EWindow by Wormbo
//=============================================================================
// EWindowRightClickMenu - handles more than one submenu
//=============================================================================
class EWindowRightClickMenu extends EWindowPulldownMenu;

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
