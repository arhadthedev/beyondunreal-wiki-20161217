// EnhancedItems by Wormbo
//=============================================================================
// EnhancedMutator.
//
// Features:
// - can handle MultiPickupPlus replacement
// - new RegisterHUDMutator function
// - can draw on HUD before and after weapon is drawn
//   (only if an EnhancedWeapon is selected)
// - unregisters from all mutator chains when destroyed
// - activates the enhanced death messages of EnhancedWeapon and EnhancedProjectile
//=============================================================================

class EnhancedMutator extends Mutator abstract config(EnhancedItems);

// additional HUD mutator variables
var PlayerPawn PlayerOwner;	// the PlayerPawn owning the HUD this mutator is registered to
var HUD MyHUD;	// HUD this mutator is registered to
var ChallengeHUD MyChallengeHUD;	// ChallengeHUD this mutator is registered to
var bool bPendingHUDRegistration;	// the RegisterHUDMutator() function has failed, so try again later

// Subclass of MultiPickupPlus to use by default in replace functions.
var() string MultiPickupBaseClass;

// Set this to true if the mutator should not be added more than once.
var() bool bAllowOnlyOnce;

// The mutator should always create a MultiPickupPlus,
// even if there is no need to do so.
// This can solve errors with other EnhancedMutators
// but can also produce new ones with non-EnhancedMutators.
// (Must be implemented in CheckReplacement() for child classes.)
var(Advanced) globalconfig bool bAlwaysCreateMPP;

var EIDeathMessageMutator EIDMM;
var bool bMIConverterSpawned;

function AddMutator(Mutator M)
{
	if ( M == Self )
		return;	// I'm already added to the mutators list
	else if ( bAllowOnlyOnce && M.Class == Class )
		M.Destroy();	// already have a mutator of this class
	else if ( M != None && !M.bDeleteMe )
		Super.AddMutator(M);
}

// convert ChaosUT.MultiItems to EnhancedItems.MultiPickupPlus
// and add new player status icon
function PreBeginPlay()
{
	local Mutator M;
	
	SpawnMIConverter();
	
	if ( class'PickupPlus'.default.bEnhancedStatusDoll )
		SpawnEIChallengeHUD();
	
	if ( !bDeleteMe && EIDMM == None ) {
		for (M = Level.Game.MessageMutator; M != None; M = M.NextMessageMutator)
			if ( M.IsA('EIDeathMessageMutator') ) {
				EIDMM = EIDeathMessageMutator(M);
				return;
			}
		EIDMM = Spawn(class'EnhancedItems.EIDeathMessageMutator');
	}
}

function SpawnMIConverter()
{
	local class<Mutator> M;
	local EnhancedMutator EM;
	local Inventory Inv;
	
	if ( Level.NetMode == NM_Client )
		return;	// MIConverter is server-side only
	
	if ( bMIConverterSpawned )
		return;
	
	// check, if MIConverter was already spawned
	ForEach AllActors(class'EnhancedMutator', EM)
		If ( EM.IsA('MIConverter') ) {
			bMIConverterSpawned = True;	// MIConverter already exists
			return;
		}
	
	log(class$": Spawning the MIConverter...");
	M = class<Mutator>(DynamicLoadObject("MIConverter.MIConverter", class'Class', True));
	if ( M != None && Spawn(M) != None )
		log(class$": MIConverter spawned.");
	
	bMIConverterSpawned = True;
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

// correctly unregister this mutator from all linked mutator chains
simulated function Destroyed()
{
	local Mutator M;
	local HUD H;
	
	if ( Level.Game != None ) {
		if ( Level.Game.BaseMutator == Self )
			Level.Game.BaseMutator = NextMutator;
		if ( Level.Game.DamageMutator == Self )
			Level.Game.DamageMutator = NextDamageMutator;
		if ( Level.Game.MessageMutator == Self )
			Level.Game.MessageMutator = NextMessageMutator;
	}
	ForEach AllActors(Class'Engine.HUD', H)
		if ( H.HUDMutator == Self )
			H.HUDMutator = NextHUDMutator;
	ForEach AllActors(Class'Engine.Mutator', M) {
		if ( M.NextMutator == Self )
			M.NextMutator = NextMutator;
		if ( M.NextHUDMutator == Self )
			M.NextHUDMutator = NextHUDMutator;
		if ( M.NextDamageMutator == Self )
			M.NextDamageMutator = NextDamageMutator;
		if ( M.NextMessageMutator == Self )
			M.NextMessageMutator = NextMessageMutator;
	}
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

// Mutators sometimes want to work on actors the DMMutator wants to replace.
// Use this function to get a reference to the BaseMutator after it has been
// replaced by a configurable version. This will not work when the game type
// uses a BaseMutator other than DMMutator or EIDMMutator.
function EIDMMutator GetDMMutator()
{
	if ( Level.Game.BaseMutator.IsA('EIDMMutator') )
		return EIDMMutator(Level.Game.BaseMutator);
	else if ( Level.Game.BaseMutator.Class == Class'Botpack.DMMutator' ) {
		ReplaceDMMutator();
		if ( Level.Game.BaseMutator.IsA('EIDMMutator') )
			return EIDMMutator(Level.Game.BaseMutator);
	}
	return None;
}

function ReplaceDMMutator()
{
	local Mutator M, PrevMutator, BaseNextMutator;
	local EIDMMutator NewBaseMutator;
	
	log("Replacing BaseMutator...");
	if ( Level.Game.IsA('DeathMatchPlus') && Level.Game.BaseMutator.Class == Class'Botpack.DMMutator' ) {
		For ( M = Level.Game.BaseMutator; M != None; M = M.NextMutator )
			if ( M.NextMutator == Self ) {
				PrevMutator = M;
				break;
			}
		if ( PrevMutator != None )
			PrevMutator.NextMutator = NextMutator;
		BaseNextMutator = Level.Game.BaseMutator.NextMutator;
		
		NewBaseMutator = Spawn(class'EnhancedItems.EIDMMutator');
		if ( NewBaseMutator != None ) {
			NewBaseMutator.NextMutator = BaseNextMutator;
			
			// Usually Self is spawned using BaseMutator.AddMutator(Spawn(Self.Class))
			// in GameInfo.InitGame(). The next line redirects this AddMutator() call
			// to the new BaseMutator.
			Level.Game.BaseMutator.NextMutator = NewBaseMutator;
			Level.Game.BaseMutator.Destroy();
			Level.Game.BaseMutator = NewBaseMutator;
		}
		log("BaseMutator now is"@Level.Game.BaseMutator);
	}
	else
		log("BaseMutator still is"@Level.Game.BaseMutator);
}

// These function helps identifying projectiles, weapons, ammo and other pickups.
static final function bool OtherIsA(actor Other, name DesiredType)
{
	if ( Other == None || DesiredType == '' || DesiredType == 'None' )
		return false;
	if ( Other.IsA(DesiredType) )
		return true;
	if ( Other.IsA('EnhancedProjectile') )
		return EnhancedProjectile(Other).IdenticalTo == DesiredType;
	if ( Other.IsA('EnhancedWeapon') )
		return EnhancedWeapon(Other).IdenticalTo == DesiredType;
	if ( Other.IsA('EnhancedAmmo') )
		return EnhancedAmmo(Other).IdenticalTo == DesiredType;
	if ( Other.IsA('PickupPlus') )
		return PickupPlus(Other).IdenticalTo == DesiredType;
	return false;
}

// same as Actor.GetItemName() but is a static function
static function String StaticGetItemName(string FullName)
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 ) {
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

static final function bool ClassIsA(class aClass, coerce string DesiredType)
{
	local string DesiredClass, DesiredName;
	local class TestClass;
	
	DesiredName = StaticGetItemName(DesiredType);
	if ( DesiredType != DesiredName )
		DesiredClass = DesiredType;
	
	if ( aClass == None || DesiredName == "" )
		return false;
	
	if ( string(aClass) ~= DesiredClass || string(aClass.Name) ~= DesiredName )
		return true;
	if ( class<EnhancedProjectile>(aClass) != None
			&& string(class<EnhancedProjectile>(aClass).default.IdenticalTo) ~= DesiredName )
		return true;
	if ( class<EnhancedWeapon>(aClass) != None
			&& string(class<EnhancedWeapon>(aClass).default.IdenticalTo) ~= DesiredName )
		return true;
	if ( class<EnhancedAmmo>(aClass) != None
			&& string(class<EnhancedAmmo>(aClass).default.IdenticalTo) ~= DesiredName )
		return true;
	if ( class<PickupPlus>(aClass) != None
			&& string(class<PickupPlus>(aClass).default.IdenticalTo) ~= DesiredName )
		return true;
	
	if ( DesiredClass != "" )
		TestClass = Class(DynamicLoadObject(DesiredClass, Class'Class', True));
	if ( TestClass != None )
		return ClassIsChildOf(aClass, TestClass);
	
	return false;
}

// Give a weapon to a player and optionally bring it up as current weapon.
function Weapon GiveWeapon(Pawn PlayerPawn, string aClassName, optional bool bBringUp)
{
	local class<Weapon> WeaponClass;
	local Weapon NewWeapon;

	WeaponClass = class<Weapon>(DynamicLoadObject(aClassName, class'Class'));

	if ( PlayerPawn.FindInventoryType(WeaponClass) != None )
		return None;
	newWeapon = Spawn(WeaponClass);
	if ( newWeapon != None ) {
		newWeapon.RespawnTime = 0.0;
		newWeapon.GiveTo(PlayerPawn);
		newWeapon.bHeldItem = true;
		newWeapon.GiveAmmo(PlayerPawn);
		newWeapon.SetSwitchPriority(PlayerPawn);
		newWeapon.WeaponSet(PlayerPawn);
		newWeapon.AmbientGlow = 0;
		if ( PlayerPawn.IsA('PlayerPawn') )
			newWeapon.SetHand(PlayerPawn(PlayerPawn).Handedness);
		else
			newWeapon.GotoState('Idle');
		if ( bBringUp ) {
			PlayerPawn.Weapon.GotoState('DownWeapon');
			PlayerPawn.PendingWeapon = None;
			PlayerPawn.Weapon = newWeapon;
			PlayerPawn.Weapon.BringUp();
		}
	}
	return newWeapon;
}

// replaces an inventory Other with a MultiPickupPlus, adds Other.Class
// and returns the MultiPickupPlus
final function MultiPickupPlus ConvertToMPP(inventory Other, optional string MPPClass)
{
	local MultiPickupPlus A;
	local class<Inventory> OtherClass;
	
	OtherClass = Other.Class;
	A = ReplaceWithMPP(Other, MPPClass);
	if ( A != None )
		A.AddItem(OtherClass);
	return A;
}

// This function is called after a MultiPickupPlus is spawned.
// It is called for all EnhancedMutators except for the one that created the MPP.
function bool CheckMPP(MultiPickupPlus Other)
{
	return false;
}

// This function is called before an item is removed from a MultiPickupPlus.
function bool AlwaysKeepInMPP(MultiPickupPlus Other, class<Inventory> ItemClass)
{
	return false;
}

// Modified version of the ReplaceWith function.
// Replaces an Inventory Other with a MultiPickupPlus and
// returns a reference to it.
final function MultiPickupPlus ReplaceWithMPP(inventory Other, optional string MPPClass)
{
	local MultiPickupPlus A;
	local class<MultiPickupPlus> aClass;
	
	if ( Other.Location == vect(0,0,0) )
		return None;
	
	if ( MPPClass == "" )
		MPPClass = MultiPickupBaseClass;
	aClass = class<MultiPickupPlus>(DynamicLoadObject(MPPClass, class'Class'));
	
	if ( aClass == None && MPPClass != Default.MultiPickupBaseClass ) {
		log(Name$":"@MPPClass@"is not a valid MultiPickupPlus subclass, using default.");
		aClass = class<MultiPickupPlus>(DynamicLoadObject(Default.MultiPickupBaseClass, class'Class'));
	}
	
	if ( aClass == None ) {
		log(Name$":"@Default.MultiPickupBaseClass@"is not a valid MultiPickupPlus subclass, using class'MultiPickupPlus'.");
		aClass = class<MultiPickupPlus>(DynamicLoadObject("EnhancedItems.MultiPickupPlus", class'Class'));
	}
	
	if ( aClass != None )
		A = Spawn(aClass, Other.Owner, Other.Tag, Other.Location + (aClass.Default.CollisionHeight - Other.CollisionHeight) * vect(0,0,1), Other.Rotation);
	
	if ( Other.MyMarker != None ) {
		Other.MyMarker.markedItem = A;
		if ( A != None )
			A.MyMarker = Other.MyMarker;
		Other.MyMarker = None;
	}
	
	if ( A != None ) {
		if ( Other.Physics != Other.Default.Physics ) {
			if ( Other.Physics == PHYS_Falling )
				A.bForceItemFall = True;
			else if ( Other.Default.Physics == PHYS_Falling )
				A.bAllowItemFall = False;
		}
		if ( (!Other.bRotatingPickup || Other.RotationRate == rot(0,0,0))
				&& (A.Rotation.Pitch != 0 || A.Rotation.Roll != 0) )
			A.bAllowItemRotation = False;
		else
			A.bAllowItemRotation = (Other.RotationRate != rot(0,0,0) && Other.bRotatingPickup)
					|| !Other.default.bRotatingPickup || Other.default.RotationRate == rot(0,0,0);
		A.bForceItemRotation = Other.RotationRate != rot(0,0,0) && Other.bRotatingPickup
				&& (!Other.default.bRotatingPickup || Other.default.RotationRate == rot(0,0,0));
		A.Event = Other.Event;
		A.Tag = Other.Tag;
		A.ReplacedItem = Other.Class;	// save, which item class was replaced
		A.CreatedBy = Self;
		return A;
	}
	log(Name $ ": Error: Couldn't spawn MultiPickupPlus (" $ MPPClass $ ")");
	return None;
}

final function MultiPickupPlus ReplaceWithItemAsMPP(Inventory Other, coerce string aClassName, optional vector NewItemOffset, optional float NewInitTime, optional float NewChance, optional float NDuration)
{
	local MultiPickupPlus MPP;
	
	MPP = ReplaceWithMPP(Other);
	if ( MPP != None )
		MPP.AddItem(aClassName, NewItemOffset, NewInitTime, NewChance, NDuration);
	return MPP;
}

// Modified version of the ReplaceWith function
// Replaces an inventory Other with an inventory of class aClassName and
// returns a reference to it
final function Inventory ReplaceWithItem(Inventory Other, coerce string aClassName)
{
	local Inventory A;
	local class<Inventory> aClass;
	local bool bAllowItemFall, bForceItemFall;
	local bool bAllowItemRotation, bForceItemRotation;

	if ( Other.Location == vect(0,0,0) )
		return None;
	aClass = class<Inventory>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass, Other.Owner, Other.Tag, Other.Location + (aClass.Default.CollisionHeight - Other.CollisionHeight) * vect(0,0,1), Other.Rotation);
	
	if ( Other.MyMarker != None ) {
		Other.MyMarker.markedItem = A;
		if ( A != None )
			A.MyMarker = Other.MyMarker;
		Other.MyMarker = None;
	}
	else if ( A != None ) {
		A.bHeldItem = true;
		A.Respawntime = 0.0;
	}
	
	if ( A != None ) {
		if ( Other.Physics != Other.Class.Default.Physics ) {
			if ( Other.Physics == PHYS_Falling )
				bForceItemFall = True;
			else if ( Other.Class.Default.Physics == PHYS_Falling )
				bAllowItemFall = False;
		}
		if ( (!Other.bRotatingPickup || Other.RotationRate == rot(0,0,0))
				&& (Other.Rotation.Pitch != 0 || Other.Rotation.Roll != 0) )
			bAllowItemRotation = False;
		else
			bAllowItemRotation = (Other.RotationRate != rot(0,0,0) && Other.bRotatingPickup)
					|| !Other.default.bRotatingPickup || Other.default.RotationRate == rot(0,0,0);
		bForceItemRotation = Other.RotationRate != rot(0,0,0) && Other.bRotatingPickup
				&& (!Other.default.bRotatingPickup || Other.default.RotationRate == rot(0,0,0));
		
		if ( A.Physics == PHYS_Falling && !bAllowItemFall )
			A.SetPhysics(PHYS_None);
		else if ( A.Physics != PHYS_Falling && bForceItemFall )
			A.SetPhysics(PHYS_Falling);
		A.bRotatingPickup = bAllowItemRotation && (A.bRotatingPickup || bForceItemRotation);
		
		A.Event = Other.Event;
		A.Tag = Other.Tag;
		return A;
	}
	return None;
}

// You need to set the following three variables in the defaultproperties of
// your HUD mutator in order to make it work:
/*
     bAlwaysRelevant=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
*/
// also add bPendingHUDRegistration=True to make the mutator automatically register itself as HUD mutator
simulated function RegisterHUDMutator()
{
	local PlayerPawn P;
	local Mutator M;
	
	bPendingHUDRegistration = False;
	
	if ( PlayerPawn(Owner) != None ) {
		P = PlayerPawn(Owner);
		if ( P.MyHUD != None ) {
			For (M = P.MyHUD.HUDMutator; M != None; M = M.NextHUDMutator)
				if ( M.Class == Class )
					break;
			if ( M == None || M.Class != Class ) {
				NextHUDMutator = P.MyHUD.HUDMutator;
				MyHUD = P.MyHUD;
				MyChallengeHUD = ChallengeHUD(MyHud);
				if ( class'PickupPlus'.default.bDebugMode &&  P.MyHUD.HUDMutator != None )
					log("RegisterHUDMutator: Registered"@Name$", NextHUDMutator is"@P.MyHUD.HUDMutator.Name);
				else if ( class'PickupPlus'.default.bDebugMode )
					log("RegisterHUDMutator: Registered"@Name);
				P.MyHUD.HUDMutator = Self;
				PlayerOwner = P;
				bHUDMutator = True;
			}
		}
	}
	else ForEach AllActors(class'Engine.PlayerPawn', P)
		if ( P.MyHUD != None ) {
			For (M = P.MyHUD.HUDMutator; M != None; M = M.NextHUDMutator)
				if ( M.Class == Class )
					break;
			if ( M != None && M.Class == Class )
				continue;	// already registered, check next PlayerPawn
			NextHUDMutator = P.MyHUD.HUDMutator;
			MyHUD = P.MyHUD;
			MyChallengeHUD = ChallengeHUD(MyHud);
			if ( class'PickupPlus'.default.bDebugMode &&  P.MyHUD.HUDMutator != None )
				log("RegisterHUDMutator: Registered"@Name$", NextHUDMutator is"@P.MyHUD.HUDMutator.Name);
			else if ( class'PickupPlus'.default.bDebugMode )
				log("RegisterHUDMutator: Registered"@Name);
			P.MyHUD.HUDMutator = Self;
			PlayerOwner = P;
			bHUDMutator = True;
		}
	
	if ( !bHUDMutator ) {
		bPendingHUDRegistration = True;
		Enable('Tick');
	}
}

// always call Super.Tick(DeltaTime) to ensure the HUD registration works
simulated function Tick(float DeltaTime)
{
	if ( Level.NetMode != NM_DedicatedServer && !bHUDMutator && bPendingHUDRegistration )
		RegisterHUDMutator();
}

// If this function returns true, the mutator will handle drawing the weapon and
// the weapon's OldRenderOverlays() function and all PostRenderOverlaysFor()
// functions will be skipped. Following PreRenderOverlaysFor() calls for other
// mutators or PickupPlus affectors will not be skipped.
simulated function bool PreRenderOverlaysFor(Weapon W, Canvas C)
{
	return false;
}

simulated function PostRenderOverlaysFor(Weapon W, Canvas C);

// this is missing in the original PostRender() function of Engine.Mutator
simulated function PostRender(Canvas Canvas)
{
	if ( NextHUDMutator != None )
		NextHUDMutator.PostRender(Canvas);
}

defaultproperties
{
     MultiPickupBaseClass="EnhancedItems.MultiPickupPlus"
}
