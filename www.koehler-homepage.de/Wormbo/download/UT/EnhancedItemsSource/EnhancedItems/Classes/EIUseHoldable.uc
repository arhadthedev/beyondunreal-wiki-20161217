// EnhancedItems by Wormbo
//=============================================================================
// EIUseHoldable.
//
// Features:
//	- manages item selection and using holdable powerups
//	- added automatically by any PickupPlus that needs it
//=============================================================================

class EIUseHoldable extends EnhancedMutator config(EnhancedItems);

var bool Initialized;

// if true, checking for holdable usage occurs with player pawns, too
var globalconfig bool bAutoUseHoldables;

var localized string SelectedNone;

function PostBeginPlay()
{
	if ( Initialized || bDeleteMe )
		return;
	Initialized = True;
	
	Level.Game.BaseMutator.AddMutator(Self);
	Level.Game.RegisterDamageMutator(Self);
}

function MutatorTakeDamage(out int ActualDamage, Pawn Victim, Pawn InstigatedBy, out Vector HitLocation, out Vector Momentum, name DamageType)
{
	local Inventory Inv;

	if ( NextDamageMutator != None )
		NextDamageMutator.MutatorTakeDamage( ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType );
	
	if ( Victim.IsA('Bot') || bAutoUseHoldables ) {
		for( Inv = Victim.Inventory; Inv != None; Inv = Inv.Inventory )   
			if ( Inv.IsA('HoldablePowerup') ) {
				HoldablePowerup(Inv).RecommendUse(DamageType, ActualDamage, InstigatedBy, HitLocation, True);
				Break;
			}
	}
}

// modified version of Pawn.NextItem()
function NextItem(pawn Other)
{
	local Inventory Inv;

	if ( Other.SelectedItem == None ) {
		Other.SelectedItem = SelectNext(Other.Inventory);
		Return;
	}
	if ( Other.SelectedItem.Inventory != None)
		Other.SelectedItem = SelectNext(Other.SelectedItem.Inventory); 
	else
		Other.SelectedItem = SelectNext(Other.Inventory);

	if ( Other.SelectedItem == None )
		Other.SelectedItem = SelectNext(Other.Inventory);
}

// modified version of PlayerPawn.PrevItem()
function PrevItem(pawn Other)
{
	local Inventory Inv, LastItem, CurItem;

	if ( Other.SelectedItem != None )
		CurItem = SelectNext(Other.SelectedItem, True);
	
	for( Inv = Other.Inventory; Inv != None; Inv = SelectNext(Inv.Inventory, True) ) {
		if ( LastItem == CurItem )
			break;
		LastItem = Inv;
	}
	
	if ( LastItem != None )
		Other.SelectedItem = SelectNext(LastItem);
	else
		NextItem(Other);	// PrevItem() failed, try NextItem()
}

// modified version of Inventory.SelectNext()
function Inventory SelectNext(Inventory PrevItem, optional bool bQuiet)
{
	if ( PrevItem.IsA('Pickup') && (!PrevItem.IsA('PickupPlus') || !PrevItem.IsInState('Activated')
			|| PickupPlus(PrevItem).bDeactivatable || !Pickup(PrevItem).bAutoActivate)
			&& PrevItem.bActivatable && PrevItem.M_Selected != "" ) {
		if ( !bQuiet )
			Pawn(Owner).ClientMessage(PrevItem.ItemName$PrevItem.M_Selected);
		return PrevItem;
	}
	if ( PrevItem.Inventory != None )
		return SelectNext(PrevItem.Inventory, bQuiet);
	else
		return None;
}

function Mutate(string MutateString, PlayerPawn Sender)
{
	local Inventory Inv;
	local bool bUsedHoldable;
	
	if ( MutateString ~= "UseHoldable" ) {
		for (Inv = Sender.Inventory; Inv != None; Inv = Inv.Inventory)
			if ( Inv.IsA('HoldablePowerup') ) {
				HoldablePowerup(Inv).UseHoldable();
				bUsedHoldable = True;
			}
		if ( !bUsedHoldable )
			Sender.ActivateItem();
	}
	
	Inv = Sender.SelectedItem;
	if ( MutateString ~= "SelectNext" ) {
		NextItem(Sender);
		if ( Inv != None && Sender.SelectedItem == None )
			Sender.ClientMessage(SelectedNone);
	}
	
	if ( MutateString ~= "SelectPrev" ) {
		PrevItem(Sender);
		if ( Inv != None && Sender.SelectedItem == None )
			Sender.ClientMessage(SelectedNone);
	}
	
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

defaultproperties
{
     bAllowOnlyOnce=True
     bAutoUseHoldables=True
}
