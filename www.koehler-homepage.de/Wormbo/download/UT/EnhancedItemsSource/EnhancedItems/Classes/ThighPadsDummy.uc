// this item does nothing but displaying the thigh pads icon in the status doll
class ThighPadsDummy extends ThighPads;

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	return Damage;
}

function bool HandlePickupQuery( inventory Item )
{
	if ( Inventory != None )
		return Inventory.HandlePickupQuery(Item);
	return false;
}

function Inventory SpawnCopy(Pawn Other)
{
	return Super(TournamentPickup).SpawnCopy(Other);
}

// this item needs bIsAnArmor to work but is not inserted into the temporary armor chain
function inventory PrioritizeArmor( int Damage, name DamageType, vector HitLocation )
{
	local Inventory FirstArmor, InsertAfter;

	if ( Inventory != None )
		FirstArmor = Inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
	else
		FirstArmor = None;
	
	// don't return self
	return FirstArmor;
}

function int ArmorPriority(name DamageType)
{
	return -1;
}

event float BotDesireability( pawn Bot )
{
	return -1;
}

defaultproperties
{
     Charge=0
     ArmorAbsorption=0
     AbsorptionPriority=-1
}
