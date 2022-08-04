/*=============================================================================
	Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
=============================================================================*/
 
class SpeedTreeActor extends Actor
	native(SpeedTree)
	placeable;
	
var() const editconst SpeedTreeComponent SpeedTreeComponent;



defaultproperties
{	
	Begin Object Class=SpeedTreeComponent Name=SpeedTreeComponent0
		bAllowApproximateOcclusion=TRUE
		bCastDynamicShadow=FALSE
		bForceDirectLightMap=TRUE
	End Object
	SpeedTreeComponent = SpeedTreeComponent0;
	CollisionComponent = SpeedTreeComponent0;
	Components.Add(SpeedTreeComponent0);
	
	bEdShouldSnap	= FALSE

	bStatic			= TRUE 
	bMovable		= FALSE
	bNoDelete		= TRUE

	bCollideActors	= TRUE
	bBlockActors	= TRUE
	bWorldGeometry	= TRUE
}
