class UTSeqAct_AddNamedBot extends SequenceAction;

/** name of bot to spawn */
var() string BotName;
/** If true, force the bot to a given team */
var() bool bForceTeam;
/** The Team to add this bot to.  For DM leave at 0, otherwise Red=0, Blue=1 */
var() int TeamIndex;
/** NavigationPoint to spawn the bot at */
var() NavigationPoint StartSpot;

/** reference to bot controller so Kismet can work with it further */
var UTBot SpawnedBot;

event Activated()
{
	local UTGame Game;

	Game = UTGame(GetWorldInfo().Game);
	if (Game != None)
	{
		Game.ScriptedStartSpot = StartSpot;
		if (Game.SinglePlayerMissionID != INDEX_NONE)
		{
			if (Game.NumDivertedOpponents > 0 && bForceTeam && TeamIndex != 0)
			{
				Game.NumDivertedOpponents--;
			}
			else
			{
				SpawnedBot = Game.SinglePlayerAddBot(BotName, bForceTeam, TeamIndex);
			}
		}
		else
		{
			SpawnedBot = Game.AddBot(BotName, bForceTeam, TeamIndex);
		}
		if (SpawnedBot != None && SpawnedBot.Pawn == None)
		{
			Game.RestartPlayer(SpawnedBot);
		}
		Game.ScriptedStartSpot = None;
	}
}

defaultproperties
{
	ObjClassVersion=2
	ObjCategory="AI"
	ObjName="Add Named Bot"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Bot",bWriteable=true,PropertyName=SpawnedBot)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawn Point",PropertyName=StartSpot,MaxVars=1)
}
