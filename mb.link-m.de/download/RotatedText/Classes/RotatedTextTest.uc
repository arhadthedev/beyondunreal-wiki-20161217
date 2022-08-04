// ============================================================================
// RotatedTextTest
// Copyright (c) 2002 by Mychaeel <mychaeel@planetunreal.com>
//
// Test mutator for the RotatedText actor. Displays some useless information
// rotating around the crosshair.
//
// Free for use, modification and distribution. Credit is appreciated.
// ============================================================================


class RotatedTextTest extends Mutator;


// ============================================================================
// Variables
// ============================================================================

var int Angle;
var RotatedText MyRotatedText;


// ============================================================================
// PostBeginPlay
//
// Create a RotatedText actor.
// ============================================================================

simulated event PostBeginPlay() {

  MyRotatedText = Spawn(class 'RotatedText');
  }


// ============================================================================
// Tick
//
// Register this mutator as a HUD mutator
// ============================================================================

simulated event Tick(float TimeDelta) {

  if (bHUDMutator)
    Disable('Tick');
  else
    RegisterHUDMutator();
  }


// ============================================================================
// PostRender
//
// Draw information on the HUD, using the previously created RotatedText actor.
// ============================================================================

simulated event PostRender(Canvas Canvas) {

  local string TextPlayerName;

  // Get the local player's name.

  TextPlayerName = Canvas.Viewport.Actor.PlayerReplicationInfo.PlayerName;

  // Increase angle.

  Angle = (Angle + 1) % 360;

  // DrawColor black (as set here) is special: It draws anti-aliased or
  // colored fonts in their original colors. Any other color takes the closest
  // color available in the ScriptedTexture's palette.

  Canvas.DrawColor.R = 0;
  Canvas.DrawColor.G = 0;
  Canvas.DrawColor.B = 0;

  Canvas.Font = ChallengeHUD(Canvas.Viewport.Actor.myHUD).MyFonts.GetBigFont(Canvas.ClipX);
  Canvas.Style = ERenderStyle.STY_Translucent;
  Canvas.bNoSmooth = false;

  // Draw rotated text, starting from the middle of the HUD.

  Canvas.SetPos(Canvas.ClipX / 2, Canvas.ClipY / 2);

  MyRotatedText.DrawRotatedText(Canvas,  Angle, "Elapsed Time" @ int(Level.TimeSeconds));
  MyRotatedText.DrawRotatedText(Canvas, -Angle, TextPlayerName);

  // Call the next HUD mutator in the list.

  if (NextHUDMutator != None)
    NextHUDMutator.PostRender(Canvas);
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties {

  RemoteRole=ROLE_SimulatedProxy
  bAlwaysRelevant=true
  bNetTemporary=true
  }