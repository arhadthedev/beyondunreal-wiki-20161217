// EnhancedItems by Wormbo
//=============================================================================
// TimedPowerup
//
// Activates on pickup and expires after the amount of time initially
// specified by FullCharge
//=============================================================================

class TimedPowerup extends PickupPlus
	abstract;

var() float FinalCount,	// if Remaining drops below this the DeactivateSound is played when calling TimedAction()
	FullCharge,		// the amount of charge this item initially has
	Remaining,		// the amount of charge the item still has left
	TimingInterval;	// interval of time for calling TimedAction()
var() int FinalCountInterval;	// after playing the DeactivateSound this amount of intervals have to pass before playing it again
var int FinalCounter;
var() bool bPreFinalCount,	// play DeactivateSound once when twice the amount of FinalCount is left
	bDeactivateCount,	// play DeactivateSound when Remaining reaches 0
	bAddCharge,		// add the charge of the picked up item (else restore to FullCharge)
	bDeactivatedUseCharge;	// also uses charge in Deactivated state

replication
{
	reliable if ( Role == ROLE_Authority )
		FinalCount, Remaining;
}

simulated function Destroyed()
{
	if ( bActive )
		UsedUp();
	
	Super.Destroyed();
}

simulated function UsedUp()
{
	if ( !IsInState('Activated') )
		TimedOut();
	if ( !bActive )
		return;
	
	SetTimer(0.0, False);
	DeactivateAction();
	
	bActive = False;
	SetOwnerDisplay();
	ChangedWeapon();
	
	if ( Level.Game != None && Pawn(Owner) != None ) {
		if ( Level.Game.LocalLog != None )
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if ( Level.Game.WorldLog != None )
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	if ( ShellEffect != None )
		ShellEffect.Destroy();
	
	if ( Role == ROLE_Authority ) {
		ResetOwnerSpeed();
		ResetDamageFactor();
	}
}

event float BotDesireability( pawn Bot )
{
	local Inventory Inv;
	local float desire;
	local TimedPowerup AlreadyHas;
	
	desire = MaxDesireability;
	AlreadyHas = TimedPowerup(Bot.FindInventoryType(class));
	
	if ( AlreadyHas == None )
		return Super.BotDesireability(Bot);
	
	if ( AlreadyHas.Remaining > AlreadyHas.FullCharge )
		desire *= AlreadyHas.FullCharge / AlreadyHas.Remaining;

	return desire;
}

function bool HandlePickupQuery( inventory Item )
{
	if ( Item.Class == Class ) {
		if ( bAllowSameClassPickup && bDisplayableInv ) {		
			if ( bAddCharge )
				Remaining += TimedPowerup(Item).FullCharge;
			else
				Remaining = FullCharge;
			
			if ( Level.Game.LocalLog != None )
				Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
			if ( Level.Game.WorldLog != None )
				Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
			
			if ( Item.PickupMessageClass == None )
				Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
			else
				Pawn(Owner).ReceiveLocalizedMessage(Item.PickupMessageClass, 0, None, None, Item.Class);
			
			PlaySound(Item.PickupSound,,2.0);
			PlayGlobalSound(PickupPlus(Item).GlobalPickupSound);
			Item.SetReSpawn();
		}
		return true;				
	}
	if ( Inventory == None )
		return false;
	
	return Inventory.HandlePickupQuery(Item);
}

simulated function ActivateAction();
simulated function TimedAction();
simulated function DeactivateAction();

State Activated
{
	simulated function Timer()
	{
		Remaining -= TimingInterval;
		
		TimedAction();
		
		if ( Remaining > FinalCount) {
			if ( bPreFinalCount && Remaining == 2 * FinalCount )
				Owner.PlaySound(DeactivateSound);
		}
		else if ( Remaining > 0 ) {
			if ( ++FinalCounter % FinalCountInterval == 0 )
				Owner.PlaySound(DeactivateSound);
		}
		else {
			if ( bDeactivateCount )
				Owner.PlaySound(DeactivateSound);
			UsedUp();
			Destroy();
		}
	}
	
	simulated function EndState()
	{
		UsedUp();
	}

	simulated function BeginState()
	{
		// (re-)start countdown
		if ( Remaining == 0 || (Remaining > FullCharge && !bAddCharge) )
			Remaining = FullCharge;
		FinalCount = Min(FinalCount, Remaining - 1);
		SetTimer(TimingInterval, True);
		bActive = true;
		
		ActivateAction();
	}
}

// this is similar to UsedUp(), but is called instead of that function if in
// Deactivated state
simulated function TimedOut()
{
	bActive = False;
	
	if ( Level.Game != None && Pawn(Owner) != None ) {
		if ( Level.Game.LocalLog != None )
			Level.Game.LocalLog.LogItemDeactivate(Self, Pawn(Owner));
		if ( Level.Game.WorldLog != None )
			Level.Game.WorldLog.LogItemDeactivate(Self, Pawn(Owner));
	}
	if ( ShellEffect != None )
		ShellEffect.Destroy();
	
	if ( Role == ROLE_Authority ) {
		ResetOwnerSpeed();
		ResetDamageFactor();
	}
}

state Deactivated
{
	simulated function Timer()
	{
		Remaining -= TimingInterval;
		
		if ( Remaining == FinalCount)
			Owner.PlaySound(DeactivateSound);
		else {
			if ( bDeactivateCount )
				Owner.PlaySound(DeactivateSound);
			TimedOut();
			Destroy();
		}
	}
	
	simulated function BeginState()
	{
		if ( bDeactivatedUseCharge )
			SetTimer(TimingInterval, True);
		FinalCount = Min(FinalCount, Remaining - 1);
		bActive = false;
	}
}

defaultproperties
{
     bDeactivateCount=True
     FinalCount=5
     FullCharge=45
     TimingInterval=1.000000
     FinalCountInterval=1
     RespawnTime=120.000000
     MaxDesireability=2.500000
}
