/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTDmgType_NightshadeBeam extends UTDamageType
	abstract;

var ParticleSystem PS_AttachToGib;

var name BoneToAttach;
var ParticleSystem PS_AttachToBody;

static function DoCustomDamageEffects(UTPawn ThePawn, class<UTDamageType> TheDamageType, const out TraceHitInfo HitInfo, vector HitLocation)
{
	// call this so we don't have code duplication
	class'UTDmgType_LinkBeam'.static.DoCustomDamageEffects( ThePawn, TheDamageType, HitInfo, HitLocation );
}


/** allows special effects when gibs are spawned via DoCustomDamageEffects() instead of the normal way */
simulated static function SpawnExtraGibEffects(UTGib TheGib)
{
	if ( (TheGib.WorldInfo.GetDetailMode() != DM_Low) && !TheGib.WorldInfo.bDropDetail && FRand() < 0.70f )
	{
		TheGib.PSC_GibEffect = new(TheGib) class'UTParticleSystemComponent';
		TheGib.PSC_GibEffect.SetTemplate(default.PS_AttachToGib);
		TheGib.AttachComponent(TheGib.PSC_GibEffect);
	}
}

defaultproperties
{
	KillStatsName=KILLS_NIGHTSHADEGUN
	DeathStatsName=DEATHS_NIGHTSHADEGUN
	SuicideStatsName=SUICIDES_NIGHTSHADEGUN
	DamageWeaponClass=class'UTVWeap_NightShadeGun'
	DamageWeaponFireMode=1

	DamageBodyMatColor=(R=50,G=50,B=50)
	DamageOverlayTime=0.5
	DeathOverlayTime=1.0

	bCausesBlood=false
	bLeaveBodyEffect=true
	bUseDamageBasedDeathEffects=true
	VehicleDamageScaling=0.8
	VehicleMomentumScaling=0.1

	KDamageImpulse=100

	PS_AttachToGib=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Death_Gib_Effect'
	DamageCameraAnim=CameraAnim'Camera_FX.LinkGun.C_WP_Link_Beam_Hit'

	BoneToAttach="b_Spine1"
	PS_AttachToBody=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Skeleton_Dissolve'
}
