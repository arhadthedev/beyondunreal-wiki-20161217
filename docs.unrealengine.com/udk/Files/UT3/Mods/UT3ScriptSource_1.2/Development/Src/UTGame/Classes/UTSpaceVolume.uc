class UTSpaceVolume extends UTWaterVolume;

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	super(PhysicsVolume).Touch(Other, OtherComp, HitLocation, HitNormal);
}

simulated function PlayEntrySplash(Actor Other)
{
}

defaultproperties
{
}