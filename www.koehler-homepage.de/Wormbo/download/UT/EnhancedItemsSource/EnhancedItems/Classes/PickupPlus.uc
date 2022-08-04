// EnhancedItems by Wormbo
//=============================================================================
// PickupPlus
//
// Features:
// - Global sound effects for respawn and pickup (heard by all players)
// - aura effects for the pickup itself and the owning player
// - stackable damage/speed/jump-height/air-control factors for owning player
//   and his selected weapon (fixes the jumpboots bug when using speed relic;
//   the weapon must be an EnhancedWeapon to support speed scaling)
// - new armor and damagetype functions
// - weapon affector chain to allow more than one item to affect a weapon
//   (use FireFunction() and set bFireEffectLast to true or false instead of
//   using FireEffect() )
// - may draw on HUD before and after weapon is drawn if it is a weapon
//   affector and the weapon is an EnhancedWeapon (see PreRenderOverlaysFor() )
//=============================================================================

class PickupPlus extends TournamentPickup abstract config(EnhancedItems);

const MaxDamageFactor = 10.0;
const MinDamageFactor = 0.3;
const MaxSpeedFactor = 2.5;
const MinSpeedFactor = 0.3;

// this specifies, if the actor should drop some visual effects (for slower machines)
var(Advanced) globalconfig bool bDropEffects;

var() bool bDeactivatable, bNeverAutoActivate;
var pawn PawnOwner;
var() name IdenticalTo;	// used by OtherIsA() and ClassIsA() to identify new versions of an actor

var() sound GlobalRespawnSound, GlobalPickupSound, DeniedAnnounce;

// aura, shield or flashing effect around owner or pickup
var PlayerShellEffect ShellEffect, PickupShellEffect;
var() class<PlayerShellEffect> ShellType;
var() Texture ShellSkin;		// the texture to use on the shell effect
var() bool bShellAlwaysOn,	// player shell is always visible
	bMakesInvisible;	// the item makes invisible so other items shouldn't add effects
var() Texture PickupShellSkin;
var() class<PlayerShellEffect> PickupShellType;

// use this maybe with a HUD mutator to play a certain effect on this item's HUD icon
var float BlinkIcon;

// used with SetDamageFactor() to let multiple items scale players damage
var() float AddToDamageFactor;

// used with SetSpeedFactor() to let multiple items scale weapons firing speed
// this only affects EnhancedWeapons
var() float AddToSpeedFactor;

// used with SetOwnerSpeed() to let multiple items scale the players jumping height,
// Speed and AirControl
var() float AddToJumpZFactor, AddToOwnerSpeed, DesiredAirControl;

// if these are true the item affects the weapon's/owner's speed/damage factor
var() bool bWeaponSpeedUp, bPawnSpeedUp, bPawnDamageUp;

// used with SetOwnerMass() to let items scale the players mass/buoyancy
var() float AddToMassFactor, AddToBuoyancyFactor;
var() bool bPawnMassAffect;

// some additional armor properties
var() bool bIsSpecialArmor,	// armor doesn't use it's charge on damage absorption
	bAltCharge,		// armor uses alternative charge (not shown in total armor charge if bIsAnArmor)

	bIsChestArmor,    //	\
	bIsThighArmor,    //	 \
	bIsShieldArmor,   //	  \ Display this item as chest armor, thigh armor, etc.
	bIsBeltArmor,     //	  / These need bEnhancedStatusDoll to be true.
	bIsGlovesArmor,   //	 /  (use instead of a dummy item)
	bIsBootsArmor,    //	/
	
	bIsChestSpecial,  //	\
	bIsThighSpecial,  //	 \  Display this item as chest special, thigh special, etc.
	bIsShieldSpecial, //	  \ These need bEnhancedStatusDoll to be true.
	bIsGlovesSpecial, //	  /
	bIsBeltSpecial,   //	 / <- not needed if IdenticalTo == 'GravBelt'
	bIsJumpBoots;     //	/  <- not needed if IdenticalTo == 'JumpBoots' or 'UT_JumpBoots'
	
var() travel int AltCharge;	// amount of armor if bAltCharge is used
var() float ProtectedDamageFactor;	// damage of ProtectionType is multiplied with this

// should play the DeniedAnnounce sound for players inside DeniedRadius when picked up
// called by PickupFunction()
var() bool bDeniedAnnounce;
var() float DeniedRadius;

// for replacable pickups
var() name ReplaceTag;
var() bool bAllowSameClassPickup;

// used to let more than one item affect a TournamentWeapon
// assigned by RegisterAsAffector()
var TournamentPickup NextAffector;
var TournamentWeapon AffectedWeapon;
var() bool bFireEffectLast,	// this item wants to add its firing effect after all other affectors
	bRenderOverlays;	// this item wants to add something to the weapons display
var globalconfig bool bDrawShieldOverWeapon,	// the item may draw a shield effect on the weapon
	bEnhancedStatusDoll;

// just used for debugging FirstPickupPlus and NextPickupPlus
var(Advanced) globalconfig bool bDebugMode;

var localized float UnitRatio[4];
var localized string UnitDisplay[4], UnitFullName[4];
var(Advanced) globalconfig string DecimalChar;
var(Advanced) globalconfig int UsedUnit;

var EIDeathMessageMutator EIDMM;

replication
{
	reliable if ( Role == ROLE_Authority && bNetOwner )
		NextAffector, AffectedWeapon, bAltCharge, AltCharge, bDeactivatable, bRenderOverlays;
}

static final function bool OtherIsA(actor Other, name DesiredType)
{
	return class'EnhancedMutator'.static.OtherIsA(Other, DesiredType);
}

static final function bool ClassIsA(class aClass, coerce string DesiredType)
{
	return class'EnhancedMutator'.static.ClassIsA(aClass, DesiredType);
}

// FindInventoryType()
// Returns an inventory item of the requested class or a subclass if it exists
// in the specified pawn's inventory. Optionally a search for identical
// PickupPlus items can be performed.
static final function Inventory FindInventoryType(Actor Other, name DesiredType, optional bool bFindIdentical)
{
	local Inventory Inv;
	local int RecursionCount;
	
	for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory) {
		if ( RecursionCount++ > 500 )
			return None;
		if ( bFindIdentical && OtherIsA(Inv, DesiredType) )
			return Inv;
		else if ( Other.IsA(DesiredType) )
			return Inv;
	}
	return None;
}

function PreBeginPlay()
{
	local Mutator M;
	local bool bFound;
	
	Super.PreBeginPlay();
	if ( bDeleteMe )
		return;
	
	if ( bNeverAutoActivate )
		bAutoActivate = False;	// override DMMutator's auto-activate modification, if desired
	
	// add EIUseHoldable
	for (M = Level.Game.DamageMutator; M != None; M = M.NextDamageMutator)
		if ( M.IsA('EIUseHoldable') ) {
			bFound = True;
			break;
		}
	
	if ( !bFound )
		log(Name$": Adding"@Spawn(class'EnhancedItems.EIUseHoldable').Name$"...");
	
	if ( bEnhancedStatusDoll )
		SpawnEIChallengeHUD();
}

function SpawnEIChallengeHUD()
{
	local class<Mutator> M;
	local EnhancedMutator EM;
	
	// check, if EIChallengeHUD was already spawned
	ForEach AllActors(class'EnhancedMutator', EM)
		if ( EM.IsA('EIChallengeHUD') )
			return;	// EIChallengeHUD already exists
	
	M = class<Mutator>(DynamicLoadObject("EIChallengeHUD.EIChallengeHUD", class'Class', True));
	if ( M != None )
		Spawn(M);
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

// gather general information
/* common InfoType strings might look like these:
 *	MaxDefaultOwnerHealth       (owner's health gets regenerated up to this value)
 *	CurrentDamageFactor         (combination of all active damage multipliers)
 *	CurrentOwnerSpeedFactor     (combination of all active speed multipliers)
 *	CurrentWeaponSpeedFactor
 *	CurrentJumpZFactor          	.
 *	CurrentAirControl           	.
 *	CurrentOwnerMassFactor      	.
 *	CurrentOwnerBuoyancyFactor
 *	 ...
 *	Of course, others can be used as well.
 */
function float GetInfoOn(string InfoType, optional string OtherInfo)
{
	local float tmp;
	
	tmp = 0;
	if ( NextPickupPlus() != None )
		tmp = NextPickupPlus().GetInfoOn(InfoType);
	
	if ( InfoType ~= "CurrentDamageFactor" && bPawnDamageUp ) {
		if ( tmp <= 0 )
			tmp = 1;
		tmp *= AddToDamageFactor;
	}
	else if ( InfoType ~= "CurrentOwnerSpeedFactor" && bPawnSpeedUp ) {
		if ( tmp <= 0 )
			tmp = 1;
		tmp *= AddToOwnerSpeed;
	}
	else if ( InfoType ~= "CurrentJumpZFactor" && bPawnSpeedUp ) {
		if ( tmp <= 0 )
			tmp = 1;
		tmp *= AddToJumpZFactor;
	}
	else if ( InfoType ~= "CurrentAirControl" && bPawnSpeedUp )
		tmp = FMax(tmp, DesiredAirControl);
	else if ( InfoType ~= "CurrentWeaponSpeedFactor" && bWeaponSpeedUp ) {
		if ( tmp <= 0 )
			tmp = 1;
		tmp *= AddToSpeedFactor;
	}
	else if ( InfoType ~= "CurrentOwnerMassFactor" && bPawnMassAffect ) {
		if ( tmp <= 0 )
			tmp = 1;
		tmp *= AddToMassFactor;
	}
	else if ( InfoType ~= "CurrentOwnerBuoyancyFactor" && bPawnMassAffect ) {
		if ( tmp <= 0 )
			tmp = 1;
		tmp *= AddToBuoyancyFactor;
	}
	return tmp;
}

static simulated function string ConvertDistance(float Distance, optional int NewUnit, optional int OldUnit, optional int Accuracy, optional bool bNoUnit, optional bool bLongName)
{
	local string DistanceText;
	
	Default.UsedUnit = Clamp(Default.UsedUnit, 0, ArrayCount(Default.UnitRatio));
	if ( NewUnit == 0 )
		NewUnit = Default.UsedUnit + 1;
	
	if ( OldUnit > 0 )
		Distance *= Default.UnitRatio[OldUnit - 1] / Default.UnitRatio[NewUnit - 1];
	else
		Distance /= Default.UnitRatio[NewUnit - 1];
	
	if ( Accuracy > 0 )
		DistanceText = int(Distance) $ Default.DecimalChar $ int(int(Distance * 10 ** Accuracy) % 10 ** Accuracy);
	else if ( Accuracy < 0 )
		DistanceText = string(int(Distance / 10 ** Accuracy) * 10 ** Accuracy);
	else
		DistanceText = string(int(Distance));
	
	if ( !bNoUnit && bLongName )
		return DistanceText @ Default.UnitFullName[NewUnit - 1];
	else if ( !bNoUnit )
		return DistanceText @ Default.UnitDisplay[NewUnit - 1];
	else
		return DistanceText;
}

// this is the function which converts strings like "%k killed %o with %w." to something more useful
static final function string ReplaceText(out string Text, coerce string Replace, coerce string With, optional bool bNoChange)
{
	local int i;
	local string Input, Output;
	
	Input = Text;
	i = InStr(Input, Replace);
	while (i != -1) {	
		Output = Output $ Left(Input, i) $ With;
		Input = Mid(Input, i + Len(Replace));	
		i = InStr(Input, Replace);
	}
	Output = Output $ Input;
	if ( !bNoChange )
		Text = Output;
	return Output;
}

function bool HandlePickupQuery(Inventory Item)
{
	local PlayerPawn P;
	
	if ( Item.Class == Class ) {
		if ( bAllowSameClassPickup ) {
			if ( bCanHaveMultipleCopies ) {
				NumCopies++;
				if ( Level.Game.LocalLog != None )
					Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
				if ( Level.Game.WorldLog != None )
					Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
				if ( Item.PickupMessageClass == None )
					Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
				else
					Pawn(Owner).ReceiveLocalizedMessage(Item.PickupMessageClass, 0, None, None, Item.Class);
				Item.PlaySound(Item.PickupSound,, 2.0);
				PlayGlobalSound(PickupPlus(Item).GlobalPickupSound);
				Item.SetRespawn();
				
				if ( PickupPlus(Item).bDeniedAnnounce )
					ForEach VisibleCollidingActors(class'PlayerPawn', P, DeniedRadius, Location)
						if ( P != Owner && P.PlayerReplicationInfo != None && !P.PlayerReplicationInfo.bIsSpectator )
							P.ClientPlaySound(DeniedAnnounce);
			}
			else if ( bDisplayableInv ) {		
				if ( Charge < Item.Charge )	
					Charge = Item.Charge;
				if ( bAltCharge && AltCharge < PickupPlus(Item).AltCharge )	
					AltCharge = PickupPlus(Item).AltCharge;
				if ( Level.Game.LocalLog != None )
					Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
				if ( Level.Game.WorldLog != None )
					Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
				if ( Item.PickupMessageClass == None )
					Pawn(Owner).ClientMessage(item.PickupMessage, 'Pickup');
				else
					Pawn(Owner).ReceiveLocalizedMessage(Item.PickupMessageClass, 0, None, None, Item.Class);
				Item.PlaySound(Item.PickupSound,, 2.0);
				PlayGlobalSound(PickupPlus(Item).GlobalPickupSound);	
				Item.SetReSpawn();
				
				if ( PickupPlus(Item).bDeniedAnnounce )
					ForEach VisibleCollidingActors(class'PlayerPawn', P, DeniedRadius, Location)
						if ( P != Owner && P.PlayerReplicationInfo != None && !P.PlayerReplicationInfo.bIsSpectator )
							P.ClientPlaySound(DeniedAnnounce);
			}
		}
		return true;				
	}
	if ( Inventory == None )
		return false;
	
	return Inventory.HandlePickupQuery(Item);
}

function UsedUp()
{
	if ( Pawn(Owner) != None ) {
		bActivatable = false;
		Pawn(Owner).NextItem();
		if ( Pawn(Owner).SelectedItem == Self ) {
			Pawn(Owner).NextItem();	
			if ( Pawn(Owner).SelectedItem == Self )
				Pawn(Owner).SelectedItem = None;
		}
		if ( Level.Game.LocalLog != None )
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if ( Level.Game.WorldLog != None )
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
		if ( ItemMessageClass != None )
			Pawn(Owner).ReceiveLocalizedMessage(ItemMessageClass, 0, None, None, Class);
		else if ( ExpireMessage != "" )
			Pawn(Owner).ClientMessage(ExpireMessage);	
	}
	Owner.PlaySound(DeactivateSound);
	Destroy();
}

/* RegisterAsAffector()
Register your item using this function to receive FireEffect calls.
Use FireFunction instead of FireEffect to let other affectors do their stuff, too.
Check registration by running this function from time to time since non-PickupPlus affectors
will override the Affector property so the chain gets unlinked.

To remove the item from the affectors chain use the UnregisterAsAffector(TournamentWeapon)
function. Registering to another weapon will automatically unregister this item from
the previously affected weapon.
*/
final function RegisterAsAffector(TournamentWeapon W)
{
	local TournamentPickup A;
	
	if ( bDeleteMe ) {
		UnRegisterAsAffector(W);
		return;
	}
	
	if ( W == None || W == AffectedWeapon )
		return;
	
	// already registered to another weapon, unregister first
	if ( AffectedWeapon != None )
		UnRegisterAsAffector(AffectedWeapon);
	
	NextAffector = W.Affector;
	W.Affector = Self;
	AffectedWeapon = W;
}

final function UnRegisterAsAffector(TournamentWeapon W)
{
	local PickupPlus A;
	local string Affectors;
	
	if ( W == None )
		return;
	
	if ( W.Affector == Self ) {
		W.Affector = NextAffector;
		NextAffector = None;
	}
	else {
		For (A = PickupPlus(W.Affector); A != None; A = PickupPlus(A.NextAffector))
			if ( A.NextAffector == Self ) {
				A.NextAffector = NextAffector;
				NextAffector = None;
				break;	// self successfully unregistered
			}
	}
	AffectedWeapon = None;
}

// If this function returns true, this item will handle drawing the weapon.
// In this case, the PostRenderOverlaysFor() functions are not called.
simulated function bool PreRenderOverlaysFor(Weapon W, Canvas C)
{
	return false;
}

simulated function PostRenderOverlaysFor(Weapon W, Canvas C);

// make sure this item does not affect any weapon
final function UnRegisterFromWeapons()
{
	local TournamentWeapon W;
	
	ForEach AllActors(class'TournamentWeapon', W) {
		if ( IsAffectorOf(W) )
			UnRegisterAsAffector(W);
		if ( W.IsA('EnhancedWeapon') && W.Owner == Owner )
			ResetSpeedFactor(W);
	}
}

final function bool IsAffectorOf(TournamentWeapon W, optional PickupPlus P)
{
	local PickupPlus Inv;
	
	if ( W == None )
		return false;
	
	if ( P == None )
		P = Self;
	
	For (Inv = PickupPlus(W.Affector); Inv != None; Inv = PickupPlus(Inv.NextAffector))
		if ( Inv == P ) {
			if ( bDebugMode && W != P.AffectedWeapon )
				log("Affecting"@W.Name, P.Name);
			return true;
		}
	return false;
}

simulated function FireEffect()
{
	if ( !bFireEffectLast ) FireFunction();
	
	if ( NextAffector != None )
		NextAffector.FireEffect();
	
	if ( bFireEffectLast ) FireFunction();
}

simulated function FireFunction();

// SetDamageFactor.
// Sets DamageScaling for owning Pawn.
final function SetDamageFactor()
{
	local float newDamageFactor;
	local PickupPlus I;
	
	if ( bDeleteMe ) {
		ResetDamageFactor();
		return;
	}
	
	if ( Pawn(Owner) == None ) return;
	
	bPawnDamageUp = True;
	newDamageFactor = 1.0;
	//for ( I = Pawn(Owner).Inventory; I != None; I = I.Inventory )
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( !I.bDeleteMe && I.bPawnDamageUp )
			newDamageFactor *= I.AddToDamageFactor;
	
	Pawn(Owner).DamageScaling = FClamp(newDamageFactor, MinDamageFactor, MaxDamageFactor);
}

final function ResetDamageFactor()
{
	local float newDamageFactor;
	local PickupPlus I;
	
	if ( !bPawnDamageUp ) return;
	bPawnDamageUp = False;
	if ( Pawn(Owner) == None ) return;
	
	newDamageFactor = 1.0;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( I != Self && !I.bDeleteMe && I.bPawnDamageUp )
			newDamageFactor *= I.AddToDamageFactor;
	
	Pawn(Owner).DamageScaling = FClamp(newDamageFactor, MinDamageFactor, MaxDamageFactor);
}

// SetOwnerMass.
// Sets Mass and Buoyancy for owning Pawn.
final function SetOwnerMass()
{
	local float newMassFactor;
	local PickupPlus I;
	
	if ( bDeleteMe ) {
		ResetOwnerMass();
		return;
	}
	
	if ( Pawn(Owner) == None ) return;
	
	bPawnMassAffect = True;
	newMassFactor = 1.0;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( !I.bDeleteMe && I.bPawnMassAffect )
			newMassFactor *= I.AddToBuoyancyFactor;
	
	Pawn(Owner).Buoyancy = Pawn(Owner).Default.Buoyancy * newMassFactor;
	
	newMassFactor = 1.0;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( !I.bDeleteMe && I.bPawnMassAffect )
			newMassFactor *= I.AddToMassFactor;
	
	Pawn(Owner).Mass = Pawn(Owner).Default.Mass * newMassFactor;
}

final function ResetOwnerMass()
{
	local float newMassFactor;
	local PickupPlus I;
	
	if ( !bPawnMassAffect ) return;
	bPawnMassAffect = False;
	if ( Pawn(Owner) == None ) return;
	
	newMassFactor = 1.0;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( I != Self && !I.bDeleteMe && I.bPawnMassAffect )
			newMassFactor *= I.AddToBuoyancyFactor;
	
	Pawn(Owner).Buoyancy = Pawn(Owner).Default.Buoyancy * newMassFactor;
	
	newMassFactor = 1.0;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( I != Self && !I.bDeleteMe && I.bPawnMassAffect )
			newMassFactor *= I.AddToMassFactor;
	
	Pawn(Owner).Mass = Pawn(Owner).Default.Mass * newMassFactor;
}

// SetOwnerSpeed.
// sets speed, Acceleration and AirControl for the owning Pawn
final function SetOwnerSpeed()
{
	local float newFactor;
	local PickupPlus I;
	
	if ( bDeleteMe ) {
		ResetOwnerSpeed();
		return;
	}
	
	if ( Pawn(Owner) == None ) return;
	
	bPawnSpeedUp = True;
	
	// JumpZ
	newFactor = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();
	if ( Pawn(Owner).FindInventoryType(class'Botpack.UT_JumpBoots') != None )
		newFactor = Pawn(Owner).Default.JumpZ * 3.0;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( !I.bDeleteMe && I.bPawnSpeedUp )
			newFactor *= I.AddToJumpZFactor;
	
	Pawn(Owner).JumpZ = newFactor;
	//log("Set"@Owner$".JumpZ to"@newFactor);
	
	
	// AirControl
	if ( Level.Game.IsA('DeathMatchPlus') )
		newFactor = DeathMatchPlus(Level.Game).AirControl;
	else if ( Pawn(Owner).FindInventoryType(class'Botpack.UT_JumpBoots') != None )
		newFactor = 1.0;
	else
		newFactor = Pawn(Owner).Default.AirControl;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( !I.bDeleteMe && I.bPawnSpeedUp && I.DesiredAirControl > newFactor )
			newFactor = I.DesiredAirControl;
	
	Pawn(Owner).AirControl = newFactor;
	//log("Set"@Owner$".AirControl to"@newFactor);
	
	
	// Speed & Acceleration
	newFactor = 1.0;
	if ( Level.Game.IsA('DeathMatchPlus') )
		if ( DeathMatchPlus(Level.Game).bMegaSpeed )
			newFactor = 1.3;
	
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( !I.bDeleteMe && I.bPawnSpeedUp )
			newFactor *= I.AddToOwnerSpeed;
	
	Pawn(Owner).GroundSpeed = Pawn(Owner).Default.GroundSpeed * FClamp(newFactor, MinSpeedFactor, MaxSpeedFactor);
	Pawn(Owner).AirSpeed    = Pawn(Owner).Default.AirSpeed    * FClamp(newFactor, MinSpeedFactor, MaxSpeedFactor);
	Pawn(Owner).WaterSpeed  = Pawn(Owner).Default.WaterSpeed  * FClamp(newFactor, MinSpeedFactor, MaxSpeedFactor);
	Pawn(Owner).AccelRate   = Pawn(Owner).Default.AccelRate   * newFactor;
}

final function ResetOwnerSpeed()
{
	local float newFactor;
	local PickupPlus I;
	
	if ( !bPawnSpeedUp ) return;
	bPawnSpeedUp = False;
	if ( Pawn(Owner) == None ) return;
	
	// JumpZ
	newFactor = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();
	if ( Pawn(Owner).FindInventoryType(class'Botpack.UT_JumpBoots') != None )
		newFactor = Pawn(Owner).Default.JumpZ * 3.0;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( I != Self && !I.bDeleteMe && I.bPawnSpeedUp )
			newFactor *= I.AddToJumpZFactor;
	
	Pawn(Owner).JumpZ = newFactor;
	//log("Set"@Owner$".JumpZ to"@newFactor);
	
	
	// AirControl
	if ( Level.Game.IsA('DeathMatchPlus') )
		newFactor = DeathMatchPlus(Level.Game).AirControl;
	else if ( Pawn(Owner).FindInventoryType(class'Botpack.UT_JumpBoots') != None )
		newFactor = 1.0;
	else
		newFactor = Pawn(Owner).Default.AirControl;
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( I != Self && !I.bDeleteMe && I.bPawnSpeedUp && I.DesiredAirControl > newFactor )
			newFactor = I.DesiredAirControl;
	
	Pawn(Owner).AirControl = newFactor;
	//log("Set"@Owner$".AirControl to"@newFactor);
	
	
	// Speed & Acceleration
	newFactor = 1.0;
	if ( Level.Game.IsA('DeathMatchPlus') )
		if ( DeathMatchPlus(Level.Game).bMegaSpeed )
			newFactor = 1.3;
	
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( I != Self && !I.bDeleteMe && I.bPawnSpeedUp )
			newFactor *= I.AddToOwnerSpeed;
	
	Pawn(Owner).GroundSpeed = Pawn(Owner).Default.GroundSpeed * FClamp(newFactor, MinSpeedFactor, MaxSpeedFactor);
	Pawn(Owner).AirSpeed    = Pawn(Owner).Default.AirSpeed    * FClamp(newFactor, MinSpeedFactor, MaxSpeedFactor);
	Pawn(Owner).WaterSpeed  = Pawn(Owner).Default.WaterSpeed  * FClamp(newFactor, MinSpeedFactor, MaxSpeedFactor);
	Pawn(Owner).AccelRate   = Pawn(Owner).Default.AccelRate   * newFactor;
}

// SetSpeedFactor.
// Sets the SpeedScale value of the specified weapon if it is an EnhancedWeapon.
final function SetSpeedFactor(Weapon W)
{
	local float newSpeedFactor;
	local PickupPlus I;
	local EnhancedWeapon EW;
	
	if ( bDeleteMe ) {
		ResetSpeedFactor(W);
		return;
	}
	
	EW = EnhancedWeapon(W);
	if ( EW == None || Pawn(Owner) == None ) return;
	
	newSpeedFactor = 1.0;
	
	bWeaponSpeedUp = True;
	
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( !I.bDeleteMe && I.bWeaponSpeedUp )
			newSpeedFactor *= I.AddToSpeedFactor;
	
	EW.SpeedScale = EW.default.SpeedScale * FClamp(newSpeedFactor, MinSpeedFactor, MaxSpeedFactor);
	if ( EW.SlaveWeapon != None )
		SetSpeedFactor(EW.SlaveWeapon);
}

final function ResetSpeedFactor(Weapon W)
{
	local float newSpeedFactor;
	local PickupPlus I;
	local EnhancedWeapon EW;
	
	if ( !bWeaponSpeedUp ) return;
	bWeaponSpeedUp = False;
	
	EW = EnhancedWeapon(W);
	if ( EW == None || Pawn(Owner) == None ) return;
	
	newSpeedFactor = 1.0;
	
	for ( I = FirstPickupPlus(Pawn(Owner)); I != None; I = I.NextPickupPlus() )
		if ( I != Self && !I.bDeleteMe && I.bWeaponSpeedUp )
			newSpeedFactor *= I.AddToSpeedFactor;
	
	EW.SpeedScale = EW.default.SpeedScale * FClamp(newSpeedFactor, MinSpeedFactor, MaxSpeedFactor);
	if ( EW.SlaveWeapon != None )
		ResetSpeedFactor(EW.SlaveWeapon);
}

// checks if a given DamageType is splash damage (e.g. 'GrenadeSplashDamage', 'JoltedSplashDamage')
static function bool IsSplashDamage(coerce string DamageType)
{
	if ( DamageType ~= "SplashDamage" )
		return true;
	if ( Right(DamageType,12) ~= "SplashDamage" ) {
		//log(DamageType@"is a SplashDamage");
		return true;
	}
	return false;
}

// Checks if a DamageType is a "subclass" of another one (e.g. 'RocketDeath' or
// 'RocketSplashDamage' are types of 'Rocket'). If 'SplashDamage' is specified as
// DesiredType, the IsSplashDamage function is called instead.
static function bool DamageIsTypeOf(coerce string TestType, coerce string DesiredType)
{
	if ( DesiredType ~= "SplashDamage" )
		return IsSplashDamage(TestType);
	if ( DesiredType ~= "AllEnviromental" )
		return ( DamageIsTypeOf(TestType, 'Corroded') || DamageIsTypeOf(TestType, 'Burned')
				|| DamageIsTypeOf(TestType, 'Frozen') );
	if ( Len(TestType) < Len(DesiredType) ) {
//		log(TestType@"is shorter than"@DesiredType);
		return false;
	}
	if ( TestType ~= DesiredType ) {
//		log(TestType@"is equal to"@DesiredType);
		return true;
	}
	if ( Left(TestType, Len(DesiredType)) ~= DesiredType ) {
//		log(TestType@"is a"@DesiredType);
		return true;
	}
	return false;
}

function int GetCharge()
{
	if ( bAltCharge )
		return AltCharge;
	return Charge;
}

function bool DamageProtectionFactor(name DamageType, out float Factor)
{
	if ( DamageType != 'None' && DamageType != 'ProtectNone' && (DamageIsTypeOf(DamageType, ProtectionType1)
			|| DamageIsTypeOf(DamageType, ProtectionType2)) ) {
		Factor = ProtectedDamageFactor;
		return true;
	}
	return false;
}

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	local int ArmorDamage;
	local float DamageFactor;

	if ( DamageType != 'Drowned' )
		ArmorImpactEffect(HitLocation);
	if ( DamageType != 'None' && DamageProtectionFactor(DamageType, DamageFactor) )
		return Damage * DamageFactor;
	
	if ( DamageType == 'Drowned' ) Return Damage;
	
	ArmorDamage = (Damage * ArmorAbsorption) / 100;
	
	// special armor doesn't drain its charge when absorbing damage
	if ( !bIsSpecialArmor && bAltCharge ) {
		if ( ArmorDamage >= AltCharge ) {
			ArmorDamage = AltCharge;
			Destroy();
		}
		else 
			AltCharge -= ArmorDamage;
	}
	else if ( !bIsSpecialArmor ) {
		if ( ArmorDamage >= Charge ) {
			ArmorDamage = Charge;
			Destroy();
		}
		else 
			Charge -= ArmorDamage;
	}
	return (Damage - ArmorDamage);
}

function int ArmorPriority(name DamageType)
{
	local float DamageFactor;
	
	if ( DamageType == 'Drowned' && !DamageProtectionFactor(DamageType, DamageFactor) )
		return 0;
	
	DamageFactor = 1.0;
	// check, if completely blocks damage
	if ( DamageProtectionFactor(DamageType, DamageFactor) )
		if ( DamageFactor == 0.0 )
			return 1000000;
		else
			return AbsorptionPriority / DamageFactor;

	return AbsorptionPriority;
}

// This function checks a pawn's inventory for armors and calculates the
// approximate amount of damage the pawn can still take. Armor items with
// custom ArmorAbsorbDamage functions could produce errors in this calculation.
// Use the DamageProtectionFactor function of PickupPlus to describe custom
// damage reduction.
static final function int EstimatedPawnHitpoints(Pawn Other, optional name DamageType)
{
	local Inventory Inv;
	local int HitPoints;
	local float DamageFactor;
	
	HitPoints = Other.Health;
	
	for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory) {
		if ( !Inv.bIsAnArmor ) continue;
		if ( DamageType != '' && DamageType != 'None' && DamageType != 'ProtectNone' ) {
			if ( PickupPlus(Inv) == None && (Inv.ProtectionType1 == DamageType
					|| Inv.ProtectionType2 == DamageType) )
				return MaxInt;	// pawn is resistant against this type of damage
			else if ( PickupPlus(Inv) != None && PickupPlus(Inv).DamageProtectionFactor(DamageType, DamageFactor) ) {
				if ( DamageFactor == 0 )
					return MaxInt;	// pawn completely resists this type of damage
				else
					HitPoints *= DamageFactor;
			}
		}
		if ( Inv.IsA('PickupPlus') && PickupPlus(Inv).GetCharge() > 0 ) {
			if ( !PickupPlus(Inv).bIsSpecialArmor )
				HitPoints += (PickupPlus(Inv).GetCharge() * Inv.ArmorAbsorption) / 100;
		}
		else if ( Inv.Charge > 0 )
			HitPoints += (Inv.Charge * Inv.ArmorAbsorption) / 100;
	}
	
	for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory) {
		if ( !Inv.bIsAnArmor ) continue;
		if ( PickupPlus(Inv) != None ) {
			if ( PickupPlus(Inv).bIsSpecialArmor && Inv.ArmorAbsorption > 0 )
				HitPoints *= 100 / Inv.ArmorAbsorption;
		}
		else if ( Inv.Charge == 0 && Inv.ArmorAbsorption > 0 )
			HitPoints *= 100 / Inv.ArmorAbsorption;
	}
	
	return HitPoints;
}

// play a sound effect for all players
final function PlayGlobalSound(sound GlobalSound, optional bool bDontPlayInSlot)
{
	local Pawn P;
	local PlayerPawn Player;
	
	for (P = Level.PawnList; P != None; P = P.NextPawn) {
		if ( P.IsA('PlayerPawn') )
			Player = PlayerPawn(P);
		else
			continue;
		
		if ( bDontPlayInSlot ) {
			if ( Player.ViewTarget == None )
				Player.PlaySound(GlobalSound);
			else
				Player.ViewTarget.PlaySound(GlobalSound);
		}
		else
			Player.ClientPlaySound(GlobalSound,, True);
	}
}

simulated function CreateShell()
{
	if ( ShellEffect == None || ShellEffect.bDestroyMe || ShellEffect.bDeleteMe )
		ShellEffect = Spawn(ShellType, Owner,, Owner.Location, Owner.Rotation); 
	if ( ShellEffect != None ) {
		ShellEffect.Master = Self;
		if ( ShellSkin != None ) {
			ShellEffect.Texture = ShellSkin;
			ShellEffect.MultiSkins[1] = ShellSkin;
		}
	}
}

simulated function FlashShell(float Duration)
{
	ShowShell();
	if ( ShellEffect != None ) {
		if ( bShellAlwaysOn )
			ShellEffect.SetFlashTime(Duration);
		else
			ShellEffect.VisibleTime = Duration;
	}
}

simulated function ShowShell()
{
	CreateShell();
	if ( ShellEffect != None )
		ShellEffect.ShowMe();
}

simulated function Destroyed()
{
	if ( Role == ROLE_Authority ) {
		UnRegisterFromWeapons();
		ResetDamageFactor();
		ResetOwnerSpeed();
		ResetOwnerMass();
	}
	if ( ShellEffect != None )
		ShellEffect.DestroyMe();
	if ( PickupShellEffect != None )
		PickupShellEffect.DestroyMe();
	
	Super.Destroyed();
}

function PickupFunction(Pawn Other)
{
	local PlayerPawn P;
	local Inventory I;
	
	// remove other PickupPlus with the same ReplaceTag
	if ( ReplaceTag != 'None' && ReplaceTag != '' )
		for (I = Other.Inventory; I != None; I = I.Inventory)
			if ( I.IsA('PickupPlus') && PickupPlus(I).ReplaceTag == ReplaceTag && I.Class != Class )
				I.Destroy();
	
	Super.PickupFunction(Other);
	if ( bPawnDamageUp )
		SetDamageFactor();
	if ( bPawnSpeedUp )
		SetOwnerSpeed();
	if ( bPawnMassAffect )
		SetOwnerMass();
	if ( bAltCharge ) {
		AltCharge += Charge;
		Charge = 0;
	}
	
	if ( bDeniedAnnounce )
		ForEach VisibleCollidingActors(class'PlayerPawn', P, DeniedRadius, Location)
			if ( P != Other && P.PlayerReplicationInfo != None && !P.PlayerReplicationInfo.bIsSpectator )
				P.ClientPlaySound(DeniedAnnounce);
}

function GiveTo(pawn Other)
{
	// make sure I'm not already in an inventory chain
	if ( Instigator != Other && Instigator != None && Instigator.FindInventoryType(Class) == Self )
		Instigator.DeleteInventory(Self);
	if ( Owner != Other && Pawn(Owner) != None && Pawn(Owner).FindInventoryType(Class) == Self )
		Pawn(Owner).DeleteInventory(Self);
	
	Instigator = Other;
	BecomeItem();
	Other.AddInventory(Self);
	if ( bAltCharge ) {
		AltCharge += Charge;
		Charge = 0;
	}
	PawnOwner = Other;
	if ( bPawnDamageUp )
		SetDamageFactor();
	if ( bPawnSpeedUp )
		SetOwnerSpeed();
	if ( bPawnMassAffect )
		SetOwnerMass();
	GotoState('Idle2');
}

function BecomePickup()
{
	local Pawn P;
	
	Super.BecomePickup();
	
	// make sure this item no longer is in any inventory chain
	for (P = Level.PawnList; P != None; P = P.nextPawn)
		if ( P.FindInventoryType(Class) == Self )
			P.DeleteInventory(Self);
	Inventory = None;
}

// Returns whether this item wants to be picked up by Other. This function works
// a bit like HandlePickupQuery() but allowes the item to decide for itself if
// it wants to allow getting picked up before HandlePickupQuery() is called.
function bool AllowPickup(Pawn Other)
{
	return true;
}

auto state Pickup
{	
	function bool ValidTouch(actor Other)
	{
		local Actor A;

		if ( Other.bIsPawn && Pawn(Other).bIsPlayer && Pawn(Other).Health > 0
				&& AllowPickup(Pawn(Other)) && Level.Game.PickupQuery(Pawn(Other), Self) ) {
			if ( Event != '' )
				foreach AllActors(class 'Actor', A, Event)
					A.Trigger(Other, Other.Instigator);
			return true;
		}
		return false;
	}
	
	function Touch( actor Other )
	{
		local Inventory Copy;
		if ( ValidTouch(Other) ) {
			Copy = SpawnCopy(Pawn(Other));
			if ( Copy == None )
				return;
			
			if ( Level.Game.LocalLog != None )
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if ( Level.Game.WorldLog != None )
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			if ( bActivatable ) {
				if ( Pawn(Other).SelectedItem == None ) 
					Pawn(Other).SelectedItem = Copy;
				if ( bAutoActivate && Pawn(Other).bAutoActivate )
					Copy.Activate();
			}
			if ( PickupMessageClass == None )
				Pawn(Other).ClientMessage(PickupMessage, 'Pickup');
			else
				Pawn(Other).ReceiveLocalizedMessage(PickupMessageClass, 0, None, None, Self.Class);
			PlaySound (PickupSound,,2.0);	
			PlayGlobalSound (GlobalPickupSound);	
			Pickup(Copy).PickupFunction(Pawn(Other));
			if ( PickupPlus(Copy) != None )
				PickupPlus(Copy).PawnOwner = Pawn(Other);
		}
	}

	simulated function BeginState()
	{
		Super.BeginState();
		LightType = Default.LightType;
		if ( PickupShellType != None ) {
			PickupShellEffect = Spawn(PickupShellType, Self,, Location, Rotation);
			if ( PickupShellEffect != None ) {
				PickupShellEffect.Master = Self;
				PickupShellEffect.GotoState('PickupShell');
			}
		}
	}
	
	simulated function EndState()
	{
		Super.EndState();
		LightType = LT_None;
		if ( PickupShellEffect != None )
			PickupShellEffect.Destroy();
	}
}

// modified version of SelectNext() to support bDeactivatable
function Inventory SelectNext()
{
	if ( bActivatable && (!bAutoActivate || bDeactivatable) && M_Selected != "" ) {
		Pawn(Owner).ClientMessage(ItemName$M_Selected);
		return Self;
	}
	if ( Inventory != None )
		return Inventory.SelectNext();
	else
		return None;
}

// modified version of Activate() to support bDeactivatable
function Activate()
{
	//log(Name@"in state"@GetStateName()@"activated.");
	if ( bActivatable ) {
		if ( Level.Game.LocalLog != None )
			Level.Game.LocalLog.LogItemActivate(Self, Pawn(Owner));
		if ( Level.Game.WorldLog != None )
			Level.Game.WorldLog.LogItemActivate(Self, Pawn(Owner));

		if ( M_Activated != "" && (!bAutoActivate || bDeactivatable) )
			Pawn(Owner).ClientMessage(ItemName$M_Activated);	
		GoToState('Activated');
	}
}

state Activated
{
	simulated function BeginState()
	{
		Super.BeginState();
		if ( bShellAlwaysOn )
			ShowShell();
	}
	
	function Activate()
	{
		//log(self@"wants to deactivate");
		if ( Pawn(Owner) != None && Pawn(Owner).bAutoActivate 
			&& bAutoActivate && !bDeactivatable )
				return;
		if ( Pawn(Owner) != None && M_Deactivated != "" )
			Pawn(Owner).ClientMessage(ItemName$M_Deactivated);	
		GoToState('DeActivated');	
	}
}

state Deactivated
{
	simulated function BeginState()
	{
		Super.BeginState();
		if ( ShellEffect != None )
			ShellEffect.DestroyMe();
	}
	
Begin:
}

//=============================================================================
// Sleeping state: Sitting hidden waiting to respawn.

State Sleeping
{
	ignores Touch;
	
	function BeginState()
	{
		BecomePickup();
		bHidden = true;
	}
	
	function EndState()
	{
		local int i;
		
		bSleepTouch = false;
		for (i = 0; i < 4; i++)
			if ( Touching[i] != None && Touching[i].IsA('Pawn') )
				bSleepTouch = true;
	}
Begin:
	Sleep(ReSpawnTime);
	Sleep(Level.Game.PlaySpawnEffect(Self));
	PlaySound(RespawnSound);
	PlayGlobalSound(GlobalRespawnSound);
	GoToState('Pickup');
}

// returns the next PickupPlus in the inventory chain starting from this item
final function PickupPlus NextPickupPlus()
{
	local Inventory I;
	local int Counter;
	local bool logOwner;
	local pawn PrevOwner;
	
	if ( bDebugMode ) {
		if ( Pawn(Owner) != None )
			logOwner = True;
		else
			log("! NextPickupPlus:"@Name@"is not owned by a Pawn");
	}
	
	// find next PickupPlus
	for (I = Inventory; I != None; I = I.Inventory) {
		Counter++;
		if ( bDebugMode && logOwner ) {
			if ( Pawn(I.Owner) == None )
				log("Found an un-owned item ("$I.Name$") in inventory chain of"@Owner.Name, 'InventoryError');
			else if ( i.Owner != Owner )
				log("Item"@I.Name@"in same inventory chain like"@Name@"is owned by"@I.Owner.Name@"instead of"@Owner.Name, 'InventoryError');
		}
		if ( I.IsA('PickupPlus') ) {
//			log("NextPickupPlus is"@I);
			return PickupPlus(I);
		}
		else if ( I == Self ) {
			if ( bDebugMode ) {
				if ( logOwner )
					log(Name@"loops to itself in inventory chain of"@Owner.Name@"after"@Counter@"steps", 'InventoryError');
				else
					log(Name@"loops to itself after"@Counter@"steps and has no owner", 'InventoryError');
			}
			return None;
		}
		else if ( Counter > 500 ) {
			if ( bDebugMode ) {
				if ( logOwner )
					log("Infinite recursion in inventory chain of"@Owner.Name, 'InventoryError');
				else
					log("Infinite recursion in inventory chain of"@Name, 'InventoryError');
			}
			return None;
		}
	}
	
	// no PickupPlus found
	return None;
}

// finds the first PickupPlus in pawn Other's inventory
static final function PickupPlus FirstPickupPlus(Pawn Other)
{
	local Inventory I;
	local int Counter;
	local pawn PrevOwner;
	
	// no pawn specified
	if ( Other == None ) {
		if ( Default.bDebugMode )
			log("FirstPickupPlus: No pawn specified.");
		return None;
	}
	
	// no items in Other's inventory
	if ( Other.Inventory == None ) {
		if ( Default.bDebugMode )
			log("FirstPickupPlus:"@Other.Name@"has no inventory.");
		return None;
	}
	
	// find first PickupPlus
	for(I = Other.Inventory; I != None; I = I.Inventory) {
		Counter++;
		if ( Default.bDebugMode && I.Owner != Other )
			log("Item"@I.Name@"in inventory chain of"@Other.Name@"is owned by"@I.Owner.Name, 'InventoryError');
		
		if ( I.IsA('PickupPlus') ) {
//			log("FirstPickupPlus is"@I);
			return PickupPlus(I);
		}
		else if ( Counter > 500 ) {
			if ( Default.bDebugMode )
				log("Infinite recursion in inventory chain of"@Other.Name, 'InventoryError');
			return None;
		}
	}
	
	// no PickupPlus found
	return None;
}

defaultproperties
{
     UnitDisplay(0)="UU"
     UnitDisplay(1)="m"
     UnitDisplay(2)="yd"
     UnitDisplay(3)="ft"
     UnitFullName(0)="Unreal Units"
     UnitFullName(1)="Meters"
     UnitFullName(2)="Yards"
     UnitFullName(3)="Feet"
     DecimalChar="."
     UnitRatio(0)=1.000000
     UnitRatio(1)=44.000000
     UnitRatio(2)=40.233600
     UnitRatio(3)=13.411200
     UsedUnit=1
     bAllowSameClassPickup=True
     bDrawShieldOverWeapon=True
     bEnhancedStatusDoll=True
     bAutoActivate=True
     bActivatable=True
     bDisplayableInv=True
     M_Activated=" activated."
     M_Selected=" selected."
     M_Deactivated=" deactivated."
     AddToDamageFactor=1.000000
     AddToSpeedFactor=1.000000
     AddToJumpZFactor=1.000000
     AddToOwnerSpeed=1.000000
     AddToMassFactor=1.000000
     AddToBuoyancyFactor=1.000000
     DeniedRadius=150.000000
}
