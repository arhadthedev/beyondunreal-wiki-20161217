// EWindow by Wormbo
//=============================================================================
// EWindowPulldownMenuItem - menu item for EWindowPulldownMenu
//=============================================================================
class EWindowPulldownMenuItem extends UWindowPulldownMenuItem;

var string AltValue;

function Select()
{
	if ( SubMenu != None ) {
		SubMenu.WinLeft = Owner.WinLeft + Owner.WinWidth - Owner.HBorder;
		SubMenu.WinTop = ItemTop - Owner.VBorder;
		
		if ( EWindowPulldownMenu(Owner) != None )
			EWindowPulldownMenu(Owner).SubMenu = EWindowPulldownMenu(SubMenu);
		if ( EWindowPulldownMenu(SubMenu) != None )
			EWindowPulldownMenu(SubMenu).ParentMenu = Owner;
		SubMenu.ShowWindow();
	}
}

function DeSelect()
{
	if ( SubMenu != None ) {
		if ( EWindowPulldownMenu(Owner) != None && EWindowPulldownMenu(Owner).SubMenu == SubMenu )
			EWindowPulldownMenu(Owner).SubMenu = None;
		if ( EWindowPulldownMenu(SubMenu) != None )
			EWindowPulldownMenu(SubMenu).ParentMenu = None;
		SubMenu.DeSelect();
		SubMenu.HideWindow();
	}
}

defaultproperties
{
}
