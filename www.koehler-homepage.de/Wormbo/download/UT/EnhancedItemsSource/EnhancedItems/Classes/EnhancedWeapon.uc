// EnhancedItems by Wormbo
//=============================================================================
// EnhancedWeapon.
//
// Don't use the DeathMessage. Combine DirectHit or SplashDamage with the
// hit strings below to create more complex death messages.
// Look at EIRazor2 (EIBotpackUpgrade) or MercuryMissile (RocketsUT) for an
// example of how to use hit strings and head shot settings.
//=============================================================================

class EnhancedWeapon extends TournamentWeapon abstract config(EnhancedItems);

// this specifies, if the actor should drop some visual effects (for slower machines)
var(Advanced) globalconfig bool bDropEffects;

var name SamePriorityLike;	// used to set the switch priority
var() name IdenticalTo;	// used by OtherIsA() and ClassIsA() to identify new versions of an actor

// used by weapon priority menu
var() localized string MenuName;	// name to be displayed in weapon priority menu
var() Mesh MenuMesh;		// mesh to be displayed in weapon priority menu (if None, PickupViewMesh is used)
var() float MenuViewScale;	// scaling factor for MenuMesh (default is PickupViewScale)
var() rotator MenuRotation;	// Yaw component will not be used

// used to speed up weapons when under the effect of the relic of speed or similar powerup
var() float SpeedScale;

// for weapons like the Enforcer
var EnhancedWeapon SlaveWeapon, MasterWeapon;
var bool bIsSlave;
var() bool bCustomDrawSlave;	// drawing of the slave weapon is handled by subclass
var() name DoublePriorityName;
var() int DoubleSwitchPriority;
var() localized string DoubleName;

var() localized string ProjectileName,	// name of the (imaginary) projectile fired by this weapon

// death strings
	DirectHitString,	// direct hit death message
	SplashHitString,		// splash damage death message
	HeadHitString,			// head shot death message
	SuicideString,			// suicide death message (male)
	SuicideFString,			// suicide death message (female)
	HeadSuicideString,		// head shot suicide death message (male)
	HeadSuicideFString;		// head shot suicide death message (female)

// message displayed when killing with a head shot
// The message should respond to the Switch parameter in the following way:
// 1 = Player is killer
// 2 = Player is victim
// 3 = Player killed self
// (Botpack.DecapitationMessage will always be displayed for killer and victim.)
var() class<LocalMessage> HeadShotMessage;

var() bool bCanHeadShoot,		// has special head shooting abilities (more damage, different death message)
	bConstantSplashDamage;	// causes the damage in the outer splash area
	// to be as high as in the center (used in Combo InstaGib DM)

var() float Damage,	// Damage done when hit with this weapon
	Range,			// range of melee weapon
	MaxRange,		// maximum range of instant hit weapon
	HeadShotHeight,	// hitting an opponent above this multiplied with the
					// CollisionHeight causes a HeadShot
	HeadShotDamageFactor;	// Damage is multiplied with this if projectile
							// hit victims head and bCanHeadShoot is true

var() name HeadDamageType,	// type of head shot damage, use 'Decapitated' for "Head Shot!" announcement
	SplashDamageType;	// type of splash damage (When 'Push' is specified here,
			// actors are just pushed away without being damaged.)

var() float DamageRadius,	// radius of splash damage, no splash damage if 0
	MomentumTransfer,	// momentum applied from direct hits
	SplashMomentum,		// momentum applied from splash damage
	
	SplashRangeModifier,	// how the Instigator's DamageScaling affects DamageRadius:
		// splash radius = DamageRadius + (DamageRadius * (Instigator.DamageScaling - 1) * SplashRangeModifier)
		// SplashRangeModifier = 0:	constant splash radius
		// SplashRangeModifier > 0:	DamageFactors greater than 1 have a larger splash radius
		// SplashRangeModifier < 0:	DamageFactors greater than 1 have a smaller splash radius
	
	MomentumModifier;	// how the Instigator's DamageScaling affects MomentumTransfer and SplashMomentum:
		// momentum = MomentumTransfer + (MomentumTransfer * (Instigator.DamageScaling - 1) * MomentumModifier)
		// MomentumModifier = 0:	constant momentum transfer
		// MomentumModifier > 0:	DamageFactors greater than 1 apply more momentum transfer
		// MomentumModifier < 0:	DamageFactors greater than 1 apply less momentum transfer

var() class<effects> ExplosionEffectClass;	// effect to play at hit location
var() class<decal> ExplosionDecal;	// impact decal spawned at hit location

var() int SubMunitionCount;	// amount of submunition to spawn when exploding
var() class<projectile> SubMunitionClass;	// type of submunition to spawn

// Set this to another class to use its death strings. Must be a subclass of
// EnhancedWeapon or EnhancedProjectile to work. Use ReturnMessageActor() to
// get this value. (Returns this class if wrong class was specified.)
var() class<Actor> DeathMessageActorClass;

var bool bDrawingWeapon; // weapon is not hidden in 1st person view (updated in OldRenderOverlays)

var EIDeathMessageMutator EIDMM;

replication
{
	unreliable if ( Role == ROLE_Authority && bNetOwner )
		SpeedScale, SlaveWeapon, bIsSlave;
	unreliable if ( Role == ROLE_Authority && bIsSlave )
		MasterWeapon;
}

// add the EIDeathMessageMutator to support enhanced death messages
function PreBeginPlay()
{
	local Mutator M;
	
	Super.PreBeginPlay();
	if ( !bDeleteMe && EIDMM == None ) {
		for (M = Level.Game.MessageMutator; M != None; M = M.NextMessageMutator)
			if ( M.IsA('EIDeathMessageMutator') ) {
				EIDMM = EIDeathMessageMutator(M);
				return;
			}
		EIDMM = Spawn(class'EnhancedItems.EIDeathMessageMutator');
	}
}

static final function bool OtherIsA(actor Other, name DesiredType)
{
	return class'EnhancedMutator'.static.OtherIsA(Other, DesiredType);
}

static final function bool ClassIsA(class aClass, coerce string DesiredType)
{
	return class'EnhancedMutator'.static.ClassIsA(aClass, DesiredType);
}

simulated function vector CalcZoomedFireOffset()
{
	local vector DrawOffset, WeaponBob;
	local Pawn PawnOwner;
	
	PawnOwner = Pawn(Owner);
	DrawOffset = VSize(PlayerViewOffset) / PawnOwner.FOVAngle * vector(PawnOwner.ViewRotation);
	
	if ( Level.NetMode == NM_DedicatedServer
			|| (Level.NetMode == NM_ListenServer && Owner.RemoteRole == ROLE_AutonomousProxy) )
		DrawOffset += PawnOwner.BaseEyeHeight * vect(0,0,1);
	else {	
		DrawOffset += PawnOwner.EyeHeight * vect(0,0,1);
		WeaponBob = BobDamping * PawnOwner.WalkBob;
		WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
		DrawOffset += WeaponBob;
	}
	return DrawOffset;
}

//=============================================================================
// Allow HUD mutators and weapon affectors to draw on the canvas right after
// the weapon has been rendered and before the HUD is drawn.
// Note that any number of PickupPlus items and one TournamentPickup can affect
// a TournamentWeapon at the same time but only the PickupPlus items are
// allowed to draw on the canvas.
simulated function RenderOverlays(Canvas Canvas)
{
	local Mutator M;
	local PickupPlus A;
	local bool bOverride;
	
	if ( SlaveWeapon != None && !bCustomDrawSlave )
		SlaveWeapon.Affector = Affector;
	else if ( bIsSlave && MasterWeapon != None && !bCustomDrawSlave )
		Affector = MasterWeapon.Affector;
	
	if ( PlayerPawn(Owner) != None && PlayerPawn(Owner).myHUD != None )
		for (M = PlayerPawn(Owner).myHUD.HUDMutator; M != None; M = M.NextHUDMutator)
			if ( M.IsA('EnhancedMutator') )
				bOverride = EnhancedMutator(M).PreRenderOverlaysFor(Self, Canvas) || bOverride;
	
	for (A = PickupPlus(Affector); A != None; A = PickupPlus(A.NextAffector))
		if ( A.bRenderOverlays )
			bOverride = A.PreRenderOverlaysFor(Self, Canvas) || bOverride;
	
	if ( !bOverride ) {
		OldRenderOverlays(Canvas);
		
		if ( PlayerPawn(Owner) != None && PlayerPawn(Owner).myHUD != None )
			for (M = PlayerPawn(Owner).myHUD.HUDMutator; M != None; M = M.NextHUDMutator)
				if ( M.IsA('EnhancedMutator') )
					EnhancedMutator(M).PreRenderOverlaysFor(Self, Canvas);
		
		for (A = PickupPlus(Affector); A != None; A = PickupPlus(A.NextAffector))
			if ( A.bRenderOverlays )
				A.PostRenderOverlaysFor(Self, Canvas);
	}
	if ( SlaveWeapon != None && !bCustomDrawSlave )
		SlaveWeapon.RenderOverlays(Canvas);
}

// OldRenderOverlays() is called by RenderOverlays() or PreRenderOverlays() function
// of an EnhancedMutator registered as HUD mutator or a PickupPlus registered as affector.
// It does the actual drawing of the weapon.
simulated function OldRenderOverlays(Canvas C)
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int Hand;
	local PlayerPawn PlayerOwner;
	
	bDrawingWeapon = !bHideWeapon;
	if ( bHideWeapon || Owner == None )
		bDrawingWeapon = False;
	
	PlayerOwner = PlayerPawn(Owner);
	
	if ( PlayerOwner != None ) {
		if ( PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV )
			bDrawingWeapon = False;
		bPlayerOwner = true;
		Hand = PlayerOwner.Handedness;
		
		if ( Level.NetMode == NM_Client && Hand == 2 ) {
			bHideWeapon = true;
			bDrawingWeapon = False;
		}
	}
	
	if ( !bPlayerOwner || PlayerOwner.Player == None )
		Pawn(Owner).WalkBob = vect(0,0,0);
	
	if ( bDrawingWeapon && bMuzzleFlash > 0 && bDrawMuzzleFlash && Level.bHighDetailMode && MFTexture != None ) {
		MuzzleScale = Default.MuzzleScale * C.ClipX / 640.0;
		if ( !bSetFlashTime ) {
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if ( FlashTime < Level.TimeSeconds )
			bMuzzleFlash = 0;
		if ( bMuzzleFlash > 0 ) {
			if ( Hand == 0 )
				C.SetPos(C.ClipX / 2 - 0.5 * MuzzleScale * FlashS + C.ClipX * (-0.2 * Default.FireOffset.Y * FlashO), C.ClipY / 2 - 0.5 * MuzzleScale * FlashS + C.ClipY * (FlashY + FlashC));
			else
				C.SetPos(C.ClipX / 2 - 0.5 * MuzzleScale * FlashS + C.ClipX * (Hand * Default.FireOffset.Y * FlashO), C.ClipY / 2 - 0.5 * MuzzleScale * FlashS + C.ClipY * FlashY);
			
			C.Style = 3;
			C.DrawIcon(MFTexture, MuzzleScale);
			C.Style = 1;
		}
	}
	else if ( bDrawingWeapon )
		bSetFlashTime = false;
	
	SetLocation(Owner.Location + CalcDrawOffset());
	NewRot = Pawn(Owner).ViewRotation;
	
	if ( Hand == 0 )
		newRot.Roll = -2 * Default.Rotation.Roll;
	else
		newRot.Roll = Default.Rotation.Roll * Hand;
	
	setRotation(newRot);
	if ( bDrawingWeapon )
		C.DrawActor(Self, False);
}

function Fire( float Value )
{
	if ( SlaveWeapon != None )
		SlaveWeapon.Affector = Affector;
	else if ( bIsSlave && MasterWeapon != None )
		Affector = MasterWeapon.Affector;
	if ( AmmoType == None && AmmoName != None )
		GiveAmmo(Pawn(Owner));
	if ( AmmoType.UseAmmo(1) ) {
		GotoState('NormalFire');
		bPointing = True;
		bCanClientFire = true;
		ClientFire(Value);
		if ( bRapidFire || FiringSpeed > 0 )
			Pawn(Owner).PlayRecoil(FiringSpeed * SpeedScale);
		if ( bInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	}
}

function AltFire( float Value )
{
	if ( SlaveWeapon != None )
		SlaveWeapon.Affector = Affector;
	else if ( bIsSlave && MasterWeapon != None )
		Affector = MasterWeapon.Affector;
	if ( AmmoType == None && AmmoName != None )
		GiveAmmo(Pawn(Owner));
	if ( AmmoType.UseAmmo(1) ) {
		GotoState('AltFiring');
		bPointing = True;
		bCanClientFire = true;
		ClientAltFire(Value);
		if ( bRapidFire || FiringSpeed > 0 )
			Pawn(Owner).PlayRecoil(FiringSpeed * SpeedScale);
		if ( bAltInstantHit )
			TraceFire(0.0);
		else
			ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	}
}

// EstimatedHitNormal
// Returns the HitNormal, if the level wouldn't change and the projectile would fly from CurLocation along
// vector Distance and hits something within the range specified by Distance. Returns a vector of
// size 0 if it would hit nothing or HitLevel is true and it would hit any other actor than the level.
// If HitLevel isn't true HitActor is set like in the Trace function, if HitLevel is true HitActor will
// be set to Level or None depending on if it hit level geometry or not.
function vector EstimatedHitNormal (
	out vector HitLocation, out actor HitActor, optional vector CurLocation,
	optional vector Distance, optional bool HitLevel, optional vector Extend)
{
	local vector Loc,Dist,HN;
	local actor Collider;
	
	if ( VSize(CurLocation) == 0 )
		Loc = Location;
	else
		Loc = CurLocation;
	
	if ( VSize(CurLocation) == 0 )
		Dist = Velocity;
	else
		Dist = Distance;
	
	if ( HitLevel ) {
		Collider = Trace(HitLocation, HN, Dist+Loc, Loc, False, Extend);
		if ( Collider == Level ) {
			HitActor = Collider;
			return HN;
		}
	}
	else {
		Collider = Trace(HitLocation, HN, Dist+Loc, Loc, True, Extend);
		if ( Collider != None ) {
			HitActor = Collider;
			return HN;
		}
	}
	HitActor = None;
	return vect(0,0,0);
}

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

// bSpecialHit causes head shot death message (no head shot announce) with normal and splash hits
function SplashDamage(vector HitLocation, actor Other, vector HitNormal, optional bool bSpecialHit)
{
	local actor Victims;
	local float damageScale, dist, momentumScale, ScaledRadius;
	local vector dir;
	local name DamageName;
	local string SavedSString, SavedFSString, SavedDString;
	
	if( bHurtEntry )
		return;
	bHurtEntry = true;
	
	if ( Instigator != None )
		ScaledRadius = DamageRadius + (DamageRadius * (Instigator.DamageScaling - 1) * SplashRangeModifier);
	else
		ScaledRadius = DamageRadius;
	
	SetKillType(True, bSpecialHit);	// activate spash hit death message
	foreach VisibleCollidingActors( class 'Actor', Victims, ScaledRadius, HitLocation ) {
		if ( Victims != self ) {
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			if ( bConstantSplashDamage )
				dist = 1;
			dir = SplashMomentum * dir / dist; 
			damageScale = 1 - FClamp((dist - Victims.CollisionRadius) / ScaledRadius, 0, 1);
			if ( Instigator != None )
				momentumScale = Instigator.DamageScaling - 1;
			else
				momentumScale = 0;
			
			momentumScale *= damageScale;
			
			// direct hit
			if ( Victims == Other ) {
				dir = Normal(dir) * SplashMomentum * momentumScale + Normal(HitNormal) * MomentumTransfer * momentumScale;
				if ( Instigator != None && Instigator.Weapon != None )
						Instigator.Weapon.Class.Default.DeathMessage = DirectHitString;
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
				
				// reset messages
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
function DirectHit(vector HitLocation, actor Other, vector HitNormal, optional bool bSpecialHit, optional bool bSplashHit)
{
	local float damageScale, momentumScale;
	local vector dir;
	local name DamageName;
	
	if ( Other == None )
		return;
	
	dir = Normal(HitNormal) * MomentumTransfer;
	damageScale = 1.0;
	
	// direct hit
	if ( bCanHeadShoot && Other.bIsPawn && (HitLocation.Z - Other.Location.Z > HeadShotHeight * Other.CollisionHeight)
			&& (!Instigator.IsA('Bot') || !Bot(Instigator).bNovice) ) {
		DamageName = HeadDamageType;
		damageScale *= HeadShotDamageFactor;
		SetKillType(bSplashHit, True);
	}
	else {
		DamageName = MyDamageType;
		SetKillType(bSplashHit, bSpecialHit);
	}
	
	if ( Instigator != None )
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
// applying damage to them e.g. if this projectile should set of ASMD plasma balls,
// the ball's SuperExplosion function must be called. The function returns a Name
// so the damagetype done by the projectile can be set individually for each
// actor in splash range.
function Name AdjustSplashDamageType(Actor Other)
{
	return SplashDamageType;
}

simulated function SpawnExplosionEffects(vector HitLocation, vector HitNormal)
{
	local Effects s;
	
	if ( Level.NetMode != NM_DedicatedServer ) {
  		if ( ExplosionEffectClass != None ) {
	  		s = spawn(ExplosionEffectClass,,, HitLocation);
			s.RemoteRole = ROLE_None;
		}
		if ( HitNormal == vect(0,0,0) )
			HitNormal = vect(0,0,1);
		if ( ExplosionDecal != None )
			Spawn(ExplosionDecal,,, HitLocation, rotator(HitNormal));
	}
}

function SpawnSubMunition(vector HitLocation, vector HitNormal, int Number)
{
	local Projectile s;
	local int i;
	
	if ( Number < 1 || SubMunitionClass == None )
		return;
	
	for (i = 0; i < Number; i++) {
		s = Spawn(SubMunitionClass, Instigator,, HitLocation, rotator(Normal(VRand() + HitNormal)));
		s.Instigator = Instigator;
		ModifySubMunition(s);
	}
}

function ModifySubMunition(Projectile Other);

// Return the switch priority of the weapon (normally AutoSwitchPriority, but may be
// modified by environment (or by other factors for bots)
function float SwitchPriority() 
{
	local int bTemp;

	if ( bIsSlave )
		return -10;
	if ( !Owner.IsA('PlayerPawn') )
		return RateSelf(bTemp);
	else if ( AmmoType != None && AmmoType.AmmoAmount <= 0 ) {
		if ( Pawn(Owner).Weapon == Self )
			return -0.5;
		else
			return -1;
	}
	else if ( SlaveWeapon != None && DoublePriorityName != 'None' )
		return DoubleSwitchPriority;
	else
		return AutoSwitchPriority;
}

// If this weapon is replacing another one it might use the same switching priority.
// Also, if this weapon can have a slave weapon (like Enforcer) it might use a
// different priority.
function SetSwitchPriority(pawn Other)
{
	local int i;
	local name PriorityName, temp;
	local bool bFound, bFoundDouble;
	
	if ( PlayerPawn(Other) != None ) {
		if ( SamePriorityLike == 'None' )
			PriorityName = Class.Name;
		else
			PriorityName = SamePriorityLike;
		
		// get AutoSwitchPriority and DoubleSwitchPriority
		for (i = 0; i < ArrayCount(PlayerPawn(Other).WeaponPriority); i++) {
			if ( PlayerPawn(Other).WeaponPriority[i] == PriorityName ) {
				AutoSwitchPriority = i;
				bFound = True;
			}
			if ( DoublePriorityName != 'None'
					&& PlayerPawn(Other).WeaponPriority[i] == DoublePriorityName ) {
				DoubleSwitchPriority = i;
				bFoundDouble = True;
			}
		}
		
		// didn't find AutoSwitchPriority, so register it
		if ( !bFound )
			for (i = AutoSwitchPriority; i < ArrayCount(PlayerPawn(Other).WeaponPriority); i++) {
					if ( PlayerPawn(Other).WeaponPriority[i] == '' || PlayerPawn(Other).WeaponPriority[i] == 'None' ) {
					PlayerPawn(Other).WeaponPriority[i] = PriorityName;
					break;
				}
				else if ( i < ArrayCount(PlayerPawn(Other).WeaponPriority) - 1 ) {
					temp = PlayerPawn(Other).WeaponPriority[i];
					PlayerPawn(Other).WeaponPriority[i] = PriorityName;
					PriorityName = temp;
				}
			}
		
		// didn't find DoubleSwitchPriority, so register it
		if ( !bFoundDouble && DoublePriorityName != 'None' ) {
			PriorityName = DoublePriorityName;
			for (i = DoubleSwitchPriority; i < ArrayCount(PlayerPawn(Other).WeaponPriority); i++) {
				if ( PlayerPawn(Other).WeaponPriority[i] == '' || PlayerPawn(Other).WeaponPriority[i] == 'None' ) {
					PlayerPawn(Other).WeaponPriority[i] = PriorityName;
					break;
				}
				else if ( i < ArrayCount(PlayerPawn(Other).WeaponPriority) - 1 ) {
					temp = PlayerPawn(Other).WeaponPriority[i];
					PlayerPawn(Other).WeaponPriority[i] = PriorityName;
					PriorityName = temp;
				}
			}
		}
	}
}

defaultproperties
{
     SamePriorityLike=None
     DoublePriorityName=None
     SpeedScale=1.000000
     MaxRange=10000.000000	// default maximum range for instant hit TournamentWeapons
     HeadShotHeight=0.62	// default value for sniper rifle and ripper blade
     DirectHitString="%k killed %o with the %w."
     SplashHitString="%k killed %o with the %w."
     HeadHitString="%k put a %p in %o's head."
     SuicideString=" killed his own dumb self."
     SuicideFString=" killed her own dumb self."
     HeadSuicideString=" put a %p in his own head."
     HeadSuicideFString=" put a %p in her own head."
     ProjectileName="bullet"
     HeadShotDamageFactor=1.500000
     HeadDamageType=Decapitated
     SplashDamageType=SplashDamage
     DeathMessage="%k was to heavy for %o."	// still used when crushing opponents (jumping on their head)
}
