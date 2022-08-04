class PlayerSphere extends PlayerShellEffect;

var() float SizeAdjust;
var() bool bUseVortexSphere;

// try to find the c_VortexShpere of ChaosUT (looks better)
simulated function PreBeginPlay()
{
	local mesh m;
	
	if ( !bUseVortexSphere ) return;
	
	m = mesh(DynamicLoadObject("ChaosUTMedia2.c_vortexsphere", class'Mesh', True));
	// radius of c_vortexsphere is twice the radius of ShockWaveM
	if ( m != None ) {
		Mesh = m;
		DrawScale *= 0.5;
		StartSize *= 0.5;
		EndSize *= 0.5;
		MaxSize *= 0.5;
		MinSize *= 0.5;
		SizeAdjust *= 2;
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	MultiSkins[1] = Texture;
}

state Forming
{
	function UpdateAppearance()
	{
		switch(FormAnim) {
			case SFORM_Instant:
				ScaleGlow = MaxGlow;
				DrawScale = MaxSize;
				break;
			case SFORM_Grow:
				ScaleGlow = MaxGlow;
				DrawScale = StartSize * (FormTime - AnimTime) / FormTime + MaxSize * AnimTime / FormTime;
				break;
			case SFORM_LightUp:
				ScaleGlow = MaxGlow * AnimTime / FormTime;
				DrawScale = MaxSize;
				break;
			case SFORM_GrowLightUp:
				ScaleGlow = MaxGlow * AnimTime / FormTime;
				DrawScale = StartSize * (FormTime - AnimTime) / FormTime + MaxSize * AnimTime / FormTime;
				break;
		}
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
				if ( AnimTime > AnimRate * 0.5 )
					DrawScale = MinSize * 2 * (AnimRate - AnimTime) / AnimRate
							+ MaxSize * (AnimTime * 2 - AnimRate) / AnimRate;
				else
					DrawScale = MaxSize * (AnimRate - AnimTime * 2) / AnimRate
							+ MinSize * (AnimTime * 2) / AnimRate;
				break;
			case SVIS_Expand:
				DrawScale = MinSize * (AnimRate - AnimTime) / AnimRate + MaxSize * AnimTime / AnimRate;
				break;
			case SVIS_Collaps:
				DrawScale = MaxSize * (AnimRate - AnimTime) / AnimRate + MinSize * AnimTime / AnimRate;
				break;
			case SVIS_None:
				CurOffset = MinSize * FMax(AnimRate - FlashTime, 0) / AnimRate + MaxSize * FlashTime / AnimRate;
				break;
			default:
				DrawScale = MaxSize;
				break;
		}

		switch(GlowAnim) {
			case SGLOW_LightUp:
				ScaleGlow = MinGlow * (GlowRate - GlowTime) / GlowRate + MaxGlow * GlowTime / GlowRate;
				break;
			case SGLOW_Darken:
				ScaleGlow = MaxGlow * (GlowRate - GlowTime) / GlowRate + MinGlow * GlowTime / GlowRate;
				break;
			case SGLOW_Blink:
				if ( GlowTime > GlowRate * 0.5 )
					ScaleGlow = MinGlow * 2 * (GlowRate - GlowTime) / GlowRate
							+ MaxGlow * (GlowTime * 2 - GlowRate) / GlowRate;
				else
					ScaleGlow = MaxGlow * (GlowRate - GlowTime * 2) / GlowRate
							+ MinGlow * (GlowTime * 2) / GlowRate;
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
				DrawScale = CurSize * (VanishTime - AnimTime) / VanishTime + StartSize * AnimTime / VanishTime;
				break;
			case SVANISH_ShrinkFade:
				ScaleGlow = CurGlow * (VanishTime - AnimTime) / VanishTime;
				DrawScale = CurSize * (VanishTime - AnimTime) / VanishTime + StartSize * AnimTime / VanishTime;
				break;
			case SVANISH_GrowFade:
				ScaleGlow = CurGlow * (VanishTime - AnimTime) / VanishTime;
				DrawScale = CurSize * (VanishTime - AnimTime) / VanishTime + EndSize * AnimTime / VanishTime;
				break;
		}
		AmbientGlow = Default.AmbientGlow * ScaleGlow;
	}
}

defaultproperties
{
     bUseVortexSphere=True
     SizeAdjust=29.000000
     MinGlow=0.500000
     MaxGlow=1.000000
     StartSize=0.010000
     MinSize=0.900000
     MaxSize=1.100000
     EndSize=2.000000
     bAnimByOwner=False
     Mesh=LodMesh'Botpack.ShockRWM'
     DrawScale=2.000000
     AmbientGlow=254
     bUnlit=True
}
