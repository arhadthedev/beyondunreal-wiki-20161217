/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTAnimBlendByHoverboardTilt extends AnimNodeBlendBase
	native(Animation);




var		vector UpVector;

var()	float TiltScale;
var()	float TiltDeadZone;
var()	float TiltYScale;
var		name UpperBodyName;

defaultproperties
{
	TiltYScale=1.0

	Children(0)=(Name="Flat",Weight=1.0)
	Children(1)=(Name="Forward")
	Children(2)=(Name="Backward")
	Children(3)=(Name="Left")
	Children(4)=(Name="Right")
	bFixNumChildren=true
	UpperBodyName=UpperBody
}