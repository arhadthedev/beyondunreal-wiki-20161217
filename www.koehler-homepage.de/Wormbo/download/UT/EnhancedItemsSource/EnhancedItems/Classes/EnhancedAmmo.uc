// EnhancedItems by Wormbo
//=============================================================================
// EnhancedAmmo.
//=============================================================================

class EnhancedAmmo extends TournamentAmmo abstract;

struct RegenSuggestion {
	var() config int Max;
	var() config int Interval;
	var() config int Amount;
};

var() RegenSuggestion SuggestedRegeneration;	// suggests how this type of ammo should be regenerated
var() bool bIsSuperWeapon;	// this ammo belongs to a super weapon
var() name IdenticalTo;	// used by OtherIsA() and ClassIsA() to identify new versions of an actor
var EIDeathMessageMutator EIDMM;

static final function bool OtherIsA(actor Other, name DesiredType)
{
	return class'EnhancedMutator'.static.OtherIsA(Other, DesiredType);
}

static final function bool ClassIsA(class aClass, coerce string DesiredType)
{
	return class'EnhancedMutator'.static.ClassIsA(aClass, DesiredType);
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
     SuggestedRegeneration=(Interval=2,Amount=1)
}
