//=============================================================================
// MIConverter
//=============================================================================
// This class is spawned by an EnhancedMutator, but not added to the list of
// mutators.
// The MIConverter replaces all ChaosUT MultiItems with MultiPickupPlus items,
// exept for those which have only one item in the list. These will be
// converted directly to the item.
// These MPP will go into emulation mode so they behave (almost) like a
// MultiItem but are compatible with every EnhancedMutator's CheckMPP function.
// You can stop the emulation mode by calling the MPP's StopEmulation function
// at any time.
class MIConverter extends EnhancedMutator config(EnhancedItems);

var int Counter;
var globalconfig bool bReportOut;

function PreBeginPlay()
{
	local MultiItem mi;
	local int ConvertCount;
	
	Counter++;
//	log("MIConverter: Check #"$Counter$"...");
	foreach AllActors(class'ChaosUT.MultiItem', mi) {
		ReplaceMultiItem(mi);
		ConvertCount++;
	}
	if ( ConvertCount > 0 )
		log("MIConverter: Check #"$Counter@"completed,"@ConvertCount@"items converted.");
}

function Tick(float DeltaTime)
{
	PreBeginPlay();
	if ( Counter >= 3 ) {
		Disable('Tick');
		if ( class'PickupPlus'.default.bDebugMode )
			ReportOut();
	}
}

function ReportOut()
{
	local HUD H;
	local Mutator M;
	local string s;
	
	s = "Found Mutators:";
	ForEach AllActors(class'Engine.Mutator', M)
		if ( !M.bDeleteMe )
			s = s @ M.Name;
	log(s);
	if ( Level.Game != None ) {
		s = "Registered Mutators:";
		For (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
			s = s @ M.Name;
		log(s);
		s = "Registered Damage Mutators:";
		For (M = Level.Game.DamageMutator; M != None; M = M.NextDamageMutator)
			s = s @ M.Name;
		log(s);
		s = "Registered Message Mutators:";
		For (M = Level.Game.MessageMutator; M != None; M = M.NextMessageMutator)
			s = s @ M.Name;
		log(s);
	}
	ForEach AllActors(class'Engine.HUD', H) {
		s = "Registered HUDMutators for"@H.Name$":";
		For (M = H.HUDMutator; M != None; M = M.NextHUDMutator)
			s = s @ M.Name;
		log(s);
	}
}

function MultiPickupPlus ReplaceMultiItem(MultiItem Other)
{
	local MultiPickupPlus A;
	local class<MultiPickupPlus> aClass;
	local int i;
	
	/*if ( Other.NumItems == 1 ) {
		ReplaceWith(Other, string(Other.FixMultiItemClass(Other.Item1)));
		Other.Destroy();
		return None;
	}*/
	
	A = ReplaceWithMPP(Other);
	if ( A == None )
		return None;
	
	A.bEmulateMultiItem = !A.bNoEmulation;	// change item after Duration has passed (if the MPP allows it)
	//A.bRandomChoosing = False;
	
	if ( Other.Item1 != None && Other.Duration1 > 0 ) {
		A.AddItem(string(Other.Item1), Other.LocationOffset1,,, Other.Duration1);
		A.ImportedFromMI[0] = 1;
	}
	if ( Other.Item2 != None && Other.Duration2 > 0 ) {
		A.AddItem(string(Other.Item2), Other.LocationOffset2,,, Other.Duration2);
		A.ImportedFromMI[1] = 1;
	}
	if ( Other.Item3 != None && Other.Duration3 > 0 ) {
		A.AddItem(string(Other.Item3), Other.LocationOffset3,,, Other.Duration3);
		A.ImportedFromMI[2] = 1;
	}
	if ( Other.Item4 != None && Other.Duration4 > 0 ) {
		A.AddItem(string(Other.Item4), Other.LocationOffset4,,, Other.Duration4);
		A.ImportedFromMI[3] = 1;
	}
	
	// state 'Idle' calls CheckMPP of all EnhancedMutators
	A.bNotified = False;
	A.GotoState('Idle', 'Begin');
	
	if ( class'PickupPlus'.default.bDebugMode ) {
		log("MIConverter: Replaced"@Other@"with"@A@"("$A.NumItems@"Items):");
		for (i = 0; i < A.NumItems; i++) {
			log("MIConverter: Item["$i$"] ="@A.Item[i]);
			log("MIConverter: LocationOffset["$i$"] ="@A.LocationOffset[i]);
		}
	}
	Other.Destroy();
	
	return A;
}

defaultproperties
{
}
