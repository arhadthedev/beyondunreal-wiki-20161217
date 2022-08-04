class UTProj_HeroRocket extends UTProj_SeekingRocket;

var array<DistanceBasedParticleTemplate> DistanceExplosionTemplates;

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	ProjExplosionTemplate = class'UTEmitter'.static.GetTemplateForDistance(DistanceExplosionTemplates, HitLocation, WorldInfo);

	Super.SpawnExplosionEffects(HitLocation, HitNormal);
}

defaultproperties
{
	MyDamageType=class'UTDmgType_HeroRocket'
	BaseTrackingStrength=2.0

	DistanceExplosionTemplates[0]=(Template=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo_far',MinDistance=3500.0)
	DistanceExplosionTemplates[1]=(Template=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo_mid',MinDistance=450.0)
	DistanceExplosionTemplates[2]=(Template=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo_close',MinDistance=0.0)

	ProjFlightTemplate=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Smoke_Trail'
	ProjExplosionTemplate=ParticleSystem'WP_AVRiL.Particles.P_WP_Avril_Explo'

	speed=1000.0
	MaxSpeed=1000.0
	DamageRadius=200.0
}