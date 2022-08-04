// EWindow by Wormbo
//=============================================================================
// EnhancedPulldownMenu - handles more than one submenu
//=============================================================================
class EnhancedPulldownMenu extends UWindowPulldownMenu;

var EnhancedPulldownMenu SubMenu;	// currently opened submenu
var UWindowPulldownMenu ParentMenu;	// EnhancedPulldownMenu(ParentMenu).SubMenu == Self
var bool bOpenedToLeft;

function Created()
{
	SetAcceptsFocus();
	Super(UWindowListControl).Created();
	ItemHeight = LookAndFeel.Pulldown_ItemHeight;
	VBorder = LookAndFeel.Pulldown_VBorder;
	HBorder = LookAndFeel.Pulldown_HBorder;
	TextBorder = LookAndFeel.Pulldown_TextBorder;
}

function UWindowPulldownMenuItem AddMenuItem(string C, Texture G)
{
	local UWindowPulldownMenuItem I;
	
	I = UWindowPulldownMenuItem(Items.Append(ListClass));
	
	I.Owner = Self;
	I.SetCaption(C);
	I.Graphic = G;
	
	EnhancedPulldownMenuItem(I).AltValue = C;
	
	return I;
}

function FocusOtherWindow(UWindowWindow W)
{
	local UWindowPulldownMenu M;
	local string tmp;
	
	Super(UWindowListControl).FocusOtherWindow(W);
	
	for (M = SubMenu; M != None; M = EnhancedPulldownMenu(M).SubMenu)
		if ( W == M )
			return;
	
	if ( UWindowPulldownMenuItem(Owner) != None )
		if ( UWindowPulldownMenuItem(Owner).Owner == W )
			return;
	
	For (M = ParentMenu; M != None; M = EnhancedPulldownMenu(M).ParentMenu) {
		if ( W == M )
			return;
		if ( EnhancedPulldownMenu(M) == None )
			break;
	}
	
	if ( bWindowVisible )
		CloseUp();
}

function Clear()
{
	SubMenu = None;
	Super.Clear();
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H, MaxWidth;
	local int Count;
	local UWindowPulldownMenuItem I;
	local EnhancedPulldownMenu Parent;
	
	Parent = EnhancedPulldownMenu(ParentMenu);
	
	MaxWidth = 100;
	Count = 0;
	
	C.Font = Root.Fonts[F_Normal];
	C.SetPos(0, 0);
	
	for (I = UWindowPulldownMenuItem(Items.Next); I != None; I = UWindowPulldownMenuItem(I.Next)) {
		Count++;
		TextSize(C, RemoveAmpersand(I.Caption), W, H);
		if ( W > MaxWidth )
			MaxWidth = W;
	}
	
	WinWidth = MaxWidth + (HBorder + TextBorder) * 2;
	WinHeight = ItemHeight * Count + VBorder * 2;
	
	// Take care of bHelp items
	if ( (UWindowMenuBarItem(Owner) != None && UWindowMenuBarItem(Owner).bHelp)
			|| WinLeft + WinWidth > ParentWindow.WinWidth )
		WinLeft = ParentWindow.WinWidth - WinWidth;
	
	if ( ParentMenu != None && (WinWidth + WinLeft > ParentWindow.WinWidth
			|| ParentMenu.WinLeft + ParentMenu.WinWidth - ParentMenu.HBorder > WinLeft
			|| WinLeft + WinWidth > Root.WinWidth || (Parent != None && Parent.bOpenedToLeft))
			&& ParentMenu.WinLeft + ParentMenu.HBorder - WinWidth > 0 ) {
		WinLeft = ParentMenu.WinLeft + ParentMenu.HBorder - WinWidth;
		bOpenedToLeft = True;
	}
	
	if ( ParentMenu != None && WinTop + WinHeight > Root.WinHeight
			&& WinHeight < WinTop + ParentMenu.ItemHeight + 2 * VBorder )
		WinTop -= WinHeight - ParentMenu.ItemHeight - 2 * VBorder;
	
	WinTop = Max(Min(WinTop, Root.WinHeight - WinHeight), 0);
	WinLeft = Max(Min(WinLeft, Root.WinWidth - WinWidth), 0);
}

defaultproperties
{
     ListClass=class'EnhancedPulldownMenuItem'
}