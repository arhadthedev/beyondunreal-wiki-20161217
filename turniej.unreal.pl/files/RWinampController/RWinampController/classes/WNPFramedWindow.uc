class WNPFramedWindow extends UWindowFramedWindow;

function BeginPlay()
{
   Super.BeginPlay();
   WindowTitle = "Winamp control";
   ClientClass = class'WNPClientWindow';
   bSizable = false;
}

function Created()
{
  Super.Created();
  SetSize(170, 180);
  WinLeft = (Root.WinWidth - 170) / 2;
  WinTop = (Root.WinHeight - 180) / 2;
}
