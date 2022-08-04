class UTSeqAct_ScriptedVoiceMessage extends SequenceAction;

var() SoundNodeWave VoiceToPlay;
var() string SpeakingCharacterName;

event Activated()
{
	local UTGameReplicationInfo GRI;
	local UTPlayerReplicationInfo PRI, Sender;
	local int i;

	GRI = UTGameReplicationInfo(GetWorldInfo().GRI);
	if (GRI != None)
	{
		for (i = 0; i < GRI.PRIArray.length; i++)
		{
			PRI = UTPlayerReplicationInfo(GRI.PRIArray[i]);
			if ( PRI != None && ( PRI.PlayerName ~= SpeakingCharacterName ||
					(PRI.SinglePlayerCharacterIndex != INDEX_NONE && GRI.SinglePlayerBotNames[PRI.SinglePlayerCharacterIndex] ~= SpeakingCharacterName) ) )
			{
				Sender = PRI;
				break;
			}
		}

		if (Sender != None)
		{
			GRI.BroadcastLocalizedMessage(class'UTScriptedVoiceMessage',, Sender,, VoiceToPlay);
		}
		else
		{
			ScriptLog("Failed to find character '" $ SpeakingCharacterName $ "' for scripted voice message");
		}
	}
}

defaultproperties
{
	ObjClassVersion=2
	ObjName="Play Voice Message"
	ObjCategory="Voice/Announcements"
	VariableLinks.Empty()
}
