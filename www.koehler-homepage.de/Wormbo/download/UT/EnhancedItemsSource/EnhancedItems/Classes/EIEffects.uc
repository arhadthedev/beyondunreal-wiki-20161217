// EnhancedItems by Wormbo
//=============================================================================
// EIEffects.
//=============================================================================

class EIEffects extends Effects abstract;

var bool bDestroyMe;	// the effect is about to be destroyed, set by DestroyMe()
var EIDeathMessageMutator EIDMM;

// Destroy this effect.
// Needn't be instant destruction. (see PlayerShellEffect)
function DestroyMe()
{
	bDestroyMe = True;
	Destroy();
}

final function SetKillType(bool bSplashHit, bool bHeadHit, class<Actor> DamageProjectileClass)
{
	if ( EIDMM != None )
		EIDMM.AddDamageActor(DamageProjectileClass, bSplashHit, bHeadHit);
}

final function RestoreKillType()
{
	if ( EIDMM != None )
		EIDMM.RemoveDamageActor();
}

defaultproperties
{
}
