// EnhancedItems by Wormbo
class NoAlwaysAutoActivate extends EnhancedMutator;

function PreBeginPlay()
{
	local Mutator M;
	
	Super.PreBeginPlay();
	
	// add EIUseHoldable
	for (M = Level.Game.DamageMutator; M != None; M = M.NextDamageMutator)
		if ( M.IsA('EIUseHoldable') )
			return;
	
	log(Name$": Adding"@Spawn(class'EnhancedItems.EIUseHoldable').Name$"...");
}

// This resets the bAutoActivate values of all Pickups to their default values
// after DMMutator (base mutator of UT) set all of them to True.
function bool CheckReplacement(actor Other, byte bSuperRelevant)
{
	if ( Other.IsA('Pickup') && Pickup(Other).bActivatable
			&& Pickup(Other).bAutoActivate != Pickup(Other).Default.bAutoActivate) {
		if ( class'PickupPlus'.default.bDebugMode )
			log("Reset bAutoActivate in"@Other@"to"@Pickup(Other).Default.bAutoActivate);
		Pickup(Other).bAutoActivate = Pickup(Other).Default.bAutoActivate;
	}
	return true;
}

defaultproperties
{
     bAllowOnlyOnce=True
}
