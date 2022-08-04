class EWindowLookAndFeel extends UWindowLookAndFeel;

#exec TEXTURE IMPORT NAME=EChkChecked FILE=Textures\EChkChecked.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=EChkUnchecked FILE=Textures\EChkUnchecked.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=EChkGrayed FILE=Textures\EChkGrayed.pcx GROUP="Icons" FLAGS=2 MIPS=OFF

#exec TEXTURE IMPORT NAME=OptChecked FILE=Textures\OptChecked.pcx GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=OptUnchecked FILE=Textures\OptUnchecked.pcx GROUP="Icons" FLAGS=2 MIPS=OFF

// buttons
var Region ButtonUp;
var Region ButtonDown;
var Region ButtonOver;
var Region ButtonDisabled;

var Region SBVUpT;
var Region SBVUpB;
var Region SBVUpM;
var Region SBVUpC;
var Region SBVDownT;
var Region SBVDownB;
var Region SBVDownM;
var Region SBVDownC;
var Region SBVOverT;
var Region SBVOverB;
var Region SBVOverM;
var Region SBVOverC;

var Region SBHUpL;
var Region SBHUpR;
var Region SBHUpM;
var Region SBHUpC;
var Region SBHDownL;
var Region SBHDownR;
var Region SBHDownM;
var Region SBHDownC;
var Region SBHOverL;
var Region SBHOverR;
var Region SBHOverM;
var Region SBHOverC;

var Region SBUpUp;
var Region SBUpDown;
var Region SBUpOver;
var Region SBUpDisabled;

var Region SBDownUp;
var Region SBDownDown;
var Region SBDownOver;
var Region SBDownDisabled;

var Region SBLeftUp;
var Region SBLeftDown;
var Region SBLeftOver;
var Region SBLeftDisabled;

var Region SBRightUp;
var Region SBRightDown;
var Region SBRightOver;
var Region SBRightDisabled;

var Region FrameSBL;
var Region FrameSB;
var Region FrameSBR;

var Region TabOverL;
var Region TabOverM;
var Region TabOverR;

var Region CloseBoxUp;
var Region CloseBoxDown;
var Region CloseBoxOver;
var int CloseBoxOffsetX;
var int CloseBoxOffsetY;

var Region ComboBtnOver;

var Region ComboLeftUp;
var Region ComboLeftDown;
var Region ComboLeftOver;
var Region ComboLeftDisabled;

var Region ComboRightUp;
var Region ComboRightDown;
var Region ComboRightOver;
var Region ComboRightDisabled;

var color ControlBG, ControlTextColor, SelectedBG, SelectedTextColor;

var string ConfigWindowMenu;

function color RGBColor(byte R, byte G, byte B)
{
	local color C;
	
	C.R = R;
	C.G = G;
	C.B = B;
	return C;
}

function bool MouseInRegion(UWindowWindow Win, float X, float Y, float W, float H)
{
	local float mX, mY;
	
	Win.GetMouseXY(mX, mY);
	return mX > X && mX < X + W && mY > Y && mY < Y + H;
}

function Checkbox_SetupSizes(UWindowCheckbox W, Canvas C)
{
	local float TW, TH;

	W.TextSize(C, W.Text, TW, TH);
	W.WinHeight = Max(TH + 1, 16);
	
	switch(W.Align) {
	case TA_Left:
		W.ImageX = W.WinWidth - 16;
		W.TextX = 0;
		break;
	case TA_Right:
		W.ImageX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.ImageX = (W.WinWidth - 16) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	}

	W.ImageY = (W.WinHeight - 16) / 2;
	W.TextY = (W.WinHeight - TH) / 2;
	
	W.bUseRegion = True;
	W.UpRegion = ButtonUp;
	W.DownRegion = ButtonDown;
	W.OverRegion = ButtonOver;
	W.DisabledRegion = ButtonDisabled;
	if ( W.IsA('EnhancedCheckbox') && EnhancedCheckbox(W).bGrayed ) {
		W.UpTexture = Texture'EChkGrayed';
		W.DownTexture = Texture'EChkGrayed';
		W.OverTexture = Texture'EChkGrayed';
		W.DisabledTexture = Texture'EChkGrayed';
	}
	else if ( W.bChecked ) {
		W.UpTexture = Texture'EChkChecked';
		W.DownTexture = Texture'EChkChecked';
		W.OverTexture = Texture'EChkChecked';
		W.DisabledTexture = Texture'EChkChecked';
	}
	else {
		W.UpTexture = Texture'EChkUnchecked';
		W.DownTexture = Texture'EChkUnchecked';
		W.OverTexture = Texture'EChkUnchecked';
		W.DisabledTexture = Texture'EChkUnchecked';
	}
}

function Radiobox_SetupSizes(EWindowRadiobox W, Canvas C)
{
	local float TW, TH;

	W.TextSize(C, W.Text, TW, TH);
	W.WinHeight = Max(TH + 1, 16);
	
	switch(W.Align) {
	case TA_Left:
		W.ImageX = W.WinWidth - 16;
		W.TextX = 0;
		break;
	case TA_Right:
		W.ImageX = 0;	
		W.TextX = W.WinWidth - TW;
		break;
	case TA_Center:
		W.ImageX = (W.WinWidth - 16) / 2;
		W.TextX = (W.WinWidth - TW) / 2;
		break;
	}

	W.ImageY = (W.WinHeight - 16) / 2;
	W.TextY = (W.WinHeight - TH) / 2;
	
	W.bUseRegion = True;
	W.UpRegion = ButtonUp;
	W.DownRegion = ButtonDown;
	W.OverRegion = ButtonOver;
	W.DisabledRegion = ButtonDisabled;
	if ( W.bChecked ) {
		W.UpTexture = Texture'OptChecked';
		W.DownTexture = Texture'OptChecked';
		W.OverTexture = Texture'OptChecked';
		W.DisabledTexture = Texture'OptChecked';
	}
	else {
		W.UpTexture = Texture'OptUnchecked';
		W.DownTexture = Texture'OptUnchecked';
		W.OverTexture = Texture'OptUnchecked';
		W.DisabledTexture = Texture'OptUnchecked';
	}
}

function Radiobox_Draw(EWindowRadiobox W, Canvas C);
function bool Listbox_SetupSizes(EWindowListbox W, Canvas C);
function bool Listbox_Draw(EWindowListbox W, Canvas C);

function bool Listbox_DrawItem(EWindowListbox L, Canvas C, EWindowListboxItem Item, float X, float Y, float W, float H)
{
	if ( Item.bSelected ) {
		C.DrawColor = SelectedBG;
		L.DrawStretchedTexture(C, X, Y, W, H - 1, Texture'WhiteTexture');
		C.DrawColor = SelectedTextColor;
	}
	else
		C.DrawColor = ControlTextcolor;
	
	C.Font = L.Root.Fonts[F_Normal];
	L.ClipText(C, X + 2, Y, Item.Value);
	return true;
}

function ControlFrame_SetupSizes(UWindowControlFrame W, Canvas C)
{
	local int B;
	
	B = EditBoxBevel;
	
	W.Framed.WinLeft = MiscBevelL[B].W;
	W.Framed.WinTop = MiscBevelT[B].H;
	W.Framed.SetSize(W.WinWidth - MiscBevelL[B].W - MiscBevelR[B].W, W.WinHeight - MiscBevelT[B].H - MiscBevelB[B].H);
}

function ControlFrame_Draw(UWindowControlFrame W, Canvas C)
{
	C.DrawColor = ControlBG;
	W.DrawStretchedTexture(C, 0, 0, W.WinWidth, W.WinHeight, Texture'WhiteTexture');
	
	C.DrawColor = RGBColor(255, 255, 255);
	W.DrawMiscBevel(C, 0, 0, W.WinWidth, W.WinHeight, Misc, EditBoxBevel);
}

defaultproperties
{
     ControlBG=(R=255,B=255,G=255)
     ControlTextColor=(R=0,B=0,G=0)
     SelectedBG=(R=0,B=128,G=0)
     SelectedTextColor=(R=255,B=255,G=255)
}
