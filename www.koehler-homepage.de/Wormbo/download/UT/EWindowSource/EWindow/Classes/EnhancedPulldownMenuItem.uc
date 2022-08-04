// EWindow by Wormbo
//=============================================================================
// EnhancedPulldownMenuItem - menu item for EnhancedPulldownMenu
//=============================================================================
class EnhancedPulldownMenuItem extends UWindowPulldownMenuItem;

var string AltValue;

function Select()
{
	if ( SubMenu != None ) {
		SubMenu.WinLeft = Owner.WinLeft + Owner.WinWidth - Owner.HBorder;
		SubMenu.WinTop = ItemTop - Owner.VBorder;
		
		if ( EnhancedPulldownMenu(Owner) != None )
			EnhancedPulldownMenu(Owner).SubMenu = EnhancedPulldownMenu(SubMenu);
		if ( EnhancedPulldownMenu(SubMenu) != None )
			EnhancedPulldownMenu(SubMenu).ParentMenu = Owner;
		SubMenu.ShowWindow();
	}
}

function DeSelect()
{
	if ( SubMenu != None ) {
		if ( EnhancedPulldownMenu(Owner) != None && EnhancedPulldownMenu(Owner).SubMenu == SubMenu )
			EnhancedPulldownMenu(Owner).SubMenu = None;
		if ( EnhancedPulldownMenu(SubMenu) != None )
			EnhancedPulldownMenu(SubMenu).ParentMenu = None;
		SubMenu.DeSelect();
		SubMenu.HideWindow();
	}
}

defaultproperties
{
}
