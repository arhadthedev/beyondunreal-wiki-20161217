// EnhancedItems by Wormbo
//=============================================================================
// PlayerShellEffect.
//=============================================================================

class PlayerShellEffect extends EIEffects;

var() float FormTime, VanishTime, VisibleTime, AnimTime, GlowTime, FlashTime;
var() float MinGlow, MaxGlow;
var float CurGlow;
var() float GlowRate, AnimRate;

var() Enum EFormAnim {
	SFORM_Instant,	// no forming animation
	SFORM_Grow,		// scale size from StartSize to MinSize
	SFORM_LightUp,	// scale ambient glow (transparency) from 0 to MinGlow
	SFORM_GrowLightUp	// scale size from StartSize to MinSize and ambient glow from 0 to MinGlow
} FormAnim;

var() Enum EVisibleAnim {
	SVIS_None,		// no animation at all
	SVIS_Pulse,		// scale size between MinSize and MaxSize
	SVIS_Expand,	// scale size from MinSize to MaxSize, then jump back to MinSize
	SVIS_Collaps,	// scale size from MaxSize to MinSize, then jump back to MaxSize
	SVIS_Restore	// restore size to MinSize if different
} VisibleAnim;

var() Enum EGlowAnim {
	SGLOW_Steady,	// ambient glow doesn't change over time
	SGLOW_LightUp,	// scale ambient glow from MaxGlow to MinGlow, then jump back to MaxGlow
	SGLOW_Darken,	// scale ambient glow from MinGlow to MaxGlow, then jump back to MinGlow
	SGLOW_Blink,	// scale ambient glow between MinGlow and MaxGlow
	SGLOW_Restore	// restore ambient glow to MinGlow if different
} GlowAnim;

var() Enum EVanishAnim {
	SVANISH_Instant,	// disappears instantly
	SVANISH_Shrink,		// scale size to StartSize
	SVANISH_Fade,		// scale ambient glow to 0
	SVANISH_ShrinkFade,	// scale size to StartSize and ambient glow to 0
	SVANISH_GrowFade	// scale size to EndSize and ambient glow to 0
} VanishAnim;

var PickupPlus Master;	// the item that created this effect
var() bool bIdleLight;	// keep light effect in Idle state

// for PlayerSphere (EndSize will be used with SVANISH_GrowFade)
var float CurSize;
var() float StartSize, MinSize, MaxSize, EndSize;

// for PlayerShell
var int CurOffset;
var() int MinOffset, MaxOffset;

function SetFlashTime(float NewFlashTime)
{
	FlashTime = Max(FlashTime, NewFlashTime);
}

function UpdateFlash(float DeltaTime)
{
	if ( !bDestroyMe && (Owner == None || (Pawn(Owner) != None && Pawn(Owner).Health <= 0)) )
		DestroyMe();
	
	if ( Owner.IsA('PlayerPawn') )
		bOwnerNoSee = Default.bOwnerNoSee && PlayerPawn(Owner).ViewTarget == None
				&& !PlayerPawn(Owner).bBehindView;
	
	if ( FlashTime > 0 ) {
		FlashTime -= DeltaTime;
		if ( Default.Style == STY_Translucent )
			Style = STY_Normal;
	}
	if ( FlashTime < 0 )
		FlashTime = 0;
	if ( FlashTime == 0 && Style != STY_Translucent && Default.Style == STY_Translucent )
		Style = STY_Translucent;
}

function ShowMe()
{
	if ( IsInState('Idle') )
		GotoState('Forming');
}

// use this instead of Destroy()
function DestroyMe()
{
	bDestroyMe = True;
	
	VisibleTime = 0.0;
	
	if ( IsInState('Visible') || IsInState('Forming') ) {
		CurSize = DrawScale;
		CurGlow = ScaleGlow;
		GotoState('Vanishing', 'Begin');
	}
	else if ( bHidden || !IsInState('Vanishing') )
		Destroy();
}

state Forming
{
	function Tick(float DeltaTime)
	{
		AnimTime += DeltaTime;
		UpdateAppearance();
		UpdateFlash(DeltaTime);
	}
	
	function UpdateAppearance();
			
Begin:
	bHidden = False;
	LightType = Default.LightType;
	AnimTime = 0.0;
	UpdateAppearance();
	if ( FormAnim != SFORM_Instant && FormTime > 0 )
		Sleep(FormTime);
	GotoState('Visible');
}

state Visible
{
	function Tick(float DeltaTime)
	{
		AnimTime += DeltaTime;
		GlowTime += DeltaTime;
		UpdateAppearance();
		UpdateFlash(DeltaTime);
	}
	
	function UpdateAppearance();
			
Begin:
	AnimTime = 0.0;
	GlowTime = 0.0;
	if ( VisibleTime > 0.0 ) {
		Sleep(VisibleTime);
		CurSize = DrawScale;
		CurGlow = ScaleGlow;
		MinOffset = CurOffset;
		GotoState('Vanishing');
	}
}

state Vanishing
{
	function Tick(float DeltaTime)
	{
		AnimTime += DeltaTime;
		UpdateAppearance();
		UpdateFlash(DeltaTime);
	}
	
	function UpdateAppearance();
			
Begin:
	AnimTime = 0.0;
	if ( VanishAnim != SVANISH_Instant && VanishTime > 0 )
		Sleep(VanishTime);
	if ( !bDestroyMe )
		GotoState('Idle');
	else
		Destroy();
}

auto state Idle
{
	Ignores Touch, Tick;
	
	function EndState()
	{
		FlashTime = 0;
		Super.EndState();
	}
Begin:
	bHidden = True;
	if ( bIdleLight )
		LightType = Default.LightType;
	else
		LightType = LT_None;
}	

state PickupShell
{
	simulated function Tick(float DeltaTime)
	{
		if ( Master == None ) {
			GotoState('Idle');
			return;
		}
		SetLocation(Master.Location);
		SetRotation(Master.Rotation);
		Velocity = Master.Velocity;
		//Mesh = Master.Mesh;
		DrawScale = Default.DrawScale;
		AmbientGlow = Default.AmbientGlow;
		ScaleGlow = Default.ScaleGlow;
		Fatness = Default.Fatness;
		Texture = Master.PickupShellSkin;
	}
Begin:
	bHidden = False;
	LightType = LT_None;
}

defaultproperties
{
     bTrailerSameRotation=True
     bOwnerNoSee=True
     bNetTemporary=False
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     LODBias=0.500000
     DrawType=DT_Mesh
     Style=STY_Translucent
}
