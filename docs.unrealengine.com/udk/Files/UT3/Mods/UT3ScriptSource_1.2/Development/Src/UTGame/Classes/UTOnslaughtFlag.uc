/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTOnslaughtFlag extends UTCarriedObject
	native(Onslaught)
	abstract;

var StaticMeshComponent Mesh;
var		Material				FlagMaterials[2];
var		ParticleSystem			FlagEffect[2];
var		ParticleSystemComponent	FlagEffectComp;

var		color					LightColors[2];

/** if a teammate is within this range when the orb would be returned, it halts the timer at zero to give them a final chance to grab it */
var float GraceDist;

var UTOnslaughtGodBeam MyGodBeam;

/** keeps track of starting home base for round resets,
 * as HomeBase changes depending on the closest friendly base when the flag gets returned
 */
var UTOnslaughtFlagBase StartingHomeBase;

var class<UTOnslaughtGodBeam> GodBeamClass;

var float MaxSpringDistance;
var vector OldLocation;

/** teamcolored effect played when we are returned */
var class<UTReplicatedEmitter> ReturnedEffectClasses[2];

/** normal orb scale */
var float NormalOrbScale;
/** scale when rebuilding/at home */
var float HomeOrbScale;
/** scale when viewed by player holding orb and driving hoverboard */
var float HoverboardOrbScale;

/** How long to wait before building power orb */
var float Prebuildtime, BuildTime;

/** remaining time (in real seconds) orb can be on the ground before it gets returned */
var byte RemainingDropTime;

/** Time when orb building started */
var repnotify float BuildStartTime;

var UTGameObjective LastNearbyObjective;

var float LastIncomingWarning;

var float LastGraceDistance;

/** currently locked node */
var UTOnslaughtPowerNode LockedNode;

/** When held, monitor last time it was used usefully, and auto-return if player isn't doing anything with orb. */
var float LastUsefulTime;

/** max time before auto-return unused orb (note that locking a vulnerable node counts as use) */
var float MaxHoldTime;

/** Don't let auto-return player pick it up again unless at least 30 seconds have passed. */
var PlayerReplicationInfo LastForcedReturnPRI;
var float LastForcedReturnTime;

/** Hide orb if closer than this, to avoid camera clipping */
var float OrbMinViewDist;

/** Use pictograph distance - show pictograph to use enemy orb if within this distance */
var float UsePictographDistSq;

/** Coordinates for the tooltip textures */
var UIRoot.TextureCoordinates ToolTipIconCoords;

/** How long before rebuilding orb if enemy returns it */
var float EnemyReturnPrebuildTime;

var localized string OrbString;

/** Used for failsafe check if orb should be unhidden */
var int HomeHiddenCount;

/** set when rebuilding and finished prebuild delay */
var repnotify bool bFinishedPreBuild;



replication
{
	if (bNetDirty)
		RemainingDropTime, LockedNode, BuildStartTime, bFinishedPreBuild;
}

simulated function PostBeginPlay()
{
	local UTPlayerController PC;

	Super.PostBeginPlay();

	// add to local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'UTPlayerController', PC)
	{
		if ( UTHUD(PC.MyHUD) != None )
		{
			UTHUD(PC.MyHUD).AddPostRenderedActor(self);
		}
		PC.PotentiallyHiddenActors[PC.PotentiallyHiddenActors.Length] = self;
	}
}

/** returns true if should be rendered for passed in player */
simulated function bool ShouldMinimapRenderFor(PlayerController PC)
{
	return (PC.PlayerReplicationInfo.Team == Team);
}

/** If being rebuilt, Draw partial icon to reflect that orb is building */
simulated function DrawIcon(Canvas Canvas, vector IconLocation, float IconWidth, float IconAlpha)
{
	local float YoverX, TimerPct;

	if ( (Holder != None) || (RemainingDropTime > 0) )
	{
		BuildStartTime = 0;
	}
	if ( Worldinfo.TimeSeconds - BuildStartTime < PreBuildTime + BuildTime )
	{
		TimerPct = FClamp((Worldinfo.TimeSeconds - BuildStartTime)/(PreBuildTime + BuildTime), 0.0, 1.0);
		YoverX = IconCoords.VL / IconCoords.UL;

		// draw low alpha backdrop
		Canvas.SetPos(IconLocation.X - 0.5*IconWidth, IconLocation.Y - 0.5*IconWidth * YoverX);
		Canvas.DrawColorizedTile(IconTexture, IconWidth, IconWidth * YoverX,
									IconCoords.U,IconCoords.V, IconCoords.UL, IconCoords.VL, MakeLinearColor(0.1,0.1,0,0.1*IconAlpha));

		// draw build pct
		Canvas.SetPos(IconLocation.X - 0.5*IconWidth, IconLocation.Y - 0.5*IconWidth * YoverX + (1 - TimerPct) * IconWidth * YoverX);
		Canvas.DrawColorizedTile(IconTexture, IconWidth, IconWidth * YoverX * TimerPct,	IconCoords.U, IconCoords.V + (1.0-TimerPct) * IconCoords.UL, IconCoords.UL, TimerPct * IconCoords.VL, MakeLinearColor(1,1,0,IconAlpha));
	}
	else
	{
		super.DrawIcon(Canvas, IconLocation, IconWidth, IconAlpha);
	}
}

simulated function RenderEnemyMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner, UTGameObjective NearbyObjective)
{
	local float YoverX,IconWidth;
	local float CurrentScale;
	local LinearColor DrawColor;

	if ( (HolderPRI != None)
		&& (WorldInfo.TimeSeconds - LastIncomingWarning > 15.0 || LastNearbyObjective == None)
		&& (NearbyObjective != None)
		&& (VSize(PlayerOwner.ViewTarget.Location - NearbyObjective.Location) < 1.5 * NearbyObjective.MaxSensorRange) )
	{
		LastIncomingWarning = WorldInfo.TimeSeconds;
		PlayerOwner.ReceiveLocalizedMessage(MessageClass, 14, HolderPRI, None, Team);
	}
	LastNearbyObjective = NearbyObjective;

	if ( HighlightScale > 1.0 )
	{
		CurrentScale = (WorldInfo.TimeSeconds - LastHighlightUpdate)/HighlightSpeed;
		HighlightScale = FMax(1.0, HighlightScale - CurrentScale * MaxHighlightScale);
		CurrentScale = HighlightScale;
	}
	else
	{
		CurrentScale = 1.0;
	}

	IconWidth = IconCoords.UL * (Canvas.ClipY / 768) * MapSize * CurrentScale * 0.33;
	YoverX = IconCoords.VL / IconCoords.UL;
	Canvas.SetPos(HudLocation.X - 0.5 * IconWidth, HudLocation.Y - 0.5 * IconWidth * YoverX);
	DrawColor = ((Team == None) || (Team.TeamIndex == 0)) ? class'UTHUD'.default.RedLinearColor : class'UTHUD'.default.BlueLinearColor;
	Canvas.DrawColorizedTile(IconTexture, IconWidth, IconWidth * YoverX , IconCoords.U, IconCoords.V, IconCoords.UL, IconCoords.VL, DrawColor);
}

simulated function RenderMapIcon(UTMapInfo MP, Canvas Canvas, UTPlayerController PlayerOwner)
{
	local float CurrentScale;

	if ( HighlightScale > 1.0 )
	{
		CurrentScale = (WorldInfo.TimeSeconds - LastHighlightUpdate)/HighlightSpeed;
		HighlightScale = FMax(1.0, HighlightScale - CurrentScale * MaxHighlightScale);
		CurrentScale = HighlightScale;
	}
	else
	{
		CurrentScale = 1.0;
	}

	DrawIcon(Canvas, HUDLocation, IconCoords.UL * (Canvas.ClipY / 768) * MapSize * CurrentScale * 0.33, 1.0);
}

simulated native function NativePostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir);

//Draw the "destroy enemy orb" pictograph
simulated event DrawUsePictograph(PlayerController PC, Canvas Canvas)
{
	local UTHUD myHUD;
	myHUD = UTHud(PC.myHUD);
	myHUD.DrawToolTip(Canvas, PC, "GBA_Use", Canvas.ClipX * 0.5, Canvas.ClipY * 0.6, ToolTipIconCoords.U, ToolTipIconCoords.V, ToolTipIconCoords.UL, ToolTipIconCoords.VL, Canvas.ClipY / 768, myHUD.AltHudTexture);
}

/**
PostRenderFor()
Hook to allow objectives to render HUD overlays for themselves.
Called only if objective was rendered this tick.
Assumes that appropriate font has already been set
*/
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	local float XL, YL, BeaconPulseScale, ScreenOffset, IconYL, InvDist, TextScale;
	local vector ScreenLoc, IconLoc;
	local string NodeString;
	local LinearColor TeamColor;
	local Color TextColor;
	local float Dist;

	// failsafe check that orb is rendered
	if (bHome && bFinishedPreBuild && bHidden)
	{
		if ( (UTOnslaughtFlagBase(HomeBase) != None) && !UTOnslaughtFlagBase(HomeBase).bPlayOrbBuilding )
		{
			HomeHiddenCount++;

			if ( HomeHiddenCount > 20 )
			{
				SetHidden(false);
				HomeHiddenCount = 0;
			}
		}
		else
		{
			HomeHiddenCount = 0;
		}
	}
	else
	{
		HomeHiddenCount = 0;
	}

	ScreenOffset = (RemainingDropTime > 0) ? 50 : 100;

	Dist = VSize(Location - CameraPosition);
	ScreenOffset += 0.1*Dist;
	screenLoc = Canvas.Project(Location + ScreenOffset * vect(0,0,1));

	// make sure not clipped out
	if (screenLoc.X < 0 ||
		screenLoc.X >= Canvas.ClipX ||
		screenLoc.Y < 0 ||
		screenLoc.Y >= Canvas.ClipY)
	{
		return;
	}

	// pulse "key" objective
	BeaconPulseScale = UTPlayerController(PC).BeaconPulseScale;

	class'UTHUD'.Static.GetTeamColor( GetTeamNum(), TeamColor, TextColor);

	InvDist = 1.0/VSize(Location - CameraPosition);
	TeamColor.A = LocalPlayer(PC.Player).GetActorVisibility(bHome ? HomeBase : self)
					? FClamp(1800*InvDist,0.35, 1.0)
					: 0.2;

	IconYL = 0.2 * FClamp(300.0*InvDist, 0.25, 0.5) * BeaconPulseScale * Canvas.ClipY;

	// make sure not clipped out
	screenLoc.X = FClamp(screenLoc.X, 0.7*IconYL, Canvas.ClipX-0.7*IconYL-1);
	screenLoc.Y = FClamp(screenLoc.Y, 1.8*IconYL, Canvas.ClipY-1.8*IconYL-1);

	// fade if close to crosshair
	if (screenLoc.X > 0.45*Canvas.ClipX &&
	  screenLoc.X < 0.55*Canvas.ClipX &&
	  screenLoc.Y > 0.45*Canvas.ClipY &&
	  screenLoc.Y < 0.55*Canvas.ClipY)
	{
	  TeamColor.A = FMax(0.2, TeamColor.A * FMax(FMin(1.0, FMax(0.5,Abs(screenLoc.X - 0.5*Canvas.ClipX) - 0.025*Canvas.ClipX)/(0.025*Canvas.ClipX)), FMin(1.0, FMax(0.5, Abs(screenLoc.Y - 0.5*Canvas.ClipY)-0.025*Canvas.ClipX)/(0.025*Canvas.ClipY))));
	}

	class'UTHUD'.static.DrawBackground(ScreenLoc.X - 0.7*IconYL,ScreenLoc.Y - 0.8*IconYL, 1.4*IconYL, 1.6*IconYL, TeamColor, Canvas);

	Canvas.DrawColor = TextColor;
	Canvas.DrawColor.A = 255.0 * TeamColor.A;

	IconLoc = ScreenLoc;
	IconLoc.Y = IconLoc.Y;

	if ( RemainingDropTime > 0 )
	{
		DrawIcon(Canvas, IconLoc, IconYL * 0.7, 0.5 * TeamColor.A);

		Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(1);
		NodeString = string(RemainingDropTime);
		Canvas.StrLen(NodeString, XL, YL);
		TextScale = 0.6 * IconYL/YL;

		Canvas.DrawColor = class'UTHUD'.default.BlackColor;
		Canvas.DrawColor.A = 255.0 * TeamColor.A;

		Canvas.SetPos(2+ScreenLoc.X-0.5*TextScale*XL, 2+IconLoc.Y - 0.5*TextScale*YL);
		Canvas.DrawTextClipped(NodeString, true, TextScale, TextScale);

		Canvas.DrawColor = class'UTHUD'.default.WhiteColor;
		Canvas.DrawColor.A = 255.0 * TeamColor.A;

		Canvas.SetPos(ScreenLoc.X-0.5*TextScale*XL, IconLoc.Y - 0.5*TextScale*YL);
		Canvas.DrawTextClipped(NodeString, true, TextScale, TextScale);
		Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(0);
	}
	else
	{
		DrawIcon(Canvas, IconLoc, IconYL * 0.7, TeamColor.A);
	}
}

function SendFlagMessage(Controller C)
{
	if ( UTBot(C) != None )
	{
		// delay sending flag message till bot decides what to do with it
		UTBot(C).bSendFlagMessage = true;
		return;
	}
	C.SendMessage(None, 'HOLDINGFLAG', 10);
}

// For onslaught orbs, only send picked up from base messages to same team or if orb visible
function BroadcastTakenFromBaseMessage(Controller EventInstigator)
{
	BroadcastLocalizedTeamMessage(Team.TeamIndex, MessageClass, 6 + 7 * GetTeamNum(), EventInstigator.PlayerReplicationInfo, None, Team);
}

function Reset()
{
	Super.Reset();
	UTOnslaughtFlagBase(HomeBase).myFlag = None;
	HomeBase = StartingHomeBase;
	StartingHomeBase.myFlag = self;
	Global.SendHome(None);
	bForceNetUpdate = TRUE;
}

function SetTeam(int TeamIndex)
{
	Team = UTOnslaughtGame(WorldInfo.Game).Teams[TeamIndex];
	Team.TeamFlag = self;
	UpdateTeamEffects();
}

simulated function NotifyLocalPlayerTeamReceived()
{
	UpdateTeamEffects();
}

/* epic ===============================================
* ::ReplicatedEvent
*
* Called when a variable with the property flag "RepNotify" is replicated
*
* =====================================================
*/
simulated event ReplicatedEvent(name VarName)
{
	local UTOnslaughtFlagBase ONSBase;

	if (VarName == 'Team')
	{
		UpdateTeamEffects();
	}
	else if (VarName == 'BuildStartTime')
	{
		BuildStartTime = WorldInfo.TimeSeconds;
	}
	else
	{
		if (VarName == 'bHome' || (VarName == 'bFinishedPreBuild' && bHome && bFinishedPreBuild))
		{
			// make sure home base animation is correctly updated
			ONSBase = UTOnslaughtFlagBase(HomeBase);
			if (ONSBase != None)
			{
				ONSBase.OrbHomeStatusChanged();
			}
		}
		Super.ReplicatedEvent(VarName);
	}
}

simulated function ClientReturnedHome()
{
	Super.ClientReturnedHome();

	LastNearbyObjective = None;
}

simulated function UpdateTeamEffects()
{
	local PlayerController PC;

	if ( Team == None )
		return;

	// give flag appropriate color
	if (Team.TeamIndex < 2)
	{
		Mesh.SetMaterial(1,FlagMaterials[Team.TeamIndex]);
		FlagLight.SetLightProperties(, LightColors[Team.TeamIndex]);
		FlagEffectComp.SetTemplate(FlagEffect[Team.TeamIndex]);
		FlagEffectComp.SetActive(true);
	}

	// god beam only visible to same team
	if ( WorldInfo.GRI != None )
	{
		foreach LocalPlayerControllers(class'PlayerController', PC)
		{
			if ( WorldInfo.GRI.OnSameTeam(self, PC) )
			{
				if ( MyGodBeam == None )
				{
					// create godbeam;
					MyGodBeam = spawn(GodBeamClass);
					MyGodBeam.SetBase(self);
				}
				return;
			}
		}
	}
	if ( MyGodBeam != None )
		MyGodBeam.Destroy();
}

simulated event Destroyed()
{
	Super.Destroyed();

	if (MyGodBeam != None)
	{
		MyGodBeam.Destroy();
	}
}

simulated event SetOrbTeam()
{
	if (Team == None && Role == ROLE_Authority)
	{
		Team = UTOnslaughtGame(WorldInfo.Game).Teams[HomeBase.GetTeamNum()];
	}
}

simulated native function byte GetTeamNum();

function bool ValidHolder(Actor Other)
{
	if ( bHome && (WorldInfo.TimeSeconds - LastForcedReturnTime < 30) )
	{
		// make sure it's not the same guy that never used it
		if ( (Pawn(Other) != None) && (Pawn(Other).PlayerReplicationInfo == LastForcedReturnPRI) )
		{
			if ( UTPlayerController(Pawn(Other).Controller) != None )
			{
				UTPlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(MessageClass, 18, HolderPRI, None, Team);
			}
			return false;
		}
	}

	if ( !Super.ValidHolder(Other) )
	{
		return false;
	}

	return WorldInfo.GRI.OnSameTeam(self,Pawn(Other).Controller);
}

function SetHolder(Controller C)
{
	Super.SetHolder(C);

	if ( UTPawn(C.Pawn) != None )
		UTPawn(C.Pawn).bJustDroppedOrb = false;
	LastUsefulTime = WorldInfo.TimeSeconds;
}

function Drop(optional Controller Killer)
{
	Super.Drop(Killer);

	// Super clobbers the rotation rate, so put it back
	RotationRate = default.RotationRate;
}

// States

/** called to send the flag to its home base
 * @param Returner the player responsible for returning the flag (may be None)
 */
function SendHome(Controller Returner)
{
	CalcSetHome();
	LogReturned(Returner);

	if ( GetTeamNum() < ArrayCount(ReturnedEffectClasses) )
	{
		Spawn(ReturnedEffectClasses[GetTeamNum()]);
	}
	GotoState('Rebuilding');
}

function Score()
{
	GetKismetEventObjective().TriggerFlagEvent('Captured', Holder != None ? Holder.Controller : None);
	//`log(self$" score holder="$holder,, 'GameObject');
	Disable('Touch');
	SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
	SetRotation(HomeBase.Rotation);
	CalcSetHome();
	GotoState('Rebuilding');
}

function DoBuildOrb()
{
	`log("DoBuildOrb() called in  "$GetStateName());
}

function OrbBuilt()
{
	`log("OrbBuilt() called in  "$GetStateName());
}

function bool IsRebuilding()
{
	return false;
}

auto state Rebuilding
{
	ignores SendHome, KismetSendHome, Score, Drop;

	function bool IsRebuilding()
	{
		return true;
	}

	function Reset()
	{
		Global.Reset();

		// since our home base might have been changed by Reset(), make sure we're in the right location
		SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
		SetRotation(HomeBase.Rotation);
		SetBase(HomeBase);
	}

	function DoBuildOrb()
	{
		bFinishedPreBuild = true;
		UTOnslaughtFlagBase(HomeBase).BuildOrb();
		SetTimer(BuildTime, false, 'OrbBuilt');
	}

	function OrbBuilt()
	{
		GotoState('Home');
	}

	function BeginState(Name PreviousStateName)
	{
		LastNearbyObjective = None;
		Disable('Touch');
		bHome = true;
		SetCollision(false);
		SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
		SetRotation(HomeBase.Rotation);
		SetBase(HomeBase);
		SetHidden(true);
		bFinishedPreBuild = false;
		SetTimer(PrebuildTime, false, 'DoBuildOrb');
		BuildStartTime = WorldInfo.TimeSeconds;
		bForceNetUpdate = TRUE;
		if (UTGameReplicationInfo(WorldInfo.GRI) != None)
		{
			UTGameReplicationInfo(WorldInfo.GRI).SetFlagHome(GetTeamNum());
		}
	}

	function EndState(Name NextStateName)
	{
		PrebuildTime = default.PrebuildTime;
		bHome = false;
		bFinishedPreBuild = false;
	}
}

state Home
{
	ignores SendHome, KismetSendHome, Score, Drop;

	function Reset()
	{
		Global.Reset();

		// since our home base might have been changed by Reset(), make sure we're in the right location
		SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
		SetRotation(HomeBase.Rotation);
		SetBase(HomeBase);
	}

	function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
		SetBase(HomeBase);
		SetCollision(true);
		HomeBase.ObjectiveChanged();
		HomeBase.bForceNetUpdate = TRUE;
		bForceNetUpdate = TRUE;

		if (UTGameReplicationInfo(WorldInfo.GRI) != None)
		{
			UTGameReplicationInfo(WorldInfo.GRI).SetFlagHome(GetTeamNum());
		}
	}

	function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		UTOnslaughtFlagBase(HomeBase).HideOrb();
		SetHidden(false);
		UTGameReplicationInfo(WorldInfo.GRI).SetFlagHeldFriendly(GetTeamNum());
	}
}

/** find the nearest flag base to the given objective on the Onslaught node network */
function UTOnslaughtFlagBase FindNearestFlagBase( UTOnslaughtNodeObjective CurrentNode,
							optional out array<UTOnslaughtNodeObjective> CheckedNodes )
{
	local int i;
	local UTOnslaughtFlagBase Result;

	// avoid too much recursion
	if (CheckedNodes.length > 100)
	{
		return None;
	}
	else
	{
		CheckedNodes[CheckedNodes.length] = CurrentNode;
		// check adjacent nodes for a flag base; if we find one, return it
		for (i = 0; i < ArrayCount(CurrentNode.LinkedNodes); i++)
		{
			if ( CurrentNode.LinkedNodes[i] != None && CurrentNode.LinkedNodes[i].FlagBase != None
				&& CurrentNode.LinkedNodes[i].GetTeamNum() == Team.TeamIndex && CurrentNode.LinkedNodes[i].IsActive() )
			{
				return CurrentNode.LinkedNodes[i].FlagBase;
			}
		}
		// didn't find one, so now ask the nodes if any adjacent to them have a flag base
		for (i = 0; i < ArrayCount(CurrentNode.LinkedNodes); i++)
		{
			if ( CurrentNode.LinkedNodes[i] != None && CurrentNode.LinkedNodes[i].GetTeamNum() == Team.TeamIndex
				&& CheckedNodes.Find(CurrentNode.LinkedNodes[i]) == -1 )
			{
				Result = FindNearestFlagBase(CurrentNode.LinkedNodes[i], CheckedNodes);
				if (Result != None)
				{
					return Result;
				}
			}
		}
	}

	return None;
}

/** sets HomeBase to the nearest friendly Onslaught flag base */
function SetHomeBase()
{
	local UTOnslaughtNodeObjective O, Best;
	local float Dist, BestDist;

	// set homebase to closest line dist to current location
  	foreach WorldInfo.AllNavigationPoints(class'UTOnslaughtNodeObjective', O)
  	{
  		if (O.GetTeamNum() == Team.TeamIndex && O.FlagBase != None && O.IsActive())
  		{
  			Dist = VSize(O.Location - Location);
  			if (Best == None || Dist < BestDist)
	  		{
	  			Best = O;
	  			BestDist = Dist;
	  		}
	  	}
  	}

	UTOnslaughtFlagBase(HomeBase).myFlag = None;
  	if (Best != None)
  	{
  		HomeBase = Best.FlagBase;
  	}
  	else
  	{
  		HomeBase = StartingHomeBase;
  	}
  	UTOnslaughtFlagBase(HomeBase).myFlag = self;
}

function BroadcastDroppedMessage(Controller EventInstigator)
{
	if ( !WorldInfo.GRI.bMatchIsOver )
	{
		if ( EventInstigator == None )
			BroadcastLocalizedTeamMessage(Team.TeamIndex,MessageClass, 2 + 7 * GetTeamNum(), HolderPRI, None, Team);
		else
			BroadcastLocalizedTeamMessage(Team.TeamIndex,MessageClass, 2 + 7 * GetTeamNum(), HolderPRI, EventInstigator.PlayerReplicationInfo, Team);
	}
}

function LogDropped(Controller EventInstigator)
{
	local UTOnslaughtPowerNode Node;
	local UTOnslaughtGame Game;

	if (bLastSecondSave && (EventInstigator != Holder.Controller) )
	{
		Game = UTOnslaughtGame(WorldInfo.Game);
		if (Game != None)
		{
			Node = UTOnslaughtPowerNode(Game.ClosestNodeTo(self));
			if (Node != None && Node.GetTeamNum() < ArrayCount(Game.Teams))
			{
				if ( PlayerController(EventInstigator) != None )
					PlayerController(EventInstigator).ReceiveLocalizedMessage(class'UTLastSecondMessage', 1, EventInstigator.PlayerReplicationInfo, None, None);
				if ( PlayerController(HolderPRI.Owner) != None )
					PlayerController(HolderPRI.Owner).ReceiveLocalizedMessage(class'UTLastSecondMessage', 1, EventInstigator.PlayerReplicationInfo, None, None);
				bLastSecondSave = false;
				if ( UTPlayerReplicationInfo(EventInstigator.PlayerReplicationInfo) != None )
				{
					UTPlayerReplicationInfo(EventInstigator.PlayerReplicationInfo).IncrementEventStat('EVENT_LASTSECONDSAVE');
				}
			}
		}
	}
	BroadcastDroppedMessage(EventInstigator);
	bLastSecondSave = false;

	GetKismetEventObjective().TriggerFlagEvent('Dropped', EventInstigator);
}

/** @return whether this flag is at its homebase or reasonably close to it */
function bool IsNearlyHome()
{
	return (bHome || (IsInState('Dropped') && VSize(HomeBase.Location - Location) < 1024.0));
}

event OrbUnused()
{
	`warn("called OrbUnused outside of Held state!");
}

state Held
{
	ignores SetHolder;

	/**
	  * Send unused orb home
	  */
	event OrbUnused()
	{
		local UTPlayerController HolderPC;

		HolderPC = UTPlayerController(HolderPRI.Owner);

		// don't return orb in standalone or small games
		if ( (WorldInfo.NetMode == NM_Standalone) || (WorldInfo.Game.NumPlayers < 3) )
		{
			LastUsefulTime = WorldInfo.TimeSeconds;
			if ( HolderPC != None )
			{
				HolderPC.bNotUsingOrb = true;
			}
			return;
		}

		LastForcedReturnPRI = HolderPRI;
		LastForcedReturnTime = WorldInfo.TimeSeconds;
		if ( HolderPC != None )
		{
			HolderPC.bNotUsingOrb = true;
			HolderPC.ReceiveLocalizedMessage(MessageClass, 17, HolderPRI, None, Team);
		}
		SetHomeBase();
		Disable('Touch');
		SetLocation(HomeBase.Location + (HomeBaseOffset >> HomeBase.Rotation));
		SetRotation(HomeBase.Rotation);
		CalcSetHome();
		GotoState('Rebuilding');
	}

	function Score()
	{
		SetHomeBase();
		Global.Score();
	}
}

state Dropped
{
	ignores Drop;

	function SendHome(Controller Returner)
	{
		SetHomeBase();

	  	Global.SendHome(Returner);
	}

	function Timer()
	{
		local Controller C;
		local float NewGraceDist;

		RemainingDropTime--;
		if ( (RemainingDropTime < 10) && !IsInPain() )
		{
			// slow down tick if friendly players closing in on orb
			// if a team member is very close, give a short grace period
			NewGraceDist = GraceDist + 1;
			ForEach WorldInfo.AllControllers(class'Controller', C)
			{
				if (C.bIsPlayer && C.Pawn != None && WorldInfo.GRI.OnSameTeam(self, C) )
				{
					NewGraceDist = FMin(NewGraceDist, VSize(C.Pawn.Location - Location));
				}
			}
			if ( NewGraceDist < LastGraceDistance )
			{
				RemainingDropTime = Max(RemainingDropTime, 1);
				SetTimer(2*WorldInfo.TimeDilation, true);
			}
			else
			{
				SetTimer(WorldInfo.TimeDilation, true);
			}
			LastGraceDistance = NewGraceDist;
		}

		if ( RemainingDropTime <= 0 )
		{
			super.Timer();
		}
	}

	function bool FlagUse(Controller C)
	{
		// make sure its a valid enemy trying to destroy this orb
		if ( (C.Pawn == None) || !super.ValidHolder(C.Pawn) || WorldInfo.GRI.OnSameTeam(self,C) )
		{
			return false;
		}

		// destroy the orb
		UTOnslaughtGame(WorldInfo.Game).ScoreFlag(C, self);

		// longer time to rebuild when enemy returns
		PrebuildTime = EnemyReturnPrebuildTime;

		SendHome(C);
		C.Pawn.TakeDamage(100, None, C.Pawn.Location, vect(0,0,80000), class'UTDmgType_OrbReturn');
		C.PlayerReplicationInfo.Score += 4;
		return true;
	}

	event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
	{
		local Pawn P;

		Super.Touch(Other, OtherComp, HitLocation, HitNormal);

		// check if bot wants to return me
		P = Pawn(Other);
		if (P != None && UTBot(P.Controller) != None && (P.Controller.MoveTarget == self || P.Controller.RouteGoal == self))
		{
			FlagUse(P.Controller);
		}
	}

	event BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if (IsInState('Dropped')) // might have left immediately if we were dropped inside a pain volume, etc
		{
			RemainingDropTime = MaxDropTime / WorldInfo.TimeDilation;
			LastGraceDistance = GraceDist;
			SetTimer(WorldInfo.TimeDilation, true);
		}
	}

	event EndState(name NextStateName)
	{
		Super.EndState(NextStateName);

		RemainingDropTime = 0;
	}
}


defaultproperties
{
	MaxHoldTime=120.0
	OrbMinViewDist=28.0
	HomeBaseOffset=(X=12.68,Z=32.04)
	bPostRenderIfNotVisible=true

	UsePictographDistSq=21025.0

	ToolTipIconCoords=(U=921,V=61,UL=93,VL=54)

}
