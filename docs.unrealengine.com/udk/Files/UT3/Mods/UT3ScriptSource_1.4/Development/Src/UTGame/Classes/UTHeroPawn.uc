/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTHeroPawn extends UTPawn;

var	UTEmitter PendingHeroEffect;

var class<UTEmitter> PendingHeroEffectClass[2];
var repnotify bool bIsHero;
var repnotify bool bIsSuperHero;
var repnotify bool bHeroPending;

/** post processing applied for this hero's camera */
var vector PP_Scene_HighLights;
var float PP_Scene_Desaturation;

/** Color values to use for the spawn in effect */
var array<vector> TeamSpawnColors;

/** Replication of spawning */
var repnotify bool bPlayHeroSpawnEffects;

/** camera shake for players near the hero when it dies */
var CameraAnim DeathExplosionShake;
/** radius at which the death camera shake is full intensity */
var float InnerExplosionShakeRadius;
/** radius at which the death camera shake reaches zero intensity */
var float OuterExplosionShakeRadius;

/** camera anim played when foot lands nearby */
var CameraAnim FootStepShake;
var float FootStepShakeRadius;
var soundcue footsound;

/** Scale of the hero while in crouch mode */
var float CrouchedMeshScale;

/** Collision cylinder of standing hero */
var float HeroRadius, HeroHeight;

/** Collision cylinder of standing hero */
var float SuperHeroRadius, SuperHeroHeight;

/** if true, redeemer explosion on death */
var bool bExplosionOnDeath;
/** Replication of gib on redeemer explosion */
var repnotify bool bSpawnHeroGibs;

/** Melee attack properties */
var class <DamageType> MeleeDmgClass;
var float MeleeInterval;
var float LastMeleeTime;
var float MeleeRadius;
var float MeleeDamageInterval;
var float MeleeStopTime;
var float MeleeDamageTime;
var repnotify bool bInHeroMelee;
var SoundCue MeleeSound;
var byte PendingHeroFire[2];

/** Melee attack effects */
var class<UTReplicatedEmitter> HeroMeleeEmitterClass;
var ParticleSystem HeroGroundPoundTemplate;
var ParticleSystem SuperHeroGroundPoundTemplate;
var ParticleSystemComponent HeroGroundPoundEmitter;

/** Hero aura effects for the controlling player and others */
var ParticleSystemComponent HeroAuraEffect;
var ParticleSystemComponent HeroOwnerAuraEffect;

/** Hero postprocess effect */
var PostProcessChain HeroPostProcessEffect;

/** Hero movement animation rate scaling */
var float HeroAnimScaling;
var float SuperHeroAnimScaling;
var bool bHeroAnimScaled;
var bool bSuperHeroAnimScaled;

replication
{
	if (bNetDirty)
		bPlayHeroSpawnEffects, bHeroPending, bIsHero, bIsSuperHero, bInHeroMelee, bExplosionOnDeath, bSpawnHeroGibs;
}

simulated function UnPossessed()
{
	if ( UTPlayerController(Controller) != None )
	{
		ClientAdjustPPEffects(UTPlayerController(Controller), true);
	}

	Super.UnPossessed();
}

simulated function TurnOff()
{
	if ( UTPlayerController(Controller) != None )
	{
		ClientAdjustPPEffects(UTPlayerController(Controller), true);
	}

	Super.TurnOff();
}

reliable server function ServerForceHeroWeapon(byte FireModeNum)
{
	//`log("FORCING "$PlayerController(Controller));
	if ( PlayerController(Controller) != None )
	{
		if ( Weapon != None )
		{
			`log(PlayerReplicationInfo.PlayerName$" TELL CLIENT "$Weapon.Class);
			ClientSetHeroWeapon(Weapon.Class);
			Weapon.ServerStartFire(FireModeNum);
		}
	}
}

reliable client function ClientSetHeroWeapon( class<Weapon> WeaponClass )
{
	//`log("CLIENT SET HERO WEAPON "$WeaponClass);	
	if ( bIsHero && (Controller != None) )
	{
		Controller.ClientSetWeapon(WeaponClass);
	}
}

simulated function StartFire(byte FireModeNum)
{
	if( !bNoWeaponFiring && !bFeigningDeath && ((Weapon == None) || Weapon.bDeleteMe) && (WorldInfo.NetMode == NM_Client) )
	{
		//`log("Force hero weapon");
		ServerForceHeroWeapon(FireModeNum);
	}

	Super.StartFire(FireModeNum);
	PendingHeroFire[FireModeNum] = 1;
}

function bool StopFiring()
{
	PendingHeroFire[0] = 0;
	PendingHeroFire[1] = 0;
	return super.StopFiring();
}

simulated function StopFire(byte FireModeNum)
{
	PendingHeroFire[FireModeNum] = 0;
	super.StopFire(FireModeNum);
}

simulated function ToggleMelee()
{
	if ( !bIsHero )
	{
		super.ToggleMelee();
		return;
	}
	PerformMeleeAttack();
}

simulated function bool PerformMeleeAttack()
{
	if ( ValidateMeleeAttack() )
	{
		if ( Weapon != None )
		{
			Weapon.StopFire(0);
			Weapon.StopFire(1);
		}
		bClientInHeroMelee = true;
		ServerStartMeleeAttack();
		return true;
	}
	return false;
}

simulated function SwitchWeapon(byte NewGroup)
{
	if ( bIsHero && (NewGroup == 1) )
	{
		ToggleMelee();
	}
	else
	{
		super.SwitchWeapon(NewGroup);
	}
}

singular event EncroachedBy( actor Other )
{
	if ( !bIsHero || (UTPawn(Other) == None) )
	{
		super.EncroachedBy(Other);
	}
}

function bool ValidateMeleeAttack()
{
	if ( WorldInfo.TimeSeconds - LastMeleeTime < MeleeInterval || Physics != PHYS_Walking )
	{
		return false;
	}
	bInHeroMelee = true;
	bClientInHeroMelee = true;
	LastMeleeTime = WorldInfo.TimeSeconds;
	AccelRate = 0;
	
	SetTimer(MeleeStopTime, false, 'StopMeleeAttack');
	return true;
}

unreliable server function ServerStartMeleeAttack()
{
	if ( (Controller == None) || (!IsLocallyControlled() && !ValidateMeleeAttack()) )
	{
		return;
	}

	// melee animation and sound
	PlayEmote('MeleeA', -1);
	if ( bIsSuperHero )
	{
		PlaySound(SoundCue'A_Gameplay_UT3G.Titan.A_Gameplay_UT3G_Titan_BehemothMelee01_Cue');
	}
	else
	{
		PlaySound(SoundCue'A_Gameplay_UT3G.Titan.A_Gameplay_UT3G_Titan_TitanMelee01_Cue');
	}
	HeroGroundPoundEmitter.ActivateSystem();

	SetTimer(MeleeDamageTime, false, 'CauseMeleeDamage');
}

simulated function StopMeleeAttack()
{
	if ( !WorldInfo.GRI.bMatchIsOver )
	{
		AccelRate = default.AccelRate;
		bInHeroMelee = false;
		bClientInHeroMelee = false;
		if ( Weapon != None )
		{
			if ( PendingHeroFire[0] == 1 )
			{
				Weapon.StartFire(0);
			}
			else if ( PendingHeroFire[1] == 1 )
			{
				Weapon.StartFire(1);
			}
		}

		if (HeroGroundPoundEmitter != None)
		{
			HeroGroundPoundEmitter.DeactivateSystem();
		}
	}
}

function CauseMeleeDamage()
{
	local Actor HitActor;
	local Pawn HitPawn;
	local InterpActor HitIA;
	local vector HornImpulse, MeleeLocation;
	local Pawn BoardPawn;
	local UTVehicle_Scavenger UTScav;
	local UTPawn OldDriver;
	local UTVehicle UTV;
	local float pct, Dist;
	local UTPlayerController PC;

	local bool bValidOtherTeamPawn, bValidInterpActor;

	// FIXMESTEVE only if ground underneath Titan
	PlaySound(MeleeSound, false, true,,, true);

	Spawn(HeroMeleeEmitterClass);

	foreach WorldInfo.AllControllers(class'UTPlayerController', PC)
	{
		Dist = (PC == Controller) ? MeleeRadius : VSize(Location - PC.ViewTarget.Location);
		if (Dist < 2.0 * MeleeRadius)
		{
			PC.ClientPlayCameraAnim(FootStepShake, 1.0 - (Dist/(2.0 * MeleeRadius)));
		}
	}

	// kill close by players
	// knock down further away players
	MeleeLocation = Location + vect(0,0,1) * GetCollisionHeight();

	ForEach OverlappingActors(class 'Actor', HitActor, MeleeRadius, Location)
	{
		HitPawn = Pawn(HitActor);
		if ( HitPawn != None )
		{
			bValidOtherTeamPawn = HitPawn != self && HitPawn.Mesh != None && !WorldInfo.GRI.OnSameTeam(HitPawn, self);
			bValidOtherTeamPawn = bValidOtherTeamPawn && (FastTrace(MeleeLocation, HitPawn.Location) || FastTrace(MeleeLocation, HitPawn.Location + vect(0,0,1)*HitPawn.GetCollisionHeight()));
		}
		else
		{
			HitIA = InterpActor(HitActor);
			bValidInterpActor = HitIA != None && HitIA.StaticMeshComponent != None;
			bValidOtherTeamPawn = false;
		}	

		if ( HitPawn != self && ( bValidInterpActor || bValidOtherTeamPawn ) )// && ((Normal(HitActor.Location - Location) dot LookDir) > 0.7))
		{
			// throw him outwards also
			HornImpulse = HitActor.Location - Location;
			pct = (MeleeRadius - VSize(HornImpulse))/MeleeRadius;
			HornImpulse.Z = 0;
			HornImpulse = 1000.0 * Normal(HornImpulse);
			HornImpulse.Z = 400.0;

			if ( !bValidOtherTeamPawn || FastTrace(MeleeLocation, HitPawn.Location) || FastTrace(MeleeLocation, HitPawn.Location + vect(0,0,1)*HitPawn.GetCollisionHeight()) )
			{
				HitActor.TakeDamage(150*pct, Controller, HitActor.Location, HornImpulse*FMax(0.5, pct), MeleeDmgClass);
			}

			//Throw the pawns around
			if (bValidOtherTeamPawn)
			{
				if (HitPawn.Physics != PHYS_RigidBody && HitPawn.IsA('UTPawn'))
				{
					HitPawn.Velocity += HornImpulse;
					UTPawn(HitPawn).ForceRagdoll();
					UTPawn(HitPawn).FeignDeathStartTime = WorldInfo.TimeSeconds + 1.5;
					HitPawn.LastHitBy = Controller;
				}
				else if( UTVehicle_Hoverboard(HitPawn) != none)
				{
					HitPawn.Velocity += HornImpulse;
					BoardPawn = UTVehicle_Hoverboard(HitPawn).Driver; // just in case the board gets destroyed from the ragdoll
					UTVehicle_Hoverboard(HitPawn).RagdollDriver();
					HitPawn = BoardPawn;
					HitPawn.LastHitBy = Controller;
				}
				else if ( HitPawn.Physics == PHYS_RigidBody )
				{
					UTV = UTVehicle(HitPawn);
					if(UTV != none)
					{
						// Special case for scavenger - force into ball mode for a bit.
						UTScav = UTVehicle_Scavenger(UTV);
						if(UTScav != None && UTScav.bDriving)
						{
							UTScav.BallStatus.bIsInBallMode = TRUE;
							UTScav.BallStatus.bBoostOnTransition = FALSE;
							UTScav.NextBallTransitionTime = WorldInfo.TimeSeconds + 2.0; // Stop player from putting legs out for 2 secs.
							UTScav.BallModeTransition();
						}
						// See if darkwalker forces this player out of vehicle.
						else if(UTV.bRagdollDriverOnDarkwalkerHorn)
						{
							OldDriver = UTPawn(UTV.Driver);
							if (OldDriver != None)
							{
								UTV.DriverLeave(true);
								OldDriver.Velocity += HornImpulse;
								OldDriver.ForceRagdoll();
								OldDriver.FeignDeathStartTime = WorldInfo.TimeSeconds + 1.5;
								OldDriver.LastHitBy = Controller;
							}
						}

						HitPawn.Mesh.AddImpulse(HornImpulse*5.3, Location);
					}
					else
					{
						HitPawn.Mesh.AddImpulse(HornImpulse, Location,, true);
					}
				}
			}
		}
	}
}

simulated function AttachMeleeEffects()
{
	local ParticleSystem GroundPoundTemplate;

	if ( bIsSuperHero )
	{
		HeroMeleeEmitterClass = class'UTEmit_SuperHeroMelee';
		GroundPoundTemplate = SuperHeroGroundPoundTemplate;
	}
	else
	{
		HeroMeleeEmitterClass = class'UTEmit_HeroMelee';
		GroundPoundTemplate = HeroGroundPoundTemplate;
	}


	if ( HeroGroundPoundEmitter == None || GroundPoundTemplate != HeroGroundPoundEmitter.Template )
	{
		HeroGroundPoundEmitter = new(self) class'UTParticleSystemComponent';
		HeroGroundPoundEmitter.SetTemplate(GroundPoundTemplate);
		HeroGroundPoundEmitter.bAutoActivate = false;
		Mesh.AttachComponentToSocket(HeroGroundPoundEmitter, WeaponSocket);
	}
}

simulated function DetachMeleeEffects()
{
	Mesh.DetachComponent(HeroGroundPoundEmitter);
	HeroGroundPoundEmitter = None;
}

simulated function ToggleMeleeEffects()
{
	bClientInHeroMelee = bInHeroMelee;
	if ( bInHeroMelee )
	{
		HeroGroundPoundEmitter.ActivateSystem();
	}
	else
	{
		HeroGroundPoundEmitter.DeactivateSystem();
	}
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local UTPlayerReplicationInfo OldPRI, KillerPRI;

	OldPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	KillerPRI = (Killer != None) ? UTPlayerReplicationInfo(Killer.PlayerReplicationInfo) : None;
	if (Super.Died(Killer, DamageType, HitLocation))
	{
		if ( OldPRI != None && OldPRI.IsHero() )
		{
			if ( (PlayerController(Killer) != None) && (OldPRI != KillerPRI) )
			{
				PlayerController(Killer).ReceiveLocalizedMessage( class'UTHeroMessage', 2, KillerPRI );
			}
			OldPRI.ResetHero();
			DetachHeroAuraEffect();
			DetachMeleeEffects();
		}
		if ( PendingHeroEffect != None )
		{
			PendingHeroEffect.Destroy();
			PendingHeroEffect = None;
		}

		return true;
	}
	return false;
}

function UTWeapon GiveWeapon( String WeaponClassStr )
{
	Local UTWeapon		Weap;
	local class<UTWeapon> WeaponClass;

	WeaponClass = class<UTWeapon>(DynamicLoadObject(WeaponClassStr, class'Class'));
	Weap = UTWeapon(FindInventoryType(WeaponClass));
	if( Weap != None )
	{
		return Weap;
	}
	return UTWeapon(CreateInventory( WeaponClass ));
}

function bool BecomeHero()
{
	local PlayerController PC;
	local UTPlayerReplicationInfo NewPRI;
	local UTHeroDamage UDPickup;
	local UTHeroBerserk BPickup;
	local MaterialInterface ShieldMat;
	local UTWeapon NewWeapon;
	local UTWeap_RocketLauncher NewRL;
	local inventory inv;
	local array<UTWeapon> WeaponList;
	local int i;

	if ( IsInState('FeigningDeath') || WorldInfo.Game.bGameEnded || bIsSuperHero )
	{
		return false;
	}

	if ( bIsHero )
	{
		if ( !HeroFits(self, SuperHeroRadius, SuperHeroHeight) )
		{
			if ( PlayerController(Controller) != None )
			{
				PlayerController(Controller).ReceiveLocalizedMessage(class'UTHeroMessage',1);
			}
			return false;
		}
		ShieldBeltArmor = 800;
		VestArmor = 0;
		ThighpadArmor = 0;
		HelmetArmor = 0;
		Health = 800;
		HealthMax = 800;
		ShieldBeltPickupClass = None;

		// Adjust weapon fire offsets for superhero mode
		UTInventoryManager(InvManager).GetWeaponList(WeaponList);
		for ( i = 0; i < WeaponList.length; ++i )
		{
			WeaponList[i].FireOffset = GetFamilyInfo().default.SuperHeroFireOffset;
		}

		bIsSuperHero = true;
		Spawn(class'UTEmit_HeroSpawn');
		ActivateSuperHero();
		SetTimer(45, false, 'Suicide');
		SetTimer(41, false, 'InitHeroBomb');
		ForEach WorldInfo.AllControllers(class'PlayerController', PC)
		{
			PC.ClientPlaySound(SoundCue'A_Gameplay_UT3G.Titan.A_Gameplay_UT3G_Titan_BehemothGrow01_Cue');
		}
		if ( PlayerController(Controller) != None )
		{
			PlayerController(Controller).ReceiveLocalizedMessage(class'UTHeroRewardMessage', 0);
		}
		return true;
	}
	if ( !HeroFits(self, HeroRadius, HeroHeight) )
	{
		if ( PlayerController(Controller) != None )
		{
			PlayerController(Controller).ReceiveLocalizedMessage(class'UTHeroMessage',1);
		}
		return false;
	}

	bIsHero = true;
	UpdateHeroStatus();
	bAlwaysRelevant = true;
	ForEach WorldInfo.AllControllers(class'PlayerController', PC)
	{
		PC.ClientPlaySound(SoundCue'A_Gameplay_UT3G.Titan.A_Gameplay_UT3G_Titan_TitanGrow01_Cue');
	}

	// Heroes can't carry flag/orb
	NewPRI = UTPlayerReplicationInfo(PlayerReplicationInfo);
	if ( (NewPRI != None) && NewPRI.bHasFlag)
	{
		NewPRI.GetFlag().Drop();
	}
	bCanPickupInventory = false;

	ForEach InvManager.InventoryActors(class'Inventory', Inv)
	{
		Inv.Destroy();
	}
	InvManager.InventoryChain = None;
	BPickup = spawn(class'UTHeroBerserk');

	ShieldMat = GetShieldMaterialInstance(WorldInfo.GRI.GameClass.default.bTeamGame);
	SetOverlayMaterial(ShieldMat);

	NewWeapon = GiveWeapon("UTGame.UTWeap_RocketLauncher");
	NewWeapon.WeaponProjectiles[0] = class'UTProj_HeroRocket';
	NewWeapon.WeaponProjectiles[1] = class'UTProj_HeroRocket';
	NewWeapon.FireOffset = GetFamilyInfo().default.HeroFireOffset;
	NewWeapon.bAutoCharge = true;
	NewWeapon.AmmoCount = NewWeapon.MaxAmmoCount;
	NewWeapon.bCanThrow = false;
	NewRL = UTWeap_RocketLauncher(NewWeapon);
	NewRL.SeekingRocketClass = class'UTProj_HeroRocket';
	NewRL.GrenadeClass = class'UTProj_HeroGrenade';
	NewRL.LockAim = 0.97;
	NewRL.LockChecktime = 0.1;
	NewRL.LockAcquireTime = 0.3;
	NewRL.LockTolerance = 3.0;

	NewWeapon = GiveWeapon("UTGame.UTWeap_ShockRifle");
	NewWeapon.InstantHitDamageTypes[0] = class'UTDmgType_HeroShockPrimary';
	NewWeapon.WeaponProjectiles[0] = class'UTProj_HeroShockBall';
	NewWeapon.WeaponProjectiles[1] = class'UTProj_HeroShockBall';
	NewWeapon.FireOffset = GetFamilyInfo().default.HeroFireOffset;
	NewWeapon.bAutoCharge = true;
	NewWeapon.bCanThrow = false;
	NewWeapon.AmmoCount = NewWeapon.MaxAmmoCount;

	ShieldBeltArmor = 400;
	Health = 400;
	HealthMax = 400;
	ActivateHero();
	Spawn(class'UTEmit_HeroSpawn');

	UDPickup = spawn(class'UTHeroDamage');
	if ( UDPickup != None )
	{
		UDPickup.TimeRemaining = 99999999999.0;
		UDPickup.GiveTo(self);
	}

	if ( BPickup != None )
	{
		BPickup.TimeRemaining = 99999999999.0;
		BPickup.GiveTo(self);
	}

	if ( PlayerController(Controller) != None )
	{
		PlayerController(Controller).ReceiveLocalizedMessage(class'UTHeroRewardMessage', 0);
	}

	// Update "Titanic" achievement
	if ( UTPlayerController(Controller) != None )
	{
		UTPlayerController(Controller).ClientUpdateAchievement(EUTA_UT3GOLD_Titanic, 1);
	}

	return true;
}

/* return a value (typically 0 to 1) adjusting pawn's perceived strength if under some special influence (like berserk)
*/
function float AdjustedStrength()
{
	return bIsHero ? 5.0 : 0.0;
}

simulated function SetBaseEyeheight()
{
	if ( bIsSuperHero )
	{
		if ( bIsCrouched )
		{
			BaseEyeHeight = 30.0;
		}
		else
		{
			BaseEyeHeight = 150.0;
		}
	}
	else if ( bIsHero && !bIsCrouched )
	{
		BaseEyeheight = 76.0;
	}
	else
	{
		super.SetBaseEyeheight();
	}
}

simulated function AttachHeroAuraEffect()
{
	if ( (Controller != None) && Controller.IsLocalPlayerController() )
	{
		AttachComponent(HeroOwnerAuraEffect);
		// Change the HeroAuraEffect color to red if on the red team
		if (GetTeamNum() != 1)
		{
			HeroOwnerAuraEffect.SetVectorParameter('HeroColor', vect(1.0, 0.2, 0.2));
		}
		HeroOwnerAuraEffect.ActivateSystem();
	}
	else
	{
		AttachComponent(HeroAuraEffect);
		// Change the HeroAuraEffect color to red if on the red team
		if (GetTeamNum() != 1)
		{
			HeroAuraEffect.SetVectorParameter('HeroColor', vect(1.0, 0.2, 0.2));
		}
		HeroAuraEffect.ActivateSystem();
	}
}

simulated function DetachHeroAuraEffect()
{
	if ( HeroOwnerAuraEffect.bIsActive )
	{
		DetachComponent(HeroOwnerAuraEffect);
		HeroOwnerAuraEffect.DeactivateSystem();
	}
	if ( HeroAuraEffect.bIsActive )
	{
		DetachComponent(HeroAuraEffect);
		HeroAuraEffect.DeactivateSystem();
	}
}

simulated function ActivateHero()
{
	local AnimTree	AnimTreeRootNode;
	local UTWeapon HeroWeapon;
	local int i,j;

	HeroStartTime = 0;
	Mass = 1000.0;
	SetMaxStepHeight(52.0);
	AccelRate = 500.0;
	DefaultHeight = HeroHeight;
	DefaultRadius = HeroRadius;
	SetCollisionSize(DefaultRadius, DefaultHeight);
	Mesh.AnimSets[Mesh.AnimSets.Length] = GetFamilyInfo().default.HeroMeleeAnimSet;

	CrouchRadius=42.0;
	CrouchHeight=44.0;
	DefaultMeshScale=2.15;
	DesiredMeshScale=2.15;
	CrouchedMeshScale=1.85;
	BaseTranslationOffset = Default.BaseTranslationOffset * DefaultHeight/Default.DefaultHeight;
	BaseEyeHeight = 76.0;
	DoubleJumpEyeHeight = 81.0;
	OutofWaterZ = 660.0;
	bCanRagDoll = false;
	MaxLeanRoll = 2000;
	bCanPickupInventory = false;

	// Set the current weapon, and make sure the first-person model is hidden
	ClientSetHeroWeapon(class'UTWeap_RocketLauncher');
	HeroWeapon = UTWeapon(FindInventoryType(class'UTWeap_RocketLauncher'));
	if ( HeroWeapon != None )
	{
		HeroWeapon.bPendingShow = false;
		HeroWeapon.SetHidden(true);
	}

	class'UTHeroDamage'.static.AddWeaponOverlay(UTGameReplicationInfo(WorldInfo.GRI));
	class'UTHeroBerserk'.static.AddWeaponOverlay(UTGameReplicationInfo(WorldInfo.GRI));

	if ( UTPlayerController(Controller) != None )
	{
		ClientAdjustPPEffects(UTPlayerController(Controller), false);
	}

	if ( bIsCrouched )
	{
		StartCrouch(HeroHeight - CrouchHeight);
	}

	AttachHeroAuraEffect();
	AttachMeleeEffects();
	
	if ( !bHeroAnimScaled )
	{
		bHeroAnimScaled = true;

		// slow down movement animations since hero is bigger
		AnimTreeRootNode = AnimTree(Mesh.Animations);
		if( AnimTreeRootNode != None )
		{
			for(i=0; i<AnimTreeRootNode.AnimGroups.Length; i++)
			{
				for ( j=0; j<AnimTreeRootNode.AnimGroups[i].SeqNodes.Length; j++ )
				{
					AnimTreeRootNode.AnimGroups[i].SeqNodes[j].Rate *= HeroAnimScaling;
				}
			}
		}
	}
}

simulated function ActivateSuperHero()
{
	local AnimTree	AnimTreeRootNode;
	local int i,j;

	HeroStartTime = WorldInfo.TimeSeconds;
	Mass = 8000.0;
	SetMaxStepHeight(104.0);
	DefaultHeight = SuperHeroHeight;
	DefaultRadius = SuperHeroRadius;
	SetCollisionSize(DefaultRadius, DefaultHeight);
	MeleeRadius = 2 * Default.MeleeRadius;

	CrouchRadius=120.0;
	CrouchHeight=100.0;
	DefaultMeshScale=4.3;
	DesiredMeshScale=4.3;
	CrouchedMeshScale=4.0;
	BaseTranslationOffset = Default.BaseTranslationOffset * DefaultHeight/Default.DefaultHeight;
	BaseEyeHeight = 164.0;
	DoubleJumpEyeHeight = 169.0;
	OutofWaterZ = 1200.0;

	// Update "Behemoth" achievement
	if ( UTPlayerController(Controller) != None )
	{
		UTPlayerController(Controller).ClientUpdateAchievement(EUTA_UT3GOLD_Behemoth, 1);
	}

	// Adjust hero aura to "Behemoth" size
	if ( HeroOwnerAuraEffect.bIsActive )
	{
		HeroOwnerAuraEffect.SetScale(2.0);
		HeroOwnerAuraEffect.SetTranslation(vect(0.0, 0.0, -200.0));
	}
	if ( HeroAuraEffect.bIsActive )
	{
		HeroAuraEffect.SetScale(2.5);
		HeroAuraEffect.SetTranslation(vect(0.0, 0.0, -200.0));
	}

	if ( bIsCrouched )
	{
		StartCrouch(SuperHeroHeight - CrouchHeight);
	}

	AttachMeleeEffects();
	
	if ( !bSuperHeroAnimScaled )
	{
		bSuperHeroAnimScaled = true;

		// slow down movement animations since hero is bigger
		AnimTreeRootNode = AnimTree(Mesh.Animations);
		if( AnimTreeRootNode != None )
		{
			for(i=0; i<AnimTreeRootNode.AnimGroups.Length; i++)
			{
				for ( j=0; j<AnimTreeRootNode.AnimGroups[i].SeqNodes.Length; j++ )
				{
					AnimTreeRootNode.AnimGroups[i].SeqNodes[j].Rate *= SuperHeroAnimScaling;
				}
			}
		}
	}
}

simulated function bool IsHero()
{
	return bIsHero;
}

simulated function NotifyTeamChanged()
{
	local UTPlayerReplicationInfo PRI;

	super.NotifyTeamChanged();

	PRI = GetUTPlayerReplicationInfo();

	if (PRI != None)
	{
		if ( PRI.GetHeroMeter() == PRI.HeroThreshold )
		{
			SetHeroPending((PRI.Team != None) ? PRI.Team.TeamIndex : 0);
		}
	}
}

simulated function SetInfoFromFamily(class<UTFamilyInfo> Info, SkeletalMesh SkelMesh)
{
	local UTPlayerReplicationInfo PRI;
	local UTPlayerController PC;
	local UTHeroPawn UTP;

	Super.SetInfoFromFamily(Info, SkelMesh);

	PRI = GetUTPlayerReplicationInfo();

	if ( PRI != None && bIsHero )
	{
		ActivateHero();
		if ( bIsSuperHero )
		{
			ActivateSuperHero();
		}
	}

	foreach WorldInfo.AllControllers( class'UTPlayerController', PC )
	{
		UTP = UTHeroPawn(PC.Pawn);
		if ( UTP != None )
		{
			if ( UTP.IsHero() )
			{
				UTP.AdjustPPESaturation(self, true);
			}
			else
			{
				UTP.AdjustPPESaturation(self, false);
			}
		}
	}
}

function SetHeroPending(int TeamIndex)
{
	bHeroPending = true;
	if ( (PendingHeroEffect == None) || PendingHeroEffect.bDeleteMe )
	{
		PendingHeroEffect = spawn(PendingHeroEffectClass[TeamIndex], self);
		PendingHeroEffect.SetBase(self);
	}
}

/** 
 *	  OnGiveHeroPoints()
 *    Gives some amount of hero points to this pawn
 *    @param Action - The sequence providing the heropoints for this action
 */
function OnGiveHeroPoints(UTSeqAct_GiveHeroPoints Action)
{
	local UTPlayerReplicationInfo UTPRI;

	UTPRI = GetUTPlayerReplicationInfo();
	if (UTPRI != None)
	{
		UTPRI.IncrementHeroMeter(Action.HeroPoints);
		UTPRI.CheckHeroMeter();
	}
}

simulated function UpdateHeroStatus()
{
	bClientIsHero = bIsHero;
}

simulated function DetachFromController( optional bool bDestroyController )
{
	ClientAdjustPPEffects(UTPlayerController(Controller), true);
	Super.DetachFromController(bDestroyController);
}

simulated event Destroyed()
{
	ClientAdjustPPEffects(UTPlayerController(Controller), true);

	Super.Destroyed();

	if ( PendingHeroEffect != None )
	{
		PendingHeroEffect.Destroy();
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bHeroPending')
	{
		SetHeroPending((PlayerReplicationInfo.Team != None)? PlayerReplicationInfo.Team.TeamIndex : 0);
	}	
	else if (VarName == 'bIsHero')
	{
		UpdateHeroStatus();
		if (bIsHero)
		{
			ActivateHero();
			if (bIsSuperHero)
			{	
				ActivateSuperHero();
			}
		}
	}
	else if (VarName == 'bIsSuperHero')
	{
		if (bIsSuperHero)
		{	
			ActivateSuperHero();
		}
	}
	else if (VarName == 'bPlayHeroSpawnEffects')
	{
		PlaySpawnEffects();
	}
	else if (VarName == 'bInHeroMelee')
	{
		ToggleMeleeEffects();
	}
	else if (VarName == 'bSpawnHeroGibs')
	{
		SpawnHeroGibs();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/** Called when the hero has been activated */
simulated function PlaySpawnEffects()
{
	//Tell clients via replication
	bPlayHeroSpawnEffects = true;

	//Play the spawn particle effect

	//Let the spawn effect play for a little while
	//SetTimer(4.0, false, 'StopSpawnEffects');
}

/** Called when the hero has stopped spawning in */
simulated function StopSpawnEffects()
{
}

simulated function ClientReStart()
{
	Super.ClientReStart();
	ClientAdjustPPEffects(UTPlayerController(Controller), true);
}

/** applies and removes any post processing effects while hero */
reliable client function ClientAdjustPPEffects(UTPlayerController PC, bool bRemove)
{
	local LocalPlayer LP;
	local MaterialEffect NewEffect;
	local UTHeroPawn UTP;
	local int i;

	if ( PC != None )
	{
		LP = LocalPlayer(PC.Player);
		if ( LP != None )
		{
			if ( !bRemove && !PC.bHeroPPEffectsOn )
			{
				LP.InsertPostProcessingChain(HeroPostProcessEffect, INDEX_NONE, true);
				NewEffect = MaterialEffect(LP.PlayerPostProcess.FindPostProcessEffect('HeroPostProcess'));
				NewEffect.Material = MaterialInterface'UN_HeroEffects.Materials.MI_HeroEffect_HeroPost';
				PC.bHeroPPEffectsOn = true;

				foreach WorldInfo.AllPawns( class'UTHeroPawn', UTP )
				{
					AdjustPPESaturation(UTP, true);
				}
			}
			else if ( bRemove && PC.bHeroPPEffectsOn )
			{
				for ( i = 0; i < LP.PlayerPostProcessChains.length; ++i )
				{
					if ( LP.PlayerPostProcessChains[i].FindPostProcessEffect('HeroPostProcess') != None )
					{
						LP.RemovePostProcessingChain(i);
						i--;
					}
				}
				PC.bHeroPPEffectsOn = false;
		
				foreach WorldInfo.AllPawns( class'UTHeroPawn', UTP )
				{
					AdjustPPESaturation(UTP, false);
				}
			}
		}
	}
}

/** On a hero player client, adjusts materials for a pawn */
reliable client function AdjustPPESaturation(UTHeroPawn UTP, bool bEnable)
{
	local MaterialInstanceConstant MIC;
	local int i;

	if ( UTP != None && UTP.VerifyBodyMaterialInstance() )
	{
		for (i = 0; i < UTP.BodyMaterialInstances.length; i++)
		{
			MIC = UTP.BodyMaterialInstances[i];
			if ( MIC != None )
			{
				if ( bEnable && UTPlayerController(Controller).bHeroPPEffectsOn )
				{
					MIC.SetScalarParameterValue('Char_DistSaturateSwitch', 10.0);
				}
				else
				{
					MIC.SetScalarParameterValue('Char_DistSaturateSwitch', 1.0);
				}
			}
		}
	}
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if ( bIsHero )
	{
		bForceNetUpdate = TRUE; // force quick net update

		if ( DamageType != None )
		{
			Damage *= DamageType.default.VehicleDamageScaling;
		}
		Momentum = vect(0,0,0);
	}

	super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo);
}

event Landed(vector HitNormal, actor FloorActor)
{
	Super.Landed(HitNormal, FloorActor);

	if ( bIsHero )
	{
		// FIXME - want custom landing sound and screenshack here
		PlayFootStepSound(0);
	}
}

simulated event PlayFootStepSound(int FootDown)
{
	local UTPlayerController PC;
	local float Dist;

	if ( bIsHero )
	{
		PlaySound(FootSound, false, true,,, true);

		foreach LocalPlayerControllers(class'UTPlayerController', PC)
		{
			if (PC == Controller)
			{
				Dist = 0.7*FootStepShakeRadius;
			}
			else
			{
				Dist = VSize(Location - PC.ViewTarget.Location);
			}
			if (Dist < FootStepShakeRadius)
			{
				PC.PlayCameraAnim(FootStepShake, 1.0 - (Dist/FootStepShakeRadius));
			}
		}
	}
	else
	{
		super.PlayFootStepSound(FootDown);
	}
}

function bool Dodge(eDoubleClickDir DoubleClickMove) 
{
	if ( !bIsHero )
	{
		return super.Dodge(DoubleClickMove);
	}
	return false;
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross) 
{
	if ( !bIsHero )
	{
		return super.PerformDodge(DoubleClickMove, Dir, Cross);
	}
	return false;
}

/**
 * Event called from native code when Pawn stops crouching.
 * Called on non owned Pawns through bIsCrouched replication.
 * Network: ALL
 *
 * @param	HeightAdjust	height difference in unreal units between default collision height, and actual crouched cylinder height.
 */
simulated event EndCrouch( float HeightAdjust )
{
	Super.EndCrouch(HeightAdjust);
	if ( bIsHero )
	{
		DesiredMeshScale = DefaultMeshScale;
	}
}

/**
 * Event called from native code when Pawn starts crouching.
 * Called on non owned Pawns through bIsCrouched replication.
 * Network: ALL
 *
 * @param	HeightAdjust	height difference in unreal units between default collision height, and actual crouched cylinder height.
 */
simulated event StartCrouch( float HeightAdjust )
{
	Super.StartCrouch(HeightAdjust);
	DesiredMeshScale = CrouchedMeshScale;
	CrouchMeshZOffset = HeightAdjust - DefaultHeight * (1.0 - CrouchedMeshScale/DefaultMeshScale);
}

/**
  *	For heroes, use the camera's actual location, instead of an approximation 
  * that assumes the camera is directly above the pawn's location
  */
simulated event Vector GetPawnViewLocation()
{
	local vector	POVLoc;
	local rotator	POVRot;

	if ( bIsHero )
	{
		if ( Controller != None )
		{
			Controller.GetPlayerViewPoint( POVLoc, POVRot );
			return POVLoc;
		}
	}	
	return Super.GetPawnViewLocation();
}

/**
  * Hero specific camera implementation
  */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector CamStart, FirstHitLocation, HitLocation, HitNormal, CamDir, X, Y, Z;
	local float DesiredCameraZOffset;
	local bool bInsideHero, bObstructed;
	local class<UTFamilyInfo> FamilyInfo;

	if ( !bIsHero || bWinnerCam )
	{
		if ( bWinnerCam )
		{
			Mesh.SetOwnerNoSee(false);
			if ( bIsHero )
			{
				return CalcThirdPersonCam(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
			}
		}
		return super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
	}

	FamilyInfo = GetFamilyInfo();

	Mesh.SetOwnerNoSee(false);

	// Handle the fixed camera
	if (bFixedView)
	{
		out_CamLoc = FixedViewLoc;
		out_CamRot = FixedViewRot;
	}

	ModifyRotForDebugFreeCam(out_CamRot);

	CamStart = Location;
	DesiredCameraZOffset = (Health > 0) ? FamilyInfo.default.ExtraCameraZOffset + GetCollisionHeight() + Mesh.Translation.Z : 0.f;
	CameraZOffset = (fDeltaTime < 0.2) ? DesiredCameraZOffset * 5 * fDeltaTime + (1 - 5*fDeltaTime) * CameraZOffset : DesiredCameraZOffset;

	CamStart.Z += CameraZOffset;
	GetAxes(out_CamRot, X, Y, Z);
	CamDir = FamilyInfo.default.CameraXOffset * X * GetCollisionRadius() * CurrentCameraScale 
			+ FamilyInfo.default.CameraYOffset * Y * GetCollisionRadius()
			- GetCollisionRadius() * FMax(0,(1.0 - Z.Z)) * Z;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// adjust camera position to make sure it's not clipping into world
		// @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
		FindSpot(GetCollisionExtent(),CamStart);
	}
	if (CurrentCameraScale < CameraScale)
	{
		CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	else if (CurrentCameraScale > CameraScale)
	{
		CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	if (CamDir.Z > GetCollisionHeight())
	{
		CamDir *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
	}

	out_CamLoc = CamStart - CamDir;

	if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None)
	{
		out_CamLoc = HitLocation;
		bObstructed = true;
	}


	if ( TraceComponent( FirstHitLocation, HitNormal, CollisionComponent, out_CamLoc, CamStart, vect(0,0,0)) )
	{
		// going through hero collision - it's ok if outside collision on other side
		if ( !TraceComponent( HitLocation, HitNormal, CollisionComponent, CamStart, out_CamLoc, vect(0,0,0)) )
		{
			// end point is inside collision - that's bad
			out_CamLoc = FirstHitLocation;
			bObstructed = true;
			bInsideHero = true;
		}
	}

	if (bObstructed)
	{
		// We hit something
		// if trace doesn't hit collisioncomponent going back in, it means we are inside the collision box
		// in which case we want to hide the hero
		bInsideHero = bInsideHero || !TraceComponent( HitLocation, HitNormal, CollisionComponent, Location, out_CamLoc, vect(0,0,0));
		bInsideHero = bInsideHero || (VSizeSq(HitLocation - out_CamLoc) < FamilyInfo.default.MinCameraDistSq);
		Mesh.SetOwnerNoSee(bInsideHero);
		return false;
	}

	return true;
}

/** sets whether or not the owner of this pawn can see it */
simulated function SetMeshVisibility(bool bVisible)
{
	// HACK - don't let hero get hidden
	if ( !bIsHero )
	{
		super.SetMeshVisibility(bVisible);
	}
}

simulated function bool IsFirstPerson()
{
	return !bIsHero && super.IsFirstPerson();
}

simulated function bool ShouldGib(class<UTDamageType> UTDamageType)
{
	if ( IsHero() )
	{
		return (UTDamageType == class'UTGame.UTDmgType_HeroBomb');
	}
	return Super.ShouldGib(UTDamageType);
}

simulated function InitHeroBomb()
{
	local UTHeroBomb Bomb;

	Bomb = Spawn(class'UTHeroBomb', Owner,,Location);
	Bomb.SetBase(self, ,Mesh);

	if ( Controller != None && Bomb != None )
	{
		Bomb.SetTeamIndex(GetTeamNum());
		Bomb.InstigatorController = Controller;
	}

	// Make sure only 1 Hero Bomb will detonate per death
	bExplosionOnDeath = false;
}

simulated function Suicide()
{
	Super.Suicide();
	if ( bIsSuperHero )
	{
		SpawnHeroGibs();
	}
}

/** If hero, starts the explosion countdown */
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	if ( IsHero() && bExplosionOnDeath )
	{
		InitHeroBomb();
		PlaySound(SoundCue'A_Titan_Extras.Powerups.A_Powerup_Berzerk_EndCue');
	}
	Super.PlayDying(DamageType, HitLoc);
}

simulated function SpawnHeroGibs()
{
	bSpawnHeroGibs = true;
}

simulated State Dying
{
	simulated function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		if ( bSpawnHeroGibs )
		{
			SpawnHeroGibs();
		}
		else if ( bIsHero && !IsTimerActive('SpawnHeroGibs'))
		{
			SetTimer(4.0, false, 'SpawnHeroGibs');
		}
	}

	simulated function SpawnHeroGibs()
	{
		bSpawnHeroGibs = true;
		SpawnGibs(class'UTGame.UTDmgType_HeroBomb', Location);
	}

	simulated function EndState(Name NextStateName)
	{
		if ( IsHero() )
		{
			bIsHero = false;
			bExplosionOnDeath = true;
			UpdateHeroStatus();
			SpawnHeroGibs();
		}
		Super.EndState(NextStateName);
	}
};


/** returns true if this pawn wants to force a special attack (for AI) */
function bool ForceSpecialAttack(Pawn EnemyPawn)
{
	return (EnemyPawn != None) && bIsHero 
		&& (WorldInfo.TimeSeconds - LastMeleeTime > MeleeInterval + 6*FRand())
		&& (VSize(Location - EnemyPawn.Location) < 0.8 * MeleeRadius)
		&& (UTPawn(EnemyPawn) != None) 
		&& !UTPawn(EnemyPawn).bFeigningDeath
		&& Controller.LineOfSightTo(EnemyPawn)
		&& PerformMeleeAttack();
}


/**
  *  Delay triggering bot hero so it doesn't happen during physics thread
  */
function DelayedTriggerHero()
{
	if ( UTPlayerReplicationInfo(PlayerReplicationInfo) != None )
	{
		UTPlayerReplicationInfo(PlayerReplicationInfo).TriggerHero();
	}
}

defaultproperties
{
	PendingHeroEffectClass(0)=class'UTEmit_PendingHeroEffectRed'
	PendingHeroEffectClass(1)=class'UTEmit_PendingHeroEffectBlue'

	PP_Scene_Highlights=(Y=-0.07,Z=-0.14)
	PP_Scene_Desaturation=0.3

	Begin Object Class=ParticleSystemComponent Name=OwnerAuraEffect
		Template=ParticleSystem'UN_HeroEffects.Effects.FX_HeroAura_3rd'
		bAutoActivate=false
		AbsoluteRotation=true
		Translation=(Z=-100)
	End Object
	HeroOwnerAuraEffect=OwnerAuraEffect

	Begin Object Class=ParticleSystemComponent Name=AuraEffect
		Template=ParticleSystem'UN_HeroEffects.Effects.FX_HeroAura'
		bAutoActivate=false
		AbsoluteRotation=true
		Translation=(Z=-100)
		Scale=1.25
	End Object
	HeroAuraEffect=AuraEffect

	TeamSpawnColors(0)=(X=10,Y=0.5,Z=0.25)
	TeamSpawnColors(1)=(X=0.25,Y=0.5,Z=10)

	AuraRadius=400.0

	DeathExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=400.0
	OuterExplosionShakeRadius=1000.0

	FootStepShakeRadius=1000.0
	FootStepShake=CameraAnim'Camera_FX.DarkWalker.C_VH_DarkWalker_Step_Shake'
	FootSound=SoundCue'A_Titan_Extras.Cue.A_Vehicle_DarkWalker_FootstepCue'

	HeroHeight=88.0
	HeroRadius=42.0

	SuperHeroHeight=176.0
	SuperHeroRadius=84.0

	bExplosionOnDeath=true

	DefaultMeshScale=1.0
	CrouchedMeshScale=1.0

	MeleeDmgClass=class'UTDmgType_HeroMelee'
	MeleeInterval=2.0
	MeleeStopTime=2.0
	MeleeDamageTime=0.84
	MeleeDamageInterval=0.2
	MeleeRadius=900.0
	MeleeSound=SoundCue'A_Titan_Extras.SoundCues.A_Vehicle_Goliath_Collide'
//	MeleeSound=SoundCue'A_Vehicle_Leviathan.Cue.A_Vehicle_Leviathan_BigBang'

	HeroMeleeEmitterClass=class'UTEmit_HeroMelee'
	HeroGroundPoundTemplate=ParticleSystem'UN_HeroEffects.Effects.FX_GroundPoundHands'
	SuperHeroGroundPoundTemplate=ParticleSystem'UN_HeroEffects.Effects.FX_GroundPoundHands_Super'
	HeroPostProcessEffect=PostProcessChain'UN_HeroEffects.Effects.HeroPostProcess'
	
	HeroAnimScaling=0.65
	SuperHeroAnimScaling=0.65
}