// shield or aura around the player or an item, using its mesh
class PlayerShell extends PlayerShellEffect;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( MaxOffset == -1 ) MaxOffset = GetMaxOffset();
}

function byte GetIdealFatness(int FatnessOffset)
{
	local int IdealFatness;
	
	if ( Master==None ) return 128;
	if ( Master.Owner==None ) return 128;
	
	IdealFatness = Master.Owner.Fatness; // Convert to int for safety.
	IdealFatness += FatnessOffset;

	return Clamp(IdealFatness, 0, 255);
}

function int GetMaxOffset()
{
	if ( Master == None ) return 128;
	if ( Master.Owner == None ) return 128;
	return 255 - Owner.Fatness;
}

function ShowMe()
{
	Super.ShowMe();
	
	if ( Master != None && Master.Owner != None ) {
		Mesh = Master.Owner.Mesh;
		DrawScale = Master.Owner.Drawscale;
		Texture = Master.ShellSkin;
	}
}

state Forming
{
	function UpdateAppearance()
	{
		switch(FormAnim) {
			case SFORM_Instant:
				ScaleGlow = MaxGlow;
				CurOffset = MaxOffset;
				break;
			case SFORM_Grow:
				ScaleGlow = MaxGlow;
				CurOffset = MaxOffset * AnimTime / FormTime;
				break;
			case SFORM_LightUp:
				ScaleGlow = MaxGlow * AnimTime / FormTime;
				CurOffset = MaxOffset;
				break;
			case SFORM_GrowLightUp:
				ScaleGlow = MaxGlow * AnimTime / FormTime;
				CurOffset = MaxOffset * AnimTime / FormTime;
				break;
		}
		Fatness = GetIdealFatness(CurOffset);
		AmbientGlow = Default.AmbientGlow * ScaleGlow;
	}
}

state Visible
{
	function UpdateAppearance()
	{
		if ( AnimTime > AnimRate )
			AnimTime = 0;
		if ( GlowTime > GlowRate )
			GlowTime = 0;
		
		switch(VisibleAnim) {
			case SVIS_Pulse:
				if ( AnimTime > AnimRate / 2 )
					CurOffset = MinOffset * 2 * (AnimRate - AnimTime) / AnimRate
							+ MaxOffset * (AnimTime * 2 - AnimRate) / AnimRate;
				else
					CurOffset = MaxOffset * (AnimRate - AnimTime * 2) / AnimRate
							+ MinOffset * AnimTime * 2 / AnimRate;
				break;
			case SVIS_Expand:
				CurOffset = MinOffset * (AnimRate - AnimTime) / AnimRate + MaxOffset * AnimTime / AnimRate;
				break;
			case SVIS_Collaps:
				CurOffset = MaxOffset * (AnimRate - AnimTime) / AnimRate + MinOffset * AnimTime / AnimRate;
				break;
			case SVIS_Restore:
				CurOffset = MinOffset * FMax(AnimRate - FlashTime, 0) / AnimRate + MaxOffset * FlashTime / AnimRate;
				break;
			default:
				CurOffset = MaxOffset;
				break;
		}
		Fatness = GetIdealFatness(CurOffset);

		switch(GlowAnim) {
			case SGLOW_LightUp:
				ScaleGlow = MinGlow * (GlowRate - GlowTime) / GlowRate + MaxGlow * GlowTime / GlowRate;
				break;
			case SGLOW_Darken:
				ScaleGlow = MaxGlow * (GlowRate - GlowTime) / GlowRate + MinGlow * GlowTime / GlowRate;
				break;
			case SGLOW_Blink:
				if ( GlowTime > GlowRate / 2 )
					ScaleGlow = MinGlow * 2 * (GlowRate - GlowTime) / GlowRate
							+ MaxGlow * (GlowTime * 2 - GlowRate) / GlowRate;
				else
					ScaleGlow = MaxGlow * (GlowRate - GlowTime * 2) / GlowRate
							+ MinGlow * GlowTime * 2 / GlowRate;
				break;
			case SGLOW_Restore:
				ScaleGlow = MinGlow * FMax(GlowRate - FlashTime, 0) / GlowRate + MaxGlow * FlashTime / GlowRate;
				break;
			default:
				ScaleGlow = MaxGlow;
				break;
		}
		AmbientGlow = Default.AmbientGlow * ScaleGlow;
	}
}

state Vanishing
{
	function UpdateAppearance()
	{
		switch(VanishAnim) {
			case SVANISH_Instant:
				ScaleGlow = 0;
				break;
			case SVANISH_Fade:
				ScaleGlow = CurGlow * (VanishTime - AnimTime) / VanishTime;
				break;
			case SVANISH_Shrink:
				CurOffset = MinOffset * (VanishTime - AnimTime) / AnimRate;
				break;
			case SVANISH_ShrinkFade:
				ScaleGlow = CurGlow * (VanishTime - AnimTime) / VanishTime;
				CurOffset = MinOffset * (VanishTime - AnimTime) / AnimRate;
				break;
			case SVANISH_GrowFade:
				ScaleGlow = CurGlow * (VanishTime - AnimTime) / VanishTime;
				CurOffset = MinOffset * (VanishTime - AnimTime) / AnimRate
						+ GetMaxOffset() * AnimTime / AnimRate;
				break;
		}
		Fatness = GetIdealFatness(CurOffset);
		AmbientGlow = Default.AmbientGlow * ScaleGlow;
	}
}

state PickupShell
{
	simulated function Tick(float DeltaTime)
	{
		if ( Master == None ) {
			GotoState('Idle');
			return;
		}
		Super.Tick(DeltaTime);
		Mesh = Master.Mesh;
		DrawScale = Master.DrawScale;
		Fatness = Clamp(Master.Fatness + MaxOffset, 0, 255);
	}
}

defaultproperties
{
     bAnimByOwner=True
     MinGlow=0.500000
     MaxGlow=1.000000
     MinOffset=16
     MaxOffset=64
     Texture=None
     ScaleGlow=0.500000
     AmbientGlow=64
     bUnlit=True
     bMeshEnviroMap=True
}
