/**
 * This will hold all of our enums and types and such that we need to
 * use in multiple files where the enum can't be mapped to a specific file.
 * Also to make these type available to the native land without forcing objects to be native.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTTypes extends Object
	native;


enum ECrossfadeType
{
	CFT_BeginningOfMeasure,
	CFT_EndOfMeasure
};


struct native MusicSegment
{
	/** Tempo in Beats per Minute. This allows for the specific segement to have a different BPM **/
	var() float TempoOverride;

	/** crossfading always begins at the beginning of the measure **/
	var ECrossfadeType CrossfadeRule;

	/**
	* How many measures it takes to crossfade to this MusicSegment
	* (e.g. No matter which MusicSegement we are currently in when we crossfade to this one we will
	* fade over this many measures.
	**/
	var() int CrossfadeToMeNumMeasuresDuration;

	var() SoundCue TheCue;

	structdefaultproperties
	{
		CrossfadeRule=CFT_BeginningOfMeasure;
		CrossfadeToMeNumMeasuresDuration=1
	}

};

struct native StingersForAMap
{
	var() SoundCue Died;
	var() SoundCue DoubleKill;
	var() SoundCue EnemyGrabFlag;
	var() SoundCue FirstKillingSpree;
	var() SoundCue FlagReturned;
	var() SoundCue GrabFlag;
	var() SoundCue Kill;
	var() SoundCue LongKillingSpree;
	var() SoundCue MajorKill;
	var() SoundCue MonsterKill;
	var() SoundCue MultiKill;
	var() SoundCue ReturnFlag;
	var() SoundCue ScoreLosing;
	var() SoundCue ScoreTie;
	var() SoundCue ScoreWinning;

};


struct native MusicForAMap
{
	/** Default Tempo in Beats per Minute. **/
	var() float Tempo;

	var() MusicSegment Action;
	var() MusicSegment Ambient;
	var() MusicSegment Intro;
	var() MusicSegment Suspense;
	var() MusicSegment Tension;
	var() MusicSegment Victory;
};

/** Live achievement defines (check UT3.spa.h for order)*/
enum EUTGameAchievements
{
	// Achievement IDs start from 1 so skip Zero
	EUTA_InvalidAchievement,

	EUTA_CAMPAIGN_Chapter1,
	EUTA_CAMPAIGN_SignTreaty,
	EUTA_CAMPAIGN_LiandriMainframe,
	EUTA_CAMPAIGN_ReachOmicron,
	EUTA_CAMPAIGN_DefeatAkasha,
	EUTA_CAMPAIGN_SignTreatyExpert,
	EUTA_CAMPAIGN_LiandriMainframeExpert,
	EUTA_CAMPAIGN_ReachOmicronExpert,
	EUTA_CAMPAIGN_DefeatAkashaExpert,
	EUTA_COOP_Complete1,
	EUTA_COOP_Complete10,
	EUTA_COOP_CompleteCampaign,
	EUTA_IA_EveryGameMode,
	EUTA_IA_Untouchable,
	EUTA_EXPLORE_AllPowerups,
	EUTA_EXPLORE_EveryMutator,
	EUTA_WEAPON_BrainSurgeon,
	EUTA_WEAPON_DontTaseMeBro,
	EUTA_WEAPON_GooGod,
	EUTA_WEAPON_Pistolero,
	EUTA_WEAPON_ShardOMatic,
	EUTA_WEAPON_Hammerhead,
	EUTA_WEAPON_StrongestLink,
	EUTA_WEAPON_HaveANiceDay,
	EUTA_WEAPON_BigGameHunter,
	EUTA_VEHICLE_Armadillo,
	EUTA_VEHICLE_JackOfAllTrades,
	EUTA_VEHICLE_Ace,
	EUTA_VEHICLE_Deathwish,
	EUTA_POWERUP_SeeingRed,
	EUTA_POWERUP_NeverSawItComing,
	EUTA_POWERUP_SurvivalFittest,
	EUTA_POWERUP_DeliveringTheHurt,
	EUTA_GAME_HatTrick,
	EUTA_GAME_BeingAHero,
	EUTA_GAME_FlagWaver,
	EUTA_GAME_30MinOrLess,
	EUTA_GAME_PaintTownRed,
	EUTA_GAME_ConnectTheDots,
	EUTA_HUMILIATION_SerialKiller,
	EUTA_HUMILIATION_SirSlaysALot,
	EUTA_HUMILIATION_KillJoy,
	EUTA_HUMILIATION_OffToAGoodStart,
	EUTA_VERSUS_GetItOn,
	EUTA_VERSUS_AroundTheWorld,
	EUTA_VERSUS_GetALife,
	EUTA_RANKED_BloodSweatTears,
	EUTA_UT3GOLD_CantBeTrusted,
	EUTA_UT3GOLD_Avenger,
	EUTA_UT3GOLD_BagOfBones,
	EUTA_UT3GOLD_SkullCollector,
	EUTA_UT3GOLD_Titanic,
	EUTA_UT3GOLD_Behemoth,
	EUTA_UT3GOLD_Unholy,
	EUTA_UT3GOLD_TheSlowLane,
	EUTA_UT3GOLD_Eradication,
	EUTA_UT3GOLD_Arachnophobia,
};


enum EUTChapterType
{
	UTCT_JimBrownNeedsToSendMartinEmailWithTheChapterNames,
	UTCT_SoWeCanRockThisUpYo,
};


