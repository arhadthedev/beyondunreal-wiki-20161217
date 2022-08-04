/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtPowerCore extends UTOnslaughtPanelNode
	native(Onslaught)
	nativereplication
	hidecategories(VoiceMessage)
	abstract;

var		bool	bWasVulnerable; // for determining transitions
var()	bool	bReverseForThisCore;		// if true, vehicle factories reverse vehicle spawns when controlled by this core's team
var()	bool	bNoCoreSwitch;		// If true, don't switch cores between rounds

/** if set, the team that controls this core is the Necris team (can affect what vehicle factories will activate for this team) */
var()	bool	bNecrisCore;

/** set during beginstate of active state */
var bool bResettingCore;

var int ProcessedTarydium;

var SkeletalMeshComponent BaseMesh;

var MaterialInstanceConstant BaseMaterialInstance;
var LinearColor BaseMaterialColors[2];

/** effect for the inner sphere */
var ParticleSystemComponent InnerCoreEffect;
var ParticleSystem InnerCoreEffectTemplates[2];

/** sparking energy effects visible when the core is vulnerable */
var struct native EnergyEffectInfo
{
	/** reference to the effect component */
	var ParticleSystemComponent Effect;
	/** current bones used for the effect endpoints */
	var name CurrentEndPointBones[2];
} EnergyEffects[6];

/** if the energy effect beam length is greater than this, a new endpoint bone is selected */
var float MaxEnergyEffectDist;

/** parameter names for the endpoints */
var name EnergyEndPointParameterNames[2];

/** energy effect endpoint will only be attached to bones with this prefix */
var string EnergyEndPointBonePrefix;

/** team colored energy effect templates */
var ParticleSystem EnergyEffectTemplates[2];

/** destruction effect */
var ParticleSystem DestructionEffectTemplates[2];

/** physics asset to use for BaseMesh while destroyed */
var PhysicsAsset DestroyedPhysicsAsset;

/** shield effects when not attackable */
var ParticleSystemComponent ShieldEffects[3];
var ParticleSystem ShieldEffectTemplates[2];

/** team colors for light emitted by powercore */
var Color EnergyLightColors[2];

/** dynamic powercore light */
var() PointLightComponent EnergyEffectLight;

/** the sound to play when the core becomes shielded */
var SoundCue ShieldOnSound;
/** the sound to play when the core loses its shield */
var SoundCue ShieldOffSound;
/** ambient sound when shield is up */
var SoundCue ShieldedAmbientSound;
/** ambient sound when shield is down */
var SoundCue UnshieldedAmbientSound;
/** Sound that plays to all players on team as core takes damage */
var SoundCue DamageWarningSound;

/** cached of health for warning effects*/
var float OldHealth;

/** last time warning played*/
var float LastDamageWarningTime;

/** Last time took damage */
var float LastDamagedTime;

var AnimNodeBlend DamageCrossfader;

var localized String NamePrefix;

var class<UTLocalMessage> ONSAnnouncerMessagesClass;
var class<UTLocalMessage> ONSOrbMessagesClass;

/** SkeletalMeshActor spawned to give Kismet when there are events controlling destruction effects */
var SkeletalMeshActor KismetMeshActor;

/** Team specific message classes */
var class<UTLocalMessage> CoreMessageClass, RedMessageClass, BlueMessageClass;

/** Time this powercore became vulnerable */
var float VulnerableTime;

/** Duration of reduced damage after becoming vulnerable */
var float ReducedDamageTime;

var Array<SoundNodeWave> DefendingLocationSpeech;
var Array<SoundNodeWave> EnemyLocationSpeech;
var Array<SoundNodeWave> AttackingOurCoreSpeech;
var Array<SoundNodeWave> DefendingEnemyCoreSpeech;

var float LastNoHealWarningTime;

/** offset to location for AI to consider shooting if the center cannot be hit */
var vector AlternateTargetLocOffset;

var ForceFeedbackWaveform CoreDestroyWaveForm;

/** If true, bots and player orders will never be to attack this core, but rather to hold a prime node */
var() bool bNeverAttack;



replication
{
	if (bNetDirty && Role == ROLE_Authority)
		ProcessedTarydium;
}

native simulated function vector GetTargetLocation(optional Actor RequestedBy, optional bool bRequestAlternateLoc) const;

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'DefenderTeamIndex')
	{
		SetTeamEffects();
	}
	else if (VarName == 'Health')
	{
		UpdateDamageEffects(true);
	}
	super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < ArrayCount(EnergyEffects); i++)
		{
			EnergyEffects[i].Effect = new(Outer) class'UTParticleSystemComponent';
			EnergyEffects[i].Effect.bAutoActivate = false;
			BaseMesh.AttachComponentToSocket(EnergyEffects[i].Effect, name("EnergyEffect" $ (i + 1)));
		}
		for (i = 0; i < ArrayCount(ShieldEffects); i++)
		{
			ShieldEffects[i] = new(Outer) class'UTParticleSystemComponent';
			ShieldEffects[i].bAutoActivate = false;
			BaseMesh.AttachComponentToSocket(ShieldEffects[i], name("EnergyEffect" $ (i + 1)));
		}
		BaseMaterialInstance = BaseMesh.CreateAndSetMaterialInstanceConstant(0);

		DamageCrossfader = AnimNodeBlend(BaseMesh.FindAnimNode('DamageCrossfade'));
	}
}

simulated function SoundNodeWave GetLocationSpeechFor(PlayerController PC, int LocationSpeechOffset, int MessageIndex)
{
	// different location message if enemy powercore
	if ( (WorldInfo.GRI != None) && !WorldInfo.GRI.OnSameTeam(PC, self) )
	{
		if ( MessageIndex < 2 )
		{
			return (LocationSpeechOffset < EnemyLocationSpeech.Length) ? EnemyLocationSpeech[LocationSpeechOffset] : None;
		}
		else if ( MessageIndex == 3 )
		{
			return (LocationSpeechOffset < DefendingEnemyCoreSpeech.Length) ? AttackingOurCoreSpeech[LocationSpeechOffset] : None;
		}
		else
		{
			return (LocationSpeechOffset < AttackingLocationSpeech.Length) ? AttackingLocationSpeech[LocationSpeechOffset] : None;
		}
	}
	if ( MessageIndex < 2 )
	{
		return (LocationSpeechOffset < LocationSpeech.Length) ? LocationSpeech[LocationSpeechOffset] : None;
	}
	else if ( MessageIndex == 2 )
	{
		return (LocationSpeechOffset < AttackingOurCoreSpeech.Length) ? AttackingOurCoreSpeech[LocationSpeechOffset] : None;
	}
	else
	{
		return (LocationSpeechOffset < DefendingLocationSpeech.Length) ? DefendingLocationSpeech[LocationSpeechOffset] : None;
	}
}

simulated function HighlightOnMinimap(int Switch)
{
	if ( HighlightScale < 1.25 )
	{
		HighlightScale = (Switch == 0) ? 2.0 : MaxHighlightScale;
		LastHighlightUpdate = WorldInfo.TimeSeconds;
	}
}

simulated function string GetHumanReadableName()
{
	return default.ObjectiveName;
}

simulated function InitialUpdateEffects()
{
	bResettingCore = false;
	UpdateEffects(true);
}

simulated function UpdateEffects(bool bPropagate)
{
	local bool bIsVulnerable;
	local PlayerController PC;
	local AnimNodeSequence MainSeq;
	local int i;

	if (WorldInfo.NetMode == NM_DedicatedServer)
		return;

	Super.UpdateEffects(bPropagate);

	if ( bResettingCore )
	{
		bWasVulnerable = false;
		bIsVulnerable = false;
	}
	else
	{
		bIsVulnerable = PoweredBy(1 - DefenderTeamIndex);
	}

	if ( bIsVulnerable && !bWasVulnerable )
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
   			PC.ReceiveLocalizedMessage(CoreMessageClass, 3);
   			break;
   		}
   		PlaySound(ShieldOffSound, true);
		VulnerableTime = WorldInfo.TimeSeconds;
	}
	else if (!bIsVulnerable && bWasVulnerable)
	{
		ForEach LocalPlayerControllers(class'PlayerController', PC)
		{
   			PC.ReceiveLocalizedMessage(CoreMessageClass, 6);
   			break;
   		}
		PlaySound(ShieldOnSound, true);
	}

	bWasVulnerable = bIsVulnerable;

	if (bScriptInitialized)
	{
		SetAmbientSound(bIsVulnerable ? UnshieldedAmbientSound : ShieldedAmbientSound);
		MainSeq = AnimNodeSequence(BaseMesh.FindAnimNode('CorePlayer'));
		if (bIsVulnerable)
		{
			if(MainSeq != none)
			{
				MainSeq.SetAnim('Retract');
				MainSeq.PlayAnim();
			}
			for (i = 0; i < ArrayCount(EnergyEffects); i++)
			{
				EnergyEffects[i].Effect.SetHidden(false);
				EnergyEffects[i].Effect.SetActive(true);
			}
			for (i = 0; i < ArrayCount(ShieldEffects); i++)
			{
				ShieldEffects[i].DeactivateSystem();
				ShieldEffects[i].SetHidden(true);
			}
		}
		else
		{
			if(MainSeq != none)
			{
				MainSeq.SetAnim('Extend');
				MainSeq.PlayAnim();
			}
			for (i = 0; i < ArrayCount(EnergyEffects); i++)
			{
				EnergyEffects[i].Effect.DeactivateSystem();
				EnergyEffects[i].Effect.SetHidden(true);
			}
			for (i = 0; i < ArrayCount(ShieldEffects); i++)
			{
				ShieldEffects[i].SetHidden(false);
				ShieldEffects[i].SetActive(true);
			}
		}
	}
}

function InitializeForThisRound(int CoreIndex)
{
	local int Hops;

	// Set the distance in hops from every PowerNode to this powercore
	Hops = 0;
	SetCoreDistance(CoreIndex, Hops);

	// set flag team appropriately
	if (FlagBase != None && FlagBase.myFlag != None)
	{
		FlagBase.myFlag.SetTeam(GetTeamNum());
	}
}

simulated event SetInitialState()
{
	bScriptInitialized = true;

	if ( Role < ROLE_Authority )
		return;

	if (LinkedNodes[0] == None)
	{
		InitialState = 'DisabledNode';
	}
	else
	{
		InitialState = 'ActiveNode';
	}
	GotoState(InitialState,, true);
}

simulated function vector GetHUDOffset(PlayerController PC, Canvas Canvas)
{
	local float Z;

	Z = 280;
	if ( PC.ViewTarget != None )
	{
		Z += 0.1 * VSize(PC.ViewTarget.Location - Location);
	}
	return Z*vect(0,0,1);
}

function bool ValidSpawnPointFor(byte TeamIndex)
{
	return ( TeamIndex == DefenderTeamIndex );
}

function bool KillEnemyFirst(UTBot B)
{
	return false;
}

/** HealDamage()
PowerCores cannot be healed
*/
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if ( PlayerController(Healer) != None )
		PlayerController(Healer).ReceiveLocalizedMessage(MessageClass, 30);
	return false;
}

function OnHealDamage(SeqAct_HealDamage Action)
{
	local int Amount;

	Amount = Min(DamageCapacity - Health, Action.HealAmount);
	Health += Amount;
	HealPanels(Amount);
}

function ScoreDamage(UTOnslaughtPRI AttackerPRI, float Damage)
{
	Super.ScoreDamage(AttackerPRI, 10*Damage);
	AttackerPRI.AddToNodeStat('NODE_DAMAGEDCORE', Damage);
}


/** applies any scaling factors to damage we're about to take */
simulated function ScaleDamage(out int Damage, Controller InstigatedBy, class<DamageType> DamageType)
{
	Super.ScaleDamage(Damage, InstigatedBy, DamageType);

	// only apply special "last minute" and "camping" modifiers if being damaged by a person, leave kismet damage alone
	if (InstigatedBy != None)
	{
	if ( (WorldInfo.GRI.RemainingTime < 120) && (WorldInfo.GRI.RemainingTime > 0) )
	{
		Damage *= 1.75;
	}
	else if ( WorldInfo.TimeSeconds - VulnerableTime < ReducedDamageTime )
	{
		Damage *= 0.5;
	}
}
}

simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float LastHealth;

	LastHealth = Health;

	Super.TakeDamage(Damage, InstigatedBy,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if (Health != LastHealth)
	{
		LastDamagedTime = WorldInfo.TimeSeconds;
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			UpdateDamageEffects(true);
		}
		if ( UTOnslaughtGame(WorldInfo.Game) != None )
		{
			UTOnslaughtGame(WorldInfo.Game).AdjustOnslaughtSkill();
		}
	}
}

simulated function UpdateDamageEffects(bool bCheckAlarm)
{
	local int ScaledDamage;
	local float PercentageToNextAlarm;
	local PlayerController P;

	if (DamageCrossfader != None && Health / DamageCapacity < 0.5f && !IsInState('ObjectiveDestroyed'))
	{
		DamageCrossfader.SetBlendTarget(1.0 - (Health / DamageCapacity * 2.0f), 0.0);
	}
	if (BaseMaterialInstance != None)
	{
		BaseMaterialInstance.SetScalarParameterValue('DamageOverlay', 1.0 - FClamp(Health / DamageCapacity, 0.0, 1.0));
	}

	// damage alarm
	if (bCheckAlarm && LastDamageWarningTime + 5.0 < WorldInfo.TimeSeconds)
	{
		ScaledDamage = OldHealth - Health;
		OldHealth = Health;
		LastDamageWarningTime = WorldInfo.TimeSeconds;
		PercentageToNextAlarm = (Health / DamageCapacity) % 0.07;
		if (PercentageToNextAlarm == 0.0f) // we're right at a 7%, so need to cover a full 7% more to sound off
		{
			PercentageToNextAlarm = 0.07f;
		}
		if (float(ScaledDamage) / DamageCapacity > PercentageToNextAlarm)
		{
			foreach LocalPlayerControllers(class'PlayerController', P)
			{
				if (P.GetTeamNum() == DefenderTeamIndex)
				{
					P.ClientPlaySound(DamageWarningSound);
				}
			}
		}
	}

}

function DisableObjective(Controller InstigatedBy)
{
	local UTPlayerReplicationInfo PRI;

	if (InstigatedBy != None)
	{
		PRI = UTPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo);
		if ( PRI != None )
		{
			PRI.IncrementNodeStat('NODE_DESTROYEDCORE');
		}
	}

	BroadcastLocalizedMessage(CoreMessageClass, 1, PRI,, self);

	GotoState('ObjectiveDestroyed');
}

/** sets team specific effects depending on DefenderTeamIndex */
simulated function SetTeamEffects()
{
	local int i;

	CoreMessageClass = (DefenderTeamIndex == 0) ? RedMessageClass : BlueMessageClass;
	if (WorldInfo.NetMode != NM_DedicatedServer && DefenderTeamIndex < 2)
	{
		if (InnerCoreEffect.Template != InnerCoreEffectTemplates[DefenderTeamIndex])
		{
			InnerCoreEffect.SetTemplate(InnerCoreEffectTemplates[DefenderTeamIndex]);
		}
		for (i = 0; i < ArrayCount(EnergyEffects); i++)
		{
			if (EnergyEffects[i].Effect.Template != EnergyEffectTemplates[DefenderTeamIndex])
			{
				EnergyEffects[i].Effect.SetTemplate(EnergyEffectTemplates[DefenderTeamIndex]);
			}
		}
		for (i = 0; i < ArrayCount(ShieldEffects); i++)
		{
			if (ShieldEffects[i].Template != ShieldEffectTemplates[DefenderTeamIndex])
			{
				ShieldEffects[i].SetTemplate(ShieldEffectTemplates[DefenderTeamIndex]);
			}
		}
		BaseMaterialInstance.SetVectorParameterValue('PowerCoreColor', BaseMaterialColors[DefenderTeamIndex]);
		EnergyEffectLight.SetLightProperties(20, EnergyLightColors[DefenderTeamIndex]);
	}
}

simulated state ObjectiveDestroyed
{
	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{}

	function Timer() {}

	function bool LegitimateTargetOf(UTBot B)
	{
		return false;
	}

	function bool TellBotHowToDisable(UTBot B)
	{
		if ( StandGuard(B) )
			return TooClose(B);

		return B.Squad.FindPathToObjective(B, self);
	}

	simulated function UpdateEffects(bool bPropagate)
	{
		local LinearColor MaterialColor;
		local int i;

		Super(UTOnslaughtNodeObjective).UpdateEffects(bPropagate);

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			for (i = 0; i < ArrayCount(EnergyEffects); i++)
			{
				EnergyEffects[i].Effect.DeactivateSystem();
				EnergyEffects[i].Effect.SetHidden(true);
			}
			for (i = 0; i < ArrayCount(ShieldEffects); i++)
			{
				ShieldEffects[i].DeactivateSystem();
				ShieldEffects[i].SetHidden(true);
			}

			MaterialColor.A = 1.0;
			BaseMaterialInstance.SetVectorParameterValue('PowerCoreColor', MaterialColor);
		}
	}

	/** blows off all panels at once */
	simulated function BlowOffAllPanels()
	{
		local array<name> BoneNames;
		local UTPowerCorePanel Panel;
		local vector BoneLocation;
		local int i;

		if (PanelBoneScaler != None && PanelMesh != None)
		{
			PanelMesh.GetBoneNames(BoneNames);
			for (i = 0; i < BoneNames.length; i++)
			{
				if ( (i >= PanelBoneScaler.BoneScales.length || PanelBoneScaler.BoneScales[i] != DESTROYED_PANEL_BONE_SCALE) &&
					InStr(string(BoneNames[i]), PanelBonePrefix) == 0 )
				{
					BoneLocation = PanelMesh.GetBoneLocation(BoneNames[i]);

					PanelBoneScaler.BoneScales[i] = DESTROYED_PANEL_BONE_SCALE;

					WorldInfo.MyEmitterPool.SpawnEmitter(PanelExplosionTemplates[DefenderTeamIndex], BoneLocation);

					Panel = Spawn(PanelGibClass, self,, BoneLocation, rotator(BoneLocation - PanelMesh.GetPosition()));
					if (Panel != None)
					{
						Panel.Mesh.AddImpulse(Normal(BoneLocation - PanelMesh.GetPosition()) * 500.0);
					}
				}
			}
		}
	}

	simulated function BeginState(Name PreviousStateName)
	{
		local PlayerController PC;
		local array<SequenceEvent> DestructionEvents;
		local int i;

		SetAmbientSound(None);
		Health = 0;
		NodeState = GetStateName();

		BaseMesh.SetPhysicsAsset(DestroyedPhysicsAsset);
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			if (DamageCrossfader != None)
			{
				DamageCrossfader.SetBlendTarget(0.0, 0.0);
			}
			if (BaseMaterialInstance != None)
			{
				BaseMaterialInstance.SetScalarParameterValue('DamageOverlay', 1.0);
			}
			if (FindEventsOfClass(class'UTSeqEvent_PowerCoreDestructionEffect', DestructionEvents))
			{
				// play level-specific destruction
				BlowOffAllPanels();
				KismetMeshActor = Spawn(class'SkeletalMeshActorMATSpawnable');
				KismetMeshActor.DetachComponent(KismetMeshActor.SkeletalMeshComponent);
				KismetMeshActor.SetDrawScale(DrawScale);
				KismetMeshActor.SetDrawScale3D(DrawScale3D);
				KismetMeshActor.SkeletalMeshComponent = new(KismetMeshActor) BaseMesh.Class(BaseMesh);
				KismetMeshActor.SkeletalMeshComponent.SetAnimTreeTemplate(AnimTree(BaseMesh.Animations));
				KismetMeshActor.AttachComponent(KismetMeshActor.SkeletalMeshComponent);
				SetHidden(true);
				for (i = 0; i < DestructionEvents.length; i++)
				{
					UTSeqEvent_PowerCoreDestructionEffect(DestructionEvents[i]).MeshActor = KismetMeshActor;
					DestructionEvents[i].CheckActivate(self, None);
				}
			}
			else
			{
				foreach LocalPlayerControllers(class'PlayerController', PC)
				{
					PC.ClientPlaySound(DestroyedSound);
				}

				if (DefenderTeamIndex < 2)
				{
					WorldInfo.MyEmitterPool.SpawnEmitter(DestructionEffectTemplates[DefenderTeamIndex], InnerCoreEffect.GetPosition());
				}
				SetTimer(5.0, false, 'BlowOffPanelTimer');
			}
		}

		UpdateLinks();
		UpdateEffects(true);

		if (Role == ROLE_Authority)
		{
			bForceNetUpdate = TRUE;
			Scorers.length = 0;
			UpdateCloseActors();
			UTOnslaughtGame(WorldInfo.Game).MainCoreDestroyed(DefenderTeamIndex);
		}
	}

	simulated event EndState(name NextStateName)
	{
		if (DamageCrossfader != None)
		{
			DamageCrossfader.SetBlendTarget(0.0f, 0.001);
		}
		if (BaseMaterialInstance != None)
		{
			BaseMaterialInstance.SetScalarParameterValue('DamageOverlay', 0.0);
		}
		Super.EndState(NextStateName);

		SetHidden(false);
		if (KismetMeshActor != None)
		{
			KismetMeshActor.Destroy();
		}
	}
}

simulated state ActiveNode
{
	simulated function string GetNodeString(PlayerController PC)
	{
		if ( DefenderTeamIndex == 0 )
			return "RED Core";
		else
			return "BLUE Core";
	}

	simulated function BeginState(Name PreviousStateName)
	{
		bResettingCore = true;
		Super.BeginState(PreviousStateName);
		SetTimer(2.0, false, 'InitialUpdateEffects');

		BaseMesh.SetPhysicsAsset(default.BaseMesh.PhysicsAsset);
		CoreMessageClass = (DefenderTeamIndex == 0) ? RedMessageClass : BlueMessageClass;
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			SetTeamEffects();
			InnerCoreEffect.SetHidden(false);
		}
	}

	simulated function EndState(name NextStateName)
	{
		Super.EndState(NextStateName);

		InnerCoreEffect.SetHidden(true);
	}

	function bool HasActiveDefenseSystem()
	{
		return true;
	}
}

function BroadcastAttackNotification(Controller InstigatedBy)
{
	//attack notification
	bForceNetUpdate = TRUE;
	if (LastAttackMessageTime + 1 < WorldInfo.TimeSeconds)
	{
		if ( Health/DamageCapacity > 0.55 )
		{
			if ( InstigatedBy != None )
				BroadcastLocalizedMessage(CoreMessageClass, 0,,, self);
		}
		else if ( Health/DamageCapacity > 0.45 )
			BroadcastLocalizedMessage(CoreMessageClass, 4,,, self);
		else
			BroadcastLocalizedMessage(CoreMessageClass, 2,,, self);

		if ( InstigatedBy != None )
		{
			UTTeamInfo(WorldInfo.GRI.Teams[DefenderTeamIndex]).AI.CriticalObjectiveWarning(self, instigatedBy.Pawn);
		}
		LastAttackMessageTime = WorldInfo.TimeSeconds;
	}
	LastAttackTime = WorldInfo.TimeSeconds;
}

function FailedLinkHeal(Controller C)
{
	local PlayerController PC;

	PC = PlayerController(C);
	if ( (PC == None) || (WorldInfo.TimeSeconds - LastNoHealWarningTime < 5.0) )
	{
		return;
	}
	LastNoHealWarningTime = WorldInfo.TimeSeconds;
	PC.ReceiveLocalizedMessage(CoreMessageClass, 5);
}


function bool TellBotHowToDisable(UTBot B)
{
	if ( bNeverAttack )
	{
		// defend prime node instead
		return LinkedNodes[0].TellBotHowToHeal(B);
	}

	return Super.TellBotHowToDisable(B);
}

DefaultProperties
{
	ReducedDamageTime=+10.0
	DestroyedStinger=15
}
