class RMp3FramedWindow extends UWindowFramedWindow;

function BeginPlay()
{
   Super.BeginPlay();
   WindowTitle = "Mp3Player :: Volume Control";
   ClientClass = class'RMp3ClientWindow';
   bSizable = false;
}

function Created()
{
  Super.Created();
  SetSize(170, 128);
  WinLeft = (Root.WinWidth - 170) / 2;
  WinTop = (Root.WinHeight - 128) / 2;
}
