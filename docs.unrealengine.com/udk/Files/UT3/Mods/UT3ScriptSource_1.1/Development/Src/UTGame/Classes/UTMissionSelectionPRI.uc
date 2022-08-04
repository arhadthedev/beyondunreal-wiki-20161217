/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTMissionSelectionPRI extends UTPlayerReplicationInfo;


var bool bIsHost;

reliable server function SetModifierCard(name Card)
{

	local UTPlayerController PC;
	if ( bIsHost )
	{
		PC = UTPlayerController(Owner);
		if ( PC != none && (Card == '' || PC.HasModifierCard(Card)) )
		{
			UTMissionSelectionGame(WorldInfo.Game).SetModifierCard(Card);
		}
	}
}

/**
 * Called by the host, this tells the server to force all clients to the briefing menu
 */

reliable server function BriefMission()
{
    if ( bIsHost )
    {
    	UTMissionSelectionGame(WorldInfo.Game).BriefMission();
    }
}


/**
 * Tell the game we have selected the mission
 */
reliable server function AcceptMission()
{
	if ( bIsHost )
	{
    	UTMissionSelectionGame(WorldInfo.Game).AcceptMission();
	}
	else
	{
		bReadyToPlay = !bReadyToPlay;
	}
}


/**
 * The Mission has changed, notify everyone
 */
reliable server function ChangeMission(int NewMissionID)
{
	local UTMissionGRI GRI;

	GRI = UTMissionGRI(Worldinfo.GRI);
	if (GRI != none && bIsHost)
	{
		GRI.ChangeMission(NewMissionID);
	}
}


/**
 * Let's the server know we are ready to play
 */

reliable server function ServerReadyToPlay()
{
	bReadyToPlay = true;
}

defaultproperties
{


}
