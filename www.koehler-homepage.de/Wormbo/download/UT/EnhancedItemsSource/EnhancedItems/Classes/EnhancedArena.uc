// EnhancedItems by Wormbo
//=============================================================================
// EnhancedArena.
//
// Features:
//	- Keeps the Translocator.
//	- Also checks MPP for correct item classes.
//=============================================================================

class EnhancedArena extends Arena abstract;

var() string KeepClasses[10];
var bool bMIConverterSpawned;

static function bool OtherIsA(actor Other, name DesiredType)
{
	return class'EnhancedMutator'.static.OtherIsA(Other, DesiredType);
}

static final function bool ClassIsA(class aClass, coerce string DesiredType)
{
	return class'EnhancedMutator'.static.ClassIsA(aClass, DesiredType);
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

function bool AlwaysKeep(Actor Other)
{
	if ( Other.IsA('MultiItem') )
		SpawnMIConverter();
	
	if ( Other.IsA(WeaponName) ) {
		if ( Weapon(Other).AmmoName != None )
			Weapon(Other).PickupAmmoCount = Weapon(Other).AmmoName.Default.MaxAmmo;
		return true;
	}
	if ( Other.IsA(AmmoName) ) {
		Ammo(Other).AmmoAmount = Ammo(Other).MaxAmmo;
		return true;
	}
	
	if ( NextMutator != None )
		return NextMutator.AlwaysKeep(Other);
	
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int i;
	
	for (i = 0; i < 10; i++)
		if ( KeepClasses[i] != "" && ClassIsA(Other.Class, KeepClasses[i]) )
			return true;
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

function bool CheckMPP(MultiPickupPlus Other)
{
	local int i;
	
	if ( Other.InItem(class'Ammo', i, True) ) {
		i = 0;
		while ( i < Other.MaxNumItems )
			if ( class<Ammo>(Other.Item[i]) == None || !Other.RemoveItem(i) )
				i++;
		if ( AmmoString != "" && !Other.FindItem(AmmoName, i) )
			Other.AddItem(AmmoString);
	}
	if ( Other.InItem(class'Weapon', i, True) ) {
		i = 0;
		while ( i < Other.MaxNumItems )
			if ( class<Weapon>(Other.Item[i]) == None || !Other.RemoveItem(i) )
				i++;
		if ( WeaponString != "" && !Other.FindItem(WeaponName, i) )
			Other.AddItem(WeaponString);
	}
	return false;
}

function bool AlwaysKeepInMPP(MultiPickupPlus Other, class<Inventory> ItemClass)
{
	local int i;
	
	if ( ItemClass.Name == WeaponName || string(ItemClass) ~= WeaponString || ItemClass == DefaultWeapon
			|| ItemClass.Name == AmmoName || string(ItemClass) ~= AmmoString )
		return true;
	
	for (i = 0; i < 10; i++)
		if ( string(ItemClass) ~= KeepClasses[i] )
			return true;
	
	return false;
}

defaultproperties
{
     KeepClasses(0)="Botpack.Translocator"
}
