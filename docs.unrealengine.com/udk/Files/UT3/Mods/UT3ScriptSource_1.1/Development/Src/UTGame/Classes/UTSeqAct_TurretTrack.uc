/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTSeqAct_TurretTrack extends SeqAct_Interp
	native(Sequence)
	hidecategories(SeqAct_Interp);



function Reset()
{
	SetPosition(0.0, false);
}

defaultproperties
{
	ObjName="Turret Track"
	InputLinks.Empty()
	InputLinks(0)=(LinkDesc="Spawned")
	OutputLinks.Empty()

	ReplicatedActorClass=class'UTTurretTrackActor'
}
