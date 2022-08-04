/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTPlayerReplicationInfo extends PlayerReplicationInfo
	native
	nativereplication
	dependson(UTCustomChar_Data);

var bool bHolding;
var databinding int spree;
var databinding int		MultiKillLevel;
var float		LastKillTime;

var UTLinkedReplicationInfo CustomReplicationInfo;	// for use by mod authors
var UTSquadAI Squad;
var private UTCarriedObject		HasFlag;

var class<UTVoice>		VoiceClass;

var repnotify UTGameObjective StartObjective;
var UTGameObjective TemporaryStartObjective;

var UTPlayerReplicationInfo LastKillerPRI;	/** Used for revenge reward, and for avoiding respawning near killer */

var color DefaultHudColor;

/** Set when pawn with this PRI has been rendered on HUD map, to avoid drawing it twice */
var bool bHUDRendered;

/** Replicated class of pawn controlled by owner of this PRI.  Replicated when drawing HUD Map */
var class<Pawn> HUDPawnClass;

var vector HUDLocation, HUDPawnLocation;
var byte HUDPawnYaw;
var MaterialInstanceConstant HUDMaterialInstance;

/** Determines which character this player will be in the single player game */
var int SinglePlayerCharacterIndex;

/** data for the character this player is using */
var repnotify CustomCharData CharacterData;
/** the mesh constructed from the above data */
var SkeletalMesh CharacterMesh;

/** Texture of render of custom character head. */
var	Texture		CharPortrait;

var MaterialInstanceConstant	RedHeadMIC;
var MaterialInstanceConstant	RedBodyMIC;

var MaterialInstanceConstant	BlueHeadMIC;
var MaterialInstanceConstant	BlueBodyMIC;

/** Mesh to use for first person arms. Should only be present for local players! */
var SkeletalMesh FirstPersonArmMesh;
/** Material applied to first person arms. Should only be present for local players! */
var MaterialInterface FirstPersonArmMaterial;
/** result of GetTeamNum() as of the last time we constructed the mesh for this player */
var byte CharacterMeshTeamNum;
/** last time we called ProcessCharacterData() from ReplicatedEvent() (to avoid calling it multiple times at once and clobbering stuff) */
var float LastReceivedCharacterDataTime;
/** set if the mesh/portrait were taken from another PRI (didn't construct our own) */
var bool bUsingReplacementCharacter;

/** counter used in native replication to detect whether the server has sent the latest character data to each client
 * should be incremented whenever CharacterData changes
 */
var byte CharacterDataChangeCount;

/**
 * The clan tag for this player
 */
var databinding string ClanTag;

struct native IntStat
{
	var name	StatName;
	var int		StatValue;
};

/** holds all kill stats (this player's kills, sorted by weapon/damagetype) */
var Array<IntStat> KillStats;

/** holds all death stats (this player's deaths instigated by another player, sorted by weapon/damagetype)*/
var Array<IntStat> DeathStats;

/** holds all suicide stats (this player's suicides, sorted by weapon/damagetype)*/
var Array<IntStat> SuicideStats;

/** holds event stats (mostly reward announcer related */
var Array<IntStat> EventStats;

/** holds node captured/built/healed and core damaged/destroyed stats */
var Array<IntStat> NodeStats;

/** Stats of vehicles killed by this player */
var Array<IntStat> VehicleKillStats;

/** Armor, health, and powerups picked up by this player */
var Array<IntStat> PickupStats;

// Pickup Flags
var bool bAllPickupsFoundThisMap;
var Array<INT> PickupFlags;

struct native TimeStat
{
	var name StatName;
	var float TotalTime;
	var float CurrentStart;
};

/** Time spent driving, sorted by vehicle */
var Array<TimeStat> DrivingStats;

/** Time spent holding powerups and flag/orb */
var Array<TimeStat> PowerupTimeStats;

/** this class is used to cache the character data temporarily when this PRI is destroyed */
var class<UTProcessedCharacterCache> CharacterCacheClass;

/** indicates that this is a bot spawned only to precache a custom character. It should be destroyed when the game begins
 * but the character data should stay around to be used by something spawned later (usually a character spawned by Kismet in the level)
 */
var bool bPrecachedBot;

var localized string OrdersString[8];
var byte OrdersIndex;

/************************************
*  Hero related variables
************************************/
var float HeroThreshold;
var bool bHasBeenHero;

/** Voice to use for TTS. */
var transient ETTSSpeaker TTSSpeaker;

/** Weapon award (most kills) at end of match - can reference by class since some aren't always loaded for console */
var int WeaponAwardIndex;

/** Used for weapon award calculation */
var int WeaponAwardKills;



replication
{
	if (bNetDirty)
		CustomReplicationInfo, bHolding, Squad, OrdersIndex, ClanTag, SinglePlayerCharacterIndex;

	if ( bNetOwner && ROLE==ROLE_Authority )
		StartObjective;

	if ( !bNetOwner ) // && UTPlayerController(ReplicationViewer).bViewingMap (if so, in C++ HUDLocationRep = HUDLocation, HUDPawnClass updated too);
		HUDPawnClass, HUDPawnLocation, HUDPawnYaw;

	if (bNetDirty) // && CharacterDataChangeCount != Recent->CharacterDataChangeCount
		CharacterData;

	if (bNetInitial)
		bPrecachedBot;
}

simulated event Destroyed()
{
	local UTProcessedCharacterCache CharacterCache;
	local UTGameReplicationInfo GRI;

	Super.Destroyed();

	// listen server/standalone can copy the mesh/etc data using CopyProperties(), so only need the cache on client
	if (!bUsingReplacementCharacter)
	{
		if ((WorldInfo.NetMode == NM_Client || bPrecachedBot) && CharacterCacheClass != None && CharacterCacheClass.static.ShouldCacheCharacter(self))
		{
			CharacterCache = Spawn(CharacterCacheClass);
			CharacterCache.CachePRICharacter(self);
			if (bPrecachedBot)
			{
				CharacterCache.LifeSpan = 0.0;
			}
		}
		else if (CharacterMesh != None)
		{
			GRI = UTGameReplicationInfo(WorldInfo.GRI);
			if (GRI != None)
			{
				GRI.TotalPlayersSetToProcess--;
			}
		}
	}
}

simulated function bool ShouldBroadCastWelcomeMessage()
{
	local UTGame Game;

	Game = UTGame(WorldInfo.Game);
	return (!bBot || Game == None || Game.SinglePlayerMissionID == INDEX_NONE) && Super.ShouldBroadcastWelcomeMessage();
}

function int IncrementKillStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	// Check if we should increment "Arachnophobia" achievement progress
	// We are doing this here because we cannot modify UTGameContent scripts for UT3Gold
	if (NewStatName == 'KILLS_SPIDERMINE' && UTPlayerController(Owner) != None && 
		UTTeamGame(WorldInfo.Game) == None && UTDeathmatch(WorldInfo.Game) != None)
	{
		UTPlayerController(Owner).ClientUpdateAchievement(EUTA_UT3GOLD_Arachnophobia, 1);
	}

	Len = KillStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( KillStats[i].StatName == NewStatName )
		{
			KillStats[i].StatValue++;
			return KillStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	KillStats[Len] = NewStat;
	UpdateEventStatAchievements(NewStatName); // need to track the roadkill award which is a kill stat
	return 1;
}

function int IncrementDeathStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = DeathStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( DeathStats[i].StatName == NewStatName )
		{
			DeathStats[i].StatValue++;
			return DeathStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	DeathStats[Len] = NewStat;
	return 1;
}

function int IncrementSuicideStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = SuicideStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( SuicideStats[i].StatName == NewStatName )
		{
			SuicideStats[i].StatValue++;
			return SuicideStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	SuicideStats[Len] = NewStat;
	return 1;
}

function UpdateEventStatAchievements(name StatName)
{
	local UTPlayerController PC;

	PC = UTPlayerController(Owner);

	if (PC != None && UTGame(WorldInfo.Game).IsMPOrHardBotsGame())
	{
		if (StatName == 'REWARD_HEADHUNTER')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_BrainSurgeon, 1);
		}
		else if (StatName == 'REWARD_COMBOKING')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_DontTaseMeBro, 1);
		}
		else if (StatName == 'REWARD_BIOHAZARD')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_GooGod, 1);
		}
		else if (StatName == 'REWARD_GUNSLINGER')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_Pistolero, 1);
		}
		else if (StatName == 'REWARD_BLUESTREAK')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_ShardOMatic, 1);
		}
		else if (StatName == 'REWARD_JACKHAMMER')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_Hammerhead, 1);
		}
		else if (StatName == 'REWARD_SHAFTMASTER')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_StrongestLink, 1);
		}
		else if (StatName == 'REWARD_BIGGAMEHUNTER')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_BigGameHunter, 1);
		}
		else if (StatName == 'REWARD_ROCKETSCIENTIST')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_HaveANiceDay, 0);
		}
		else if (StatName == 'REWARD_FLAKMASTER')
		{
			PC.ClientUpdateAchievement(EUTA_WEAPON_HaveANiceDay, 1);
		}
		else if (StatName == 'SPREE_KILLINGSPREE')
		{
			PC.ClientUpdateAchievement(EUTA_HUMILIATION_SerialKiller, 1);
		}
		else if (StatName == 'MULTIKILL_MONSTERKILL')
		{
			PC.ClientUpdateAchievement(EUTA_HUMILIATION_SirSlaysALot, 1);
		}
		else if (StatName == 'EVENT_FIRSTBLOOD')
		{
			PC.ClientUpdateAchievement(EUTA_HUMILIATION_OffToAGoodStart, 1);
		}
		else if (StatName == 'EVENT_ENDSPREE')
		{
			PC.ClientUpdateAchievement(EUTA_HUMILIATION_KillJoy, 1);
		}
		else if (StatName == 'EVENT_RANOVERKILLS')
		{
			PC.ClientUpdateAchievement(EUTA_VEHICLE_Armadillo, 1);
		}
		else if (StatName == 'EVENT_TOPGUN')
		{
			PC.ClientUpdateAchievement(EUTA_VEHICLE_Ace, 1);
		}
		else if (StatName == 'EVENT_BULLSEYE')
		{
			PC.ClientUpdateAchievement(EUTA_VEHICLE_Deathwish, 1);
		}
		else if (StatName == 'EVENT_HATTRICK')
		{
			PC.ClientUpdateAchievement(EUTA_GAME_HatTrick, 1);
		}
		else if (StatName == 'EVENT_RETURNEDORB')
		{
			PC.ClientUpdateAchievement(EUTA_GAME_BeingAHero, 1);
		}
	}
}

function int IncrementEventStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	//`log("Increment Event Stat "$NewStatName);

	Len = EventStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( EventStats[i].StatName == NewStatName )
		{
			// this is the only one we count more than once per match
			if (NewStatName == 'EVENT_RETURNEDORB')
			{
				UpdateEventStatAchievements(NewStatName);
			}
			EventStats[i].StatValue++;
			return EventStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	EventStats[Len] = NewStat;
	UpdateEventStatAchievements(NewStatName);
	return 1;
}

function int AddToEventStat(name NewStatName, int Amount)
{
	local int i, Len;
	local IntStat NewStat;

	Len = EventStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( EventStats[i].StatName == NewStatName )
		{
			EventStats[i].StatValue += Amount;
			return EventStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = Amount;
	EventStats[Len] = NewStat;
	return Amount;
}

function int IncrementNodeStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = NodeStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( NodeStats[i].StatName == NewStatName )
		{
			NodeStats[i].StatValue++;
			return NodeStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	NodeStats[Len] = NewStat;
	return 1;
}

function int AddToNodeStat(name NewStatName, int Amount)
{
	local int i, Len;
	local IntStat NewStat;

	Len = NodeStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( NodeStats[i].StatName == NewStatName )
		{
			NodeStats[i].StatValue += Amount;
			return NodeStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = Amount;
	NodeStats[Len] = NewStat;
	return Amount;
}

function StartDrivingStat(name NewStatName)
{
	local int i, Len;
	local TimeStat NewStat;

	Len = DrivingStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( DrivingStats[i].StatName == NewStatName )
		{
			DrivingStats[i].CurrentStart = WorldInfo.TimeSeconds;
			return;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.CurrentStart = WorldInfo.TimeSeconds;
	DrivingStats[Len] = NewStat;
	return;
}

function StopDrivingStat(name NewStatName)
{
	local int i, Len;

	Len = DrivingStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( DrivingStats[i].StatName == NewStatName )
		{
			DrivingStats[i].TotalTime = DrivingStats[i].TotalTime + WorldInfo.TimeSeconds - DrivingStats[i].CurrentStart;
			return;
		}
	}

	// didn't find it - just fail
	`warn("Stopped driving stat "$NewStatName$" without starting it");
	return;
}

function int IncrementVehicleKillStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = VehicleKillStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( VehicleKillStats[i].StatName == NewStatName )
		{
			VehicleKillStats[i].StatValue++;
			return VehicleKillStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	VehicleKillStats[Len] = NewStat;
	return 1;
}

function int IncrementPickupStat(name NewStatName)
{
	local int i, Len;
	local IntStat NewStat;

	Len = PickupStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( PickupStats[i].StatName == NewStatName )
		{
			PickupStats[i].StatValue++;
			return PickupStats[i].StatValue;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.StatValue = 1;
	PickupStats[Len] = NewStat;
	return 1;
}

function int UpdatePickupFlags(int index)
{
	local int Len, Offset, BitIndex;

	if (index >=0 && !bAllPickupsFoundThisMap && Owner != None && UTPlayerController(Owner) != None)
	{
		// find where this bit will be in 32 bit values
		Offset = index / 32;
		BitIndex = index % 32;

		Len = PickupFlags.Length;

		if (Offset+1 > Len)
		{
			// grow the array if we need to
			PickupFlags.Length = Offset + 1;
		}

		// mark this pickup as taken
		if ((PickupFlags[Offset] | (1<<BitIndex)) != PickupFlags[Offset])
		{
			PickupFlags[Offset] = PickupFlags[Offset] | (1<<BitIndex);
			//`log("Picked up pickup "$index$" resolved to Offset "$Offset$", BitIndex "$BitIndex$" : PickupFlags["$Offset$"] = "$PickupFlags[Offset]);
			if (class'UTDeathmatch'.static.CheckLikeTheBackOfMyHandAchievement(UTPlayerController(Owner), UTGame(WorldInfo.Game).NextPickupIndex-1))
			{
				ClientOnAllPickupsTaken();
				//Server knows we have all pickups
				bAllPickupsFoundThisMap = true;
			}  
		}
	}

	return 1;
}

function StartPowerupTimeStat(name NewStatName)
{
	local int i, Len;
	local TimeStat NewStat;

	Len = PowerupTimeStats.Length;
	for (i=0; i<Len; i++ )
	{
		if ( PowerupTimeStats[i].StatName == NewStatName )
		{
			PowerupTimeStats[i].CurrentStart = WorldInfo.TimeSeconds;
			return;
		}
	}

	// didn't find it - add a new one
	NewStat.StatName = NewStatName;
	NewStat.CurrentStart = WorldInfo.TimeSeconds;
	PowerupTimeStats[Len] = NewStat;
	return;
}

function UpdatePowerupAchievements(name StatName, int time)
{
	local UTPlayerController PC;

	PC = UTPlayerController(Owner);

	if (PC != None && UTGame(WorldInfo.Game).IsMPOrHardBotsGame())
	{
		if (StatName == 'POWERUPTIME_BERSERK')
		{
			PC.ClientUpdateAchievement(EUTA_POWERUP_SeeingRed, time);
		}
		if (StatName == 'POWERUPTIME_INVISIBILITY')
		{
			PC.ClientUpdateAchievement(EUTA_POWERUP_NeverSawItComing, time);
		}
		if (StatName == 'POWERUPTIME_INVULNERABILITY')
		{
			PC.ClientUpdateAchievement(EUTA_POWERUP_SurvivalFittest, time);
		}
		if (StatName == 'POWERUPTIME_UDAMAGE')
		{
			PC.ClientUpdateAchievement(EUTA_POWERUP_DeliveringTheHurt, time);
		}
		if (StatName == 'POWERUPTIME_SLOWFIELD')
		{
			PC.ClientUpdateAchievement(EUTA_UT3GOLD_TheSlowLane, time);
		}
	}
}

function StopPowerupTimeStat(name NewStatName)
{
	local int i, Len, TimeDelta;

	Len = PowerupTimeStats.Length;
	for (i=0; i<Len; i++ )
	{
		if (PowerupTimeStats[i].StatName == NewStatName)
		{
			if (PowerupTimeStats[i].CurrentStart >= 0.0)
			{
				TimeDelta = WorldInfo.TimeSeconds - PowerupTimeStats[i].CurrentStart + 0.5;
				UpdatePowerupAchievements(NewStatName, TimeDelta);
				PowerupTimeStats[i].TotalTime = PowerupTimeStats[i].TotalTime + TimeDelta;
				//Mark the current start in case we call stop twice
				PowerupTimeStats[i].CurrentStart = -1.0;
			}

			return;
		}
	}

	// didn't find it - just fail
	`warn("Stopped powerup time stat "$NewStatName$" without starting it");
	return;
}

simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController HUDPlayerOwner, LinearColor FinalColor)
{
	local class<UTVehicle> VClass;
	local class<UTPawn> PClass;
	local float MapSize;
	local TextureCoordinates UVs;

	if ( HUDPawnClass == None )
	{
		return;
	}

	PClass = class<UTPawn>(HUDPawnClass);
	if ( PClass != None )
	{
		MapSize = PClass.Default.MapSize;
		UVs = PClass.Default.IconCoords;
	}
	else
	{
		VClass = class<UTVehicle>(HUDPawnClass);
		if ( VClass != None )
		{
			MapSize = VClass.Default.MapSize;
			UVs = VClass.Default.IconCoords;
		}
		else
		{
			`log(PlayerName$" PRI has bad pawn class "$HUDPawnClass);
			return;
		}
	}

	Canvas.SetPos(HUDLocation.X - 0.5*MapSize* MP.MapScale, HUDLocation.Y - 0.5* MapSize* MP.MapScale * Canvas.ClipY / Canvas.ClipX);
	MP.DrawRotatedTile(Canvas,class'UTHUD'.default.IconHudTexture, HUDLocation, HUDPawnYaw, MapSize, UVs, FinalColor);
}

function UpdatePlayerLocation()
{
	local UTBot B;
	local UTPlayerController PC;
	local name BotOrders;

	B = UTBot(Owner);
	if ( B != None )
	{
		BotOrders = B.GetOrders();
		if ( BotOrders == 'ATTACK' )
		{
			OrdersIndex = 2;
		}
		else if ( BotOrders == 'DEFEND' )
		{
			OrdersIndex = 3;
		}
		else if ( BotOrders == 'FOLLOW' )
		{
			OrdersIndex = 6;
		}
		else if ( BotOrders == 'HOLD' )
		{
			OrdersIndex = 7;
		}
		else
		{
			OrdersIndex = 0;
		}
		return;
	}

	PC = UTPlayerController(Owner);
	if ( PC != None )
	{
		OrdersIndex = PC.AutoObjectivePreference;
	}
}

simulated function string GetLocationName()
{
	return OrdersString[OrdersIndex];
}

reliable server function SetStartObjective(UTGameObjective Objective, bool bTemporary)
{
	if ( Objective == None || Objective.ValidSpawnPointFor(Team.TeamIndex))
	{
		// make sure old StartSpot isn't used by the spawning code since it might not be valid for the new start objective
		Controller(Owner).StartSpot = None;
		if (bTemporary)
		{
			TemporaryStartObjective = Objective;
		}
		else
		{
			StartObjective = Objective;
		}
	}
}

function UTGameObjective GetStartObjective()
{
	local UTBot B;
	local UTGameObjective SelectedPC;

	SelectedPC = TemporaryStartObjective;
	TemporaryStartObjective = None;
	if (SelectedPC != None && SelectedPC.ValidSpawnPointFor(Team.TeamIndex))
	{
		return SelectedPC;
	}
	else
	{
		B = UTBot(Owner);
		if (B != None && B.Squad != None)
		{
			return B.Squad.GetStartObjective(B);
		}
		else
		{
			return (StartObjective != None && StartObjective.ValidSpawnPointFor(Team.TeamIndex)) ? StartObjective : None;
		}
	}
}

function SetFlag(UTCarriedObject NewFlag)
{
	HasFlag = NewFlag;
	bHasFlag = (HasFlag != None);
}

function UTCarriedObject GetFlag()
{
	return HasFlag;
}

simulated function bool IsHero()
{
	return false;
}

simulated function bool CanBeHero()
{
	return false;
}

simulated function float GetHeroMeter()
{
	return 0.0f;
}

function int GetNumCoins()
{
	return 0;
}

function ResetHero();
function IncrementHeroMeter(float AddedValue, optional class<UTDamageType> DamageType);
function CheckHeroMeter();
function bool TriggerHero()
{
	return false;
}

function AddCoins(int Coins);

// Deprecated
function LogMultiKills(bool bEnemyKill);

// Deprecated
function IncrementSpree();

function IncrementKills(bool bEnemyKill, class<UTDamageType> DamageType)
{

	if ( bEnemyKill )
	{
		IncrementHeroMeter(1.0, DamageType);

		if ( WorldInfo.TimeSeconds - LastKillTime < 4 )
		{
			IncrementHeroMeter(1.0, DamageType);
			MultiKillLevel++;
			IncrementEventStat(class'UTLeaderboardWriteDM'.Default.MULTIKILL[Min(MultiKillLevel-1, 4)]);
		}
		else
		{
			MultiKillLevel = 0;
		}

		LastKillTime = WorldInfo.TimeSeconds;

		spree++;
		if ( spree > 4 )
		{
			IncrementHeroMeter(1.0, DamageType);
			UTGame(WorldInfo.Game).NotifySpree(self, spree);
		}
	}
	else
	{
		MultiKillLevel = 0;
	}
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	SetFlag(None);
	Spree = 0;

	KillStats.length = 0;
	DeathStats.length = 0;
	SuicideStats.length = 0;
	EventStats.length = 0;
	NodeStats.length = 0;
	VehicleKillStats.length = 0;
	PickupStats.length = 0;
	DrivingStats.length = 0;
	PowerupTimeStats.length = 0;
	PickupFlags.length = 0;
	bHasBeenHero = false;
}

simulated function string GetCallSign()
{
	return PlayerName;
}

/* epic ===============================================
* ::OverrideWith
Get overridden properties from old PRI
*/
function OverrideWith(PlayerReplicationInfo PRI)
{
	local UTPlayerReplicationInfo UTPRI;

	Super.OverrideWith(PRI);

	UTPRI = UTPlayerReplicationInfo(PRI);
	if ( UTPRI == None )
		return;
}

/* epic ===============================================
* ::CopyProperties
Copy properties which need to be saved in inactive PRI
*/
function CopyProperties(PlayerReplicationInfo PRI)
{
	local UTPlayerReplicationInfo UTPRI;

	Super.CopyProperties(PRI);

	UTPRI = UTPlayerReplicationInfo(PRI);
	if ( UTPRI == None )
		return;

	UTPRI.CustomReplicationInfo = CustomReplicationInfo;
	UTPRI.CharacterData = CharacterData;
	UTPRI.bIsFemale = bIsFemale;
	UTPRI.CharacterDataChangeCount++;

	UTPRI.KillStats = KillStats;
	UTPRI.DeathStats = DeathStats;
	UTPRI.SuicideStats = SuicideStats;
}

function SeamlessTravelTo(PlayerReplicationInfo NewPRI)
{
	local UTPlayerReplicationInfo UTPRI;
	local UTGameReplicationInfo GRI;

	Super.SeamlessTravelTo(NewPRI);

	// copy constructed character data directly
	UTPRI = UTPlayerReplicationInfo(NewPRI);
	if (UTPRI != None)
	{
		UTPRI.CharacterMesh = CharacterMesh;
        //Save the materials also so we can switch teams (server only)
 		UTPRI.RedBodyMIC = RedBodyMIC;
 		UTPRI.RedHeadMIC = RedHeadMIC;
 		UTPRI.BlueBodyMIC = BlueBodyMIC;
 		UTPRI.BlueHeadMIC = BlueHeadMIC;
		UTPRI.CharPortrait = CharPortrait;
		UTPRI.VoiceClass = VoiceClass;
		UTPRI.SinglePlayerCharacterIndex = SinglePlayerCharacterIndex;

		UTPRI.bUsingReplacementCharacter = bUsingReplacementCharacter;
		UTPRI.FirstPersonArmMesh = FirstPersonArmMesh;
		UTPRI.FirstPersonArmMaterial = FirstPersonArmMaterial;
		// increment GRI's counter if a mesh persisted
		//@warning: this assumes a new GRI is created after each travel and that happens before calling this function
		if (!UTPRI.bUsingReplacementCharacter && UTPRI.CharacterMesh != None)
		{
			GRI = UTGameReplicationInfo(WorldInfo.GRI);
			if (GRI != None)
			{
				GRI.TotalPlayersSetToProcess++;
			}
		}
	}
}

/**********************************************************************************************
 Teleporting
 *********************************************************************************************/

/**
 * The function is used to setup the conditions that allow a teleport.  It also defers to the gameinfo
 *
 * @Param		DestinationActor 	The actor to teleport to
 * @param		OwnerPawn			returns the pawn owned by the controlling owner casts to UTPawn
 *
 * @returns		True if the teleport is allowed
 */

function bool AllowClientToTeleport(Actor DestinationActor, out UTPawn OwnerPawn)
{
	local Controller OwnerC;

	OwnerC = Controller(Owner);

//	`log("##"@OwnerC@DestinationActor@UTGame(WorldInfo.Game).AllowClientToTeleport(Self, DestinationActor));


	if ( OwnerC != none && DestinationActor != None &&
			UTGame(WorldInfo.Game) != none && UTGame(WorldInfo.Game).AllowClientToTeleport(Self, DestinationActor) )
	{
		// Cast the Pawn as we know we need it.
		OwnerPawn = UTPawn(OwnerC.Pawn);
		if ( OwnerPawn != none )
		{
			if (bHasFlag)
			{
				GetFlag().Drop();
			}
			return true;
		}
	}

	return false;
}

/**
 * This function is used to teleport directly to actor.  Currently, only 2 types of actors
 * support teleporting.  UTGameObjectives and UTVehicle_Leviathans.
 *
 * @param	DestinationActor	This is the Actor the player is trying to teleport to
 */

server reliable function ServerTeleportToActor(Actor DestinationActor)
{
	local UTPawn OwnedPawn;
	local UTOnslaughtNodeObjective DestObj;
	local UTOnslaughtNodeTeleporter Teleporter;
	local int i;
	local UTVehicle_Leviathan Levi;

	if ( AllowClientToTeleport(DestinationActor, OwnedPawn) )
	{

		// Handle teleporting to Game Objectives

		if ( UTGameObjective(DestinationActor) != none )
		{
			Teleporter = UTOnslaughtNodeTeleporter(OwnedPawn.Base);
			if ( Teleporter != none )
			{
				DestObj = UTOnslaughtNodeObjective(DestinationActor);
				if ( DestObj != none )
				{
					for (i=0;i<DestObj.NodeTeleporters.Length;i++)
					{
						if ( DestObj.NodeTeleporters[i] == Teleporter )
						{
							// FIXME: Add a message about the failure
							return;
						}
					}
				}
			}

			UTGameObjective(DestinationActor).TeleportTo( OwnedPawn );
		}
		// Handle Leviathans (but only if the current gametype allows that)
		else if (UTVehicle_Leviathan(DestinationActor) != none && UTOnslaughtGame(WorldInfo.Game) != none)
		{
			Levi = 	UTVehicle_Leviathan(DestinationActor);
			if ( Levi.AnySeatAvailable() )
			{
				Levi.TryToDrive(OwnedPawn);
			}
			else
			{
				Levi.PlaceExitingDriver(OwnedPawn);
			}
		}
	}
}

simulated event color GetHudColor()
{
	if ( Team != none )
	{
		return Team.GetHudColor();
	}
	else
	{
		return DefaultHudColor;
	}
}

simulated event ReplicatedEvent(name VarName)
{
	local UTGameReplicationInfo UTGRI;

	if ( VarName == 'Team' )
	{
		if (LastReceivedCharacterDataTime != WorldInfo.TimeSeconds && GetTeamNum() != CharacterMeshTeamNum)
		{
			// try to recreate custom character mesh as they are team specific
			UTGRI = UTGameReplicationInfo(WorldInfo.GRI);
			if (UTGRI != none)
			{
				UTGRI.ProcessCharacterData(self, IsLocalPlayerPRI());
				LastReceivedCharacterDataTime = WorldInfo.TimeSeconds;
			}
		}

		Super.ReplicatedEvent(VarName);
	}
	else if (VarName == 'CharacterData')
	{
		if (LastReceivedCharacterDataTime != WorldInfo.TimeSeconds)
		{
			UTGRI = UTGameReplicationInfo(WorldInfo.GRI);
			if (UTGRI != None)
			{
				UTGRI.ProcessCharacterData(self);
				LastReceivedCharacterDataTime = WorldInfo.TimeSeconds;
			}
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/** triggers custom mesh creation only if we didn't get one
 * this is used on a timer to retry after a delay when we don't think we have all the necessary info
 */
simulated function RetryProcessCharacterData()
{
	local UTGameReplicationInfo GRI;

	if (CharacterMesh == None)
	{
		GRI = UTGameReplicationInfo(WorldInfo.GRI);
		if (GRI != None)
		{
			GRI.ProcessCharacterData(self);
		}
	}
}

/** Called by custom character code when building player mesh to create team-coloured texture.  */
simulated function string GetCustomCharTeamString()
{
	if (Team != None)
	{
		if (Team.TeamIndex == 0)
		{
			return "VRed";
		}
		else if (Team.TeamIndex == 1)
		{
			return "VBlue";
		}
	}

	return "V01";
}

simulated function string GetCustomCharOtherTeamString()
{
	if (Team != None)
	{
		if (Team.TeamIndex == 0)
		{
			return "VBlue";
		}
		else if (Team.TeamIndex == 1)
		{
			return "VRed";
		}
	}

	return "V01";
}

/** sets character data, triggering an update for the local player and any clients */
function SetCharacterData(const out CustomCharData NewData)
{
	local UTGameReplicationInfo GRI;
	local UTGame UTG;

	// If we don't want custom characters (or this is PIE) - skip this part.
	UTG = UTGame(WorldInfo.Game);
	if ((UTG == None || !UTG.bNoCustomCharacters) && !WorldInfo.IsPlayInEditor() && NewData != CharacterData)
	{
		CharacterData = NewData;
		CharacterDataChangeCount++;
		bForceNetUpdate = TRUE;

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			GRI = UTGameReplicationInfo(WorldInfo.GRI);
			if (GRI != None)
			{
				GRI.ProcessCharacterData(self);
			}
		}
	}
}

/** Save the materials off the supplied mesh as the 'other' team materials. */
simulated function SetOtherTeamSkin(SkeletalMesh NewSkelMesh)
{
	if (Team != None && NewSkelMesh != None)
	{
		if (Team.TeamIndex == 0)
		{
			assert(BlueHeadMIC == None);
			BlueHeadMIC = MaterialInstanceConstant(NewSkelMesh.Materials[0]);
			BlueBodyMIC = MaterialInstanceConstant(NewSkelMesh.Materials[1]);
		}
		else if (Team.TeamIndex == 1)
		{
			assert(RedHeadMIC == None);
			RedHeadMIC = MaterialInstanceConstant(NewSkelMesh.Materials[0]);
			RedBodyMIC = MaterialInstanceConstant(NewSkelMesh.Materials[1]);
		}
	}
}

simulated native function SetCharMeshMaterial(int MatIndex, MaterialInstanceConstant MIC);

/** Util to swamp the team skin colour on a custom character mesh. */
simulated function bool UpdateCustomTeamSkin()
{
	local Pawn P;

	if(Team != None && IsLocalPlayerPRI())
	{
		if (Team.TeamIndex == 0 && RedBodyMIC != None)
		{
			SetCharMeshMaterial(0, RedHeadMIC);
			SetCharMeshMaterial(1, RedBodyMIC);
		}
		else if (Team.TeamIndex == 1 && BlueBodyMIC != None)
		{
			SetCharMeshMaterial(0, BlueHeadMIC);
			SetCharMeshMaterial(1, BlueBodyMIC);
		}
		else
		{
			return FALSE;
		}

		foreach WorldInfo.AllPawns(class'Pawn', P)
		{
			if (P.PlayerReplicationInfo == self || (P.DrivenVehicle != None && P.DrivenVehicle.PlayerReplicationInfo == self))
			{
				P.NotifyTeamChanged();
			}
		}

		CharacterMeshTeamNum = Team.TeamIndex;

		return TRUE;
	}

	return FALSE;
}

/** Accessor that sets the custom character mesh to use for this PRI, and updates instance of player in map if there is one. */
simulated function SetCharacterMesh(SkeletalMesh NewSkelMesh, optional bool bIsReplacement)
{
	local Pawn P;
	local UTGameReplicationInfo GRI;
	local class<UTFamilyInfo> FamilyInfoClass;

	if (CharacterMesh != NewSkelMesh)
	{
		CharacterMesh = NewSkelMesh;

		bIsFemale = FALSE;
		VoiceClass = default.VoiceClass;

		RedHeadMIC = None;
		RedBodyMIC = None;
		BlueHeadMIC = None;
		BlueBodyMIC = None;

		if (CharacterMesh == None)
		{
			if (!bUsingReplacementCharacter)
			{
				GRI = UTGameReplicationInfo(WorldInfo.GRI);
				if (GRI != None)
				{
					GRI.TotalPlayersSetToProcess--;
				}
			}
		}
		else
		{
			if(GetTeamNum() == 0)
			{
				RedHeadMIC = MaterialInstanceConstant(CharacterMesh.Materials[0]);
				RedBodyMIC = MaterialInstanceConstant(CharacterMesh.Materials[1]);
			}
			else
			{
				BlueHeadMIC = MaterialInstanceConstant(CharacterMesh.Materials[0]);
				BlueBodyMIC = MaterialInstanceConstant(CharacterMesh.Materials[1]);
			}

			// set sex and voice
			if( CharacterData.FamilyID != "" && CharacterData.FamilyID != "NONE" )
			{
				// We have decent family, look in info class
				FamilyInfoClass = class'UTCustomChar_Data'.static.FindFamilyInfo(CharacterData.FamilyID);
				if(FamilyInfoClass != None)
				{
					bIsFemale = FamilyInfoClass.default.bIsFemale;
					VoiceClass = FamilyInfoClass.static.GetVoiceClass(CharacterData);
				}
			}
		}

		bUsingReplacementCharacter = bIsReplacement;

		// a little hacky, relies on presumption that enum vals 0-3 are male, 4-8 are female
		if (bIsFemale)
		{
			TTSSpeaker = ETTSSpeaker(Rand(4));
		}
		else
		{
			TTSSpeaker = ETTSSpeaker(Rand(5) + 4);
		}

		foreach WorldInfo.AllPawns(class'Pawn', P)
		{
			if (P.PlayerReplicationInfo == self || (P.DrivenVehicle != None && P.DrivenVehicle.PlayerReplicationInfo == self))
			{
				P.NotifyTeamChanged();
			}
		}
	}

	CharacterMeshTeamNum = GetTeamNum();
}

/** Assign a arm mesh and material to this PRI, and updates and instance of player in the map accordingly. */
simulated function SetFirstPersonArmInfo(SkeletalMesh ArmMesh, MaterialInterface ArmMaterial)
{
	local UTPawn UTP;

	FirstPersonArmMesh = ArmMesh;
	FirstPersonArmMaterial = ArmMaterial;

	foreach WorldInfo.AllPawns(class'UTPawn', UTP)
	{
		if (UTP.PlayerReplicationInfo == self || (UTP.DrivenVehicle != None && UTP.DrivenVehicle.PlayerReplicationInfo == self))
		{
			UTP.NotifyArmMeshChanged(self);
		}
	}
}

reliable simulated client function ShowMidGameMenu(bool bInitial)
{
	if ( !AttemptMidGameMenu() )
	{
		SetTimer(0.2,true,'AttemptMidGameMenu');
	}

}

simulated function bool AttemptMidGameMenu()
{
	local UTPlayerController PlayerOwner;
	local UTGameReplicationInfo GRI;

	PlayerOwner = UTPlayerController(Owner);

	if ( PlayerOwner != none )
	{
		GRI = UTGameReplicationInfo(WorldInfo.GRI);
		if (GRI != none)
		{
			GRI.ShowMidGameMenu(PlayerOwner,'ScoreTab',true);
			if ( GRI.CurrentMidGameMenu != none )
			{
				GRI.CurrentMidGameMenu.bInitial = true;

			}
			ClearTimer('AttemptMidGameMenu');
			return true;
		}
	}

	return false;
}

/** Called when all pickups on a map have been touched in one playthrough **/
function client reliable simulated ClientOnAllPickupsTaken()
{
	local string FinalMsg;

	//Client knows from LoadProfileSettings whether we have finished this map already
	if (!bAllPickupsFoundThisMap)
	{
		bAllPickupsFoundThisMap = true;
        FinalMsg = Localize("ToastMessages","AllPickupsOneMap","UTGameUI");

		// Display toast
		class'UTUIScene'.static.ShowOnlineToast(FinalMsg);
//		UTPlayerController(Owner).SaveProfile();
	}
}

defaultproperties
{
	LastKillTime=-5.0
	DefaultHudColor=(R=64,G=255,B=255,A=255)
	VoiceClass=class'UTGame.UTVoice_DefaultMale'
	SinglePlayerCharacterIndex=-1
	CharPortrait=Texture2D'CH_IronGuard_Headshot.T_IronGuard_HeadShot_DM'
	CharacterCacheClass=class'UTProcessedCharacterCache'
	CharacterMeshTeamNum=255
	WeaponAwardIndex=-1

	HeroThreshold=20.0
}
