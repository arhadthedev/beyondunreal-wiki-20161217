//=============================================================================
// ReplicationInfo.
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class ReplicationInfo extends Info
	abstract
	native;



defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bStatic=False
	bNoDelete=False

	Components.Remove(Sprite)
}
