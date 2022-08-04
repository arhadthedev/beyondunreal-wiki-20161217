// this item does nothing but displaying the shield icon around the status doll
class ShieldBeltDummy extends UT_ShieldBelt;

// all these functions need to be disabled, so the dummy neither removes other armors
// nor absorbs damage
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

function PickupFunction(Pawn Other);

function ArmorImpactEffect(vector HitLocation);

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

function SetEffectTexture();

// ignore Destroyed function of UT_Shieldbelt
// instead execute Destroyed function of TournamentPickup to remove self from pawn's inventory
function Destroyed()
{
	Super(TournamentPickup).Destroyed();
}

defaultproperties
{
     Charge=0
     ArmorAbsorption=0
     AbsorptionPriority=-1
}
