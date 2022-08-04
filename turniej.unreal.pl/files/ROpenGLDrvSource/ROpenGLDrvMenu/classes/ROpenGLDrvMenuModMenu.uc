//==============================================
// by Raven
//==============================================
class ROpenGLDrvMenuModMenu extends UMenuModMenuItem;

function Setup()
{
   MenuCaption = "Distance Fog";
   MenuHelp = "Customize distance fog...";

}
function Execute()
{
   MenuItem.Owner.Root.CreateWindow(class'ROpenGLDrvMenuConfigWindow',20,20,210,125);
}

