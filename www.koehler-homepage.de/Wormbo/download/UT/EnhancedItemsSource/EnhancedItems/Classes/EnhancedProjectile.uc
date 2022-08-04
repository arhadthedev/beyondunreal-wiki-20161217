// EnhancedItems by Wormbo
//=============================================================================
// EnhancedProjectile.
//
// Features:
//	- death/suicide messages for projectiles (independant from weapon)
//	- headshot support with extra damage type, death/suicide messages and
//	  damage factor
//	- splash damage support with extra damage type and death/suicide messages
//	  and different momentum transfer
//	- can be used as a "DamageType" by declaring an abstract class and specifying
//	  it as DeathMessageActorClass in EnhancedWeapon/EnhancedProjectile
//	  or as DamageProjectileClass in the SetKillType() function of PickupPlus,
//	  EnhancedAmmo, EIEffect or EnhancedMutator
//	- can "capture" the firer's DamageScaling and apply it at explosion time
//=============================================================================

class EnhancedProjectile extends Projectile abstract config(EnhancedItems);

var Actor MyTarget;	    // like Target, but will be replicated to client

var(Advanced) globalconfig bool bDropEffects,	// the actor should drop some visual effects (for slower machines)
	bKeepLightEffects;  // the actor should not turn off its lighting effects (bad for FPS)

// these are available only for projectiles
var() class<Inventory> FiredFrom;	// weapon class this projectile is fired from (used for %w in
	                                // death string, can also be a pickup, only ItemName is used)
var() name IdenticalTo;	// used by OtherIsA() and ClassIsA() to identify new versions of an actor

var() localized string ProjectileName,	// name of this projectile (used for %p in death sting)

// death strings
	DirectHitString,	// direct hit death message
	SplashHitString,	// splash damage death message
	HeadHitString,		// head shot death message
	SuicideString,		// suicide death message (male)
	SuicideFString,		// suicide death message (female)
	HeadSuicideString,	// head shot suicide death message (male)
	HeadSuicideFString;	// head shot suicide death message (female)

// message displayed when killing with a head shot
// The message should respond to the Switch parameter in the following way:
// 1 = Player is killer
// 2 = Player is victim
// 3 = Player killed self
// (Botpack.DecapitationMessage will always be displayed for killer and victim.)
var() class<LocalMessage> HeadShotMessage;

var() bool bCanHeadShoot,	// projectile can cause head shots
	bConstantSplashDamage;  // causes the damage in the outer splash area to be as
	                        // high as in the center (used in Combo InstaGib DM)

var() float HeadShotHeight,	// hitting an opponent above this multiplied with the CollisionHeight causes a HeadShot
	HeadShotDamageFactor;	// Damage is multiplied with this if projectile hit victims head

var() name HeadDamageType,	// type of head shot damage, use 'Decapitated' for "Head Shot!" announcement
	SplashDamageType;       // type of splash damage (When 'Push' is specified here,
			// actors are just pushed away without being damaged.)

var() float DamageRadius,	// radius of splash damage, no splash damage if 0
	SplashMomentum,         // momentum applied from splash damage
	
	SplashRangeModifier,    // how the Instigator's DamageScaling affects DamageRadius:
	// splash radius = DamageRadius + (DamageRadius * (Instigator.DamageScaling - 1) * SplashRangeModifier)
	// SplashRangeModifier = 0:	constant splash radius
	// SplashRangeModifier > 0:	DamageFactors greater than 1 have a larger splash radius
	// SplashRangeModifier < 0:	DamageFactors greater than 1 have a smaller splash radius
	
	MomentumModifier;       // how the Instigator's DamageScaling affects MomentumTransfer and SplashMomentum:
	// momentum = MomentumTransfer + (MomentumTransfer * (Instigator.DamageScaling - 1) * MomentumModifier)
	// MomentumModifier = 0:	constant momentum transfer
	// MomentumModifier > 0:	DamageFactors greater than 1 apply more momentum transfer
	// MomentumModifier < 0:	DamageFactors greater than 1 apply less momentum transfer

var() class<effects> ExplosionEffectClass;	// effect to spawn when exploding

var() int SubMunitionCount;	// amount of submunition to spawn when exploding
var() class<projectile> SubMunitionClass;	// type of submunition to spawn

// Set DeathMessageActorClass to another class to use its death strings.
// Must be a subclass of EnhancedWeapon or EnhancedProjectile to work.
// Use ReturnMessageActor() to get this value. (Returns Class if wrong
// DeathMessageActorClass was specified.)
var() class<Actor> DeathMessageActorClass;

// EnhancedProjectiles are not supported by the LifeSpan mutator,
// but the LifeSpan mutator is supported by EnhancedProjectile ;-)
// Use the LifeSpanMode() function to determine, if LifeSpan is used.
var bool bLifeSpanMode, bNoLifeSpan;	// used internally by the LifeSpanMode() function

var() bool bKeepDamageScaling;	// keep the Instigator's DamageScaling of the time the projectile was fired
var float SpawnDamageScaling;

var EIDeathMessageMutator EIDMM;

replication
{
	unreliable if ( Role == ROLE_Authority )
		MyTarget;
	
	unreliable if ( Role == ROLE_Authority && bNetInitial )
		SpawnDamageScaling;
}

static final function bool OtherIsA(actor Other, name DesiredType)
{
	return class'EnhancedMutator'.static.OtherIsA(Other, DesiredType);
}

static final function bool ClassIsA(class aClass, coerce string DesiredType)
{
	return class'EnhancedMutator'.static.ClassIsA(aClass, DesiredType);
}

simulated function Spawned()
{
	Super.Spawned();
	
	if ( bKeepDamageScaling && Role == ROLE_Authority ) {
		if ( Pawn(Owner) != None )
			SpawnDamageScaling = Pawn(Owner).DamageScaling;
		else if ( Instigator != None )
			SpawnDamageScaling = Instigator.DamageScaling;
	}
}

function string GetHumanName()
{
	return ProjectileName;
}

simulated final function bool LifeSpanMode()
{
	local SpawnNotify SN;
	
	if ( bNoLifeSpan || bLifeSpanMode )
		return bLifeSpanMode;
	
	// we search for LifeSpawn (the SpawnNotify class used by the LifeSpan mutator)
	for (SN = Level.SpawnNotify; SN != None; SN = SN.Next)
		if ( SN.IsA('LifeSpawn') ) {
			bLifeSpanMode = True;
			return True;
		}
	
	bLifeSpanMode = False;
	bNoLifeSpan = True;
	return False;
}

static final function rotator RotationFromVector(vector NewDirection, optional rotator OldRotator)
{
	local rotator NewRotator;
	
	NewRotator = rotator(NewDirection);
	NewRotator.Roll = OldRotator.Roll;
	
	return NewRotator;
}

// Explosion
// Used to blow up the projectile. HitLocation, HitNormal and HitActor are optional.
// If HitLocation is not specified, the projectile's current location will be used.
// If HitActor is not specified and DamageRadius is 0 no damage will be done.
simulated function Explosion(optional vector HitLocation, optional vector HitNormal, optional actor HitActor)
{
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( Role == ROLE_Authority ) {
		if ( DamageRadius > 0 )
			SplashDamage(HitLocation, HitActor);
		else if ( HitActor != None )
			DirectHit(HitLocation, HitActor);
		if ( SubmunitionCount > 0 )
			SpawnSubMunition(HitLocation, HitNormal, SubMunitionCount);
	}
	SpawnExplosionEffects(HitLocation, HitNormal);
	BlowUp(HitLocation);
	Destroy();
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	if ( Role == ROLE_Authority ) {
		if ( Mover(Wall) != None && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage(Damage, Instigator, Location, MomentumTransfer * Normal(Velocity), '');

		MakeNoise(1.0);
	}
	Explosion(Location + ExploWallOut * HitNormal, HitNormal);
}

// EstimatedHitNormal
// Returns the HitNormal, if the level doesn't change and the projectile flies from CurLocation along
// vector Distance and hits something within the range specified by Distance. Returns a vector of
// size 0 if it would hit nothing or HitLevel is true and it would hit any other actor than the level.
// If HitLevel isn't true HitActor is set like in the Trace function, if HitLevel is true HitActor will
// be set to Level or None depending on if it hit level geometry or not.
function vector EstimatedHitNormal(out vector HitLocation, out actor HitActor, optional vector CurLocation,
		optional vector Distance, optional bool bHitLevelOnly, optional vector Extend)
{
	local vector Loc, Dist, HN;
	local actor Collider;
	
	if ( CurLocation == vect(0,0,0) )
		Loc = Location;
	else
		Loc = CurLocation;
	
	if ( Distance == vect(0,0,0) )
		Dist = Velocity;
	else
		Dist = Distance;
	
	Collider = Trace(HitLocation, HN, Dist + Loc, Loc, !bHitLevelOnly, Extend);
	if ( bHitLevelOnly ) {
		if ( Collider == Level || Mover(Collider) != None ) {
			HitActor = Collider;
			return HN;
		}
	}
	else if ( Collider != None ) {
		HitActor = Collider;
		return HN;
	}
	HitActor = None;
	return vect(0,0,0);
}

// return a subclass of EnhancedWeapon or EnhancedProjectile for the death message
function class<actor> ReturnMessageActor()
{
	if ( class<EnhancedWeapon>(DeathMessageActorClass) != None
			|| class<EnhancedProjectile>(DeathMessageActorClass) != None )
		return DeathMessageActorClass;
	return Class;
}

final function SetKillType(bool bSplashHit, bool bHeadHit)
{
	if ( EIDMM != None )
		EIDMM.AddDamageActor(ReturnMessageActor(), bSplashHit, bHeadHit);
}

final function RestoreKillType()
{
	if ( EIDMM != None )
		EIDMM.RemoveDamageActor();
}

// bSpecialHit causes head shot death message for normal and splash hits
// (just death/suicide string; announcement only with 'Decapitated' damage)
function SplashDamage(optional vector HitLocation, optional actor Other, optional vector HitNormal, optional bool bSpecialHit)
{
	local actor Victims;
	local float damageScale, dist, momentumScale, ScaledRadius;
	local vector dir;
	local name DamageName;
	
	if ( bHurtEntry )
		return;
	bHurtEntry = true;
	
	ScaledRadius = DamageRadius;
	if ( Instigator != None ) {
		if ( bKeepDamageScaling )
			ScaledRadius += DamageRadius * (SpawnDamageScaling - 1) * SplashRangeModifier;
		else
			ScaledRadius += DamageRadius * (Instigator.DamageScaling - 1) * SplashRangeModifier;
	}
	
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	
	SetKillType(True, bSpecialHit);	// activate spash hit death message
	foreach VisibleCollidingActors(class 'Actor', Victims, ScaledRadius, HitLocation) {
		if ( Victims != Self ) {
			dir = Victims.Location - HitLocation;
			dist = FMax(1, VSize(dir));
			dir = SplashMomentum * dir / dist; 
			damageScale = 1 - FClamp((dist - Victims.CollisionRadius) / ScaledRadius, 0, 1);
			if ( bKeepDamageScaling )
				momentumScale = SpawnDamageScaling - 1;
			else if ( Instigator != None )
				momentumScale = Instigator.DamageScaling - 1;
			else
				momentumScale = 0;
			
			momentumScale *= damageScale;
			if ( bConstantSplashDamage )
				damageScale = 1;
			
			if ( bKeepDamageScaling && Instigator != None )
				damageScale *= SpawnDamageScaling / Instigator.DamageScaling;
			
			// direct hit
			if ( Victims == Other ) {
				if ( VSize(HitNormal) == 0 )
					HitNormal = Normal(Velocity);
				dir = Normal(dir) * SplashMomentum * momentumScale + HitNormal * MomentumTransfer * momentumScale;
				
				if ( bCanHeadShoot && Other.bIsPawn && (HitLocation.Z - Other.Location.Z > HeadShotHeight * Other.CollisionHeight)
						&& (!Instigator.IsA('Bot') || !Bot(Instigator).bNovice) ) {
					DamageName = HeadDamageType;
					damageScale *= HeadShotDamageFactor;
					SetKillType(False, True);	// temporarily switch to head shot death message
				}
				else {
					DamageName = MyDamageType;
					if ( Victims.bIsPawn )
						SetKillType(False, bSpecialHit);	// temporarily switch to direct hit death message
				}
				
				Victims.TakeDamage
				(
					damageScale * Damage,
					Instigator, 
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Normal(dir),
					(damageScale + damageScale * momentumScale * MomentumModifier) * dir,
					DamageName
				);
				if ( Victims.bIsPawn )
					RestoreKillType();	// restore splash hit message
			}
			// splash damage hit
			else {
				if ( SplashDamageType == 'Push' )
					Victims.TakeDamage
					(
						0,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Normal(dir),
						(damageScale + damageScale * momentumScale * MomentumModifier) * dir,
						'None'
					);
				else {
					DamageName = AdjustSplashDamageType(Victims);
					Victims.TakeDamage
					(
						damageScale * Damage,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Normal(dir),
						(damageScale + damageScale * momentumScale * MomentumModifier) * dir,
						DamageName
					);
				}
			}
		} 
	}
	RestoreKillType();	// deactivate splash hit message
	bHurtEntry = false;
}

// bSpecialHit uses head shot message, bSplashHit uses splash damage message instead of direct hit message
function DirectHit(vector HitLocation, actor Other, optional vector HitNormal, optional bool bSpecialHit)
{
	local float damageScale, momentumScale;
	local vector dir;
	local name DamageName;
	
	if ( HitNormal != vect(0,0,0) )
		dir = HitNormal * MomentumTransfer;
	else
		dir = Normal(Velocity) * MomentumTransfer;
	
	damageScale = 1.0;
	
	// direct hit
	if ( Other.Physics == PHYS_Walking && dir.Z < 0 )
		dir.Z = 0.25 * dir.Z;
	if ( bCanHeadShoot && Other.bIsPawn && HitLocation.Z - Other.Location.Z > HeadShotHeight * Other.CollisionHeight
			&& (!Instigator.IsA('Bot') || !Bot(Instigator).bNovice) ) {
		DamageName = HeadDamageType;
		damageScale *= HeadShotDamageFactor;
		SetKillType(False, True);
	}
	else {
		DamageName = MyDamageType;
		SetKillType(False, bSpecialHit);
	}
	
	if ( bKeepDamageScaling && Instigator != None )
		damageScale *= SpawnDamageScaling / Instigator.DamageScaling;
	
	if ( bKeepDamageScaling )
		momentumScale = SpawnDamageScaling - 1;
	else if ( Instigator != None )
		momentumScale = Instigator.DamageScaling - 1;
	else
		momentumScale = 0;
	
	Other.TakeDamage
	(
		damageScale * Damage,
		Instigator, 
		Other.Location - 0.5 * (Other.CollisionHeight + Other.CollisionRadius) * Normal(dir),
		(damageScale + damageScale * momentumScale * MomentumModifier) * dir,
		DamageName
	);
	
	// reset messages
	RestoreKillType();
}

// You might want to use this function to do something with certain actors before
// applying damage to them e.g. if this projectile should should make the Shock
// Rifle's balls explode, the ball's SuperExplosion function must be called. The
// function returns a Name so the DamageType done by the projectile can be set
// individually for each actor in splash range.
function Name AdjustSplashDamageType(Actor Other)
{
	return SplashDamageType;
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local Effects s;
	
	if ( Level.NetMode != NM_DedicatedServer ) {
  		if ( ExplosionEffectClass != None ) {
	  		s = spawn(ExplosionEffectClass,,, HitLocation, rotator(HitNormal));
			s.RemoteRole = ROLE_None;
		}
		if ( HitNormal == vect(0,0,0) )
			HitNormal = vect(0,0,1);
		if ( ExplosionDecal != None )
			Spawn(ExplosionDecal,,, HitLocation, rotator(HitNormal));
	}
}

function SpawnSubMunition(vector HitLocation, vector HitNormal, int Amount)
{
	local Projectile s;
	local int i;
	
	if ( Amount < 1 || SubMunitionClass == None ) return;
	
	for (i = 0; i < Amount; i++) {
		s = Spawn(SubMunitionClass, Instigator,, HitLocation, rotator(VRand() + HitNormal));
		if ( s != None ) {
			s.Instigator = Instigator;
			ModifySubMunition(s);
		}
	}
}

function ModifySubMunition(Projectile Other);

function BlowUp(vector HitLocation)
{
	MakeNoise(1.0);
}

// this function is not as flexible in usage as the Explosion() function (see above)
simulated function Explode(vector HitLocation, vector HitNormal)
{
	Explosion(HitLocation, HitNormal);
}

defaultproperties
{
     DirectHitString="%k killed %o with the %w."
     SplashHitString="%k killed %o with the %w."
     HeadHitString="%k put a bullet in %o's head."
     SuicideString=" killed his own dumb self."
     SuicideFString=" killed her own dumb self."
     HeadSuicideString=" put a bullet in his own head."
     HeadSuicideFString=" put a bullet in her own head."
     HeadShotDamageFactor=1.500000
     HeadShotHeight=0.62
     HeadDamageType=Decapitated
     SplashDamageType=SplashDamage
     FiredFrom=class'Engine.Weapon'
     bKeepDamageScaling=True
     SpawnDamageScaling=1.000000
}
