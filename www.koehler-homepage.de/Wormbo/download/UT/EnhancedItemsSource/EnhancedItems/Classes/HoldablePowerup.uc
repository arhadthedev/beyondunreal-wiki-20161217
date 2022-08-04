// EnhancedItems by Wormbo
//=============================================================================
// HoldablePowerup.
//=============================================================================

class HoldablePowerup extends PickupPlus
	abstract;

var() bool bKillsOwner,	// using the holdable will kill the owner (e.g. Kamikaze)
	bMultiUse,			// if holdable is used the first time it goes to activated state
	bInstantAutoUse,	// if the holdable detects a usage situation, it will instantly activate
	bMoreUsageChecks;	// if false, checks for good usage will only be done when owner gets hit
var bool UseMe,			// if not bInstantAutoUse, this will be set to activate the holdable
	bAutoUseHoldables;	// same as EIUseHoldable.bAutoUseHoldables
var() localized string UseText, ReUseText;
var() class<LocalMessage> UseMessageClass;

function PreBeginPlay()
{
	Super(TournamentPickup).PreBeginPlay();
	bAutoUseHoldables = class'EnhancedItems.EIUseHoldable'.Default.bAutoUseHoldables;
}

function bool HandlePickupQuery( Inventory Item )
{
	if ( Item.Class == Class && bCanHaveMultipleCopies )
		return Super.HandlePickupQuery(Item);
	return Item.IsA('HoldablePowerup') || Super.HandlePickupQuery(Item);
}

// executes the functionality of the holdable and returns true if it could be activated
function bool DoActiveAction();

function UseHoldable()
{
	Pawn(Owner).PlaySound(ActivateSound);
	if ( DoActiveAction() ) {
		if ( UseMessageClass == None && UseText != "" )
			Pawn(Owner).ClientMessage(UseText);
		else if ( UseText != "" )
			Pawn(Owner).ReceiveLocalizedMessage(UseMessageClass, 0, None, None, Self.Class);
		if ( Level.Game.LocalLog != None )
			Level.Game.LocalLog.LogItemActivate(Self, Pawn(Owner));
		if ( Level.Game.WorldLog != None )
			Level.Game.WorldLog.LogItemActivate(Self, Pawn(Owner));
		if ( bMultiUse )
			GotoState('Activated');
		else if ( bCanHaveMultipleCopies && NumCopies > 0 )
			NumCopies--;
		else
			UsedUp();
	}
}

function bool RecommendUse(name DamageType, int Damage, pawn InstigatedBy, vector HitLocation, optional bool Urgent)
{
	local int ActualDamage;
	
	if ( Pawn(Owner) != None ) {
		if ( Owner.IsA('Bot') || class'EIUseHoldable'.default.bAutoUseHoldables )
			if ( GoodUsage(DamageType, Damage, InstigatedBy, Urgent) ) {
				if ( bInstantAutoUse )
					UseHoldable();
				else {
					UseMe = True;
					SetTimer(0.01, False);
				}
				return true;
			}
	}
	return false;
}

// describes good situations to use the holdable, should be redefined in subclasses
function bool GoodUsage(name DamageType, int ActualDamage, pawn InstigatedBy, optional bool Urgent)
{
	return Urgent && !bKillsOwner;
}

event float BotDesireability( pawn Bot )
{
	local Inventory Inv;
	
	// try to get rid of other holdables before picking this one up
	for( Inv = Bot.Inventory; Inv != None; Inv = Inv.Inventory )   
		if ( Inv.IsA('HoldablePowerup') && !HoldablePowerup(Inv).bKillsOwner
				&& !HoldablePowerup(Inv).RecommendUse('None', 0, None, Bot.Location, False) )
			return -1;
	return Super.BotDesireability(Bot);
}

function Activate()
{
	GoToState('Ready');
}

// holdable is ready to activate
state Ready
{
	function BeginState()
	{
		if ( (bAutoUseHoldables || Owner.IsA('Bot')) && bMoreUsageChecks )
			SetTimer(0.1, False);
		UseMe = False;
	}
	
	function Activate()
	{
		UseHoldable();
	}
	
	function Timer()
	{
		if ( bAutoUseHoldables || Owner.IsA('Bot') ) {
			if ( UseMe ) {
				UseMe = False;
				UseHoldable();
				return;
			}
			if ( !RecommendUse('None', 0, None, Owner.Location, False) && bMoreUsageChecks )
				SetTimer(0.1, False);
		}
	}
}

// holdable is active
state Activated
{
	function Activate()
	{
		UseHoldable();
	}
	
	function UseHoldable()
	{
		Pawn(Owner).PlaySound(ActivateSound);
		if ( DoActiveAction() ) {
			if ( UseMessageClass == None && ReUseText != "" )
				Pawn(Owner).ClientMessage(ReUseText);
			else if ( ReUseText != "" )
				Pawn(Owner).ReceiveLocalizedMessage(UseMessageClass, 1, None, None, Self.Class);
			if ( Level.Game.LocalLog != None )
				Level.Game.LocalLog.LogItemActivate(Self, Pawn(Owner));
			if ( Level.Game.WorldLog != None )
				Level.Game.WorldLog.LogItemActivate(Self, Pawn(Owner));
			UsedUp();
		}
	}
}

defaultproperties
{
     M_Activated=""
     M_Selected=""
     M_Deactivated=""
     UseMessageClass=class'HoldableUseMessage'
     bMoreUsageChecks=True
     RespawnTime=60.000000
     MaxDesireability=1.500000
}
