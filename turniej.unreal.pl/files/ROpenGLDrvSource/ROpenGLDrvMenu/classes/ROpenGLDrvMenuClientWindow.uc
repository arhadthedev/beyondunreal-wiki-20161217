//==============================================
// by Raven
// ROpenGLDrv.OpenGLRenderDevice
//==============================================
class ROpenGLDrvMenuClientWindow extends UWindowDialogClientWindow;

var UMenuLabelControl ErrorLabel1;
var UMenuLabelControl ErrorLabel2;

var UWindowCheckBox NoFCheck;
var localized string NoFCheckText;
var localized string NoFCheckHelp;

var UWindowCheckBox ForceCheck;
var localized string ForceCheckText;
var localized string ForceCheckHelp;

var UWindowEditControl DistanceEdit;
var localized string DistanceEditText;
var localized string DistanceEditHelp;

var UWindowHSliderControl ColorRSlider;
var localized string ColorRSliderText;
var localized string ColorRSliderHelp;

var UWindowHSliderControl ColorGSlider;
var localized string ColorGSliderText;
var localized string ColorGSliderHelp;

var UWindowHSliderControl ColorBSlider;
var localized string ColorBSliderText;
var localized string ColorBSliderHelp;

var int ControlOffset;

function Created()
{
        Super.Created();
        if(!CheckForCurrentDriver())
        {
               ErrorLabel1 = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 40, 180, 10));
               ErrorLabel1.Align = TA_Center;
               ErrorLabel1.SetFont(F_Bold);
               ErrorLabel1.SetText("ERROR: ROpenGLDrv is not your");
               ErrorLabel2 = UMenuLabelControl(CreateControl(class'UMenuLabelControl', 10, 55, 180, 10));
               ErrorLabel2.Align = TA_Center;
               ErrorLabel2.SetFont(F_Bold);
               ErrorLabel2.SetText("current driver!");
               return;
        }
	ControlOffset=5;
        NoFCheck = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, ControlOffset, 180, 1));
        NoFCheck.SetText(NoFCheckText);
       	NoFCheck.SetHelpText(NoFCheckHelp);
        NoFCheck.SetFont(F_Normal);
        NoFCheck.Align = TA_Left;
        NoFCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice SpawnIfNoDistanceFog"));
        ControlOffset+=15;
	ForceCheck = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 10, ControlOffset, 180, 1));
        ForceCheck.SetText(ForceCheckText);
       	ForceCheck.SetHelpText(ForceCheckHelp);
        ForceCheck.SetFont(F_Normal);
        ForceCheck.Align = TA_Left;
        ForceCheck.bChecked = bool(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice ForceDistanceFog"));
        ControlOffset+=15;
        DistanceEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 10, ControlOffset, 180, 1));
	DistanceEdit.SetText(DistanceEditText);
	DistanceEdit.SetHelpText(DistanceEditHelp);
	DistanceEdit.SetFont(F_Normal);
	DistanceEdit.SetNumericOnly(True);
	DistanceEdit.SetMaxLength(4);
	DistanceEdit.Align = TA_Left;
	DistanceEdit.SetValue(string(int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice FogDistance"))));
	ControlOffset+=15;
	ColorRSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 10, ControlOffset, 180, 1));
	ColorRSlider.SetRange(0, 255, 1);
	ColorRSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice FogColorR")));
	ColorRSlider.SetText(ColorRSliderText);
	ColorRSlider.SetHelpText(ColorRSliderHelp);
	ColorRSlider.SetFont(F_Normal);
        ControlOffset+=15;
	ColorGSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 10, ControlOffset, 180, 1));
	ColorGSlider.SetRange(0, 255, 1);
	ColorGSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice FogColorG")));
	ColorGSlider.SetText(ColorGSliderText);
	ColorGSlider.SetHelpText(ColorGSliderHelp);
	ColorGSlider.SetFont(F_Normal);
	ControlOffset+=15;
	ColorBSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', 10, ControlOffset, 180, 1));
	ColorBSlider.SetRange(0, 255, 1);
	ColorBSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice FogColorB")));
	ColorBSlider.SetText(ColorBSliderText);
	ColorBSlider.SetHelpText(ColorBSliderHelp);
	ColorBSlider.SetFont(F_Normal);
}

function bool CheckForCurrentDriver()
{
         if(GetPlayerOwner().ConsoleCommand("get ini:Engine.Engine.GameRenderDevice Class") == "Class'ROpenGLDrv.OpenGLRenderDevice'")
            return true;
         else
            return false;
}

function Notify(UWindowDialogControl C, byte E)
{

    switch(E)
    {
        case DE_Change:
             switch(C)
             {
                 case NoFCheck:
		      GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice SpawnIfNoDistanceFog "$NoFCheck.bChecked);
                 break;
                 case ForceCheck:
		      GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice ForceDistanceFog "$ForceCheck.bChecked);
                 break;
                 case DistanceEdit:
                      GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice FogDistance "$DistanceEdit.EditBox.Value);
                 break;
                 case ColorRSlider:
                      GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice FogColorR "$ColorRSlider.Value);
                 break;
                 case ColorGSlider:
                      GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice FogColorG "$ColorGSlider.Value);
                 break;
                 case ColorBSlider:
                      GetPlayerOwner().ConsoleCommand("set ini:Engine.Engine.GameRenderDevice FogColorB "$ColorBSlider.Value);
                 break;
             }
       break;
   }
}

defaultproperties
{
    NoFCheckText="Spawn when no distance fog"
    NoFCheckHelp="Displays distance fog when Zone Fog Distance < 128 (y/n)..."

    ForceCheckText="Force distance fog"
    ForceCheckHelp="Always displays distance fog (y/n)..."

    DistanceEditText="Fod distance"
    DistanceEditHelp="Fod distance..."

    ColorRSliderText="R"
    ColorRSliderHelp="R in RGB..."

    ColorGSliderText="G"
    ColorGSliderHelp="G in RGB..."

    ColorBSliderText="B"
    ColorBSliderHelp="B in RGB..."

}
