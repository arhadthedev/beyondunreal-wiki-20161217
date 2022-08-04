/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTAnimBlendByDriving extends AnimNodeBlend
	native(Animation);



/** Force an update of the driving state now. */
native function UpdateDrivingState();

defaultproperties
{
	Children(0)=(Name="Not-Driving",Weight=1.0)
	Children(1)=(Name="Driving")
	bFixNumChildren=true
}
