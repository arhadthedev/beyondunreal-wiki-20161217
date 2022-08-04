/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtNodeObjective extends UTOnslaughtObjective
	abstract
	native(Onslaught)
	nativereplication
	hidecategories(ObjectiveHealth,Collision,Display);

var		float               ConstructionTime;
var		soundcue            DestroyedSound;
var		soundcue			ConstructedSound;
var		soundcue			StartConstructionSound;
var		soundcue            ActiveSound;
var		soundcue            HealingSound;
var		soundcue            HealedSound;
var     repnotify bool      bSevered;			/**	true if active node is severed from its power network */
var		bool				bWasSevered;		/** utility - for determining transitions to being severed */

var InterpCurveFloat AttackEffectCurve;

/** if > 0, minimum number of players before this node is enabled (checked only when match begins, not during play) */
var int MinPlayerCount;
const MAXNUMLINKS=8;
var repnotify UTOnslaughtNodeObjective LinkedNodes[MAXNUMLINKS];
var repnotify byte NumLinks;
/** if set, this node can exist and be captured without being linked */
var bool bStandalone;
/** spawn priority for standalone nodes - lower is better, 255 = autogenerate (FinalCoreDistance is set to this) */
var() byte StandaloneSpawnPriority<tooltip=Lower is better, 255 = autogenerate>;

var() bool bFullScreenNameAboveIcon;

var array<UTOnslaughtSpecialObjective> ActivatedObjectives;

// Internal
var repnotify name			NodeState;
var float           ConstructionTimeElapsed;
var float           SeveredDamagePerSecond;
var float           HealingTime;

var int ActivationMessageIndex, DestructionMessageIndex; //base switch for UTOnslaughtMessage
var string DestroyedEvent[4];
var string ConstructedEvent[2];
var Controller Constructor;			/** player who touched me to start construction */
var Controller LastHealedBy;

var int NodeNum;

var AudioComponent AmbientSoundComponent;

var LinearColor BeamColor[3];
var StaticMeshComponent NodeBeamEffect;
var protected MaterialInstanceTimeVarying BeamMaterialInstance;

/** material parameter for god beam under attack effect */
var name GodBeamAttackParameterName;

var transient ParticleSystemComponent ShieldedEffect;

var array<UTOnslaughtNodeEnhancement> Enhancements; /** node enhancements (tarydium processors, etc.) */

/** node teleporters controlled by this node */
var array<UTOnslaughtNodeTeleporter> NodeTeleporters;

var UTOnslaughtFlagBase FlagBase;					/** If flagbase is associated with this node, onslaught flag can be returned here */

/** wake up call to fools shooting invalid target :) */
var SoundCue ShieldHitSound;
var int ShieldDamageCounter;

/** emitter spawned when we're being healed */
var UTOnslaughtNodeHealEffectBase HealEffect;
/** the class of that emitter to use */
var class<UTOnslaughtNodeHealEffectBase> HealEffectClasses[2];

/** if specified, the team that owns this PowerCore starts the game with this node in their control */
var UTOnslaughtPowerCore StartingOwnerCore;

/** localized string parts for creating location descriptions */
var localized string OutsideLocationPrefix, OutsideLocationPostfix, BetweenLocationPrefix, BetweenLocationJoin, BetweenLocationPostFix;

/** set if prime node (adjacent to power core) and bNeverCalledPrimeNode is false */
var UTOnslaughtPowerCore PrimeCore;
/** set if adjacent to both cores */
var bool bDualPrimeCore;

/** whether to render icon on HUD beacon (using DrawBeaconIcon()) */
var bool bDrawBeaconIcon;

/** if set, never override this node's name with "prime node" */
var(Announcements) bool bNeverCalledPrimeNode;

/** if set, is prime node */
var bool bIsPrimeNode;

var(VoiceMessage) Array<SoundNodeWave> CapturedLocationSpeech;
var(VoiceMessage) Array<SoundNodeWave> AttackingLocationSpeech;

var Array<SoundNodeWave> CapturedPrimeSpeech;
var Array<SoundNodeWave> CapturedEnemyPrimeSpeech;
var Array<SoundNodeWave> AttackingPrimeSpeech;
var Array<SoundNodeWave> AttackingEnemyPrimeSpeech;
var Array<SoundNodeWave> HeadingPrimeSpeech;
var Array<SoundNodeWave> HeadingEnemyPrimeSpeech;

/** Stinger to play for the killer when this objective is destroyed */
var int DestroyedStinger;

var Texture2D LinkLineTexture;



replication
{
	if ( bNetInitial )
		LinkedNodes, NumLinks;

	if (bNetDirty && Role == ROLE_Authority)
		PrimeCore, bDualPrimeCore, NodeState, bSevered;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( NodeBeamEffect != None )
	{
		NodeBeamEffect.SetHidden(true);
	}
}

simulated function string GetLocationStringFor(PlayerReplicationInfo PRI)
{
	return LocationPrefix$GetHumanReadableName()$LocationPostfix;
}

function TarydiumBoost(float Quantity)
{
	local float BoostShare;
	local int i;

	if (Enhancements.Length + VehicleFactories.Length > 0)
	{
		BoostShare = Quantity/(Enhancements.Length + VehicleFactories.Length);

		for (i = 0; i < VehicleFactories.Length; i++)
		{
			VehicleFactories[i].TarydiumBoost(BoostShare);
		}

		for (i = 0; i < Enhancements.Length; i++)
		{
			Enhancements[i].TarydiumBoost(BoostShare);
		}
	}
}

function AddActivatedObjective(UTOnslaughtSpecialObjective O)
{
	ActivatedObjectives[ActivatedObjectives.Length] = O;
}

function bool Shootable()
{
	return true;
}

function InitCloseActors()
{
	Super.InitCloseActors();

	NodeTeleporters.length = 0;
}

/** draws the icon for the HUD beacon */
simulated function DrawBeaconIcon(Canvas Canvas, vector IconLocation, float IconWidth, float IconAlpha, float BeaconPulseScale, UTPlayerController PlayerOwner)
{
	local linearcolor DrawColor;

	DrawColor = (DefenderTeamIndex < 2) ? ControlColor[DefenderTeamIndex] : ControlColor[2];
	DrawIcon(Canvas, IconLocation, IconWidth, IconAlpha, PlayerOwner, DrawColor);
}

/**
PostRenderFor()
Hook to allow objectives to render HUD overlays for themselves.
Called only if objective was rendered this tick.
Assumes that appropriate font has already been set
*/
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local float TextXL, XL, YL, HealthX, HealthMaxX, HealthY, BeaconPulseScale, TextDistScale, IconYL;
	local vector ScreenLoc, IconLoc;
	local LinearColor TeamColor;
	local Color TextColor;
	local UTWeapon Weap;
	local string NodeName;

	if ( !PoweredBy(PC.GetTeamNum()) )
	{
		if ( bIsNeutral )
			return;
	}

	screenLoc = Canvas.Project(Location + GetHUDOffset(PC,Canvas));

	// make sure not clipped out
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		return;
	}

	// make sure not behind weapon
	if ( UTPawn(PC.Pawn) != None )
	{
		Weap = UTWeapon(UTPawn(PC.Pawn).Weapon);
		if ( (Weap != None) && Weap.CoversScreenSpace(screenLoc, Canvas) )
		{
			return;
		}
	}
	else if ( (UTVehicle_Hoverboard(PC.Pawn) != None) && UTVehicle_Hoverboard(PC.Pawn).CoversScreenSpace(screenLoc, Canvas) )
	{
		return;
	}

	if ( !IsKeyBeaconObjective(UTPlayerController(PC))  )
	{
		// periodically make sure really visible using traces
		if ( WorldInfo.TimeSeconds - LastPostRenderTraceTime > 0.5 )
		{
			LastPostRenderTraceTime = WorldInfo.TimeSeconds + 0.2*FRand();
			bPostRenderTraceSucceeded = FastTrace(Location, CameraPosition)
										|| FastTrace(Location+CylinderComponent.CollisionHeight*vect(0,0,1), CameraPosition);
		}
		if ( !bPostRenderTraceSucceeded )
		{
			return;
		}
		BeaconPulseScale = 1.0;
	}
	else
	{
		// pulse "key" objective
		BeaconPulseScale = UTPlayerController(PC).BeaconPulseScale;
	}

	class'UTHUD'.Static.GetTeamColor( GetTeamNum(), TeamColor, TextColor);

	TeamColor.A = 1.0;

	// fade if close to crosshair
	if (screenLoc.X > 0.4*Canvas.ClipX &&
		screenLoc.X < 0.6*Canvas.ClipX &&
		screenLoc.Y > 0.4*Canvas.ClipY &&
		screenLoc.Y < 0.6*Canvas.ClipY)
	{
		TeamColor.A = FMax(FMin(1.0, FMax(0.0,Abs(screenLoc.X - 0.5*Canvas.ClipX) - 0.05*Canvas.ClipX)/(0.05*Canvas.ClipX)), FMin(1.0, FMax(0.0, Abs(screenLoc.Y - 0.5*Canvas.ClipY)-0.05*Canvas.ClipX)/(0.05*Canvas.ClipY)));
		if ( TeamColor.A == 0.0 )
		{
			return;
		}
	}

	// fade if far away or not visible
	TeamColor.A = FMin(TeamColor.A, LocalPlayer(PC.Player).GetActorVisibility(self)
									? FClamp(1800/VSize(Location - CameraPosition),0.35, 1.0)
									: 0.2);

	HealthY = PostRenderShowHealth() ? Canvas.ClipX*BeaconPulseScale/64 : 0.0;

	if ( PrimeCore != None )
	{
		NodeName = 	(bDualPrimeCore || WorldInfo.GRI.OnSameTeam(PC, PrimeCore)) ? class'UTOnslaughtPowernode'.default.PrimeNodeName : class'UTOnslaughtPowernode'.default.EnemyPrimeNodeName;
	}
	else
	{
		NodeName = ObjectiveName;
	}

	Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(1);
	Canvas.StrLen(NodeName, TextXL, YL);
	TextDistScale = FMin(1.5, 0.1 * Canvas.ClipX/TextXL);
	TextXL *= TextDistScale;
	XL = 0.1 * Canvas.ClipX * BeaconPulseScale;
	YL *= TextDistScale*BeaconPulseScale;

	IconYL = bDrawBeaconIcon ? XL * 0.75 : 0.0;
	class'UTHUD'.static.DrawBackground(ScreenLoc.X-0.7*XL,ScreenLoc.Y-0.6*(YL+HealthY)- 0.5*(YL+IconYL),1.4*XL,1.2*(YL+HealthY) + YL + IconYL, TeamColor, Canvas);

	Canvas.DrawColor = TextColor;
	Canvas.DrawColor.A = 255.0 * TeamColor.A;

	if (bDrawBeaconIcon)
	{
		IconLoc = ScreenLoc;
		IconLoc.Y -= 0.25 * IconYL;

		DrawBeaconIcon(Canvas, IconLoc, 0.5*IconYL, TeamColor.A, BeaconPulseScale, UTPlayerController(PC));

		ScreenLoc.Y += IconYL * 0.25;
	}

	// draw node name
	Canvas.DrawColor.A = FMin(255.0, 128.0 * (1.0 + TeamColor.A));
	Canvas.SetPos(ScreenLoc.X-0.5*BeaconPulseScale*TextXL, ScreenLoc.Y - 0.5*YL - 0.6*HealthY );
	Canvas.DrawTextClipped(NodeName, true, TextDistScale*BeaconPulseScale, TextDistScale*BeaconPulseScale);

	// draw health bar
	if ( (HealthY > 0) && LocalPlayer(PC.Player).GetActorVisibility(self) )
	{
		HealthMaxX = 0.9 * XL;
		HealthX = HealthMaxX* FMin(1.0, Health/DamageCapacity);
		Class'UTHUD'.static.DrawHealth(ScreenLoc.X-0.45*XL,ScreenLoc.Y,HealthX,HealthMaxX,HealthY, Canvas, Canvas.DrawColor.A);
	}
	Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(0);
}

simulated function bool PostRenderShowHealth()
{
	return ( bIsActive || bIsConstructing );
}

simulated function int GetLocationMessageIndex(UTBot B, Pawn StatusPawn)
{
	local name BotOrders;
	local int MessageIndex;

	// message index based on proximity
	MessageIndex = 0;

	// maybe messageindex based on orders
	if ( (B != None) && (self == B.Squad.SquadObjective) )
	{
		BotOrders = B.GetOrders();
		if ( BotOrders == 'Attack' )
		{
			if ( self == B.Focus )
			{
				MessageIndex = 2;
			}
		}
		else if ( ((VSizeSq(StatusPawn.Location - Location) < Square(BaseRadius)) || (UTDefensePoint(B.Pawn.Anchor) != None)) && (BotOrders != 'Freelance') )
		{
			MessageIndex = 3;
		}
	}
	return MessageIndex;
}

simulated function SoundNodeWave GetLocationSpeechFor(PlayerController PC, int LocationSpeechOffset, int MessageIndex)
{
	if ( PrimeCore != None )
	{
		if ( bDualPrimeCore || WorldInfo.GRI.OnSameTeam(PC, PrimeCore) )
		{
			if ( MessageIndex < 2 )
			{
				return (LocationSpeechOffset < HeadingPrimeSpeech.Length) ? HeadingPrimeSpeech[LocationSpeechOffset] : None;
			}
			else
			{
				return (LocationSpeechOffset < AttackingPrimeSpeech.Length) ? AttackingPrimeSpeech[LocationSpeechOffset] : None;
			}
		}
		else
		{
			if ( MessageIndex < 2 )
			{
				return (LocationSpeechOffset < HeadingEnemyPrimeSpeech.Length) ? HeadingEnemyPrimeSpeech[LocationSpeechOffset] : None;
			}
			else
			{
				return (LocationSpeechOffset < AttackingEnemyPrimeSpeech.Length) ? AttackingEnemyPrimeSpeech[LocationSpeechOffset] : None;
			}
		}
	}

	if ( MessageIndex < 2 )
	{
		return (LocationSpeechOffset < LocationSpeech.Length) ? LocationSpeech[LocationSpeechOffset] : None;
	}
	else
	{
		return (LocationSpeechOffset < AttackingLocationSpeech.Length) ? AttackingLocationSpeech[LocationSpeechOffset] : None;
	}
}

/** SetCoreDistance()
determine how many hops each node is from powercore N in hops
*/
function SetCoreDistance(byte TeamNum, int Hops)
{
	local int i;

	if ( Hops < FinalCoreDistance[TeamNum] )
	{
		FinalCoreDistance[TeamNum] = Hops;
		Hops += 1;
		for ( i=0; i<MAXNUMLINKS; i++ )
		{
			if (LinkedNodes[i] == None)
			{
				break;
			}
			else
			{
				LinkedNodes[i].SetCoreDistance(TeamNum, Hops);
			}
		}
		NumLinks = i;
	}
}

/** FindNearestFriendlyNode()
returns nearby node at which team can spawn
*/
function UTGameObjective FindNearestFriendlyNode(int TeamIndex)
{
	local float BestDist, NewDist;
	local UTGameObjective BestNode, NewNode;
	local UTOnslaughtGame Game;
	local int i;

	if (ValidSpawnPointFor(TeamIndex))
	{
		return self;
	}
	else
	{
		Game = UTOnslaughtGame(WorldInfo.Game);
		if (Game != None)
		{
			for (i = 0; i < Game.PowerNodes.length; i++)
			{
				NewNode = Game.PowerNodes[i];
				if (NewNode != None && NewNode.ValidSpawnPointFor(TeamIndex))
				{
					NewDist = VSize(NewNode.Location - Location);
					if (BestNode == None || NewDist < BestDist)
					{
						BestNode = NewNode;
						BestDist = NewDist;
					}
				}
			}
		}

		return BestNode;
	}
}


function InitLinks()
{
	local int i;

	for (i = 0; i < MAXNUMLINKS; i++)
	{
		if (LinkedNodes[i] != None)
		{
			// if linked to a power core, boost defense priority
			if (LinkedNodes[i].IsA('UTOnslaughtPowerCore'))
			{
				DefensePriority = Max(DefensePriority, 5);
				SetPrimeCore(UTOnslaughtPowerCore(LinkedNodes[i]));
			}
			LinkedNodes[i].CheckLink(self);
		}
	}

	if (bStandalone)
	{
		DefensePriority = default.DefensePriority - 1;
	}
}

function SetPrimeCore(UTOnslaughtPowerCore P)
{
	bIsPrimeNode = true;
	if ( bNeverCalledPrimeNode )
	{
		return;
	}
	if ( (PrimeCore != None) && (PrimeCore != P) )
	{
		bDualPrimeCore = true;
	}
	PrimeCore = P;
}

/** if this node is not already linked to the specified node, add a link to it */
function CheckLink(UTOnslaughtNodeObjective Node)
{
	local int i;

	// if linked to a power core, boost defense priority
	if (Node.IsA('UTOnslaughtPowerCore'))
	{
		DefensePriority = Max(DefensePriority, 5);
		SetPrimeCore(UTOnslaughtPowerCore(Node));
	}

	// see if Node is already in list
	for ( i=0; i<MAXNUMLINKS; i++ )
	{
		if ( LinkedNodes[i] == Node )
			return;
	}

	// if not, add it
	for ( i=0; i<MAXNUMLINKS; i++ )
	{
		if (LinkedNodes[i] == None)
		{
			LinkedNodes[i] = Node;
			NumLinks = Max(NumLinks, i + 1);
			return;
		}
	}
}

/** adds a link between two nodes */
function AddLink(UTOnslaughtNodeObjective Node)
{
	CheckLink(Node);
	Node.CheckLink(self);

	UpdateEffects(false);
	Node.UpdateEffects(false);

	UpdateLinks();
}

/** removes a link between two nodes */
function RemoveLink(UTOnslaughtNodeObjective Node)
{
	local int i, j;
	local bool bStillLinkedToCore;

	i = FindNodeLinkIndex(Node);
	if (i != INDEX_NONE)
	{
		NumLinks--;
		for (j = i; j < NumLinks; j++)
		{
			LinkedNodes[j] = LinkedNodes[j + 1];
		}
		LinkedNodes[NumLinks] = None;
		Node.RemoveLink(self);

		UpdateEffects(false);
		UpdateLinks();
		if (Node.IsA('UTOnslaughtPowerCore'))
		{
			// if we were linked to a powercore and we're not anymore, return to default defense priority
			for (j = 0; j < NumLinks; j++)
			{
				if (UTOnslaughtPowerCore(LinkedNodes[j]) != None)
				{
					bStillLinkedToCore = true;
					break;
				}
			}
			if (!bStillLinkedToCore)
			{
				DefensePriority = default.DefensePriority;
			}
		}
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'NodeState' )
	{
		GotoState(NodeState);
	}
	else if ( VarName == 'bUnderAttack' )
	{
		if (bUnderAttack)
		{
			BecameUnderAttack();
		}
	}
	else if (VarName == 'bSevered' || VarName == 'DefenderTeamIndex')
	{
		UpdateEffects(true);
	}
	else if (VarName == 'LinkedNodes' || VarName == 'NumLinks')
	{
		UpdateEffects(true);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function NotifyLocalPlayerTeamReceived()
{
	UpdateEffects(false);
}

simulated event SetInitialState()
{
	local UTOnslaughtNodeObjective O;
	local bool bDisabled;

	bScriptInitialized = true;

	if (Role == ROLE_Authority)
	{
		if (LinkedNodes[0] == None)
		{
			bDisabled = true;
			foreach WorldInfo.AllNavigationPoints(class'UTOnslaughtNodeObjective', O)
			{
				if (O.FindNodeLinkIndex(self) != -1)
				{
					bDisabled = false;
					break;
				}
			}
		}

		if (bDisabled && !bStandalone)
		{
			GotoState('DisabledNode');
		}
		else if (StartingOwnerCore == None)
		{
			GotoState('NeutralNode',, true);
		}
		else
		{
			DefenderTeamIndex = StartingOwnerCore.GetTeamNum();
			Health = DamageCapacity;
			GotoState('ActiveNode',, true);
		}
	}
}

simulated event bool IsActive()
{
	return bIsActive;
}

simulated function bool IsStandalone()
{
	return bStandalone;
}

simulated function bool PoweredBy(byte Team)
{
	local int i;

	if (bStandalone)
	{
		return true;
	}
	else
	{
		for (i = 0; i < NumLinks; i++)
		{
			if (LinkedNodes[i] != None && LinkedNodes[i].bIsActive && !LinkedNodes[i].bSevered && LinkedNodes[i].DefenderTeamIndex == Team)
			{
				return true;
			}
		}
		return false;
	}
}

function UpdateLinks()
{
	UTOnslaughtGame(WorldInfo.Game).UpdateLinks();
}

function Sever()
{
	if ( !WorldInfo.Game.bGameEnded && (UTGame(WorldInfo.Game).ResetCountDown <= 0) )
	{
		SetTimer(1.0, True,'SeveredDamage');
		if (DefenderTeamIndex == 0)
			BroadcastLocalizedMessage(MessageClass, 27,,, self);
		else if (DefenderTeamIndex == 1)
			BroadcastLocalizedMessage(MessageClass, 28,,, self);
	}
}

simulated function bool CreateBeamMaterialInstance()
{
	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return false;
	}
	else
	{
		BeamMaterialInstance = NodeBeamEffect.CreateAndSetMaterialInstanceTimeVarying(0);
		return true;
	}
}

/** called on a timer to update the under attack effect, if necessary */
simulated function UpdateAttackEffect()
{
	if (bUnderAttack)
	{
		BeamMaterialInstance.SetScalarStartTime(GodBeamAttackParameterName, 0.0);
		SetTimer(AttackEffectCurve.Points[AttackEffectCurve.Points.length - 1].InVal, false, 'UpdateAttackEffect');
	}
}

/* BecameUnderAttack()
Update Node beam effect to reflect whether node is under attack
*/
simulated function BecameUnderAttack()
{
	if (AttackEffectCurve.Points.length > 0 && (BeamMaterialInstance != None || CreateBeamMaterialInstance()))
	{
		BeamMaterialInstance.SetScalarCurveParameterValue(GodBeamAttackParameterName, AttackEffectCurve);
		BeamMaterialInstance.SetScalarStartTime(GodBeamAttackParameterName, 0.0);
		SetTimer(AttackEffectCurve.Points[AttackEffectCurve.Points.length - 1].InVal, false, 'UpdateAttackEffect');
	}
}

/*
NodeBeamEffect parameters:
GodBeamAttack is a scalar parameter that when set to 1 will show the white pulses traveling up the beam.
Team is a vector parameter to set the color inside of the material instance.
*/
/* UpdateEffects()
*/
simulated function UpdateEffects(bool bPropagate)
{
	local int i;
	local bool bPoweredByEnemy;

	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	bPoweredByEnemy = PoweredBy(1-DefenderTeamIndex);

	// update node beam
	if ( bPoweredByEnemy && BeamEnabled() )
	{
		NodeBeamEffect.SetHidden(false);
		if ( (BeamMaterialInstance != None) || CreateBeamMaterialInstance() )
			BeamMaterialInstance.SetVectorParameterValue('Team', BeamColor[DefenderTeamIndex]);
	}
	else
	{
		NodeBeamEffect.SetHidden(true);
	}

	// update shield
	UpdateShield(bPoweredByEnemy);

	UpdateTeamStaticMeshes();

	// propagate to neighbors
	if ( bPropagate )
	{
		for ( i=0; i<NumLinks; i++ )
		{
			LinkedNodes[i].UpdateEffects(false);
		}
	}
}

simulated function UpdateShield(bool bPoweredByEnemy)
{
	if (ShieldedEffect != None)
	{
		ShieldedEffect.SetHidden(bPoweredByEnemy);
		if (bPoweredByEnemy)
		{
			ShieldedEffect.DeactivateSystem();
		}
		else
		{
			ShieldedEffect.SetActive(true);
		}
	}
}

simulated function bool BeamEnabled()
{
	return false;
}

/** notify any Kismet events connected to this node that our state has changed */
function SendChangedEvent(Controller EventInstigator)
{
	local int i;
	local UTSeqEvent_OnslaughtNodeEvent NodeEvent;

	for (i = 0; i < GeneratedEvents.length; i++)
	{
		NodeEvent = UTSeqEvent_OnslaughtNodeEvent(GeneratedEvents[i]);
		if (NodeEvent != None)
		{
			NodeEvent.NotifyNodeChanged(EventInstigator);
		}
	}
}

simulated function SetAmbientSound(SoundCue NewAmbientSound)
{
	// if the component is already playing this sound, don't restart it
	if (NewAmbientSound != AmbientSoundComponent.SoundCue)
	{
		AmbientSoundComponent.Stop();
		AmbientSoundComponent.SoundCue = NewAmbientSound;
		if (NewAmbientSound != None)
		{
			AmbientSoundComponent.Play();
		}
	}
}

simulated state ActiveNode
{
	function UpdateCloseActors()
	{
	}

	function bool HasActiveDefenseSystem()
	{
		local int i;

		if ( !bHasSensor )
			return false;

		// only if all linked nodes are friendly or neutral
		for ( i=0; i<NumLinks; i++ )
		{
			if ( LinkedNodes[i].DefenderTeamIndex < 2 && LinkedNodes[i].DefenderTeamIndex != DefenderTeamIndex )
				return false;
		}
		return true;
	}

	simulated function bool BeamEnabled()
	{
		return true;
	}

	simulated function bool HasHealthBar()
	{
		return true;
	}

	function bool LegitimateTargetOf(UTBot B)
	{
		return (DefenderTeamIndex != B.Squad.Team.TeamIndex );
	}

	simulated function BeginState(Name PreviousStateName)
	{
		local int i;

		bIsActive = true;
		SetAmbientSound(ActiveSound);
		NodeState = GetStateName();

		// Update Visuals
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			PlaySound(ConstructedSound, true);

			if ( BeamMaterialInstance == None )
			{
				CreateBeamMaterialInstance();
			}
		}
		UpdateLinks();
		UpdateEffects(true);

		if (Role == ROLE_Authority)
		{
			Scorers.length = 0;
			// Update any vehicle factories in the power radius to be owned by the controlling team
			for ( i=0; i<VehicleFactories.Length; i++ )
			{
				VehicleFactories[i].Activate(DefenderTeamIndex);
			}

			// Update any deploy lockers int he power radius
			for(i=0;i<DeployableLockers.Length;++i)
			{
				DeployableLockers[i].Activate(DefenderTeamIndex);
			}

			// update node teleporters
			for (i = 0; i < NodeTeleporters.length; i++)
			{
				NodeTeleporters[i].SetTeamNum(DefenderTeamIndex);
			}

			// activate node enhancements
			for (i = 0; i < Enhancements.Length; i++)
			{
				Enhancements[i].Activate();
			}

			// activate special objectives
			for (i = 0; i < ActivatedObjectives.length; i++)
			{
				ActivatedObjectives[i].CheckActivate();
			}
		}

		// check if any players are already touching adjacent neutral nodes
		for ( i=0; i<NumLinks; i++ )
		{
			LinkedNodes[i].CheckTouching();
		}

		SendChangedEvent(Constructor);
	}

	simulated function EndState(name NextStateName)
	{
		local int i;

		if ( Role == ROLE_Authority )
		{
			// de-activate node enhancements
			for (i = 0; i < Enhancements.Length; i++)
			{
				Enhancements[i].Deactivate();
			}
		}
		bIsActive = false;
	}
}

simulated state DisabledNode
{
	function Sever() {}

	function SeveredDamage()
	{
		SetTimer(0, false, 'SeveredDamage');
	}

	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{}

	simulated function UpdateShield(bool bPoweredByEnemy)
	{
		if (ShieldedEffect != None)
		{
			ShieldedEffect.DeactivateSystem();
			ShieldedEffect.SetHidden(true);
		}
	}

	simulated event BeginState(Name PreviousStateName)
	{
		local int i;

		bisDisabled = true;
		NodeState = GetStateName();
		SetHidden(True);
		if ( NodeBeamEffect != None )
		{
			NodeBeamEffect.SetHidden(true);
		}
		bForceNetUpdate = TRUE;
		SetCollision(false, false);
		SetTimer(0, false);
		NetUpdateFrequency = 0.1;

		// tell node teleporters they're disabled
		for (i = 0; i < NodeTeleporters.length; i++)
		{
			NodeTeleporters[i].TurnOff();
		}
	}

	simulated event EndState(Name NextStateName)
	{
		SetHidden(default.bHidden);
		bForceNetUpdate = TRUE;
		SetCollision(default.bCollideActors, default.bBlockActors);
		NetUpdateFrequency = default.NetUpdateFrequency;
		bIsDisabled = false;
	}
}

simulated state NeutralNode
{
	function Sever() {}

	function SeveredDamage()
	{
		SetTimer(0, false, 'SeveredDamage');
	}

	function bool Shootable()
	{
		return false;
	}

	function bool TellBotHowToDisable(UTBot B)
	{
		if ( StandGuard(B) )
			return TooClose(B);

		return B.Squad.FindPathToObjective(B, self);
	}


	function bool ValidSpawnPointFor(byte TeamIndex)
	{
		return false;
	}

	function bool LegitimateTargetOf(UTBot B)
	{
		return false;
	}

	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{}

	function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType) { return false; }

	simulated function UpdateShield(bool bPoweredByEnemy)
	{
		if (ShieldedEffect != None)
		{
			ShieldedEffect.DeactivateSystem();
			ShieldedEffect.SetHidden(true);
		}
	}

	simulated event BeginState(Name PreviousStateName)
	{
		NodeState = GetStateName();
		SetAmbientSound(None);
		bIsNeutral = true;
		Health = 0;
		DefenderTeamIndex = 2;

		if (Role == ROLE_Authority)
		{
			bForceNetUpdate = TRUE;
		}
		UpdateLinks();
		UpdateEffects(true);
	}

	simulated function EndState(name NextStateName)
	{
		bIsNeutral = false;
	}

// this is here instead of BeginState() so we don't recurse if an Attach() caused us to enter this state
Begin:
	CheckTouching();
}

function BecomeActive()
{
	if (DefenderTeamIndex < 2)
	{
		BroadcastLocalizedMessage(MessageClass, ActivationMessageIndex + DefenderTeamIndex,,, self);
	}
	GotoState('ActiveNode');

	FindNewObjectives();
}

/** calls FindNewObjectives() on the GameInfo; separated out for subclasses */
function FindNewObjectives()
{
	UTGame(WorldInfo.Game).FindNewObjectives(self);
}

function Reset()
{
	Health = DamageCapacity;
	bForceNetUpdate = TRUE;

	if ( bScriptInitialized )
	{
		SetInitialState();
	}

	UpdateCloseActors();

	SendChangedEvent(None);
}

simulated function bool LinkedTo(UTOnslaughtNodeObjective PC)
{
	return FindNodeLinkIndex(PC) != -1;
}

/** if the given Node is in the LinkedNodes array, returns its index, otherwise INDEX_NONE */
simulated function int FindNodeLinkIndex( UTOnslaughtObjective Node )
{
	local int i;

	if ( Node == None )
	{
		return INDEX_NONE;
	}

	for (i = 0; i < NumLinks; i++)
	{
		if (LinkedNodes[i] == Node)
		{
			return i;
		}
	}

	return INDEX_NONE;
}

/** applies any scaling factors to damage we're about to take */
simulated function ScaleDamage(out int Damage, Controller InstigatedBy, class<DamageType> DamageType)
{
	if (class<UTDamageType>(DamageType) != None)
	{
		Damage *= class<UTDamageType>(DamageType).default.NodeDamageScaling;
	}
	//@note: DamageScaling isn't replicated, so this part doesn't work on clients
	if (Role == ROLE_Authority && InstigatedBy != None && InstigatedBy.Pawn != None)
	{
		Damage *= instigatedBy.Pawn.GetDamageScaling();
	}
}

function ScoreDamage(UTOnslaughtPRI AttackerPRI, float Damage)
{
	if ( AttackerPRI != None )
	{
		AttackerPRI.AddDamageBonus(Score*Damage/DamageCapacity);
	}
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (Damage <= 0 || WorldInfo.Game.bGameEnded || UTGame(WorldInfo.Game).ResetCountdown > 0)
		return;

	ScaleDamage(Damage, InstigatedBy, DamageType);

	if (InstigatedBy == None || (InstigatedBy.GetTeamNum() != DefenderTeamIndex && PoweredBy(InstigatedBy.GetTeamNum())))
	{
		SetUnderAttack(true);
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			BecameUnderAttack();
		}
		bForceNetUpdate = true;
		if (InstigatedBy != None)
		{
			LastDamagedBy = UTPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo);
			LastAttacker = InstigatedBy.Pawn;
			ScoreDamage(UTOnslaughtPRI(LastDamagedBy), FMin(Health, Damage));
		}

		// check any Kismet events
		Super(Actor).TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

		Health -= Damage;
		if (Health <= 0)
		{
			if ( UTPlayerController(InstigatedBy) != None )
			{
				if ( (class<UTDamageType>(DamageType) != None) && class<UTDamageType>(DamageType).default.bSelfDestructDamage )
				{
					PlayerController(InstigatedBy).ReceiveLocalizedMessage( class'UTWeaponKillRewardMessage', 1 );
				}
				else
				{
					UTPlayerController(InstigatedBy).ClientMusicEvent(DestroyedStinger);
				}
			}
			DisableObjective(InstigatedBy);
		}
		else
		{
			BroadcastAttackNotification(InstigatedBy);
		}
	}
	else if ( (PlayerController(InstigatedBy) != None) && !WorldInfo.GRI.OnSameTeam(InstigatedBy,self) )
	{
		PlayerController(InstigatedBy).ReceiveLocalizedMessage(MessageClass, 5);

		// play 'can't attack' sound if player keeps shooting at us
		ShieldDamageCounter += Damage;
		if (ShieldDamageCounter > 200)
		{
			PlayerController(InstigatedBy).ClientPlaySound(ShieldHitSound);
			ShieldDamageCounter -= 200;
		}
	}
}

function BroadcastAttackNotification(Controller InstigatedBy)
{
	//attack notification
	if (LastAttackMessageTime + 1 < WorldInfo.TimeSeconds)
	{
		if ( PrimeCore != None )
		{
			BroadcastLocalizedMessage(MessageClass, 9 + DefenderTeamIndex,,, self);
		}
		if ( (InstigatedBy != None) && (InstigatedBy.Pawn != None) )
			UTTeamInfo(WorldInfo.GRI.Teams[DefenderTeamIndex]).AI.CriticalObjectiveWarning(self, InstigatedBy.Pawn);
		LastAttackMessageTime = WorldInfo.TimeSeconds;
	}
	LastAttackTime = WorldInfo.TimeSeconds;
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if (Health <= 0 || Health >= DamageCapacity || Amount <= 0 || LinkHealMult <= 0.0 || (Healer != None && !TeamLink(Healer.GetTeamNum())))
	{
		return false;
	}

	Amount = Min(Amount * LinkHealMult, DamageCapacity - Health);
	Health += Amount;

	if (Health >= DamageCapacity)
	{
		PlaySound(HealedSound);
	}
	if (Healer != None && UTOnslaughtPRI(Healer.PlayerReplicationInfo) != None)
	{
		UTOnslaughtPRI(Healer.PlayerReplicationInfo).AddHealBonus(2*Score*float(Amount)/DamageCapacity);
	}

	bForceNetUpdate = TRUE;
	HealingTime = WorldInfo.TimeSeconds;
	LastHealedBy = Healer;

	if (HealEffect == None && DefenderTeamIndex < 2 && HealEffectClasses[DefenderTeamIndex] != None)
	{
		HealEffect = Spawn(HealEffectClasses[DefenderTeamIndex], self);
	}
	SetAmbientSound(HealingSound);

	SetTimer(0.5, false, 'CheckHealing');
	return true;
}

simulated function CheckHealing()
{
	if (WorldInfo.TimeSeconds - HealingTime >= 0.5)
	{
		if (HealEffect != None)
		{
			HealEffect.ShutDown();
			HealEffect = None;
		}
		SetAmbientSound(bIsActive ? ActiveSound : None);
	}
	else
	{
		SetTimer(0.5 - WorldInfo.TimeSeconds + HealingTime, false, 'CheckHealing');
	}
}

function bool LinkedToCoreConstructingFor(byte Team)
{
	local int i;

	for ( i=0; i<NumLinks; i++ )
		if (LinkedNodes[i].DefenderTeamIndex == Team && LinkedNodes[i].bIsConstructing)
			return true;

	return false;
}

/** notify actors associated with this node that it has been destroyed/disabled */
function UpdateCloseActors()
{
	local int i;

	for ( i=0; i<VehicleFactories.Length; i++ )
	{
		VehicleFactories[i].Deactivate();
	}

	for (i = 0; i < NodeTeleporters.length; i++)
	{
		NodeTeleporters[i].SetTeamNum(255);
	}

	// deactivate special objectives
	for (i = 0; i < ActivatedObjectives.length; i++)
	{
		ActivatedObjectives[i].CheckActivate();
	}

	for(i=0; i<DeployableLockers.length;++i)
	{
		DeployableLockers[i].Deactivate();
	}

	FindNewHomeForFlag();
}

/** if a flag's homebase is linked to this node, find a new homebase for it */
function FindNewHomeForFlag()
{
	local UTOnslaughtFlagBase NewFlagBase;

	if (FlagBase != None && FlagBase.myFlag != None)
	{
		NewFlagBase = FlagBase.myFlag.FindNearestFlagBase(self);
		if (NewFlagBase == None)
		{
			NewFlagBase = FlagBase.myFlag.StartingHomeBase;
		}
		if (NewFlagBase != FlagBase.myFlag.HomeBase)
		{
			FlagBase.myFlag.HomeBase = NewFlagBase;
			NewFlagBase.myFlag = FlagBase.myFlag;
			if (FlagBase.myFlag.bHome)
			{
				FlagBase.myFlag.SetLocation(NewFlagBase.Location + (FlagBase.myFlag.HomeBaseOffset >> FlagBase.Rotation));
				FlagBase.myFlag.SetRotation(NewFlagBase.Rotation);
				NewFlagBase.ObjectiveChanged();
			}
			FlagBase.myFlag.bForceNetUpdate = TRUE;
			FlagBase.myFlag = None;
			FlagBase.HideOrb();
		}
	}
}

function float GetSpawnRating(byte EnemyTeam)
{
	// don't spawn at standalone nodes if no vehicles
	return (bStandalone && GetBestAvailableVehicleRating() <= 0.0) ? 255.0 : Super.GetSpawnRating(EnemyTeam);
}

// Returns a rating based on nearby vehicles
function float RateCore()
{
	local int i;
	local float Result;

	for ( i=0; i<VehicleFactories.Length; i++ )
	{
		if ( VehicleFactories[i].VehicleClass != None )
		{
			Result += VehicleFactories[i].VehicleClass.Default.MaxDesireability * VehicleFactories[i].VehicleClass.Default.MaxDesireability;
			if ( VehicleFactories[i].VehicleClass.Default.MaxDesireability > 0.6 )
				Result += 0.5;
		}
	}
	return Result;
}

function float TeleportRating(Controller Asker, byte AskerTeam, byte SourceDist)
{
	local int i;
	local UTBot B;
	local float Rating;

	B = UTBot(Asker);
	for ( i=0; i<VehicleFactories.Length; i++ )
	{
		if ( (VehicleFactories[i].ChildVehicle != None) && VehicleFactories[i].ChildVehicle.bTeamLocked && !VehicleFactories[i].ChildVehicle.SpokenFor(Asker) )
		{
			if (B == None)
				Rating = FMax(Rating, VehicleFactories[i].ChildVehicle.MaxDesireability);
			else
				Rating = FMax(Rating, B.Squad.VehicleDesireability(VehicleFactories[i].ChildVehicle, B));
		}
	}
	return (Rating - (FinalCoreDistance[Abs(1 - AskerTeam)] - SourceDist) * 0.1);
}

function bool HasUsefulVehicles(Controller Asker)
{
	local int i;
	local UTBot B;

	B = UTBot(Asker);
	for ( i=0; i<VehicleFactories.Length; i++ )
	{
		if ( (VehicleFactories[i].ChildVehicle != None) && VehicleFactories[i].ChildVehicle.bTeamLocked
			&& (B == None || B.Squad.VehicleDesireability(VehicleFactories[i].ChildVehicle, B) > 0) )
		{
			return true;
		}
	}
	return false;
}

function Actor GetAutoObjectiveActor(UTPlayerController PC)
{
	local int i;
	local UTOnslaughtSpecialObjective Best;

	// redirect to required special objective if necessary
	for (i = 0; i < ActivatedObjectives.Length; i++)
	{
		if ( ActivatedObjectives[i].bMustCompleteToAttackNode && ActivatedObjectives[i].IsActive() &&
			(Best == None || ActivatedObjectives[i].DefensePriority > Best.DefensePriority) )
		{
			Best = ActivatedObjectives[i];
		}
	}

	return (Best != None) ? Best : Super.GetAutoObjectiveActor(PC);
}

function bool TellBotHowToDisable(UTBot B)
{
	local UTVehicle VehicleEnemy;

	if (DefenderTeamIndex == B.Squad.Team.TeamIndex)
		return false;
	if (!PoweredBy(B.Squad.Team.TeamIndex))
	{
		if (B.CanAttack(self))
			return false;
		else
			return B.Squad.FindPathToObjective(B, self);
	}

	//take out defensive turrets first
	VehicleEnemy = UTVehicle(B.Enemy);
	if ( VehicleEnemy != None && (VehicleEnemy.bStationary || VehicleEnemy.bIsOnTrack) &&
		(VehicleEnemy.AIPurpose == AIP_Defensive || VehicleEnemy.AIPurpose == AIP_Any) && B.LineOfSightTo(B.Enemy) )
	{
		return false;
	}

	if ( StandGuard(B) )
		return TooClose(B);

	if ( !B.Pawn.bStationary && B.Pawn.TooCloseToAttack(self) )
	{
		B.GoalString = "Back off from objective";
		B.RouteGoal = B.FindRandomDest();
		B.MoveTarget = B.RouteCache[0];
		B.SetAttractionState();
		return true;
	}
	else if ( B.CanAttack(self) )
	{
		if (KillEnemyFirst(B))
			return false;

		B.GoalString = "Attack Objective";
		B.DoRangedAttackOn(self);
		return true;
	}
	MarkShootSpotsFor(B.Pawn);
	return Super.TellBotHowToDisable(B);
}

function bool KillEnemyFirst(UTBot B)
{
	if ( !bUnderAttack || Health < DamageCapacity * 0.2
	     || (UTVehicle(B.Pawn) != None && UTVehicle(B.Pawn).HasOccupiedTurret()) )
	{
		return false;
	}
	else if (B.Enemy != None && B.Enemy.Controller != None 
		&& ((B.Enemy.Controller.Focus == B.Pawn) || (B.LastUnderFire > WorldInfo.TimeSeconds - 1.5))
		&& B.Enemy.CanAttack(B.Pawn) )
	{
		return true;
	}
	
	
	if ( WorldInfo.TimeSeconds - HealingTime < 1.0 && LastHealedBy != None && LastHealedBy.Pawn != None &&
		LastHealedBy.Pawn.Health > 0 && B.Squad.SetEnemy(B, LastHealedBy.Pawn) && B.Enemy == LastHealedBy.Pawn )
	{
		//attack enemy healing me
		return true;
	}
	else
	{
		return false;
	}
}

function bool NearObjective(Pawn P)
{
	if (P.CanAttack(self))
		return true;

	return (VSize(Location - P.Location) < BaseRadius && P.LineOfSightTo(self));
}

singular function CheckTouching()
{
    	local Pawn P;

    	foreach BasedActors(class'Pawn', P)
    	{
    		Attach(P);
    		return;
    	}

    	foreach TouchingActors(class'Pawn', P)
    	{
    		Touch(P, None, P.Location, vect(0,0,1));
    		return;
    	}
}

function SeveredDamage()
{
	if ( !bSevered )
	{
		SetTimer(0, false, 'SeveredDamage');
		return;
	}

	Health -= SeveredDamagePerSecond;
	if (Health <= 0)
	{
		DisableObjective(None);
	}
	bForceNetUpdate = TRUE;
	SetTimer(1.0, true, 'SeveredDamage');
}

simulated function bool HasHealthBar()
{
	return false;
}

simulated native function RenderMyLinks( UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, float ColorPercent );

simulated function RenderExtraDetails( UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, float ColorPercent, bool bSelected )
{
	local string ObjName;
	local float xl,yl;

	if (bSelected)
	{
		DrawMapSelection(MP,Canvas,PlayerOwner);
	}

	ObjName = GetHumanReadableName();
	Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(0);
	Canvas.StrLen(ObjName,xl,yl);
	if ( bFullScreenNameAboveIcon )
	{
		Canvas.SetPos( HUDLocation.X - 0.5*XL, HUDLocation.Y - 12*MP.MapScale);
	}
	else
	{
		Canvas.SetPos( HUDLocation.X - 0.5*XL, HUDLocation.Y + 8*MP.MapScale);
	}

	Canvas.DrawColor = class'UTHUD'.default.BlackColor;
	Canvas.DrawRect(XL,YL);
	Canvas.DrawColor = class'UTHUD'.default.WhiteColor;
	if ( bFullScreenNameAboveIcon )
	{
		Canvas.SetPos( HUDLocation.X - 0.5*XL, HUDLocation.Y - 12*MP.MapScale);
	}
	else
	{
		Canvas.SetPos( HUDLocation.X - 0.5*XL, HUDLocation.Y + 8*MP.MapScale);
	}
	Canvas.DrawText(ObjName);
}


function DisableObjective(Controller InstigatedBy)
{
	local PlayerReplicationInfo	PRI;

	if ( InstigatedBy != None )
	{
		Instigator = InstigatedBy.Pawn;
		PRI = InstigatedBy.PlayerReplicationInfo;
	}
	else
	{
		PRI = LastDamagedBy;
	}

	BroadcastLocalizedMessage(MessageClass, DestructionMessageIndex + DefenderTeamIndex, PRI,, self);

	if ( DefenderTeamIndex > 1 )
		`log("DisableObjective called with DefenderTeamIndex="$DefenderTeamIndex$" in state "$GetStateName());

	GotoState('ObjectiveDestroyed');
}

simulated state ObjectiveDestroyed
{
	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{}

	simulated event bool IsCurrentlyDestroyed()
	{
		return true;
	}

	function SeveredDamage()
	{
		SetTimer(0, false, 'SeveredDamage');
	}

	function Timer()
	{
		GotoState('NeutralNode');
	}

	simulated function UpdateShield(bool bPoweredByEnemy)
	{
		if (ShieldedEffect != None)
		{
			ShieldedEffect.DeactivateSystem();
			ShieldedEffect.SetHidden(true);
		}
	}

	simulated function BeginState(Name PreviousStateName)
	{
		local PlayerController PC;
		local UTBot B;

		SetAmbientSound(None);
		UpdateLinks();
		UpdateEffects(true);

		if ( Role < ROLE_Authority )
			return;

		Health = 0;
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			ForEach LocalPlayerControllers(class'PlayerController', PC)
				break;
			if (PC != None)
				PC.ClientPlaySound(DestroyedSound);
			else
				PlaySound(DestroyedSound);
		}

		SendChangedEvent(Instigator != None ? Instigator.Controller : None);

		bForceNetUpdate = TRUE;
		Scorers.length = 0;
		UpdateCloseActors();
		DefenderTeamIndex = 2;
		SetTimer(0.2, false);

		UTGame(WorldInfo.Game).ObjectiveDisabled(Self);
		FindNewObjectives();
		NodeState = GetStateName();

		// make sure any bots stop shooting at me
		foreach WorldInfo.AllControllers(class'UTBot', B)
		{
			if (B.Focus == self && B.IsShootingObjective())
			{
				B.StopFiring();
				B.WhatToDoNext();
			}
		}
	}
}

function bool TeleportTo(UTPawn Traveler)
{
	local NavigationPoint BestStart;
	local float BestRating, NewRating;
	local vector PrevPosition;
	local int i;
	local rotator NewRotation;
	local UTOnslaughtNodeTeleporter Teleporter;

	// Check to see if the teleport is valid
	if ( Traveler.Controller != none && ValidSpawnPointFor( Traveler.GetTeamNum() ) )
	{
		for (i = 0; i < PlayerStarts.length; i++)
		{
			NewRating = WorldInfo.Game.RatePlayerStart(PlayerStarts[i],Traveler.GetTeamNum(),Traveler.Controller);
			if ( NewRating > BestRating )
			{
				BestRating = NewRating;
				BestStart = PlayerStarts[i];
			}
		}

		if (BestStart != None)
		{
			// if a teleporter was used, update its destination
			if (UTOnslaughtGame(WorldInfo.Game) != None && UTOnslaughtGame(WorldInfo.Game).IsTouchingNodeTeleporter(Traveler, Teleporter))
			{
				Teleporter.SetLastDestination(BestStart);
			}
			PrevPosition = Traveler.Location;
			Traveler.SetLocation(BestStart.Location);
			Traveler.DoTranslocate(PrevPosition);
			NewRotation = BestStart.Rotation;
			NewRotation.Roll = 0;
			Traveler.Controller.ClientSetRotation(NewRotation);

			if (UTBot(Traveler.Controller) != None && UTOnslaughtPRI(Traveler.PlayerReplicationInfo) != None)
			{
				UTOnslaughtPRI(Traveler.PlayerReplicationInfo).SetStartObjective(self, false);
			}

			return true;
		}
	}
	return false;
}

defaultproperties
{
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=1

	FinalCoreDistance[0]=255
	FinalCoreDistance[1]=255
	ConstructionTime=30.0

	DamageCapacity=4500
	Score=6
	DefensePriority=2
	DefenderTeamIndex=2
	DestructionMessageIndex=14
	ActivationMessageIndex=2

	bSevered=False
	SeveredDamagePerSecond=100

	bPathColliding=true

	bStatic=False
	bNoDelete=True
	LinkHealMult=0.0

	bDestinationOnly=true
	bNotBased=True
	bCollideActors=True
	bCollideWorld=True
	bIgnoreEncroachers=True
	bBlockActors=True
	bProjTarget=True
	bHidden=False
	DestroyedEvent(0)="red_powercore_destroyed"
	DestroyedEvent(1)="blue_powercore_destroyed"
	DestroyedEvent(2)="red_constructing_powercore_destroyed"
	DestroyedEvent(3)="blue_constructing_powercore_destroyed"
	ConstructedEvent(0)="red_powercore_constructed"
	ConstructedEvent(1)="blue_powercore_constructed"
	bBlocksTeleport=true
	bHasSensor=true
	bCanWalkOnToReach=true
	MaxBeaconDistance=4000.0

	BeamColor(0)=(R=1.5,G=0.7,B=0.7)
	BeamColor(1)=(R=0.2,G=0.7,B=4.0)
	BeamColor(2)=(R=0.75,G=1.0,B=1.0)
	GodBeamAttackParameterName=GodBeamAttack
	AttackEffectCurve=(Points=((InVal=0.0,OutVal=1.0),(InVal=0.4,OutVal=5.0),(InVal=1.0,OutVal=1.0)))

	Components.Remove(Sprite)
	Components.Remove(Sprite2)
	GoodSprite=None
	BadSprite=None

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0120.000000
		CollisionHeight=+0150.000000
	End Object

	Begin Object Class=LinkRenderingComponent Name=LinkRenderer
		HiddenGame=True
	End Object
	Components.Add(LinkRenderer)

	Begin Object Class=AudioComponent Name=AmbientComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
	End Object
	AmbientSoundComponent=AmbientComponent
	Components.Add(AmbientComponent)
	SupportedEvents.Add(class'UTSeqEvent_OnslaughtNodeEvent')
	StandaloneSpawnPriority=255
	DestroyedStinger=6
	LinkLineTexture=Texture2D'UI_HUD.HUD.T_UI_HUD_WARNodeLine'
}
