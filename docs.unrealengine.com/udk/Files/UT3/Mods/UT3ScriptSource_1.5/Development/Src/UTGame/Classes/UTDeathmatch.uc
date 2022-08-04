/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTDeathmatch extends UTGame
	config(game);

function bool WantsPickups(UTBot B)
{
	return true;
}

/** return a value based on how much this pawn needs help */
function int GetHandicapNeed(Pawn Other)
{
	local float ScoreDiff;

	if ( Other.PlayerReplicationInfo == None )
	{
		return 0;
	}

	// base handicap on how far pawn is behind top scorer
	GameReplicationInfo.SortPRIArray();
	ScoreDiff = GameReplicationInfo.PriArray[0].Score - Other.PlayerReplicationInfo.Score;

	if ( ScoreDiff < 3 )
	{
		// ahead or close
		return 0;
	}
	return ScoreDiff/3;
}

function CheckSpiceOfLifeAchievement()
{
	local Mutator M;
	local int index;
	local int MutatorBitMask;
	local UTPlayerController PC;

	for (M=BaseMutator; M!=None; M=M.NextMutator)
	{
		if ( UTMutator_BigHead(M) != None)
			index = 0;
		else if ( UTMutator_FriendlyFire(M) != None)
			index = 1;
		else if ( UTMutator_Handicap(M) != None)
			index = 2;
		else if ( UTMutator_Instagib(M) != None)
			index = 3;
		else if ( UTMutator_LowGrav(M) != None)
			index = 4;
		else if ( UTMutator_NoOrbs(M) != None)
			index = 5;
		else if ( UTMutator_NoPowerups(M) != None)
			index = 6;
		else if ( UTMutator_NoTranslocator(M) != None)
			index = 7;
		else if ( UTMutator_Slomo(M) != None)
			index = 8;
		else if ( UTMutator_SlowTimeKills(M) != None)
			index = 9;
		else if ( UTMutator_SpeedFreak(M) != None)
			index = 10;
		else if ( UTMutator_SuperBerserk(M) != None)
			index = 11;
		else if ( UTMutator_WeaponReplacement(M) != None)
			index = 12;
		else if ( UTMutator_WeaponsRespawn(M) != None)
			index = 13;
		else if ( UTMutator_Survival(M) != None)
			index = 14;
		else
			index = -1;

		if (index != -1)
		{
			MutatorBitMask = MutatorBitMask | (1<<index);
		}
	}

	// Check Hero mutator without referencing UT3Gold content
	if ( UTGameReplicationInfo(WorldInfo.GRI).bHeroesAllowed )
	{
		//`log("SpiceOfLife : Hero enabled");
		MutatorBitMask = MutatorBitMask | (1<<15);
	}

	if (MutatorBitMask != 0)
	{
		foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
		{
			//Spectators don't get any
			if (PC.PlayerReplicationInfo.bOnlySpectator)
			{
				continue;
			}

			PC.ClientUpdateSpiceOfLife(MutatorBitMask);
		}
	}
}

function UpdateOnlineAchievements()
{
	local UTPlayerController PC;

	foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
	{
		//Spectators don't get any
		if (PC.PlayerReplicationInfo.bOnlySpectator)
		{
			continue;
		}

		if (PC.PlayerReplicationInfo == GameReplicationInfo.Winner || PC.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
		{
			PC.ClientUpdateAchievement(EUTA_RANKED_BloodSweatTears, 1);
		}
	}
}

function bool IsValidMutatorsForLikeTheBackOfMyHand()
{
	local Mutator M;

	for (M=BaseMutator; M!=None; M=M.NextMutator)
	{
		if ( UTMutator_Instagib(M) != None)
			return false;
		else if ( UTMutator_NoPowerups(M) != None)
			return false;
	}
	return true;
}

static function bool CheckLikeTheBackOfMyHandAchievement(UTPlayerController PC, INT index)
{
	local int Offset, BitIndex;
	local int TopMask, i, FullMask, Mask;
	local int MapIndex;
	local UTPlayerReplicationInfo UTPRI;
	local bool bAllPickups;

	if (UTBetrayalGame(PC.WorldInfo.Game) != None)
	{
		//Betrayal has no pickups, and doesn't count
		return false;
	}

    //Custom maps never count 
	MapIndex = ConvertMapNameToContext(PC.WorldInfo.GetMapName(true)); 
	if (MapIndex <= 0)
	{
		return false;
	}

	if (index < 0)
	{
		// -1 indicates no valid pickups on the map
		// so return true to catch maps with no pickups
		`log("No pickups for map "$PC.WorldInfo.GetMapName()$" - Marking it completed for Like the Back of my Hand Achievement");
		PC.ClientIncrementLikeTheBackOfMyHand(MapIndex);
		return true;
	}

	//How many 32 bit integers do we need to represent the pickups
	Offset = index / 32;
	//How many bits in the last array
	BitIndex = index % 32;

	// build the mask(s)
	FullMask = 0xFFFFFFFF;

	//Even 0 means a bitmask of 0x1
	for (i = 0; i <= BitIndex; i++)
	{
		TopMask = TopMask | (1<<i);
	}

	// get the PRI
	if (UTPlayerReplicationInfo(PC.PlayerReplicationInfo) != None)
	{
		UTPRI = UTPlayerReplicationInfo(PC.PlayerReplicationInfo);

		if ( UTPRI.PickupFlags.Length == Offset+1)
		{
			bAllPickups=true;
			for (i=0; i <= Offset; i++)
			{
				if (i == Offset)
				{
					Mask = TopMask;
				}
				else
				{
					Mask = FullMask;
				}

				if ( (UTPRI.PickupFlags[i] & Mask) != Mask )
				{
					bAllPickups=false;
					break;
				}
			}

			if (bAllPickups==true)
			{
				`log("You collected all the pickups for map "$PC.WorldInfo.GetMapName()$" - Marking it completed for Like the Back of my Hand Achievement");
				PC.ClientIncrementLikeTheBackOfMyHand(MapIndex);
			}
		}
	}

	return bAllPickups;
}

function CheckCampaignAchievements(int ChapterIndex, int Difficulty, bool Coop)
{
	local UTPlayerController PC;

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		//Spectators don't get any
		if (PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo.bOnlySpectator)
		{
			continue;
		}

		switch (ChapterIndex)
		{
			// complete chapter 1
		case 1:
			PC.ClientUpdateAchievement(EUTA_CAMPAIGN_Chapter1);
			break;
			// complete chapter 2 - sign treaty
		case 2:
			PC.ClientUpdateAchievement(EUTA_CAMPAIGN_SignTreaty);
			if (Difficulty > 2)
			{
				PC.ClientUpdateAchievement(EUTA_CAMPAIGN_SignTreatyExpert);
			}
			break;
			// complete chapter 3 - liandri mainframe
		case 3:
			PC.ClientUpdateAchievement(EUTA_CAMPAIGN_LiandriMainframe);
			if (Difficulty > 2)
			{
				PC.ClientUpdateAchievement(EUTA_CAMPAIGN_LiandriMainframeExpert);
			}
			break;
			// complete chapter 4 - reach omincron
		case 4:
			PC.ClientUpdateAchievement(EUTA_CAMPAIGN_ReachOmicron);
			if (Difficulty > 2)
			{
				PC.ClientUpdateAchievement(EUTA_CAMPAIGN_ReachOmicronExpert);
			}
			break;
			// complete chapter 5 - defeat akasha - will this trigger?
		case 5:
			PC.ClientUpdateAchievement(EUTA_CAMPAIGN_DefeatAkasha);
			if (Difficulty > 2)
			{
				PC.ClientUpdateAchievement(EUTA_CAMPAIGN_DefeatAkashaExpert);
			}
			if (Coop)
			{
				PC.ClientUpdateAchievement(EUTA_COOP_CompleteCampaign);
			}
			break;
			// this needs to be valid for Coop games
		case 6:
			if (Coop)
			{
				PC.ClientUpdateAchievement(EUTA_COOP_Complete1,1);
				PC.ClientUpdateAchievement(EUTA_COOP_Complete10,1);
			}
			break;
		}
	}
}

function CheckMissionAchievements()
{
	local bool MissionResult;
	local UTProfileSettings Profile;
	local PlayerController PC;
	local bool bCoop;
	local int UnlockChapter;

	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		Profile = UTProfileSettings( PC.OnlinePlayerData.ProfileProvider.Profile);
		break;
	}

	// get the mission result
	MissionResult = GetSinglePlayerResult();

	// Is this a Coop game?
	if (WorldInfo.Game.GetNumPlayers() > 1)
	{
		bCoop = true;
	}
	else
	{
		bCoop = false;
	}

	// you always win mission 1
	if ( SinglePlayerMissionID == 1 )
	{
		MissionResult = true;
	}

	if ( MissionResult )
	{
		switch ( SinglePlayerMissionID )
		{
			case 1:
				UnlockChapter = 1;
				break;
			case 15:
			case 110:
			case 117:
			case 121:
			case 129:
			case 135:
			case 138:
				UnlockChapter = 2;
				break;
			case 24:
			case 52:
			case 55:
			case 56:
			case 61:
			case 70:
			case 71:
			case 76:
			case 81:
			case 91:
			case 101:
			case 105:
				UnlockChapter = 3;
				break;
			case 33:
				UnlockChapter = 4;
				break;
			case 41:
				UnlockChapter = 5;
				break;
			default:
				UnlockChapter = -1;
				break;
		}
		if (UnlockChapter != -1)
		{
			`log("Unlock Chapter "$UnlockChapter);
			CheckCampaignAchievements(UnlockChapter, Profile.GetCampaignSkillLevel(), bCoop);
		}
	}

	if ( MissionResult && bCoop == true )
	{
		CheckCampaignAchievements(6,0,bCoop);
	}
}

function CheckAchievements()
{
	local int GameScore;
	local UTPlayerController PC;
	local int MixItUpType;
	local bool CheckLikeTheBackOfMyHand;

	if (SinglePlayerMissionID > INDEX_None)
	{
		CheckMissionAchievements();
	}

	CheckLikeTheBackOfMyHand = IsValidMutatorsForLikeTheBackOfMyHand();

	if (bUsingArbitration)
	{
		// it's a ranked game
		MixItUpType = 3;
	}
	else
	{
		if (WorldInfo.NetMode == NM_Standalone)
		{
			// it's an instant action game
			MixItUpType = 1;
		}
		else
		{
			// it'a a multiplayer game
			MixItUpType = 2;
		}
	}

	// Iterate through the playercontroller list
	foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
	{
		//Spectators don't get any
		if (PC.PlayerReplicationInfo.bOnlySpectator)
		{
			continue;
		}

		//These achievements aren't allowed in campaign
		if (SinglePlayerMissionID == INDEX_None)
		{
			// only increment the mix it up for ranked games if they won, do the other ones regardless
			if ((MixItUpType < 3) || (MixItUpType == 3 && (PC.PlayerReplicationInfo == GameReplicationInfo.Winner || PC.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)) )
			{
				// there has to be a better way to get the game type
				if (UTGreedGame(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(7, MixItUpType);
				else if (UTBetrayalGame(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(6, MixItUpType);
				else if (UTDuelGame(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(5, MixItUpType);
				else if (UTOnslaughtGame(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(4, MixItUpType);
				else if (UTVehicleCTFGame(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(3, MixItUpType);
				else if (UTCTFGame(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(2, MixItUpType);
				else if (UTTeamGame(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(1, MixItUpType);
				else if (UTDeathmatch(WorldInfo.Game) != None)
					PC.ClientIncrementMixItUp(0, MixItUpType);
			}

			// increment the around the world achievement
			if (WorldInfo.NetMode != NM_Standalone && (PC.PlayerReplicationInfo == GameReplicationInfo.Winner || PC.PlayerReplicationInfo.Team == GameReplicationInfo.Winner))
			{
				//`log("Update the Around the World achievement");
				// TODO:ACH - get map index, these need to have the same order/value as the map contexts on the Xbox
				PC.ClientIncrementAroundTheWorld(ConvertMapNameToContext(WorldInfo.GetMapName(true)));
			}

			// check the untouchable achievement
			if (WorldInfo.NetMode == NM_Standalone)
			{
				if (PC.PlayerReplicationInfo.Kills >= 20 && PC.PlayerReplicationInfo.Deaths == 0 && GetBotSkillLevel() == 7)
				{
					PC.ClientUpdateAchievement(EUTA_IA_Untouchable, 1);
				}
			}
		}

		if (CheckLikeTheBackOfMyHand)
		{
			CheckLikeTheBackOfMyHandAchievement(PC, UTGame(WorldInfo.Game).NextPickupIndex-1);
		}
	}

	if (BaseMutator != None)
	{
		CheckSpiceOfLifeAchievement();
	}

	// bah, check for the only non-team game achievement, the rest are in UTTeamGame
	if (IsMPOrHardBotsGame() && WorldInfo.Game.Class.Name == 'UTDeathmatch')
	{
		GameScore = UTPlayerReplicationInfo(GameReplicationInfo.Winner).Score;

		if ( GameScore >= 20 )
		{
			foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
			{
				//Spectators don't get any
				if (PC.PlayerReplicationInfo.bOnlySpectator)
				{
					continue;
				}

				PC.ClientUpdateAchievement(EUTA_GAME_PaintTownRed,1);
			}
		}
	}

	if (SinglePlayerMissionID == INDEX_NONE && WorldInfo.NetMode != NM_Standalone && !GameSettings.bIsLanMatch && (bUsingArbitration || !class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Xbox360)))
	{
		UpdateOnlineAchievements();
	}
}

/**
 * Writes out the stats for the game type
 */
function WriteOnlineStats()
{
	local UTLeaderboardWriteDM Stats;
	local UTPlayerController PC;
	local UTPlayerReplicationInfo PRI;
	local UniqueNetId ZeroUniqueId;
	local int NumInactives;
	local bool bIsPureGame;
	local int i;
	local float TimeInGame;

	//Figure out all the achievements
	CheckAchievements();

	if ((SinglePlayerMissionID > INDEX_None) || (WorldInfo.NetMode == NM_Standalone))
	{
		//We don't record single player stats
		return;
	}

	// Only calc this if the subsystem can write stats
	if (OnlineSub != None && OnlineSub.StatsInterface != None)
	{
		//Epic content + No bots => Pure
		bIsPureGame = IsPureGame() && !bPlayersVsBots;

		// Iterate through the playercontroller list updating the stats
		foreach WorldInfo.AllControllers(class'UTPlayerController',PC)
		{
			PRI = UTPlayerReplicationInfo(PC.PlayerReplicationInfo);

			// Don't record stats for bots (bots have a zero unique net id)
			// don't record for spectators either (@warning: assumes active players can't become spectators)
			if (PRI != None && !PRI.bOnlySpectator && (PRI.UniqueId != ZeroUniqueId))
			{
				TimeInGame = float(WorldInfo.GRI.ElapsedTime - PRI.StartTime);
				//Game has lasted more than 10 seconds, you've been in at least 30 secs of it or 90% of the elapsed time
				if (WorldInfo.GRI.ElapsedTime > 10 && (TimeInGame >= Min(30.0f, float(WorldInfo.GRI.ElapsedTime) * 0.9f)))
				{
					`log("Writing out stats for player"@PRI.PlayerName);
					//Write out all relevant stats
					Stats = UTLeaderboardWriteDM(new OnlineStatsWriteClass);
					Stats.CopyAndWriteAllStats(PC.PlayerReplicationInfo.UniqueId, PRI, bIsPureGame, OnlineSub.StatsInterface);
				}
			}
			else
			{
				`log("Player"@PRI.PlayerName@"did not have a valid UniqueID, stats not written");
			}
		}

		//Write out stats of players who left the game
		NumInactives = InactivePRIArray.length;
		for (i=0; i<NumInactives; i++)
		{
			PRI = UTPlayerReplicationInfo(InactivePRIArray[i]);
			if (PRI != None && (PRI.UniqueId != ZeroUniqueId))
			{
				`log("Writing out stats for inactive player"@PRI.PlayerName);
				//Write out all relevant stats
				Stats = UTLeaderboardWriteDM(new OnlineStatsWriteClass);
				Stats.CopyAndWriteAllStats(PRI.UniqueId, PRI, bIsPureGame, OnlineSub.StatsInterface);
			}
			else
			{
				`log("Inactive player"@PRI.PlayerName@"did not have a valid UniqueID, stats not written");
			}
		}
	}
}

defaultproperties
{
	Acronym="DM"
	MapPrefixes[0]="DM"
	DefaultEnemyRosterClass="UTGame.UTDMRoster"

	// Class used to write stats to the leaderboard
	OnlineStatsWriteClass=class'UTGame.UTLeaderboardWriteDM'
	// Default set of options to publish to the online service
	OnlineGameSettingsClass=class'UTGame.UTGameSettingsDM'

	bScoreDeaths=true

	// Deathmatch games don't care about teams for voice chat
	bIgnoreTeamForVoiceChat=true
}
