/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTWalkerBody_DarkWalker extends UTWalkerBody;

/** Light attached to the energy ball. */
var() protected PointLightComponent EnergyBallLight;

/** Holds energy ball's material so we can modify parameters. */
var protected transient MaterialInstanceConstant EnergyBallMatInst;

/** Current percentage the energy ball is powered.  Range [0..1]. */
var private transient float CurrentEnergyBallPowerPct;
/** Goal energy ball power percentage (to interpolate towards).  Range [0..1]. */
var private transient float GoalEnergyBallPowerPct;

/** InterpSpeed (for FInterpTo) used for interpolating the energy ball power up and down. */
var() protected const float EnergyBallPowerInterpSpeed;

/** Color for energy ball light in powered-on state. */
var() protected const color EnergyBallLightColor_PoweredOn;
/** Color for energy ball light in powered-off state. */
var() protected const color EnergyBallLightColor_PoweredOff;

/** Color for blue energy ball light in powered-on state. */
var() protected const color EnergyBallLightColor_PoweredOn_Blue;
/** Color for blue energy ball light in powered-off state. */
var() protected const color EnergyBallLightColor_PoweredOff_Blue;



/** Brightness for energy ball light in powered-on state. */
var() protected const float EnergyBallLightBrightness_PoweredOn;
/** Brightness for energy ball light in powered-off state. */
var() protected const float EnergyBallLightBrightness_PoweredOff;

/** Made a parameter because having an = in a name literal is verboten for some reason. */
var protected const Name	EnergyBallMaterialParameterName;


/** Emitters for beams connecting powerball to shoulders */
var protected ParticleSystemComponent	LegAttachBeams[NUM_WALKER_LEGS];
/** Name of beam endpoint parameter in the particle system */
var protected const name				LegAttachBeamEndPointParamName;

/** ParticleSystem Templates for the Leg beams **/
var protected ParticleSystem PS_LegBeamTemplate;
var protected ParticleSystem PS_LegBeamTemplate_Blue;

/** Names of the top leg bones.  LegAttachBeams will terminate here. */
var protected const name				TopLegBoneName[NUM_WALKER_LEGS];

/** These keep the previous location of the legs and body so that we don't have to do expensive line traces if we have actually not moved their position **/
var protected vector PreviousLegLocation[NUM_WALKER_LEGS];

/** camera anim played when foot lands nearby */
var CameraAnim FootStepShake;
var float FootStepShakeRadius;

function PostBeginPlay()
{
	local int Idx;

	super.PostBeginPlay();

	EnergyBallMatInst = SkeletalMeshComponent.CreateAndSetMaterialInstanceConstant(1);
	SetEnergyBallPowerPercent(0.f);

	// attach powerball light to the ball
	SkeletalMeshComponent.AttachComponent(EnergyBallLight, BodyBoneName);

	// attach leg attach beam emitters to the ball
	for (Idx=0; Idx<NUM_WALKER_LEGS; ++Idx)
	{
		SkeletalMeshComponent.AttachComponent(LegAttachBeams[Idx], BodyBoneName);
	}
}

final protected function SetEnergyBallPowerPercent(float Pct)
{
	local float NewBrightness;
	local color NewColor;

	if( WalkerVehicle == none )
	{
		return;
	}

	// store it
	CurrentEnergyBallPowerPct = Pct;

	// set light color and brightness
	if( WalkerVehicle.GetTeamNum() == 1 )
	{
		NewColor = EnergyBallLightColor_PoweredOff_Blue + (EnergyBallLightColor_PoweredOn_Blue - EnergyBallLightColor_PoweredOff) * CurrentEnergyBallPowerPct;

	}
	else
	{
		NewColor = EnergyBallLightColor_PoweredOff + (EnergyBallLightColor_PoweredOn - EnergyBallLightColor_PoweredOff) * CurrentEnergyBallPowerPct;
	}


	NewBrightness = EnergyBallLightBrightness_PoweredOff + (EnergyBallLightBrightness_PoweredOn - EnergyBallLightBrightness_PoweredOff) * CurrentEnergyBallPowerPct;

	//`log( "SetEnergyBallPowerPercent: " $ WalkerVehicle.GetTeamNum() $ " NewBrightness: " $ NewBrightness );

	EnergyBallLight.SetLightProperties(NewBrightness, NewColor);

	// set material param
	EnergyBallMatInst.SetScalarParameterValue(EnergyBallMaterialParameterName, CurrentEnergyBallPowerPct);
}

event PlayFootStep(int LegIdx)
{
	local UTPlayerController PC;
	local float Dist;

	Super.PlayFootStep(LegIdx);

	foreach LocalPlayerControllers(class'UTPlayerController', PC)
	{
		if (UTVehicleBase(PC.ViewTarget) == None || WalkerVehicle.Seats.Find('SeatPawn', UTVehicleBase(PC.ViewTarget)) == INDEX_NONE)
		{
			Dist = VSize(CurrentFootPosition[LegIdx] - PC.ViewTarget.Location);
			if (Dist < FootStepShakeRadius)
			{
				PC.PlayCameraAnim(FootStepShake, 1.0 - (Dist / FootStepShakeRadius));
			}
		}
	}
}

function Tick(float DeltaTime)
{
	local float NewPowerPct, NewBrightness;
	local int Idx;
	local vector LegLocation;

	super.Tick(DeltaTime);

	// ball is powered on when driven, powered off otherwise
	GoalEnergyBallPowerPct = (WalkerVehicle.bDriving && !WalkerVehicle.bDeadVehicle) ? 1.f : 0.f;

	if (GoalEnergyBallPowerPct != CurrentEnergyBallPowerPct)
	{
		NewPowerPct = FInterpTo(CurrentEnergyBallPowerPct, GoalEnergyBallPowerPct, DeltaTime, EnergyBallPowerInterpSpeed);
		SetEnergyBallPowerPercent(NewPowerPct);
	}
	else if (WalkerVehicle.bDeadVehicle)
	{
		// this will fade light to zero after it gets to the zero-energy color
		NewBrightness = FInterpTo(EnergyBallLight.Brightness, 0.f, DeltaTime, EnergyBallPowerInterpSpeed);
		EnergyBallLight.SetLightProperties(NewBrightness);
		EnergyBallMatInst.SetScalarParameterValue(EnergyBallMaterialParameterName, 0.0f);
	}

	// set leg attach beam endpoints
	for (Idx=0; Idx<NUM_WALKER_LEGS; ++Idx)
	{
		LegLocation = SkeletalMeshComponent.GetBoneLocation(TopLegBoneName[Idx]);

		if( VSize(PreviousLegLocation[Idx] - LegLocation) > 1.0f )
		{
			//`log( "Ticking Walker PSC: " $ LegAttachBeams[Idx] );
			LegAttachBeams[Idx].SetVectorParameter(LegAttachBeamEndPointParamName, LegLocation );
			PreviousLegLocation[Idx] = LegLocation;
		}
	}
}


/** NOTE:  this is actually what changes the colors on the PowerOrb on the legs of the Walker **/
simulated function TeamChanged()
{
	local int LegIdx;
	local ParticleSystem PS_LegBeam;

	Super.TeamChanged();

	if( WalkerVehicle.GetTeamNum() == 1 )
	{
		PS_LegBeam=PS_LegBeamTemplate_Blue;
	}
	else
	{
		PS_LegBeam=PS_LegBeamTemplate;
	}

	for( LegIdx = 0; LegIdx < NUM_WALKER_LEGS; ++LegIdx )
	{
		LegAttachBeams[LegIdx].SetTemplate( PS_LegBeam );
	}

	SetEnergyBallPowerPercent( CurrentEnergyBallPowerPct );
}

/** NOTE:  this is actually what changes the colors on the PowerOrb on the legs of the Walker **/
simulated function SetBurnOut()
{
	local int LegIdx;

	Super.SetBurnOut();

	for( LegIdx = 0; LegIdx < NUM_WALKER_LEGS; ++LegIdx )
	{
		LegAttachBeams[LegIdx].DeactivateSystem();
	}
}





defaultproperties
{
	bHasCrouchMode=true
	FootStepEffects[0]=(MaterialType=Dirt,Sound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_FootstepCue',ParticleTemplate=ParticleSystem'VH_Darkwalker.Effects.P_VH_DarkWalker_FootImpact_Dust')
	FootStepEffects[1]=(MaterialType=Snow,Sound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_FootstepCue',ParticleTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_FootImpact_Snow')
	FootStepEffects[2]=(MaterialType=Water,Sound=SoundCue'A_Vehicle_DarkWalker.Cue.A_Vehicle_DarkWalker_FootstepCue',ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_DarkWalker_Water_Splash')

	FootWaterEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_DarkWalker_Water_Splash'

	Begin Object Name=LegMeshComponent
		SkeletalMesh=SkeletalMesh'VH_DarkWalker.Mesh.SK_VH_DarkWalker_Legs'
		PhysicsAsset=PhysicsAsset'VH_DarkWalker.Mesh.SK_VH_DarkWalker_Legs_Physics_NewLegs'
		AnimSets(0)=AnimSet'VH_DarkWalker.Anims.K_VH_DarkWalker_Legs'
		AnimTreeTemplate=AnimTree'VH_DarkWalker.Anims.AT_VH_DarkWalker_Legs'
		bUpdateJointsFromAnimation=TRUE
	End Object

	MinStepDist=120.0
	MaxLegReach=750.0
	LegSpreadFactor=0.6

	CustomGravityScale=0.f
	FootEmbedDistance=32.0

	LandedFootDistSq=2500.0

	FootStepAnimNodeName[0]="Leg0 Step"
	FootStepAnimNodeName[1]="Leg1 Step"
	FootStepAnimNodeName[2]="Leg2 Step"

	//point light
	Begin Object Class=PointLightComponent Name=Light0
		Radius=300.f
		CastShadows=FALSE
		bForceDynamicLight=FALSE
		bEnabled=TRUE
		FalloffExponent=4.f
		LightingChannels=(BSP=FALSE,Static=FALSE,Dynamic=TRUE,bInitialized=TRUE)
	End Object
	EnergyBallLight=Light0

	EnergyBallLightColor_PoweredOn=(R=250,G=231,B=126)
	EnergyBallLightColor_PoweredOff=(R=150,G=50,B=10)

	EnergyBallLightColor_PoweredOn_Blue=(R=89,G=153,B=217)
	EnergyBallLightColor_PoweredOff_Blue=(R=10,G=50,B=150)

	EnergyBallLightBrightness_PoweredOn=8.f
	EnergyBallLightBrightness_PoweredOff=6.f

	EnergyBallMaterialParameterName="Scalar"

	EnergyBallPowerInterpSpeed=1.5f

	PS_LegBeamTemplate=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_PowerBall_Idle'
	PS_LegBeamTemplate_Blue=ParticleSystem'VH_DarkWalker.Effects.P_VH_DarkWalker_PowerBall_Idle_Blue'

	Begin Object Class=ParticleSystemComponent Name=LegAttachPSC_0
		bAutoActivate=TRUE
		SecondsBeforeInactive=1.0f
	End Object
	LegAttachBeams[0]=LegAttachPSC_0

	Begin Object Class=ParticleSystemComponent Name=LegAttachPSC_1
		bAutoActivate=TRUE
		SecondsBeforeInactive=1.0f
	End Object
	LegAttachBeams[1]=LegAttachPSC_1

	Begin Object Class=ParticleSystemComponent Name=LegAttachPSC_2
		bAutoActivate=TRUE
		SecondsBeforeInactive=1.0f
	End Object
	LegAttachBeams[2]=LegAttachPSC_2

	LegAttachBeamEndPointParamName=DarkwalkerLegEnd

	TopLegBoneName[0]=Leg1_Bone1
	TopLegBoneName[1]=Leg2_Bone1
	TopLegBoneName[2]=Leg3_Bone1

	FootStepShakeRadius=1000.0
	FootStepShake=CameraAnim'Camera_FX.DarkWalker.C_VH_DarkWalker_Step_Shake'
}
