//=============================================================================
// EWindowListBox - a listbox with frame
//=============================================================================
class EWindowListBox extends UWindowListBox;

var UWindowControlFrame Frame;
var bool bIntegralHeight;	// LookAndFeel should adjust height, so last visible item is completely displayed

function BeforeCreate()
{
	Frame = UWindowControlFrame(ParentWindow.CreateWindow(class'UWindowControlFrame', WinLeft, WinTop, WinWidth, WinHeight));
	Frame.SetFrame(Self);
	
	Super.BeforeCreate();
}

function BeforePaint(Canvas C, float MouseX, float MouseY)
{
	local UWindowListBoxItem OverItem;
	local string NewHelpText;
	
	if ( !LookAndFeel.IsA('EWindowLookAndFeel') || !EWindowLookAndFeel(LookAndFeel).Listbox_SetupSizes(Self, C) ) {
		VertSB.SetRange(0, Items.CountShown(), int(WinHeight/ItemHeight));
		
		NewHelpText = DefaultHelpText;
		if ( SelectedItem != None ) {
			OverItem = GetItemAt(MouseX, MouseY);
			if ( OverItem == SelectedItem && OverItem.HelpText != "" )
				NewHelpText = OverItem.HelpText;
		}
	}
	
	if ( NewHelpText != HelpText ) {
		HelpText = NewHelpText;
		Notify(DE_HelpChanged);
	}
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	if ( LookAndFeel.IsA('EWindowLookAndFeel') && EWindowLookAndFeel(LookAndFeel).Listbox_Draw(Self, C) )
		return;
	
	Super.Paint(C, MouseX, MouseY);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if ( LookAndFeel.IsA('EWindowLookAndFeel')
			&& EWindowLookAndFeel(LookAndFeel).Listbox_DrawItem(Self, C, EWindowListboxItem(Item), X, Y, W, H) )
		return;
	
	if ( EWindowListboxItem(Item).bSelected ) {
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 128;
		DrawStretchedTexture(C, X, Y, W, H - 1, Texture'WhiteTexture');
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
	else {
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	
	C.Font = Root.Fonts[F_Normal];
	
	ClipText(C, X + 2, Y, EWindowListBoxItem(Item).Value);
}

function int FindItemIndex(string Value, optional bool bIgnoreCase)
{
	local EWindowListBoxItem I;
	local int Count;
	
	I = EWindowListBoxItem(Items.Next);
	Count = 0;
	
	while (I != None) {
		if ( bIgnoreCase && I.Value ~= Value )
			return Count;
		if ( I.Value == Value )
			return Count;
		
		Count++;
		I = EWindowListBoxItem(I.Next);
	}
	
	return -1;
}

function int FindItemIndex2(string Value2, optional bool bIgnoreCase)
{
	local EWindowListBoxItem I;
	local int Count;
	
	I = EWindowListBoxItem(Items.Next);
	Count = 0;
	
	while (I != None) {
		if ( bIgnoreCase && I.Value2 ~= Value2 )
			return Count;
		if ( I.Value2 == Value2 )
			return Count;
		
		Count++;
		I = EWindowListBoxItem(I.Next);
	}
	
	return -1;
}

function string GetItemValue(int Index)
{
	local EWindowListBoxItem I;
	local int Count;
	
	I = EWindowListBoxItem(Items.Next);
	Count = 0;
	
	while (I != None) {
		if ( Count == Index )
			return I.Value;
		
		Count++;
		I = EWindowListBoxItem(I.Next);
	}
	
	return "";
}

function string GetItemValue2(int Index)
{
	local EWindowListBoxItem I;
	local int Count;
	
	I = EWindowListBoxItem(Items.Next);
	Count = 0;
	
	while (I != None) {
		if ( Count == Index )
			return I.Value2;
		
		Count++;
		I = EWindowListBoxItem(I.Next);
	}
	
	return "";
}

function RemoveItem(int Index)
{
	local EWindowListBoxItem I;
	local int Count;
	
	if(Index == -1)
		return;
	
	I = EWindowListBoxItem(Items.Next);
	Count = 0;
	
	while (I != None) {
		if ( Count == Index ) {
			I.Remove();
			return;
		}
		
		Count++;
		I = EWindowListBoxItem(I.Next);
	}
}

function AddItem(string Value, optional string Value2, optional int SortWeight)
{
	local EWindowListBoxItem I;
	
	I = EWindowListBoxItem(Items.Append(ListClass));
	I.Value = Value;
	I.Value2 = Value2;
	I.SortWeight = SortWeight;
}

function InsertItem(string Value, optional string Value2, optional int SortWeight)
{
	local EWindowListBoxItem I;
	
	I = EWindowListBoxItem(Items.Insert(ListClass));
	I.Value = Value;
	I.Value2 = Value2;
	I.SortWeight = SortWeight;
}

defaultproperties
{
     ItemHeight=13.000000
     ListClass=class'EWindowListBoxItem'
}
