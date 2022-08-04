/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTStealthVehicle extends UTVehicle_Deployable
	native(Vehicle)
	abstract;

/** name of the Turret control */
var name TurretName;
/** cached Turret control for Tick() */
var UTSkelControl_TurretConstrained DeployableTurretCached;

var AudioComponent StealthResSound;

var byte TurretFiringMode;

var name ExhaustEffectName;

/** Tells the vehicle to immediately redeploy after undeploying */
var bool bShouldImmediatelyRedeploy;

/** Material to use when the vehicle is cloaked */
var MaterialInterface CloakedSkin;

/* MIC for the cloaked material */
var protected MaterialInstanceConstant CloakedBodyMIC;

/** Is the vehicle currently cloaked */
var repnotify bool bIsVehicleCloaked;

/** Time last cloak was started */
var float CloakTransitionTime;

/* Total cloak res in/out time */
var() float CloakTotalResTime;

/* Team colors for rez in/out effect */
var() LinearColor OverlayTeamRezColor[2];

/* name of the skin translucency on the cloaked material */
var name SkinTranslucencyName;
/* Name of the parameter that defines the team skin color */
var name TeamSkinParamName;
/* Name of the parameter that defines the color of the hit effect */
var name HitEffectName;
/** Scale value for the hit effect color */
var() float HitEffectScale;

/* Name of the parameter that defines the overlay color*/
var name OverlayColorName;

/* Scalar value of the cloaked hit effect (team color translucency)*/
var float HitEffectColor;

/** Max ground speed while visible */
var() float VisibleGroundSpeed;
/** Max air speed while visible */
var() float VisibleAirSpeed;
/** Max speed while visible */
var() float VisibleMaxSpeed;
/** Speed modifier to the above max speeds while cloaked */
var() float CloakedSpeedModifier;
/** Speed while 'crouched' */
var() float SlowSpeed;

/** The deployable item mesh */
var MeshComponent DeployPreviewMesh;
/** Used for Either a skeletalmesh or staticmesh, common parent is Object */
var repnotify Object DeployMesh;
/** Offsets for the deployables*/
var(Deploy) array<vector> DeployablePositionOffsets;

/** Trigger for hiding/unhiding the deployable */
var repnotify bool bIsDeployableHidden;

/** How far behind the vehicle to check for obstacles  */
var() float DeployCheckDistance;

/** Lag behind value for the deploy arm control */
var transient float LagDegreesPerSecondDefault;

//============================================================
/** The Link Beam */
var particleSystem BeamTemplate;

/** Holds the Emitter for the Beam */
var ParticleSystemComponent BeamEmitter;

/** Emitter for the endpoint beam effect */
var UTEmitter BeamEndpointEffect;

/** Used for detecting change in the impact effect emitter */
var Actor LastHitActor;

/** Where to attach the Beam */
var name BeamSockets;

/** The name of the EndPoint parameter */
var name EndPointParamName;

var protected AudioComponent BeamAmbientSound;

var soundcue BeamFireSound;
var soundcue BeamStartSound;
var soundcue BeamStopSound;

/** Texture for HUD icons new to UT3G */
var Texture2d HUDIconsUT3G;
/** Coordinates for the fire tooltip textures */
var UIRoot.TextureCoordinates FireToolTipIconCoords;

/** team based colors for beam when targeting a teammate */
var color LinkBeamColors[3];

/** time to transition to deployed camera mode */
var(Movement) float FastCamTransitionTime;

/** The current steering offset of the arm when deployed. */
var int AimYawOffset;

/** The distance delta for the deploy arm */
var int ArmDeltaYaw;

/** Max distance added per frame to the deploy arm rotation */
var() int ArmSpeedTune;

/** Stores the current direction the deploy arm is moving*/
var float DeployArmTestDir;

/** Distance behind the vehicle to focus the camera */
var(Camera) float DeployArmCameraDist;

/** The pitch of the camera while deployed */
var (Camera) float DeployArmCameraPitch;

var float CurrentWeaponScale[10];
var int BouncedWeapon;
var int LastSelectedWeapon;

var AudioComponent TurretArmMoveSound;

/** Tells clients to play the release animation*/
var repnotify int ReleaseAnimCount;
var bool bReleasedADeployable;

/** last time bot tried to drop a deployable */
var float LastDropAttemptTime;

/** Last time bot succeeded in dropping a deployable */
var float LastDropSuccessTime;



replication
{
	if (bNetDirty)
		ReleaseAnimCount, bIsDeployableHidden;
	if (bNetDirty && (!bNetOwner || bDemoRecording))
		ArmDeltaYaw, DeployMesh, bIsVehicleCloaked;
	if (bNetDirty && bNetOwner)
		bShouldImmediatelyRedeploy;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'DeployMesh')
	{
		SetDeployMesh(DeployMesh, 0);
	}
	else if (VarName == 'bIsDeployableHidden')
	{
		if (DeployPreviewMesh != None)
		{
    		DeployPreviewMesh.SetHidden(bIsDeployableHidden);
		}
	}
	else if (VarName == 'bIsVehicleCloaked')
	{
		Cloak(bIsVehicleCloaked, TRUE);
	}
	else if (VarName == 'ReleaseAnimCount')
	{
		PlayReleaseAnim();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

function reliable server ServerSetArmDeltaYaw(int InArmDeltaYaw)
{
	ArmDeltaYaw = InArmDeltaYaw;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	SetupCloakedBodyMaterialMIC();
	AddBeamEmitter();

    //Cache the turret control for Tick()
	DeployableTurretCached = UTSkelControl_TurretConstrained(Mesh.FindSkelControl(TurretName));
	LagDegreesPerSecondDefault = DeployableTurretCached.LagDegreesPerSecond;
}

/**
 * Call this function to blow up the vehicle
 */
simulated function BlowupVehicle()
{
	//Don't switch the cloaking
	ClearTimer('ToggleCloak');
	super.BlowupVehicle();
}

/** Tells clients to play the release animation and sets up the timer for undeploy */
simulated function PlayReleaseAnim()
{
	//Play the animation
	PlayAnim('ArmRelease');
	bReleasedADeployable = true;

	//Tell everyone else to play it as well and toggle the deploy
	if (Role == Role_Authority)
	{
		ReleaseAnimCount++;
		if ((AnimPlay != none) && (AnimPlay.AnimSeq != none))
		{
			SetTimer(AnimPlay.AnimSeq.SequenceLength, false, 'ServerToggleDeploy');
		}
		else
		{
			ServerToggleDeploy();
		}
	}
}

/**
@RETURN true if pawn is invisible to AI
*/
native function bool IsInvisible();

/**
 * This function will verify that the CloakedBodyMIC variable is setup and ready to go.  This is a key
 * component for the BodyMat overlay system
 */
simulated function bool SetupCloakedBodyMaterialMIC()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && Mesh != None && (CloakedBodyMIC == None) )
	{
		// set up material instances (for overlay effects)
		if(CloakedSkin == none)
		{
			//No cloaked skin, use whatever is on there
			CloakedBodyMIC = Mesh.CreateAndSetMaterialInstanceConstant(0);
		}
		else
		{
			// Create the material instance.
			CloakedBodyMIC = new(Outer) class'MaterialInstanceConstant';
			CloakedBodyMIC.SetParent(CloakedSkin);
			CloakedBodyMIC.SetScalarParameterValue( TeamSkinParamName, GetTeamNum()==1?1:0 );
		}
	}

	return CloakedBodyMIC != None;
}

simulated function TeamChanged()
{
	local int i;
	local MaterialInterface NewMaterial;

    if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		//Modify the cloaked skin parameters
		if(CloakedBodyMIC == none)
		{
			SetupCloakedBodyMaterialMIC();
		}
		if(CloakedBodyMIC != none) // only proceed if the above actually worked.
		{
			CloakedBodyMIC.SetScalarParameterValue(TeamSkinParamName,GetTeamNum()==1?1:0);
		}

		//Modify the visible skin parameters
		if (Team < TeamMaterials.length && TeamMaterials[Team] != None)
		{
			NewMaterial = TeamMaterials[Team];
		}
		else if (TeamMaterials.length > 0 && TeamMaterials[0] != None)
		{
			NewMaterial = TeamMaterials[0];
		}

		//Always parent the damage MIC
		if (NewMaterial != None)
		{
			if (DamageMaterialInstance[0] != None)
			{
				DamageMaterialInstance[0].SetParent(NewMaterial);
				DamageMaterialInstance[0].SetScalarParameterValue( TeamSkinParamName, GetTeamNum()==1?1:0 );
			}
		}

		//If we aren't cloaked, set the 'visible' skin
		if(Mesh.Materials[0] != CloakedBodyMIC)
		{
			Mesh.SetMaterial(0, DamageMaterialInstance[0]);
		}
	}

	if(bPlayingSpawnEffect)
	{
		for(i=0;i<Mesh.Materials.Length && i<OriginalMaterials.Length;++i)
		{
			OriginalMaterials[i] = Mesh.Materials[i];
		}
	}

	UpdateDamageMaterial();
}

simulated state UnDeploying
{
	//Overridden to prevent redeploy while already
	//redeploying do to deployable selection
	function bool DoJump(bool bUpdating);

	//Overridden to transition the arm back
	//up and redeploy with a new deployable item
	reliable server function ServerToggleDeploy()
	{
		//If I need to redeploy, make sure I have ammo
		if (bShouldImmediatelyRedeploy && Seats[0].Gun.HasAmmo(1))
		{
			Super.ServerToggleDeploy();
			GotoState('Deploying');
		}
	}

	//Overridden to check if we need to go back to deploying
	simulated function VehicleUnDeployIsFinished()
	{
		if (ROLE==ROLE_Authority && WorldInfo.NetMode != NM_ListenServer)
		{
			SetVehicleUndeployed();
		}

		//Finish whatever is neccessary to be undeployed
		ChangeDeployState(EDS_UnDeployed);

		if (bShouldImmediatelyRedeploy)
		{
			//Try to go right back to being deployed
			ServerToggleDeploy();
			bShouldImmediatelyRedeploy = FALSE;
		}

		if (DeployedState != EDS_Deploying)
		{
			//We weren't successful in redeploying
			GotoState('');
		}
	}
};

function BotUndeploy() {}

simulated state Deployed
{
	//Overridden to transition the arm back
	//up and redeploy with a new deployable item
	reliable server function ServerToggleDeploy()
	{
		Super.ServerToggleDeploy();

		if (IsFiring())
		{
			GotoState('UnDeploying');
		}
	}

	function BotUndeploy() 
	{
		ServerToggleDeploy();
	}

	function BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		
		if ( UTBot(Controller) != None )
		{
			BotFire(true);
			SetTimer(0.25, false, 'BotUndeploy');
			LastDropSuccessTime = WorldInfo.TimeSeconds;
		}
	}
};

simulated function DisplayHud(UTHud Hud, Canvas Canvas, vector2D HudPOS, optional int SeatIndex)
{
	local PlayerController PC;
	local int i;

	Super.DisplayHud(HUD, Canvas, HudPOS, SeatIndex);
	if (DeployedState == EDS_Deployed)
	{
		for (i=0; i<Seats.length; i++)
		{
			if (Seats[i].SeatPawn != None)
			{
				PC = PlayerController(Seats[i].SeatPawn.Controller);
				if (PC != none)
				{
					if (bHasWeaponBar)
					{
						Hud.DrawToolTip(Canvas, PC, "GBA_Fire", Canvas.ClipX * 0.5, Canvas.ClipY * 0.82, FireToolTipIconCoords.U, FireToolTipIconCoords.V, FireToolTipIconCoords.UL, FireToolTipIconCoords.VL, Canvas.ClipY / 768, HUDIconsUT3G);
					}
					else
					{
						Hud.DrawToolTip(Canvas, PC, "GBA_Fire", Canvas.ClipX * 0.5, Canvas.ClipY * DeployIconOffset, FireToolTipIconCoords.U, FireToolTipIconCoords.V, FireToolTipIconCoords.UL, FireToolTipIconCoords.VL, Canvas.ClipY / 768, HUDIconsUT3G);
					}
				}
			}
		}
	}
}


/**
 * Play the ambients when an action anim finishes
 */
simulated function OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	if ( SeqNode.AnimSeqName == 'ArmRelease' )
	{
		AnimPlay.SetAnim(DeployAnim[0]);
		AnimPlay.SetPosition(AnimPlay.AnimSeq.SequenceLength, false);
	}
	else
	{
		super.OnAnimEnd(SeqNode, PlayedTime, ExcessTime);
	}
}

simulated function ImmediatelyRedeploy(bool ShouldImmediatelyRedeploy)
{
	bShouldImmediatelyRedeploy = ShouldImmediatelyRedeploy;

	if (Instigator.IsLocallyControlled() && Role < Role_Authority)
	{
		ServerSetImmediateRedeploy(ShouldImmediatelyRedeploy);
	}

	ServerToggleDeploy();
}

reliable server function ServerSetImmediateRedeploy(bool ShouldImmediatelyRedeploy)
{
	//Communicate this status to the server so it goes
	//through the appropriate motions
	bShouldImmediatelyRedeploy = ShouldImmediatelyRedeploy;
}

/**
 * Listen clients will call Cloak() replicating the value directly
 * Clients will call Cloak() which also calls this function
 * allowing the server to cloak thus replicating to everyone else
 */
reliable server function ServerSetCloak(bool bIsEnabled)
{
	Cloak(bIsEnabled);
}

/*
 * Timed event that swaps the materials at the right moment
 */
simulated function ToggleCloak()
{
	local UTPawn UTP;

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if(bIsVehicleCloaked && Mesh.Materials[0] != CloakedBodyMIC)
		{
			Mesh.SetMaterial(0,CloakedBodyMIC);
			CloakedBodyMIC.SetScalarParameterValue( TeamSkinParamName, GetTeamNum()==1?1:0 );
			UpdateShadowSettings( false );
			ApplyWeaponEffects(0, 0);
			DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = FALSE;
		}
		else if(!bIsVehicleCloaked && Mesh.Materials[0] != DamageMaterialInstance[0])
		{
			Mesh.SetMaterial(0, DamageMaterialInstance[0]);
			UpdateShadowSettings(!class'Engine'.static.IsSplitScreen() && class'UTPlayerController'.Default.PawnShadowMode == SHADOW_All);
			UTP = UTPawn(Driver);
			if (UTP != None)
			{
				ApplyWeaponEffects(UTP.WeaponOverlayFlags, 0);
			}
			DynamicLightEnvironmentComponent(Mesh.LightEnvironment).bCastShadows = TRUE;
		}
	}

	//We are about to come out of cloak in a deploying/deployed state, show the object
	if (!bIsVehicleCloaked && (DeployedState == EDS_deployed) || (DeployedState == EDS_deploying))
	{
		SetDeployMeshHidden(FALSE);
	}
}

/**
 * Cloaks or decloaks the vehicle.
 * Force is for replication to use since bIsVehicleCloaked
 * has already been modified
 */
simulated function Cloak(bool bIsEnabled, optional bool bForce=FALSE)
{
	if (bIsEnabled && Role == ROLE_Authority && DeployedState != EDS_Undeployed)
		return;

    if (bForce || (bIsVehicleCloaked != bIsEnabled))
    {
		//This will switch the materials to the appropriate thing at the right time
		ClearTimer('ToggleCloak');
	SetTimer(CloakTotalResTime * 0.5f, false, 'ToggleCloak');

	    CloakTransitionTime = 0;
		if (bIsEnabled)
		{
		 	GroundSpeed = CloakedSpeedModifier * VisibleGroundSpeed;
			AirSpeed = CloakedSpeedModifier * VisibleAirSpeed;
			MaxSpeed = CloakedSpeedModifier * VisibleMaxSpeed;
		}
		else
		{
			GroundSpeed = VisibleGroundSpeed;
			AirSpeed = VisibleAirSpeed;
			MaxSpeed = VisibleMaxSpeed;
		}

	    bIsVehicleCloaked = bIsEnabled;

	    //Trigger replication
		if (IsLocallyControlled() && Role < ROLE_Authority)
	    {
	    	ServerSetCloak(bIsVehicleCloaked);
	    }

	    if (StealthResSound != none)
	    {
	    	if (StealthResSound.IsPlaying())
	    	{
	    		StealthResSound.Stop();
	    	}

	    	StealthResSound.Play();
	    }
    }
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	super.PlayHit(Damage,InstigatedBy,HitLocation,damageType,Momentum,HitInfo);
}

/** plays take hit effects; called from PlayHit() on server and whenever LastTakeHitInfo is received on the client */
simulated event PlayTakeHitEffects()
{
	//Every time we're hit, add to the color (Fade takes away a min of 10%)
	HitEffectColor = FClamp(HitEffectColor * 1.3f, 0.5f, 3.0f);
	super.PlayTakeHitEffects();
}

simulated event Destroyed()
{
	super.Destroyed();
	KillBeamEmitter();
}

simulated function int PartialTurn(int original, int desired, float PctTurn)
{
	local float result;

	original = original & 65535;
	desired = desired & 65535;

	if ( abs(original - desired) > 32768 )
	{
		if ( desired > original )
		{
			original += 65536;
		}
		else
		{
			desired += 65536;
		}
	}
	result = original*(1-PctTurn) + desired*PctTurn;
	return (int(result) & 65535);
}

/**
  * returns the camera focus position (without camera lag)
  */
simulated function vector GetCameraFocus(int SeatIndex)
{
	local float TimeSinceTransition;
	local vector CamStart;
	local vector DeployedCameraFocus, BackDir;
	local float Pct;

	CamStart = super.GetCameraFocus(SeatIndex);
	BackDir = -vector(Rotation);

    //Camera focus is some distance behind the vehicle
	DeployedCameraFocus = Location + BackDir * DeployArmCameraDist;

	//Get there over time
	TimeSinceTransition = WorldInfo.TimeSeconds - LastDeployStartTime;

	if (DeployedState == EDS_deployed || DeployedState == EDS_deploying)
	{
		if(TimeSinceTransition < FastCamTransitionTime)
		{
			Pct = TimeSinceTransition/FastCamTransitionTime;
			CamStart = CamStart + Pct * (DeployedCameraFocus - CamStart);
		}
		else
		{
			CamStart = DeployedCameraFocus;
		}
	}
	else
	{
		if(TimeSinceTransition < FastCamTransitionTime)
		{
			Pct = TimeSinceTransition/FastCamTransitionTime;
			CamStart = CamStart + (1.0-Pct) * (DeployedCameraFocus - CamStart);
		}
	}

	//DrawDebugSphere(CamStart, 8, 10, 255, 255, 255, FALSE);
	return CamStart;
}

simulated function Rotator GetViewRotation()
{
	local rotator FixedRotation, ControllerRotation;
	local float TimeSinceTransition, PctTurn;
	local int RotationResult;
	local float RotYawModifier;

	// Start block to find deployed rotation yaw:
	RotationResult = Rotation.Yaw%65536;

	//Add some distance to the side based on arm deflection
	RotYawModifier = (AimYawOffset / 16384.0f) * 8192.0f; //45 deg max
	RotationResult -= RotYawModifier;

	// End block to find rotation yaw

	//View rotation for all time not deployed
	if ( DeployedState != EDS_Deployed && DeployedState != EDS_deploying)
	{
		// Get baseline rotation and deployed yaw
		FixedRotation = super.GetViewRotation();

	    //We are leaving the deployed state, rotate back around toward front
		TimeSinceTransition = WorldInfo.TimeSeconds - LastDeployStartTime;
		if ( TimeSinceTransition < FastCamTransitionTime )
		{
			PctTurn = TimeSinceTransition/FastCamTransitionTime;
			FixedRotation.Yaw = PartialTurn(RotationResult, FixedRotation.Yaw, PctTurn);
			FixedRotation.Pitch = PartialTurn(DeployArmCameraPitch, FixedRotation.Pitch, PctTurn);//-16384
			FixedRotation.Roll = PartialTurn(Rotation.Roll, FixedRotation.Roll, PctTurn);
		}

		return FixedRotation;
	}

	// swing smoothly around to vehicle rotation
	TimeSinceTransition = WorldInfo.TimeSeconds - LastDeployStartTime;
	if ( TimeSinceTransition < FastCamTransitionTime )
	{
		FixedRotation = super.GetViewRotation();
		PctTurn = TimeSinceTransition/FastCamTransitionTime;
		FixedRotation.Yaw = PartialTurn(FixedRotation.Yaw, RotationResult, PctTurn);
		FixedRotation.Pitch = PartialTurn(FixedRotation.Pitch, DeployArmCameraPitch, PctTurn);
		FixedRotation.Roll = PartialTurn(FixedRotation.Roll, Rotation.Roll, PctTurn);
	}
	else
	{
		FixedRotation.Yaw = RotationResult;
		FixedRotation.Pitch = DeployArmCameraPitch;
		FixedRotation.Roll = rotation.roll;
		if ( Controller != None )
		{
			ControllerRotation = FixedRotation;
			ControllerRotation.Roll = 0;
			Controller.SetRotation(ControllerRotation);
		}
	}

	return FixedRotation;
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	if(DeployedState != EDS_Undeployed)
	{
		if (DeployedState == EDS_Deployed)
		{
			ArmDeltaYaw = -out_DeltaRot.Yaw;
			//Replicate this value out to everyone
			if (Role < ROLE_Authority)
			{
				ServerSetArmDeltaYaw(ArmDeltaYaw);
			}
		}

		out_DeltaRot.Yaw = 0;
		out_DeltaRot.Pitch = 0;
	}

	super.ProcessViewRotation(deltatime,out_viewrotation,out_deltarot);
}

simulated function SetVehicleDeployed()
{
	Super.SetVehicleDeployed();
	Cloak(false);
}

simulated function SetVehicleUndeploying()
{
	local float AnimRate;

	super.SetVehicleUndeploying();

    //If we didn't drop anything, play the deploy animation backward to prevent popping
	if (!bReleasedADeployable)
	{
		AnimPlay.SetAnim(DeployAnim[0]);
		if(AnimPlay.AnimSeq != none)
		{
			AnimRate = AnimPlay.AnimSeq.SequenceLength / UnDeployTime;
			AnimPlay.PlayAnim(false, -AnimRate, AnimPlay.AnimSeq.SequenceLength);
		}
	}

	bReleasedADeployable = false;
}

simulated function SetVehicleUndeployed()
{
	Super.SetVehicleUndeployed();
	if (!bShouldImmediatelyRedeploy)
	{
		Cloak(bDriving);
	}

	TurretArmMoveSound.Stop();
}

simulated function DrivingStatusChanged()
{
	super.DrivingStatusChanged();
	//Only cloak if we are sitting here undeployed
	Cloak(bDriving && (DeployedState == EDS_Undeployed));
	//Reset the deploy arm
	AimYawOffset = 0;

	//If cancel deploy was called (we just left) and we reenter clear the timer to change deploy state
	if (bDriving)
	{
		ClearTimer('ServerToggleDeploy');
	}

	if (Role == ROLE_Authority)
	{
		if (UTBot(Controller) != None)
		{
			SetTimer(1.0, true, 'CheckAICloak');
		}
		else
		{
			ClearTimer('CheckAICloak');
		}
	}
}

simulated function bool OverrideBeginFire(byte FireModeNum)
{
	if ( (FireModeNum == 1) && IsLocallyControlled() && (DeployedState == EDS_Undeployed) )
	{
		//Toggles cloaking and max speed (only if not currently cloaking in/out)
		if (CloakTransitionTime > CloakTotalResTime)
		{
			Cloak(!bIsVehicleCloaked);
		}
		return true;
	}
	// don't allow firing while in deploy transition
	if ( (DeployedState == EDS_Deploying) || (DeployedState == EDS_UnDeploying) )
	{
		return true;
	}

	return false;
}

simulated function SetDeployMeshHidden(bool bIsHidden)
{
	if(DeployPreviewMesh != none)
	{
		DeployPreviewMesh.SetHidden(bIsHidden);
	}

	bIsDeployableHidden=bIsHidden;
}

simulated function DeployedStateChanged()
{
	local bool bShouldHideDeployMesh;
	super.DeployedStateChanged();
	switch (DeployedState)
	{
		case EDS_Deploying:
			//Create/Unhide the selected deployable
			SetDeployVisual();
			//If the vehicle wasn't cloaked, show the deployable right away
			bShouldHideDeployMesh = (CloakTransitionTime < CloakTotalResTime);
			SetDeployMeshHidden(bShouldHideDeployMesh);
			if (Seats[0].Gun != None)
			{
				Seats[0].Gun.EndFire(0); // stop the link beam while deployed
				Seats[0].Gun.DemoEndFire(0);
			}
			break;
		case EDS_Deployed:
			break;
		case EDS_Undeploying:
			TurretArmMoveSound.Play();
			break;
		case EDS_Undeployed:
			AimYawOffset=0.0f;
		    SetDeployMeshHidden(TRUE);
		    SetDeployMesh(None, 0);
			DeployMesh = none;
			break;
	}
}

//Adjust the deployable arm using a turret constraint over time
simulated native function SetArmLocation(float DeltaSeconds);

//Setup the deployable object in the pincer arm
simulated function SetDeployVisual()
{
	local UTVWeap_NightshadeGun NSG;
	local SkeletalMeshComponent SkMC;
	local StaticMeshComponent StMC;
	local class<Actor> DepActor;
	local class<UTSlowVolume> SlowActor;
	local class<UTXRayVolume> XRayActor;
	local class<UTDeployable> DeployableClass;

	NSG = UTVWeap_NightShadeGun(Seats[0].Gun);
	if(NSG != none /*&& WorldInfo.NetMode != NM_DedicatedServer*/)
	{
		DeployableClass = NSG.DeployableList[NSG.DeployableIndex].DeployableClass;
		DepActor = DeployableClass.static.GetTeamDeployable(Instigator.GetTeamNum());
		if(DepActor != none)
		{
			// HACK: slow volume weird case
			SlowActor = class<UTSlowVolume>(DepActor);
			XRayActor = class<UTXRayVolume>(DepActor);
			if(SlowActor != none)
			{
				SkMC = SlowActor.default.GeneratorMesh;
			}
			else if (XRayActor != none)
			{
				SkMC = XRayActor.default.GeneratorMesh;
			}
			else
			{
				SkMC = SkeletalMeshComponent(DepActor.default.CollisionComponent);
				if(SkMC == none)
				{
					StMC = StaticMeshComponent(DepActor.default.CollisionComponent);
				}
			}
		}
		// emergency choice is the dropped version:
		if(SkMC == none && StMC == none)
		{
			StMC = StaticMeshComponent(DeployableClass.default.DroppedPickupMesh);
			SkMC = SkeletalMeshComponent(DeployableClass.default.DroppedPickupMesh);
		}

		//Setup the visual deployable both here and
		//tell the server to replicate to clients
		if (SkMC != none)
		{
			//Setup the deployable for myself
			SetDeployMesh(SkMC.SkeletalMesh, NSG.DeployableIndex);

			//Tell everyone else about it
			if (WorldInfo.NetMode == NM_Client)
			{
				ServerSetDeployMesh(SkMC.SkeletalMesh, NSG.DeployableIndex);
			}
			else
			{
				DeployMesh = SkMC.SkeletalMesh;
				SetDeployMesh(SkMC.SkeletalMesh, NSG.DeployableIndex);
			}
		}
		else if (StMC != none)
		{
			//Setup the deployable for myself
			SetDeployMesh(StMC.StaticMesh, NSG.DeployableIndex);

			//Tell everyone else about it
			if (WorldInfo.NetMode == NM_Client)
			{
				ServerSetDeployMesh(StMC.StaticMesh, NSG.DeployableIndex);
			}
			else
			{
				DeployMesh = StMC.StaticMesh;
				SetDeployMesh(StMC.StaticMesh, NSG.DeployableIndex);
			}
		}
		else
		{
			if (WorldInfo.NetMode == NM_Client)
			{
				ServerSetDeployMesh(none, NSG.DeployableIndex);
			}
			else
			{
				DeployMesh = none;
				SetDeployMesh(none, NSG.DeployableIndex);
			}
		}
	}
}

//Tell the server what deployable mesh we're using so it can tell everyone else
function singular reliable server ServerSetDeployMesh(Object InDeployMesh, int DeployableIndex)
{
	/*
	//Trigger the replication to clients
	DeployMesh = InDeployMesh;
	//Handle the server updating its own copy if it was not called locally
	if ( (Instigator != None) && !Instigator.IsLocallyControlled() )
	{
		SetDeployMesh(InDeployMesh, DeployableIndex);
	}
	*/

	// Let the server decide the deploy mesh instead, to prevent exploits
	SetDeployVisual();

	
}

//Replicated version of code to set the deployable mesh
function simulated SetDeployMesh(Object InDeployMesh, int DeployableIndex)
{
	local StaticMesh STMesh;
	local SkeletalMesh SKMesh;

	//Get rid of anything before
	if(DeployPreviewMesh != none)
	{
		Mesh.DetachComponent(DeployPreviewMesh);
	}

	if (InDeployMesh != none)
	{
		SKMesh = SkeletalMesh(InDeployMesh);
		if (SKMesh != none)
		{
			DeployPreviewMesh = new(self) class'SkeletalMeshComponent';
			SkeletalMeshComponent(DeployPreviewMesh).SetSkeletalMesh(SKMesh);
		}
		else
		{
			STMesh = StaticMesh(InDeployMesh);
			if (STMesh != none)
			{
				DeployPreviewMesh = new(self) class'StaticMeshComponent';
				StaticMeshComponent(DeployPreviewMesh).SetStaticMesh(STMesh);
			}
		}

		if(DeployPreviewMesh != none)
		{
			DeployPreviewMesh.SetShadowParent(Mesh);
			DeployPreviewMesh.SetLightEnvironment(LightEnvironment);
			if (DeployableIndex >= 0 && DeployableIndex < DeployablePositionOffsets.Length)
				DeployPreviewMesh.SetTranslation(DeployablePositionOffsets[DeployableIndex]);
			else
				DeployPreviewMesh.SetTranslation(vect(0,0,0));

			DeployPreviewMesh.SetScale(1.0);
			Mesh.AttachComponentToSocket(DeployPreviewMesh,'DeployableDrop');
		}
	}
}

/**
request change to adjacent vehicle seat
*/
simulated function AdjacentSeat(int Direction, Controller C)
{
	AdjustCameraScale(Direction < 0);
}

/** if deployed, changes selected deployable */
simulated function AdjustCameraScale(bool bMoveCameraIn)
{
	local UTVWeap_NightshadeGun NSG;
	local int DeployableIndex;

	//Only adjustable when not extending the arm
	if (DeployedState != EDS_Deploying)
	{
		NSG = UTVWeap_NightShadeGun(Seats[0].Gun);

		if ( NSG != None )
		{
			NSG.NextAvailableDeployableIndex(bMoveCameraIn ? -1 : 1, DeployableIndex);
			if ( DeployableIndex != NSG.DeployableIndex )
			{
				NSG.SelectWeapon(DeployableIndex);
				ServerSwitchWeapon(DeployableIndex+1);
				if (DeployedState == EDS_Deployed)
				{
					//Have to undeploy to get this item
					ImmediatelyRedeploy(TRUE);
				}
			}
		}
	}
}

simulated function SwitchWeapon(byte NewGroup)
{
	local UTVWeap_NightshadeGun NSG;

    //Only adjustable when not extending the arm
	if (NewGroup > 0 && DeployedState != EDS_Deploying)
	{
		NSG = UTVWeap_NightShadeGun(Seats[0].Gun);
		if( (NSG != none) && (WorldInfo.NetMode != NM_DedicatedServer) && NSG.SelectWeapon(NewGroup-1) )
		{
			ServerSwitchWeapon(NewGroup);
			if (DeployedState == EDS_Deployed)
			{
				//Have to undeploy to get this item
				ImmediatelyRedeploy(TRUE);
			}
		}
	}
}

reliable server function ServerSwitchWeapon(byte NewGroup)
{
	local UTVWeap_NightshadeGun NSG;

	NSG = UTVWeap_NightShadeGun(Seats[0].Gun);
	if(NSG != none)
	{
		NSG.SelectWeapon(NewGroup-1);
	}
}

/**
 * Attach driver to vehicle.
 * Sets up the Pawn to drive the vehicle (rendering, physics, collision..).
 * Called only if bAttachDriver is true.
 * Network : ALL
 */
simulated function AttachDriver( Pawn P )
{
	LastSelectedWeapon = -1;
	if (Seats[0].Gun != none)
	{
		UTVWeap_NightShadeGun(Seats[0].Gun).bShowDeployableName = false;
	}
	Super.AttachDriver(P);
}

simulated function AddBeamEmitter()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (BeamEmitter == None)
		{
			if (BeamTemplate != None)
			{
				BeamEmitter = new(Outer) class'UTParticleSystemComponent';
				BeamEmitter.bAutoActivate = false;
				BeamEmitter.SetTemplate(BeamTemplate);
				BeamEmitter.SetHidden(true);
				//BeamEmitter.bDeferredBeamUpdate = true;
				BeamEmitter.SetTickGroup(TG_PostAsyncWork);
				Mesh.AttachComponentToSocket( BeamEmitter, BeamSockets );
			}
		}
		else
		{
			BeamEmitter.ActivateSystem();
		}
	}
}

//Destroy all effects related to the beam gun
simulated function KillBeamEmitter()
{
	if (BeamEmitter != none)
	{
		BeamEmitter.KillParticlesForced();
		BeamEmitter.SetHidden(true);
		BeamEmitter.DeactivateSystem();
	}

	//Disable any playing endpoint effect
	KillEndpointEffect();
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if ( BeamEmitter.HiddenGame != bHide )
		{
			if (BeamEmitter != none)
			{
		//TODO:JoshM - I don' t know why we always kill particles here, I think this should
		//go under if(bHide) but for now I won't touch what I don't fully understand
				BeamEmitter.KillParticlesForced();
				BeamEmitter.SetHidden(bHide);
			}

			BeamAmbientSound.Stop();
			if(bHide)
			{
				PlaySound(BeamStopSound);
				KillEndpointEffect();
			}
			else// if (!bHide)
			{
				BeamAmbientSound.SoundCue = BeamFireSound;
				PlaySound(BeamStartSound);
				BeamAmbientSound.Play();
				BeamEmitter.ActivateSystem();
			}
		}
	}
}

static function color GetTeamBeamColor(byte TeamNum)
{
	if (TeamNum >= ArrayCount(default.LinkBeamColors))
	{
		TeamNum = ArrayCount(default.LinkBeamColors) - 1;
	}

	return default.LinkBeamColors[TeamNum];
}

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local color BeamColor;

	Super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	if (SeatIndex == 0)
	{
		//Every time we shoot, add to the color (Fade takes away a min of 10%)
		HitEffectColor = FClamp(HitEffectColor * 1.25f, 0.3f, 2.0f);

		if ( HitLocation != Vect(0,0,0) )
		{
			BeamEmitter.SetVectorParameter(EndPointParamName, HitLocation); //should this be hit location?
			SetBeamEmitterHidden(false);

			if (FiringMode == 2 && WorldInfo.GRI.GameClass.Default.bTeamGame)
			{
				BeamColor = GetTeamBeamColor(Instigator.GetTeamNum());
			}
			else
			{
				BeamColor = GetTeamBeamColor(255);
			}
			BeamEmitter.SetColorParameter('Link_Beam_Color', BeamColor);
		}
    }
}

/**
 * Detect the transition from vehicle to ground and vice versus and handle it
 */
simulated function actor FindWeaponHitNormal(out vector HitLocation, out Vector HitNormal, vector End, vector Start, out TraceHitInfo HitInfo)
{
	local Actor NewHitActor;

	NewHitActor = Super.FindWeaponHitNormal(HitLocation, HitNormal, End, Start, HitInfo);
	if (NewHitActor != LastHitActor && BeamEndpointEffect != None)
	{
		KillEndpointEffect();
	}
	LastHitActor = NewHitActor;
	return NewHitActor;
}

simulated function SpawnImpactEmitter(vector HitLocation, vector HitNormal, const out MaterialImpactEffect ImpactEffect, int SeatIndex)
{
	if (WorldInfo.NetMode != NM_DedicatedServer && Instigator != None)
	{
		if (BeamEndpointEffect != None && !BeamEndpointEffect.bDeleteMe)
		{
			BeamEndpointEffect.SetLocation(HitLocation);
			BeamEndpointEffect.SetRotation(rotator(HitNormal));
			if (BeamEndpointEffect.ParticleSystemComponent.Template != ImpactEffect.ParticleTemplate)
			{
				BeamEndpointEffect.SetTemplate(ImpactEffect.ParticleTemplate, true);
			}
		}
		else
		{
			BeamEndpointEffect = Spawn(class'UTEmitter', self,, HitLocation, rotator(HitNormal));
			BeamEndpointEffect.SetTemplate(ImpactEffect.ParticleTemplate, true);
			BeamEndpointEFfect.LifeSpan = 0.0;
		}

		if(BeamEndpointEffect != none)
		{
			if(LastHitActor != none && UTPawn(LastHitActor) == none)
			{
				BeamEndpointEffect.SetFloatParameter('Touch',1);
			}
			else
			{
				BeamEndpointEffect.SetFloatParameter('Touch',0);
			}
		}
	}
}

/** deactivates the beam endpoint effect, if present */
simulated function KillEndpointEffect()
{
	if (BeamEndpointEffect != None)
	{
		BeamEndpointEffect.ParticleSystemComponent.DeactivateSystem();
		BeamEndpointEffect.LifeSpan = 2.0;
		BeamEndpointEffect = None;
	}
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
	SetBeamEmitterHidden(true);
}

event bool DriverLeave(bool bForceLeave)
{
	CancelDeploy();
	return Super.DriverLeave(bForceLeave);
}

event bool CanDeploy(optional bool bShowMessage = true)
{
	local vector HitLocation, HitNormal;
	local vector TraceEnd;
	local vector DeployDirection;
    local bool bIsDeployableNearby;

	//If there is no ammo, don't deploy
	if (Seats[0].Gun != None && Seats[0].Gun.HasAmmo(1))
	{
		//Do a line check to see if we aren't backed into a corner
		DeployDirection = vector(Rotation);
		DeployDirection = -DeployDirection;
		TraceEnd = Location + DeployDirection * DeployCheckDistance;
		if (Trace(HitLocation, HitNormal, TraceEnd, Location, TRUE) == None)
		{
			//Don't deploy if too close to other deployables
	    bIsDeployableNearby = class'UTDeployable'.static.DeployablesNearby(self, TraceEnd, class'UTDeployable'.default.DeployCheckRadiusSq);
			if (!bIsDeployableNearby)
			{
				return Super.CanDeploy(bShowMessage);
			}
			else
			{
				if (bShowMessage)
				{
					ReceiveLocalizedMessage(class'UTStealthVehicleMessage', 2);
				}
			}
		}
		else
		{
			if (bShowMessage)
			{
				ReceiveLocalizedMessage(class'UTStealthVehicleMessage', 0);
			}
		}
	}
	else
	{
		if (bShowMessage)
		{
			ReceiveLocalizedMessage(class'UTStealthVehicleMessage', 1);
		}
	}

	return FALSE;
}

function CancelDeploy()
{
	if(DeployedState == EDS_Deploying) // we'll have to wait till we're done
	{
		SetTimer(DeployTime - (WorldInfo.TimeSeconds - LastDeployStartTime)+0.1, false, 'ServerToggleDeploy');
	}
	else if (DeployedState == EDS_Deployed)
	{
		ServerToggleDeploy();
	}
}

/*
*/
function DisplayWeaponBar(Canvas canvas, UTHUD HUD)
{
	local int i, j, SelectedWeapon, SelectedWeaponAmmoCount, PrevWeapIndex, NextWeapIndex;
	local float TotalOffsetX, OffsetX, OffsetY, BoxOffsetSize, OffsetSizeX, OffsetSizeY, DesiredWeaponScale[10];
	local linearcolor AmmoBarColor;
	local float Delta, SelectedAmmoBarX, SelectedAmmoBarY;
	local UTVWeap_NightShadeGun Gun;

	Gun = UTVWeap_NightshadeGun(Seats[0].Gun);
	if ( Gun == None )
	{
		return;
	}

	SelectedWeapon = Gun.DeployableIndex;
	SelectedWeaponAmmoCount = Gun.Counts[SelectedWeapon];
	Delta = HUD.WeaponScaleSpeed * (WorldInfo.TimeSeconds - HUD.LastHUDUpdateTime);
	BoxOffsetSize = HUD.HUDScaleX * HUD.WeaponBarScale * HUD.WeaponBoxWidth;

	if ( (SelectedWeapon != LastSelectedWeapon) )
	{
		LastSelectedWeapon = SelectedWeapon;
		HUD.PlayerOwner.ReceiveLocalizedMessage( class'UTWeaponSwitchMessage',,,, Gun );
	}

	if ( class'Engine'.static.IsSplitScreen() )
	{
		 return;
	}

	// calculate offsets
	for ( i=0; i<Gun.NUMDEPLOYABLETYPES; i++ )
	{
		// optimization if needed - cache desiredweaponscale[] when pending weapon changes
		if ( SelectedWeapon == i && SelectedWeaponAmmoCount > 0 )
		{
			if ( BouncedWeapon == i )
			{
				DesiredWeaponScale[i] = HUD.SelectedWeaponScale;
			}
			else
			{
				DesiredWeaponScale[i] = HUD.BounceWeaponScale;
				if ( CurrentWeaponScale[i] >= DesiredWeaponScale[i] )
				{
					BouncedWeapon = i;
				}
			}
		}
		else
		{
			DesiredWeaponScale[i] = 1.0;
		}
		if ( CurrentWeaponScale[i] != DesiredWeaponScale[i] )
		{
			if ( DesiredWeaponScale[i] > CurrentWeaponScale[i] )
			{
				CurrentWeaponScale[i] = FMin(CurrentWeaponScale[i]+Delta,DesiredWeaponScale[i]);
			}
			else
			{
				CurrentWeaponScale[i] = FMax(CurrentWeaponScale[i]-Delta,DesiredWeaponScale[i]);
			}
		}
		TotalOffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
	}
	PrevWeapIndex = SelectedWeapon - 1;
	NextWeapIndex = SelectedWeapon + 1;

	OffsetX = HUD.HUDScaleX * HUD.WeaponBarXOffset + 0.5 * (Canvas.ClipX - TotalOffsetX);
	OffsetY = Canvas.ClipY - HUD.HUDScaleY * HUD.WeaponBarY;

	// @TODO - manually reorganize canvas calls, or can this be automated?
	// draw weapon boxes
	Canvas.SetDrawColor(255,255,255,255);
	OffsetSizeX = HUD.HUDScaleX * HUD.WeaponBarScale * 96 * HUD.SelectedBoxScale;
	OffsetSizeY = HUD.HUDScaleY * HUD.WeaponBarScale * 64 * HUD.SelectedBoxScale;

	for ( i=0; i<Gun.NUMDEPLOYABLETYPES; i++ )
	{
		Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
		if ( SelectedWeapon == i && SelectedWeaponAmmoCount > 0 )
		{
			//Current slot overlay
			HUD.TeamHudColor.A = HUD.SelectedWeaponAlpha;
			Canvas.DrawColorizedTile(HUD.AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 530, 248, 69, 49, HUD.TeamHUDColor);

			Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
			Canvas.DrawColorizedTile(HUD.AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 459, 148, 69, 49, HUD.TeamHUDColor);

			Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
			Canvas.DrawColorizedTile(HUD.AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 459, 248, 69, 49, HUD.TeamHUDColor);

			SelectedAmmoBarX = HUD.HUDScaleX * (HUD.SelectedWeaponAmmoOffsetX - HUD.WeaponBarXOffset) + OffsetX;
			SelectedAmmoBarY = Canvas.ClipY - HUD.HUDScaleY * (HUD.WeaponBarY + CurrentWeaponScale[i]*HUD.WeaponAmmoOffsetY);
		}
		else
		{
			HUD.TeamHudColor.A = HUD.OffWeaponAlpha;
			Canvas.DrawColorizedTile(HUD.AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 459, 148, 69, 49, HUD.TeamHUDColor);

			// draw slot overlay?
			if ( i == PrevWeapIndex && SelectedWeaponAmmoCount > 0 )
			{
				Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
				Canvas.DrawColorizedTile(HUD.AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 530, 97, 69, 49, HUD.TeamHUDColor);
			}
			else if ( i == NextWeapIndex && SelectedWeaponAmmoCount > 0 )
			{
				Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
				Canvas.DrawColorizedTile(HUD.AltHudTexture, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, 530, 148, 69, 49, HUD.TeamHUDColor);
			}
		}
		OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
	}

	// draw weapon icons - first so text appears on top
	OffsetX = HUD.HUDScaleX * HUD.WeaponXOffset + 0.5 * (Canvas.ClipX - TotalOffsetX);
	OffsetY = Canvas.ClipY - HUD.HUDScaleY * (HUD.WeaponBarY + HUD.WeaponYOffset);
	OffsetSizeX = HUD.HUDScaleX * HUD.WeaponBarScale * 100;
	OffsetSizeY = HUD.HUDScaleY * HUD.WeaponBarScale * HUD.WeaponYScale;
	for ( i=0; i<Gun.NUMDEPLOYABLETYPES; i++ )
	{
		if ( Gun.Counts[i] > 0 )
		{
			Canvas.SetDrawColor(255,255,255,255);
		}
		else
		{
			Canvas.SetDrawColor(48,48,48,128);
		}
		Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
		//Canvas.DrawTile(HUDIcons, CurrentWeaponScale[i]*OffsetSizeX, CurrentWeaponScale[i]*OffsetSizeY, Gun.IconCoords[i].U, Gun.IconCoords[i].V, Gun.IconCoords[i].UL, Gun.IconCoords[i].VL);
		DrawWeaponTile(Canvas, HUDIcons, Gun, i, OffsetSizeX, OffsetSizeY);
		OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
	}

	// draw weapon ammo bars
	// Ammo Bar:  273,494 12,13 (The ammo bar is meant to be stretched)
	Canvas.SetDrawColor(255,255,255,255);
	OffsetX = HUD.HUDScaleX * HUD.WeaponAmmoOffsetX + 0.5 * (Canvas.ClipX - TotalOffsetX);
	OffsetSizeY = HUD.HUDScaleY * HUD.WeaponBarScale * HUD.WeaponAmmoThickness;
	AmmoBarColor = MakeLinearColor(1.0,10.0,1.0,1.0);
	for ( i=0; i<Gun.NUMDEPLOYABLETYPES; i++ )
	{
		for ( j=0; j<Gun.Counts[i]; j++ )
		{
			if ( SelectedWeapon == i && SelectedWeaponAmmoCount > 0 )
			{
				Canvas.SetPos(SelectedAmmoBarX + j * 16 * HUD.HUDScaleY * HUD.WeaponBarScale * CurrentWeaponScale[i], SelectedAmmoBarY);
			}
			else
			{
				Canvas.SetPos(OffsetX + j * 16 * HUD.HUDScaleY * HUD.WeaponBarScale * CurrentWeaponScale[i], Canvas.ClipY - HUD.HUDScaleY * (HUD.WeaponBarY + CurrentWeaponScale[i]*HUD.WeaponAmmoOffsetY));
			}
			Canvas.DrawColorizedTile(HUD.AltHudTexture, 16 * HUD.HUDScaleY * HUD.WeaponBarScale * CurrentWeaponScale[i], CurrentWeaponScale[i]*OffsetSizeY, 273, 494,12,13,AmmoBarColor);
		}
		OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
	}

	// draw weapon numbers
	if ( !HUD.bNoWeaponNumbers )
	{
		OffsetX = HUD.HUDScaleX * (HUD.WeaponAmmoOffsetX + HUD.WeaponXOffset) * 0.5 + 0.5 * (Canvas.ClipX - TotalOffsetX);
		OffsetY = Canvas.ClipY - HUD.HUDScaleY * (HUD.WeaponBarY + HUD.WeaponYOffset);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.Font = class'UTHUD'.static.GetFontSizeIndex(0);
		for ( i=0; i<Gun.NUMDEPLOYABLETYPES; i++ )
		{
			Canvas.SetPos(OffsetX, OffsetY - OffsetSizeY*CurrentWeaponScale[i]);
			Canvas.DrawText(int((i+1)%10), false);
			OffsetX += CurrentWeaponScale[i] * BoxOffsetSize;
		}
	}
}

/** Draws a single weapon selection tile in the HUD
 *  Created primarily so Stealthbender could override texture for new UT3G deployables
 */
function DrawWeaponTile(Canvas Canvas, Texture2D IconTexture, UTVWeap_NightshadeGun Gun, int WeaponIndex, float OffsetSizeX, float OffsetSizeY)
{
	Canvas.DrawTile(IconTexture, CurrentWeaponScale[WeaponIndex]*OffsetSizeX, CurrentWeaponScale[WeaponIndex]*OffsetSizeY, 
					Gun.IconCoords[WeaponIndex].U, Gun.IconCoords[WeaponIndex].V, 
					Gun.IconCoords[WeaponIndex].UL, Gun.IconCoords[WeaponIndex].VL);
}

function bool ShouldDeployToAttack()
{
	return false;
}

/** called on a timer while AI controlled so AI can evaluate cloaking */
function CheckAICloak()
{
	local UTBot B;

	B = UTBot(Controller);
	if (B != None)
	{
		Cloak(B.Enemy != None || B.MoveTarget == None || !B.InLatentExecution(class'Controller'.const.LATENT_MOVETOWARD));
	}
	else
	{
		ClearTimer('CheckAICloak');
	}
}

/** used with bot's CustomAction interface to drop a deployable */
function bool BotDropDeployable(UTBot B)
{
	if (DeployedState == EDS_Undeployed)
	{
		ServerToggleDeploy();
		if (DeployedState == EDS_Undeployed && VSize(Velocity) < MaxDeploySpeed)
		{
			// failed for unknown reason, give up
			LastDropAttemptTime = WorldInfo.TimeSeconds;
			return true;
		}
		else
		{
			return false;
		}
	}
	else if (DeployedState == EDS_Deploying)
	{
		return false;
	}
	else
	{
		// attempt to drop a deployable
		LastDropAttemptTime = WorldInfo.TimeSeconds;
		if (DeployedState == EDS_Deployed)
		{
			BotFire(true);
			if (DeployedState == EDS_Deployed)
			{
				// most likely deploy failed - undeploy anyway so we don't get stuck trying
				ServerToggleDeploy();
			}
		}
		return true;
	}
}


function bool ShouldUndeploy(UTBot B) 
{
	return IsDeployed();
}


function bool GoodDefensivePosition()
{
	return !class'UTDeployable'.static.DeployablesNearby(self, Location, class'UTDeployable'.default.DeployCheckRadiusSq);
}

/** AI interface for dropping deployables
 * @return whether bot was given an action and so should exit its decision logic
 */
function bool ShouldDropDeployable()
{
	local UTBot B;
	local UTGameObjective O;

	B = UTBot(Controller);
	if (B != None && WorldInfo.TimeSeconds - LastDropAttemptTime > 3.0)
	{
		LastDropAttemptTime = WorldInfo.TimeSeconds;
		if ( class'UTDeployable'.static.DeployablesNearby(self, Location, class'UTDeployable'.default.DeployCheckRadiusSq) )
		{
			return false;
		}
		if ( (Health < FireDamageThreshold*default.Health) || (WorldInfo.TimeSeconds - LastDropSuccessTime > 10) )
		{
			B.PerformCustomAction(BotDropDeployable);
			return true;
		}
		else
		{
			// consider dropping a deployable if near a relevant objective
			foreach WorldInfo.RadiusNavigationPoints(class'UTGameObjective', O, Location, 1500.0)
			{
				if ((O.IsActive() || O.IsNeutral()) && FastTrace(O.Location, Location))
				{
						B.PerformCustomAction(BotDropDeployable);
						return true;
					}
				}
			}
		}
	return false;
}

function bool ImportantVehicle()
{
	local UTVWeap_NightShadeGun Gun;
	local int i;
	
	Gun = UTVWeap_NightshadeGun(Seats[0].Gun);
	if ( Gun == None )
	{
		return false;
	}
	for ( i=0; i<Gun.NUMDEPLOYABLETYPES; i++ )
	{
		if ( Gun.Counts[i] > 0 )
		{
			return true;
		}
	}
	return false;
}

function bool DriverEnter(Pawn P)
{
	LastDropSuccessTime = WorldInfo.TimeSeconds + 8;
	return Super.DriverEnter(P);
}

defaultproperties
{
	MaxDesireability=0.75

	CameraLag = 0
	FastCamTransitionTime=1.3
	ArmSpeedtune=8000  //25deg
	DeployArmCameraDist=250.0f
	DeployArmCameraPitch=-8500
	bHasWeaponBar=TRUE
	AIPurpose=AIP_Any

	CloakTotalResTime=.6f;

	HitEffectScale=2.0;

	HUDIconsUT3G=Texture2D'UI_GoldHud.HUDIcons'
	FireToolTipIconCoords=(U=137,V=131,UL=34,VL=41)

	OverlayTeamRezColor[0]=(R=7.f,G=.45f,B=.05f) //red team
	OverlayTeamRezColor[1]=(R=1.f,G=6.f,B=50.f)  //blue team
}

