/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

/** The Root mission never get's played.  It is mearly the starting point and guareneteed to be index 0 */
class UTSeqObj_SPRootMission extends UTSeqObj_SPMission
	native(UI);




defaultproperties
{
	ObjComment="Root Mission"
	bFirstMission=true
	ObjName="Single Player Mission (ROOT)"

	MissionInfo=(MissionTitle="NewGame",MissionIndex=0)
	OutputLinks(0)=(LinkDesc="FirstMission")
}
