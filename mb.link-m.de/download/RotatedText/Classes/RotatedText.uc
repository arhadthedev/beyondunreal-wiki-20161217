// ============================================================================
// RotatedText
// Copyright (c) 2002 by Mychaeel <mychaeel@planetunreal.com>
//
// Displays rotated text on a Canvas, using DrawClippedActor, a simple mesh
// and a ScriptedTexture.
//
// Create a RotatedText actor at some point in your script and call its
// DrawRotatedText method (see below for details on its parameters) to render
// rotated text on a Canvas.
//
// Limitations:
// * Text cannot be wider than 256 pixels, the ScriptedTexture's width.
// * Not more than 32 different strings can be rendered within a single frame.
// * Color space is limited to the palette of the base texture of the
//   ScriptedTexture. The engine uses the closest matching color.
//
// Free for use, modification and distribution. Credit is appreciated.
// ============================================================================


class RotatedText extends Info;


// ============================================================================
// Compiler Directives
// ============================================================================

// Import RotatedTextTextures.utx created in UnrealEd into the RotatedText.u
// package we're currently creating. That saves us from having to bundle that
// texture package with our release and keeps it neat and self-contained.

#exec obj load file=Textures\RotatedTextTextures.utx package=RotatedText

// Import the mesh.

#exec mesh import mesh=RotatedTextMesh anivfile=Models\RotatedTextMesh_a.3d datafile=Models\RotatedTextMesh_d.3d mlod=0
#exec meshmap new meshmap=RotatedTextMesh mesh=RotatedTextMesh
#exec meshmap scale meshmap=RotatedTextMesh x=1.0 y=1.0 z=2.0


// ============================================================================
// Variables
// ============================================================================

var int IndexScriptedTexture;
var ScriptedTexture ScriptedTextures[32];

var Font DrawFont;
var Color DrawColor;
var string DrawText;


// ============================================================================
// PostBeginPlay
//
// The scripted texture uses a callback mechanism; when it is about to be drawn
// on the screen, it calls RenderTexture in the actor pointed to by its
// NotifyActor property. Thus, we set NotifyActor to ourself in PostBeginPlay.
// ============================================================================

simulated event PostBeginPlay() {

  for (IndexScriptedTexture = 0; IndexScriptedTexture < ArrayCount(ScriptedTextures); IndexScriptedTexture++)
    ScriptedTextures[IndexScriptedTexture].NotifyActor = Self;
  }


// ============================================================================
// RenderTexture
//
// RenderTexture is called by the scripted texture before it is drawn on the
// screen. See above.
// ============================================================================

simulated event RenderTexture(ScriptedTexture ScriptedTexture) {

  if (DrawColor.R == 0 && DrawColor.G == 0 && DrawColor.B == 0)
    ScriptedTexture.DrawText(0, 0, DrawText, DrawFont);
  else
    ScriptedTexture.DrawColoredText(0, 0, DrawText, DrawFont, DrawColor);
  }


// ============================================================================
// DrawRotatedText
//
// This is the main function that is called by your UnrealScript code. It
// takes the Canvas to draw on, a rotation angle and the text to be drawn.
// Color and other rendering properties are taken from the given Canvas.
// ============================================================================

simulated function DrawRotatedText(Canvas Canvas, float Angle, string Text) {

  local float AngleRadian;
  local float AngleFovSave;
  local float SinAngle;
  local float CosAngle;
  local rotator RotationMesh;
  local vector LocationMesh;

  // Memorize the given text for use in RenderTexture.

  DrawText = Text;

  // Copy draw style and other propeties from the given Canvas to ourself.
  // The render style can't be directly copies, alas, since it's a byte
  // property in Canvas and an ERenderStyle property in Actor, we have to do it
  // this rather cumbersome way.

  DrawColor = Canvas.DrawColor;
  DrawFont  = Canvas.Font;

  switch (Canvas.Style) {
    case ERenderStyle.STY_None:         Style = ERenderStyle.STY_None;         break;
    case ERenderStyle.STY_Normal:       Style = ERenderStyle.STY_Normal;       break;
    case ERenderStyle.STY_Masked:       Style = ERenderStyle.STY_Masked;       break;
    case ERenderStyle.STY_Translucent:  Style = ERenderStyle.STY_Translucent;  break;
    case ERenderStyle.STY_Modulated:    Style = ERenderStyle.STY_Normal;       break;
    }

  bNoSmooth = Canvas.bNoSmooth;

  // The location and rotation of the actor holding the mesh we want to draw
  // determines how and where it is drawn by DrawClippedActor, so we adjust
  // our rotation and location to accommodate that.

  RotationMesh.Yaw   = 16384;
  RotationMesh.Pitch = 32768 * Angle / 180.0;
  RotationMesh.Roll  = 0;

  LocationMesh.X = 4.0 / tan(Pi / 4.0);
  LocationMesh.Y = 0.0;
  LocationMesh.Z = 0.0;
  
  SetLocation(LocationMesh);
  SetRotation(RotationMesh);

  // Save the player's current field-of-vision angle since we're changing it
  // below.

  AngleFovSave = Canvas.Viewport.Actor.FovAngle;

  // Select the next ScriptedTexture from our array and skin the mesh with it.
  
  MultiSkins[1] = ScriptedTextures[IndexScriptedTexture++ % ArrayCount(ScriptedTextures)];

  // Set the player's field-of-vision angle to a defined value, draw the mesh
  // on the canvas, and reset the field-of-vision angle to its original value
  // that we memorized above. For convenience, we draw the mesh so that its
  // upper-left corner is at the current drawing position (rather than its
  // center).

  AngleRadian = Angle * Pi / 180.0;
  SinAngle = sin(AngleRadian);
  CosAngle = cos(AngleRadian);

  Canvas.Viewport.Actor.SetFovAngle(30);
  Canvas.DrawClippedActor(Self, false, 400, 400,
    Canvas.CurX - 200 + 128 * (CosAngle + SinAngle),
    Canvas.CurY - 200 + 128 * (CosAngle - SinAngle), true);
  Canvas.Viewport.Actor.SetFovAngle(AngleFovSave);
  }


// ============================================================================
// Default Properties
// ============================================================================

defaultproperties {

  // Set ourself to use the RotatedTextMesh mesh imported above. Set a couple
  // of other display properties to make the mesh show up properly.
  
  Mesh=Mesh 'RotatedTextMesh'
  DrawScale=0.004263
  DrawType=DT_Mesh
  AmbientGlow=255
  bUnlit=True

  // Set RemoteRole to keep this actor from being replicated to other clients
  // when it is created on a listen server.

  RemoteRole=ROLE_None

  // Make our scripted textures available to the script. Cumbersome, but the
  // only way I'm aware of to work around the limitation that a given
  // ScriptedTexture is rendered only once per tick.
  
  ScriptedTextures(0)=ScriptedTexture 'RotatedTextTexture1'
  ScriptedTextures(1)=ScriptedTexture 'RotatedTextTexture2'
  ScriptedTextures(2)=ScriptedTexture 'RotatedTextTexture3'
  ScriptedTextures(3)=ScriptedTexture 'RotatedTextTexture4'
  ScriptedTextures(4)=ScriptedTexture 'RotatedTextTexture5'
  ScriptedTextures(5)=ScriptedTexture 'RotatedTextTexture6'
  ScriptedTextures(6)=ScriptedTexture 'RotatedTextTexture7'
  ScriptedTextures(7)=ScriptedTexture 'RotatedTextTexture8'
  ScriptedTextures(8)=ScriptedTexture 'RotatedTextTexture9'
  ScriptedTextures(9)=ScriptedTexture 'RotatedTextTexture10'
  ScriptedTextures(10)=ScriptedTexture 'RotatedTextTexture11'
  ScriptedTextures(11)=ScriptedTexture 'RotatedTextTexture12'
  ScriptedTextures(12)=ScriptedTexture 'RotatedTextTexture13'
  ScriptedTextures(13)=ScriptedTexture 'RotatedTextTexture14'
  ScriptedTextures(14)=ScriptedTexture 'RotatedTextTexture15'
  ScriptedTextures(15)=ScriptedTexture 'RotatedTextTexture16'
  ScriptedTextures(16)=ScriptedTexture 'RotatedTextTexture17'
  ScriptedTextures(17)=ScriptedTexture 'RotatedTextTexture18'
  ScriptedTextures(18)=ScriptedTexture 'RotatedTextTexture19'
  ScriptedTextures(19)=ScriptedTexture 'RotatedTextTexture20'
  ScriptedTextures(20)=ScriptedTexture 'RotatedTextTexture21'
  ScriptedTextures(21)=ScriptedTexture 'RotatedTextTexture22'
  ScriptedTextures(22)=ScriptedTexture 'RotatedTextTexture23'
  ScriptedTextures(23)=ScriptedTexture 'RotatedTextTexture24'
  ScriptedTextures(24)=ScriptedTexture 'RotatedTextTexture25'
  ScriptedTextures(25)=ScriptedTexture 'RotatedTextTexture26'
  ScriptedTextures(26)=ScriptedTexture 'RotatedTextTexture27'
  ScriptedTextures(27)=ScriptedTexture 'RotatedTextTexture28'
  ScriptedTextures(28)=ScriptedTexture 'RotatedTextTexture29'
  ScriptedTextures(29)=ScriptedTexture 'RotatedTextTexture30'
  ScriptedTextures(30)=ScriptedTexture 'RotatedTextTexture31'
  ScriptedTextures(31)=ScriptedTexture 'RotatedTextTexture32'
  }