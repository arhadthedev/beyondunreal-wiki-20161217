/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTGreedPRI extends UTHeroPRI;

/** Number of coins currently being carried by this player */
var int NumCoins;
/** Highest scoring coin return by this player during this game */
var int BestCoinReturn;

/** Greed flag base parameters */
var StaticMesh FlagBaseStaticMesh;
var MaterialInterface FlagBaseMaterialInterface;
var	ParticleSystem FlagBaseEffects[2];

replication
{
	if ( bNetDirty )
		NumCoins;
}

function Reset()
{
	Super.Reset();
	NumCoins = 0;
	BestCoinReturn = 0;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetupGreedBases();
}

/** Swaps in the appropriate Greed base mesh and effects for this client */
reliable client function SetupGreedBases()
{
	local UTCTFBase CTFBase;

	ForEach WorldInfo.AllNavigationPoints(class'UTCTFBase', CTFBase)
	{
		// Swap in the Greed base mesh
		CTFBase.DetachComponent(CTFBase.FlagBaseMesh);
		CTFBase.FlagBaseMesh.SetStaticMesh(FlagBaseStaticMesh);
		CTFBase.FlagBaseMesh.SetMaterial(0, FlagBaseMaterialInterface); 
		CTFBase.SetDrawScale(0.5);
		CTFBase.FlagBaseMesh.SetTranslation(Vect(0.0, 0.0, -128.0));
		CTFBase.SetRotation(rot(0.0, 16384.0, 0.0));
		CTFBase.AttachComponent(CTFBase.FlagBaseMesh);
		
		// Add the particle effects
		CTFBase.FlagEmptyParticles.SetTemplate(FlagBaseEffects[CTFBase.DefenderTeamIndex]);
		CTFBase.FlagEmptyParticles.SetScale(2.0);
		CTFBase.FlagEmptyParticles.SetTranslation(Vect(0.0, 0.0, -138.0));
		CTFBase.FlagEmptyParticles.SetActive(true);

		// Add the ambient sound
		CTFBase.AmbientSound.SoundCue = SoundCue'A_Gameplay.ONS.A_Gameplay_ONS_ConduitAmbient';
		CTFBase.AmbientSound.Play();
	}
}

/** Drops all held coins when becoming a hero */
function bool TriggerHero()
{
	if ( Super.TriggerHero() )
	{
		UTGreedGame(WorldInfo.Game).DropCoins(Controller(Owner), NumCoins);
		return true;
	}
	return false;
}

simulated function int GetNumCoins()
{
	return NumCoins;
}

/** Adds to this player's coin count
 *  Also applies any bonuses for carrying a large number of coins
 */
function AddCoins(int Coins)
{ 
	local int GoldCoinValue;
	local UTPawn UTP;
	local UTTimedPowerup DamagePickup;

	GoldCoinValue = class'UTGreedCoin_Gold'.default.Value;
	UTP = UTPawn(Controller(Owner).Pawn);
	if (UTP != None)
	{
		if (NumCoins / (2 * GoldCoinValue) != (NumCoins + Coins) / (2 * GoldCoinValue))
		{
			DamagePickup = UTUDamage(UTInventoryManager(UTP.InvManager).HasInventoryOfClass(class'UTUDamage'));
			if (DamagePickup == None)
			{
				DamagePickup = spawn(class'UTUDamage');
				DamagePickup.AddWeaponOverlay(UTGameReplicationInfo(WorldInfo.GRI));
				DamagePickup.GiveTo(UTP);
			}
			else
			{	
				DamagePickup.TimeRemaining += 30.0;
				DamagePickup.ClientSetTimeRemaining(DamagePickup.TimeRemaining);
			}
			DamagePickup.bDropOnDeath = false;
		}
		else if (NumCoins / GoldCoinValue != (NumCoins + Coins) / GoldCoinValue)
		{
			UTP.VestArmor = Max(class'UTArmorPickup_Vest'.default.ShieldAmount, UTP.VestArmor);
		}
	}
	NumCoins += Coins;
	bNetDirty = true;
	bForceNetUpdate = true;
	AddToEventStat('EVENT_SKULLSPICKEDUP', Coins);
}

function ClearCoins()
{
	NumCoins = 0;
}

defaultproperties
{
	FlagBaseStaticMesh=StaticMesh'GP_Onslaught.Mesh.S_GP_Ons_Conduit'
	FlagBaseMaterialInterface=MaterialInterface'GP_Onslaught.Materials.M_GP_Ons_Conduit'
	FlagBaseEffects(0)=ParticleSystem'FX_Gametypes.Effects.P_FX_Gametypes_Greed_Base_Red'
	FlagBaseEffects(1)=ParticleSystem'FX_Gametypes.Effects.P_FX_Gametypes_Greed_Base_Blue'
}
