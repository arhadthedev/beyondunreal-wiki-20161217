// EnhancedItems by Wormbo
//=============================================================================
// MultiPickupPlus.
//
// Features:
// - spawnes one of up to 20 different item classes
// - the next item is chosen either randomly or in the order given in the
//   Items array (see bRandomChoosing, RejectChance[])
// - the next item is spawned after the previous one was picked up or a certein
//   amount of time has passed (see bEmulateMultiItem, StopEmulation(),
//   Duration[] and DefaultDuration)
// - before the first item is spawned an initial interval of time set for this
//   item has to pass (can be set individually for each item, can be zero)
// - each EnhancedMutator may change values after the MultiPickupPlus has been
//   initialized through the mutator's CheckMPP() function
//=============================================================================

class MultiPickupPlus extends Inventory config(EnhancedItems);

// maximum number of items per MultiPickupPlus item (must be same like array sizes below)
const MaxNumItems = 20;

// default duration when emulating MultiItem
var() const float DefaultDuration;

var byte ImportedFromMI[20];

var() Class<Inventory> Item[20],	// list of item classes to spawn
	ReplacedItem;	// if this MPP replaced another item, the class of that
	             	// item is stored here (can also be set by map makers

var() vector LocationOffset[20];	// offset from the MPP's location to spawn an item
                                	// Note: Unlike ChaosUT.MultiItem MPPs calculate
                                	// the base offset from the item's CollisionHeight
                                	// like the Mutator.ReplaceWith() function.

var() float InitRespawnTime[20],	// the MPP will wait this periode of time,
                                	// until the first item will be spawned
	Duration[20],    	// used with bEmulatedMultiItem, duration for the item to stay,
	                 	// else if not 0 used as respawn time for the item
	RejectChance[20];	// chance of choosing another item instead of this one

var() int NumItems;	// Actual number of items this MPP has in its list. (Any items with
                   	// an index >= this value are removed in the PreBeginPlay() function.)
var() bool bRandomChoosing,	// If true the MPP chooses items randomly from its list.
	bEmulateMultiItem,      // The MPP should cycle its item list like ChaosUT.MultiItem does.
	bEmulateWhenCoopMode,	// Set bEmulateMultiItem=True when has weapons and Level.Game.bCoopWeaponMode=True.
	bNoMutatorCheck,        // Don't allow mutators to check the MPP's list of items.
	bAllowItemRotation,     // Items are allowed to rotate.
	bForceItemRotation,     // Spawned items always rotate. (only with bAllowItemRotation)
	bAllowItemFall,         // Items are allowed to rotate.
	bForceItemFall;         // Spawned items always rotate. (only with bAllowItemRotation)

// Whether MultiItem emulation is allowed or not. When this is true,
// bEmulateMultiItem and bEmulateWhenCoopMode have no effect.
var(Advanced) globalconfig bool bNoEmulation;

var bool bStarted, bNotified, bDebugMode;
var float CurTime;
var Inventory CurItem;	// currently spawned item
var int CurItemIndex, PrevItemIndex,	// list index of current and last item spawned
	CheckCounter;	// used for checking recursions

var Mutator CreatedBy;	// this mutator won't get a CheckMPP() call

replication
{
	unreliable if ( Role == ROLE_Authority && NumItems > 0 )
		Item;
}

static final function bool ClassIsA(class aClass, coerce string DesiredType)
{
	return class'EnhancedMutator'.static.ClassIsA(aClass, DesiredType);
}

// check the MPP's location
function CheckLocation()
{
	local vector HitLocation, HitNormal;
	local bool bCorrectLocation;
	
	bCollideWorld = True;
	
	// current location ok?
	bCorrectLocation = SetLocation(Location);
	
	// floor check (most likely causes 'Fell out of world' errors if incorrect)
	if ( !bCorrectLocation && Trace(HitLocation, HitNormal, Location - vect(0,0,1) * CollisionHeight,
			Location + vect(0,0,1) * CollisionHeight, False) == Level )
		bCorrectLocation = SetLocation(HitLocation + vect(0,0,1) * CollisionHeight);
	if ( !bCorrectLocation && bDebugMode )
		log(HitNormal,Name);
	
	// trace to sides (wall check)
	if ( !bCorrectLocation && Trace(HitLocation, HitNormal, Location - vect(1,0,0) * CollisionHeight,
			Location + vect(1,0,0) * CollisionHeight, False) == Level )
		bCorrectLocation = SetLocation(HitLocation + vect(1,0,0) * CollisionHeight);
	if ( !bCorrectLocation && Trace(HitLocation, HitNormal, Location - vect(-1,0,0) * CollisionHeight,
			Location + vect(-1,0,0) * CollisionHeight, False) == Level )
		bCorrectLocation = SetLocation(HitLocation + vect(-1,0,0) * CollisionHeight);
	if ( !bCorrectLocation && Trace(HitLocation, HitNormal, Location - vect(0,1,0) * CollisionHeight,
			Location + vect(0,1,0) * CollisionHeight, False) == Level )
		bCorrectLocation = SetLocation(HitLocation + vect(0,1,0) * CollisionHeight);
	if ( !bCorrectLocation && Trace(HitLocation, HitNormal, Location - vect(0,-1,0) * CollisionHeight,
			Location + vect(0,-1,0) * CollisionHeight, False) == Level )
		bCorrectLocation = SetLocation(HitLocation + vect(0,-1,0) * CollisionHeight);
	
	// location ok now?
	if ( !bCorrectLocation )
		Destroy();
	
	bCollideWorld = False;
}

function PreBeginPlay()
{
	local int i;
	
	bDebugMode = class'PickupPlus'.default.bDebugMode;
	
	if ( !bNoEmulation && bEmulateWhenCoopMode && Level.Game.bCoopWeaponMode && InItem(class'Weapon', i, True) )
		bEmulateMultiItem = True;
	
	// set durations, if they are not specified
	if ( bEmulateMultiItem )
		for (i = 0; i < MaxNumItems; i++)
			if ( Duration[i] == DefaultDuration || Duration[i] <= 0 )
				Duration[i] = DefaultDuration * (1 - RejectChance[i]);
	
	// remove unused items from list
	for (i = NumItems; i < MaxNumItems; i++)
		Item[i] = None;
	
	// try to prevent items from falling out of the world
	CheckLocation();
	
	// clean up other item slots
	Compact();
}

function StopEmulation()
{
	local int i;
	
	if ( bEmulateMultiItem && bDebugMode )
		log(Name$": Stopping MultiItem emulation.");
	else if ( !bEmulateMultiItem )
		return;
	bEmulateMultiItem = False;
	bRandomChoosing = True;
	for ( i = 0; i < MaxNumItems; i++ ) {
		if ( RejectChance[i] == 0 )
			RejectChance[i] = Max(0, 1 - (Duration[i] / DefaultDuration));
		Duration[i] = 0;
	}
	
	//GotoState('ChooseNextItem', 'Begin');
}

// find item class by class reference (can find subclasses, doesn't use IdenticalTo)
final function bool InItem(class<Inventory> LookFor, out int Index, optional bool bSubClasses, optional bool bCheckReplaced)
{
	local int i;
	local bool bFoundItem;
	
	Index = -1;
	if ( LookFor == None )
		return false;	// no item specified
	
	for ( i = 0; i < NumItems; i++ ) {
		if ( Item[i] == None )
			continue;
		else if ( Item[i] == LookFor ) {
			if ( bDebugMode )
				log("InItem: Found"@Item[i]@"inside"@Name@"as #"$i);
			Index = i;	// item found
			break;
		}
		else if ( bSubClasses && ClassIsChildOf(Item[i], LookFor) ) {
			if ( bDebugMode )
				log("InItem: Found"@Item[i]@"(subclass of"@LookFor.Name$") inside"@Name@"as #"$i);
			Index = i;
			break;
		}
	}
	if ( Index != -1 )
		return true;
	else if ( ReplacedItem == None )
		return false;
	else if ( LookFor == ReplacedItem && bCheckReplaced ) {
		if ( bDebugMode )
			log("InItem:"@Name@"replaced a"@ReplacedItem);
		Index = -2;
		return true;
	}
	else if ( bSubClasses && bCheckReplaced && ClassIsChildOf(ReplacedItem, LookFor) ) {
		if ( bDebugMode )
			log("InItem:"@Name@"replaced a"@ReplacedItem@"(subclass of"@LookFor$")");
		Index = -2;
		return true;
	}
	return false;	// item not found
}

// find item class by class name (can use IdenticalTo, doesn't find subclasses)
final function bool FindItem(name LookFor, out int Index, optional bool bIdenticalClasses, optional bool bCheckReplaced)
{
	local int i;
	local bool bFoundItem;
	
	Index = -1;
	if ( LookFor == '' || LookFor == 'None' )
		return false;	// no item specified
	
	for (i = 0; i < NumItems; i++) {
		if ( Item[i] == None )
			continue;
		else if ( Item[i].Name == LookFor ) {
			if ( bDebugMode )
				log("FindItem: Found"@Item[i]@"inside"@Name@"as #"$i);
			Index = i;	// item found
			break;
		}
		else if ( bIdenticalClasses && ((ClassIsChildOf(Item[i], class'EnhancedWeapon')
				&& class<EnhancedWeapon>(Item[i]).Default.IdenticalTo == LookFor)
				|| (ClassIsChildOf(Item[i], class'PickupPlus')
				&& class<PickupPlus>(Item[i]).Default.IdenticalTo == LookFor)) ) {
			if ( bDebugMode )
				log("FindItem: Found"@Item[i]@"(identical to"@LookFor$") inside"@Name@"as #"$i);
			Index = i;
			break;
		}
	}
	if ( Index != -1 )
		return true;
	else if ( !bCheckReplaced || ReplacedItem == None )
		return false;
	else if ( LookFor == ReplacedItem.Name ) {
		if ( bDebugMode )
			log("FindItem:"@Name@"replaced a"@ReplacedItem);
		Index = -2;
		return true;
	}
	else if ( bIdenticalClasses && ((ClassIsChildOf(ReplacedItem, class'EnhancedWeapon')
			&& class<EnhancedWeapon>(ReplacedItem).Default.IdenticalTo == LookFor)
			|| (ClassIsChildOf(ReplacedItem, class'PickupPlus')
			&& class<PickupPlus>(ReplacedItem).Default.IdenticalTo == LookFor)) ) {
		if ( bDebugMode )
			log("FindItem:"@Name@"replaced a"@ReplacedItem@"(identical to"@LookFor$")");
		Index = -2;
		return true;
	}
	return false;	// item not found
}

// find item class through the ClassIsA() function
final function bool AnyClassIsA(coerce string LookFor, out int Index, optional bool bCheckReplaced)
{
	local int i;
	
	Index = -1;
	for (i = 0; i < NumItems; i++) {
		if ( ClassIsA(Item[i], LookFor) ) {
			if ( bDebugMode )
				log("AnyClassIsA: Found"@Item[i]@"inside"@Name@"as #"$i);
			Index = i;
			break;
		}
	}
	if ( Index > -1 )
		return true;
	
	if ( bCheckReplaced && ClassIsA(ReplacedItem, LookFor) ) {
		if ( bDebugMode )
				log("AnyClassIsA:"@Name@"replaced a"@ReplacedItem);
		Index = -2;
		return true;
	}
	return false;	// item not found
}

function bool AddItem(coerce string NewItem, optional vector NewItemOffset, optional float NewInitTime, optional float NewChance, optional float NDuration)
{
	local int i;
	local float NewDuration;
	local class<Inventory> NewItemClass;
	
	if ( NDuration == 0.0 && bEmulateMultiItem )
		NewDuration = DefaultDuration * (1- NewChance);
	else
		NewDuration = NDuration;
	
	if ( NewItem == "" || NewItem ~= "None" || InStr(NewItem, ".") == -1 ) {
		if ( bDebugMode )
			log("AddItem: Nothing to add."@NewItem);
		return false;
	}
	
	i = 0;
	while (Item[i]!=None) {
		if ( string(Item[i]) ~= NewItem ) {
			if ( bDebugMode )
				log("AddItem: "@NewItem@"already in"@Name@"as #"$i$". Applying new values.");
			LocationOffset[i]  = NewItemOffset;
			InitRespawnTime[i] = NewInitTime;
			RejectChance[i]    = NewChance;
			Duration[i]        = NewDuration;
			return true;
		}
		i++;
		if ( i == MaxNumItems )
			return false;
		else if ( i == NumItems )
			break;
	}
	NumItems++;
	Item[i] = LoadItem(NewItem);
	if ( Item[i]!=None ) {
		LocationOffset[i]  = NewItemOffset;
		InitRespawnTime[i] = NewInitTime;
		RejectChance[i]    = NewChance;
		Duration[i]        = NewDuration;
		ImportedFromMI[i]  = 0;
		//GotoState('ChooseNextItem', 'Begin');
		if ( bDebugMode )
				log("AddItem: Added"@Item[i]@"as item #"$i@"to"@Name@"(now"@NumItems@"items)");
//		if ( Level.Game.bCoopWeaponMode && class<Weapon>(Item[i]) != None )
//			DisableCoopMode();
		return true;
	} else {
		NumItems--;
		return false;
	}
}

// disable bCoopWeaponMode and reset bWeaponStay for all weapons on map
function DisableCoopMode()
{
	local Weapon w;
	
	if ( Level.Game == None || !Level.Game.bCoopWeaponMode )
		return;
	ForEach AllActors(Class'Engine.Weapon', W) {
		W.bWeaponStay = W.Class.Default.bWeaponStay;
		W.SetWeaponStay();
	}
}

// Removes an item from the MPP.
// Can be prohibited by any EnhancedMutator via AlwaysKeepInMPP()
// Returns true if the item was removed or was None.
function bool RemoveItem(int ItemIndex)
{
	local int i;
	local bool bWasEmpty;
	
	// avoid errors due to wrong parameter
	if ( ItemIndex < 0 || ItemIndex >= MaxNumItems ) {
		if ( ItemIndex == -2 )
			log(Self.Name$".RemoveItem: Tried to remove the ReplacedItem value.");
		log(Self.Name$".RemoveItem: Parameter has to be >= 0 and <"@MaxNumItems@"(is"@ItemIndex$")");
		return false;
	}
	
	if ( Item[ItemIndex] != None && AlwaysKeep(Item[ItemIndex]) )
		return false;
	
	if ( bDebugMode )
		log("RemoveItem: Removing item #"$ItemIndex@"("$Item[ItemIndex]$") from"@Name@"("$NumItems@"items)");
	Item[ItemIndex] = None;
	
	Compact();
	
	//log("RemoveItem: Item #"$ItemIndex@"now is"@Item[ItemIndex]@"("$NumItems@"items left)");
	if ( ItemIndex == CurItemIndex )
		GotoState('ChooseNextItem', 'Begin');
	return true;
}

// this function removes empty item slots and recalculates the number of items
function Compact()
{
	local int i, j;
	
	// remove empty slots
	for (i = 0; i < MaxNumItems; i++)
		for (j = i + 1; j < MaxNumItems; j++)
			if ( Item[i] == None && Item[j] != None ) {
				//log(Name$": Item["$i$"] was empty");
				Item[i]            = Item[j];
				LocationOffset[i]  = LocationOffset[j];
				RejectChance[i]    = RejectChance[j];
				InitRespawnTime[i] = InitRespawnTime[j];
				Duration[i]        = Duration[j];
				Item[j] = None;
			}
	
	// recalculate number of items
	i = 0;
	NumItems = 0;
	while ( i < MaxNumItems ) {
		if ( Item[i] != None )
			NumItems++;
//		if ( Level.Game.bCoopWeaponMode && class<Weapon>(Item[i]) != None )
//			Level.Game.bCoopWeaponMode = False;
		i++;
	}
	
	if ( NumItems == 0 && !IsInState('Idle') )
		GotoState('Idle');
}

function bool ReplaceItem(int ItemIndex, coerce string NewItem, optional vector NewItemOffset, optional float InitTime, optional float Chance, optional float NDuration, optional bool AlwaysAdd )
{
	// InItem returns index -2 if the MPP replaced an item of the same class as searched for
	if ( ItemIndex == -2 && AlwaysAdd )
		return AddItem(NewItem, NewItemOffset, InitTime, Chance, NDuration);
	else if ( RemoveItem(ItemIndex) || AlwaysAdd )
		return AddItem(NewItem, NewItemOffset, InitTime, Chance, NDuration);
	
	return false;
}

function class<Inventory> LoadItem(coerce string ItemClass)
{
	local class<Inventory> ClassName;
	
	ClassName = Class<Inventory>(DynamicLoadObject(ItemClass, class'Class', True));
	if ( String(ClassName) == "None" ) {
		log(Name$": Loading failed!"@ItemClass@"is not a valid inventory class!");
		return None;
	} else {
		//log(Name$": Loaded"@ClassName);
		return ClassName;
	}
}

function vector AdjustLocation(int ItemIndex)
{
	local vector NewLocation;
	
	NewLocation = Location;
	if ( ImportedFromMI[ItemIndex] == 0 )
		NewLocation.Z += Item[ItemIndex].Default.CollisionHeight - CollisionHeight;
	NewLocation += LocationOffset[ItemIndex];
	return NewLocation;
}

// call the CheckMPP function of each active EnhancedMutator and EnhancedArena
function NotifyMutators()
{
	local Mutator M;
	
	if ( bNotified || bNoMutatorCheck ) return;
	bNotified = True;
	
	//log(self$": Notifying Mutators...");
	for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
		if ( M.IsA('EnhancedMutator') && M != CreatedBy ) {
			//log(Name$": Calling"@M.Name$".CheckMPP...");
			if ( EnhancedMutator(M).CheckMPP(Self) )
				break;
		}
		else if ( M.IsA('EnhancedArena') && M != CreatedBy ) {
			//log(Name$": Calling"@M.Name$".CheckMPP...");
			if ( EnhancedArena(M).CheckMPP(Self) ) {
				break;
			}
		}
}

// call the AlwaysKeepInMPP function of each active EnhancedMutator and EnhancedArena
function bool AlwaysKeep(class<Inventory> ItemClass)
{
	local Mutator M;
	
	//log(Name$": Asking Mutators if allowed to remove"@ItemClass@"...");
	for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
		if ( M.IsA('EnhancedMutator') ) {
			//log(Name$": Calling"@M.Name$".AlwaysKeepInMPP...");
			if ( EnhancedMutator(M).AlwaysKeepInMPP(Self, ItemClass) ) {
				if ( bDebugMode )
					log(M.Name@"wants to keep"@ItemClass@"in"@Name);
				return true;
			}
		}
		else if ( M.IsA('EnhancedArena') ) {
			if ( EnhancedArena(M).AlwaysKeepInMPP(Self, ItemClass) ) {
				if ( bDebugMode )
					log(M.Name@"wants to keep"@ItemClass@"in"@Name);
				return true;
			}
		}
	
	return false;
}

// no items to spawn so there's nothing to do
auto state Idle
{
	event float BotDesireability( pawn Bot )
	{
		return -1;
	}
	
Begin:
	Compact();
	Sleep(0.1);
	CurItemIndex = -1;
	NotifyMutators();
	Compact();
	if ( NumItems > 0 )
		GotoState('ChooseNextItem');
}

// choose another item and spawn it
state ChooseNextItem
{
	event float BotDesireability( pawn Bot )
	{
		if ( CurItem != None && !CurItem.bHeldItem )
			return CurItem.BotDesireability(Bot);
		return -1;
	}
	
Begin:
	CheckCounter = 0;
	if ( bEmulateMultiItem && bNoEmulation )
		StopEmulation();
	if ( CurItem != None && (CurItem.bHeldItem || CurItem.Inventory != None) )
		CurItem = None;
	If ( NumItems == 0 )
		GotoState('Idle');
	PrevItemIndex = CurItemIndex;
	Sleep(0.1);
		
Choose:
	CheckCounter++;
	
	// this should never be called
	if ( CheckCounter % 1000 == 0 )
		log(Name$": CheckCounter ="@CheckCounter@"Item["$CurItemIndex$"] ="@Item[CurItemIndex]@
				"RejectChance["$CurItemIndex$"] ="@RejectChance[CurItemIndex]);
	
	if ( bStarted && CurTime > Duration[CurItemIndex] )
		CurTime = Duration[CurItemIndex];
	if ( bRandomChoosing ) {
		CurItemIndex = Rand(NumItems);
		if ( FRand() > 1.0 - RejectChance[CurItemIndex] && !bEmulateMultiItem )
			Goto('Choose');	// item was rejected, choose again
	}
	else {
		CurItemIndex++;
		If ( CurItemIndex >= NumItems || CurItemIndex < 0 )
			CurItemIndex = 0;
	}
	
	// no item in this slot so clean up and choose again
	if ( Item[CurItemIndex] == None ) {
		Compact();
		if ( NumItems > 0 )
			Goto('Choose');
		else
			GotoState('Idle');
	}
	
	// wait before the item is spawned:
	// - after another item was picked up
	// - if this is the first item to be spawned here and there is an InitRespawnTime
	if ( bStarted && !bEmulateMultiItem ) {
		if ( Duration[CurItemIndex] == 0 )
			Sleep(Item[CurItemIndex].Default.RespawnTime + Rand(7) - 3);
		else
			Sleep(Duration[CurItemIndex] + Rand(7) - 3);
	}
	else if ( InitRespawnTime[CurItemIndex] != 0 && !bEmulateMultiItem ) {
		Sleep(InitRespawnTime[CurItemIndex] + RandRange(-5, 5));
		bStarted = True;
	}
	
	if ( PrevItemIndex != CurItemIndex || CurItem == None || CurItem.bHeldItem || !bStarted ) {
		If ( CurItem != None && !CurItem.bHeldItem )
			CurItem.Destroy();
		// now spawn the item previously chosen
		CurItem = Spawn(Item[CurItemIndex],,, AdjustLocation(CurItemIndex), Rotation);
		if ( CurItem == None )
			Goto('Choose');	// Spawn failed, choose again
		if ( CurItem.Physics == PHYS_Falling && !bAllowItemFall )
			CurItem.SetPhysics(PHYS_None);
		else if ( CurItem.Physics != PHYS_Falling && bForceItemFall )
			CurItem.SetPhysics(PHYS_Falling);
		CurItem.bRotatingPickup = bAllowItemRotation && (CurItem.bRotatingPickup || bForceItemRotation);
		CurItem.RespawnTime = 0.0;	// item should not respawn
		if ( CurItem.IsA('Weapon') )
			Weapon(CurItem).bWeaponStay = false;
		if ( bStarted ) {
			if ( CurItem.RespawnSound != None )
				CurItem.PlaySound(CurItem.RespawnSound);
	 		Sleep(Level.Game.PlaySpawnEffect(CurItem));
			if ( PickupPlus(CurItem) != None && !bEmulateMultiItem )
	 			if ( PickupPlus(CurItem).GlobalRespawnSound != None )
					PickupPlus(CurItem).PlayGlobalSound(PickupPlus(CurItem).GlobalRespawnSound);
		}
	}
	
	bStarted = True;
	GotoState('SpawnedItem');
}

// an item was spawned, wait until it is picked up or destroyed
state SpawnedItem
{
	function BeginState()
	{
		local Actor A;
		
		if ( Event != '' )
			ForEach AllActors(class'Actor', A, Event)
				A.Trigger(Self, None);
		if ( MyMarker != None )
			MyMarker.markedItem = CurItem;
	}
	
	function Timer ()
	{
		if ( bEmulateMultiItem && CurTime >= Duration[CurItemIndex] ) {
			GotoState('ChooseNextItem');
		}
		else if ( CurItem == None ) {
			if ( bEmulateMultiItem )
				GotoState('ItemPickedUp');
			else
				GotoState('ChooseNextItem');
		}
		else if ( CurItem.GetStateName() == 'Sleeping' || CurItem.bHeldItem )
		{
			if ( CurItem.bHeldItem )
				CurItem = None;
			else {
				CurItem.Destroy();
				CurItem = None;
			}
			if ( bEmulateMultiItem )
				GotoState('ItemPickedUp');
			else
				GotoState('ChooseNextItem');
		}
		else {
			CurTime += 1.0;
			SetTimer(1.0, false);
		}
	}

	event float BotDesireability( pawn Bot )
	{
		if ( CurItem != None )
			return CurItem.BotDesireability(Bot);
		return -1;
	}
	
	function EndState()
	{
		if ( MyMarker != None )
			MyMarker.markedItem = Self;
	}
	

Begin:
	CurTime = 0.0;
	SetTimer(1.0, false);
}

// CurItem was picked up while in MultiItem emulation mode.
// Wait for the periode of time specified in DefaultDuration, then continue.
state ItemPickedUp extends Idle
{
Begin:
	Sleep(DefaultDuration);
	GotoState('ChooseNextItem');
}

defaultproperties
{
     DefaultDuration=30.000000
     bEmulateWhenCoopMode=True
     bRandomChoosing=True
     bAllowItemFall=True
     bAllowItemRotation=True
     MaxDesireability=1.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bHidden=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_DumbProxy
     DrawType=DT_Sprite
     Texture=Texture'Engine.S_Inventory'
}
