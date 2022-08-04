/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTVehicleFactory_Eradicator extends UTVehicleFactory;

function Deactivate()
{
	local int i;

	// kick players out of turrets instead of killing them
	if (ChildVehicle != None)
	{
		for (i = 0; i < ChildVehicle.Seats.length; i++)
		{
			if (ChildVehicle.Seats[i].SeatPawn != None && ChildVehicle.Seats[i].SeatPawn.bDriving)
			{
				ChildVehicle.Seats[i].SeatPawn.DriverLeave(true);
			}
		}
	}

	Super.Deactivate();
}

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_SPMA.Mesh.SK_VH_SPMA'
		Translation=(X=40.0,Y=0.0,Z=-90.0)
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=100.0
		CollisionRadius=260.0
		Translation=(X=-10.0,Y=0.0,Z=-20.0)
	End Object

	VehicleClassPath="UT3Gold.UTVehicle_Eradicator_Content"
	DrawScale=1.3
}
