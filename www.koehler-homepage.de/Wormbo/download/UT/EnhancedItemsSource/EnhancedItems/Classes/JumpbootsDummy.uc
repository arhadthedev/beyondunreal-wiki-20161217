//-----------------------------------------------------------------------------
// JumpBootsDummy.
//-----------------------------------------------------------------------------
// This is a deactivated version of the UT_JumpBoots that displays the boots in
// the status doll when added to a player's inventory. It can be used by any
// boot-like inventory item that doesn't expand UT_JumpBoots.
class JumpBootsDummy extends UT_JumpBoots;

function PickupFunction(Pawn Other);

function OwnerJumped()
{
	if ( Inventory != None )
		Inventory.OwnerJumped();
}

state Activated
{
	function EndState();
Begin:
}

state DeActivated
{
Begin:		
}

defaultproperties
{
     bAutoActivate=False
     bActivatable=False
     bDisplayableInv=False
     ExpireMessage=""
     PickupMessage=""
     ItemName=""
     RespawnTime=0.000000
     Charge=0
     PickupSound=None
     ActivateSound=None
}
