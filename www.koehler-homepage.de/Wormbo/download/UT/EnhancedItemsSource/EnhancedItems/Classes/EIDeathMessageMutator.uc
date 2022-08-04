//-----------------------------------------------------------------------------
// EIDeathMessageMutator.
//-----------------------------------------------------------------------------
// This mutator enhances the death messages of EnhancedWeapons and
// EnhancedProjectiles by intercepting the regular death messages sent by UT.
class EIDeathMessageMutator extends EnhancedMutator;

var class<Actor> DamageActor[5];	// the actor (EnhancedWeapon or EnhancedProjectile) that deals out damage
var byte bSplashDamage[5],	// whether the damage was splash damage or not
	bHeadShot[5];			// whether the hit was a head shot or not

var bool Initialized, bUseMeInstead;
var class<DeathMessagePlus> EnhancedDeathMessageClass;
var class<EIDeathMessageSpawnNotify> MySpawnNotifyClass;
var EIDeathMessageSpawnNotify MySpawnNotify;

function AddDamageActor(class<Actor> NewActor, bool bSplashHit, bool bHeadHit)
{
	local int i;
	
	for (i = ArrayCount(DamageActor) - 1; i > 0; i--) {
		DamageActor[i] = DamageActor[i - 1];
		bSplashDamage[i] = bSplashDamage[i - 1];
		bHeadShot[i] = bHeadShot[i - 1];
	}
	DamageActor[0] = NewActor;
	bSplashDamage[0] = int(bSplashHit);
	bHeadShot[0] = int(bHeadHit);
}

function RemoveDamageActor()
{
	local int i;
	
	for (i = 0; i < ArrayCount(DamageActor) - 1; i++) {
		DamageActor[i] = DamageActor[i + 1];
		bSplashDamage[i] = bSplashDamage[i + 1];
		bHeadShot[i] = bHeadShot[i + 1];
	}
	DamageActor[ArrayCount(DamageActor) - 1] = None;
	bSplashDamage[ArrayCount(bSplashDamage) - 1] = 0;
	bHeadShot[ArrayCount(bHeadShot) - 1] = 0;
}

function Spawned()
{
	local SpawnNotify SN;
	
	for (SN = Level.SpawnNotify; SN != None; SN = SN.Next)
		if ( SN.IsA('EIDeathMessageSpawnNotify') ) {
			MySpawnNotify = EIDeathMessageSpawnNotify(SN);
			if ( MySpawnNotify.EIDMM == None || bUseMeInstead )
				MySpawnNotify.EIDMM = Self;
			return;
		}
	if ( MySpawnNotifyClass != None )
		MySpawnNotify = Spawn(MySpawnNotifyClass, Self);
	if ( MySpawnNotify != None )
		MySpawnNotify.EIDMM = Self;
}

function PreBeginPlay()
{
	Level.Game.RegisterMessageMutator(Self);
}

function bool MutatorBroadcastLocalizedMessage(Actor Sender, Pawn Receiver, out class<LocalMessage> Message, out optional int iSwitch, out optional PlayerReplicationInfo RelatedPRI_1, out optional PlayerReplicationInfo RelatedPRI_2, out optional Object OptionalObject)
{
	if ( Message == Level.Game.DeathMessageClass && DamageActor[0] != None ) {
		Message = EnhancedDeathMessageClass;
		OptionalObject = DamageActor[0];
		if ( iSwitch == 1 && bHeadShot[0] != 0 && bSplashDamage[0] != 0 )
			iSwitch = -5;	// splash damage suicide w/ headshot message
		else if ( iSwitch == 0 && bHeadShot[0] != 0 && bSplashDamage[0] != 0 )
			iSwitch = -4;	// splash damage kill w/ headshot message
		else if ( iSwitch == 1 && bHeadShot[0] != 0 )
			iSwitch = -3;	// head shot suicide
		else if ( iSwitch == 0 && bHeadShot[0] != 0 )
			iSwitch = -2;	// head shot kill
		else if ( iSwitch == 0 && bSplashDamage[0] != 0 )
			iSwitch = -1;	// splash damage kill
	}
	
	if ( NextMessageMutator != None )
		return NextMessageMutator.MutatorBroadcastLocalizedMessage(Sender, Receiver, Message, iSwitch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	else
		return true;
}

defaultproperties
{
     bAllowOnlyOnce=True
     EnhancedDeathMessageClass=class'EnhancedItems.EnhancedDeathMessage'
     MySpawnNotifyClass=Class'EnhancedItems.EIDeathMessageSpawnNotify'
}