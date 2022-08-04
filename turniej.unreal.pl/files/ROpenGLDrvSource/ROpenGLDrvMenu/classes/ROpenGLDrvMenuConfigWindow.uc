//==============================================
// by Raven
// http://turniej.unreal.pl
// http://ued2.prv.pl
//==============================================
class ROpenGLDrvMenuConfigWindow extends UWindowFramedWindow;

function BeginPlay()
{
  Super.BeginPlay();
  WindowTitle = "ROpenGLDrv :: Distance Fog";
  ClientClass = class'ROpenGLDrvMenuClientWindow';
  bSizable = false;
}

