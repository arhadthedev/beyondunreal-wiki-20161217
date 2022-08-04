//=============================================================================
// MessagingSpectator - spectator base class for game helper spectators which receive messages
//
//  Ported to UE3 by Josh Markiewicz
//  © 1998-2008, Epic Games, Inc. All Rights Reserved
//=============================================================================

class MessagingSpectator extends Admin;

delegate ReceiveMessage( PlayerReplicationInfo Sender, string Msg, name Type );

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	bIsPlayer = False;
}

reliable client event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional float MsgLifeTime  )
{
	if (type != 'Say' && type != 'TeamSay' && type != 'none')
	{
		`Log("Received message that is not 'say' or 'teamsay'. Type="$type$" Message= "$s);
	}
	ReceiveMessage(pri, s, type);
}

// A couple of functions that should not do anything
reliable client function ClientGameEnded(Actor EndGameFocus, bool bIsWinner)
{}

// Report end game in log
function GameHasEnded(optional Actor EndGameFocus, optional bool bIsWinner)
{}

auto state NotPlaying
{}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.PlayerName="WebAdmin";
	PlayerReplicationInfo.bIsSpectator = true;
	PlayerReplicationInfo.bOnlySpectator = true;
	PlayerReplicationInfo.bOutOfLives = true;
	PlayerReplicationInfo.bWaitingPlayer = false;
}

defaultproperties
{
	//We can't see anything remotely
	CameraClass=None
}
