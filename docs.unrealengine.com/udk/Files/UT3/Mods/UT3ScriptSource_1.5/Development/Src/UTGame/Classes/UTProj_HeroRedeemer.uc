/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_HeroRedeemer extends UTProj_RedeemerBase;

var repnotify bool bDoExplosionEffects;

replication
{
	if ( bNetDirty )
		bDoExplosionEffects;
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'bDoExplosionEffects' )
	{
		if ( bDoExplosionEffects == true )
		{
			SpawnExplosionEffects(Location, vect(0,0,1));
		}
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	bDoExplosionEffects = true;
	Super.SpawnExplosionEffects(HitLocation, HitNormal);
}

defaultproperties
{
	MyDamageType=class'UTGame.UTDmgType_HeroBomb'

	bAlwaysRelevant=true

	DistanceExplosionTemplates[0]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Far',MinDistance=2200.0)
	DistanceExplosionTemplates[1]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Mid',MinDistance=1500.0)
	DistanceExplosionTemplates[2]=(Template=ParticleSystem'WP_Redeemer.Particles.P_WP_Redeemer_Explo_Near',MinDistance=0.0)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+020.000000
		CollisionHeight=+012.000000
		Translation=(X=40.0)
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=false
		CollideActors=true
	End Object
	CylinderComponent=CollisionCylinder

	ExplosionSound=SoundCue'A_Titan_Extras.Redeemer.A_Weapon_Redeemer_ExplodeCue'

	ExplosionShake=CameraAnim'Camera_FX_02.WP_Redeemer.C_WP_Redeemer_Shake_UT3G'

	ExplosionClass=class'UTEmit_HeroRedeemerExplosion'
}
