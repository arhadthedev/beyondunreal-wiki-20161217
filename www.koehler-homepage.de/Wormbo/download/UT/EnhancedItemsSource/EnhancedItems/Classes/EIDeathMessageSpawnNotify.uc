class EIDeathMessageSpawnNotify extends SpawnNotify;

var EIDeathMessageMutator EIDMM;

simulated event Actor SpawnNotification(Actor A)
{
	if ( EIDMM == None )
		return A;
	
	if ( A.IsA('EnhancedWeapon') )
		EnhancedWeapon(A).EIDMM = EIDMM;
	else if ( A.IsA('EnhancedProjectile') )
		EnhancedProjectile(A).EIDMM = EIDMM;
	else if ( A.IsA('EnhancedAmmo') )
		EnhancedAmmo(A).EIDMM = EIDMM;
	else if ( A.IsA('EIEffects') )
		EIEffects(A).EIDMM = EIDMM;
	else if ( A.IsA('EnhancedMutator') )
		EnhancedMutator(A).EIDMM = EIDMM;
	else if ( A.IsA('PickupPlus') )
		PickupPlus(A).EIDMM = EIDMM;
	return A;
}

defaultproperties
{
     ActorClass=class'Engine.Actor'
}