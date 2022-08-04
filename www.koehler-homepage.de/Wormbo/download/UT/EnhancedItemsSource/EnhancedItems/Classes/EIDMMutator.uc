// EnhancedItems by Wormbo
//-----------------------------------------------------------------------------
// DMMutator.
//-----------------------------------------------------------------------------
class EIDMMutator extends DMMutator;

// you can disable any of these features from other mutators
var bool bSetAutoActivate,	// sets bAutoActivate (Pickup class) to True
	bKeepStationaryPawns,	// excludes StationaryPawn classes from CheckReplacement()
	bSetMegaSpeed,		// sets higher speed for players if the game type is configured for turbo speed
	bReplaceWeapons,	// replace Unreal weapons
	bReplaceAmmo,		// replace Unreal ammo and Dispersion Pistol upgrade
	bReplaceHealth,		// replace Unreal health items (not Nali Fruit)
	bReplaceArmor,		// replace Kevlar Suit and Assault Vest (Unreal body armor)
	bReplaceJumpBoots,	// replace Unreal Jump Boots (remove them if it's a jump match game)
	bReplaceShieldbelt,	// replace Unreal Shieldbelt
	bReplaceInvisibility,	// replace Unreal Invisibility
	bReplaceAmplifier;	// replace Amplifier (for Dispersion Pistol & Unreal ASMD) with Damage Amplifier

var float MegaSpeedFactor;	// actual speed factor to use in mega speed games

function AddMutator(Mutator M)
{
	if ( M.IsA('NoAlwaysAutoActivate') ) {
		bSetAutoActivate = False;
		M.Destroy();
	}
	else
		Super.AddMutator(M);
}

function bool AlwaysKeep(Actor Other)
{
	local bool bTemp;
	
	if ( bKeepStationaryPawns && Other.IsA('StationaryPawn') )
		return true;

	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Inventory Inv;

	// replace Unreal I inventory actors by their Unreal Tournament equivalents
	// set bSuperRelevant to false if want the gameinfo's super.IsRelevant() function called
	// to check on relevancy of this actor.

	bSuperRelevant = 1;
	if ( bSetMegaSpeed && MyGame.bMegaSpeed && Other.bIsPawn && Pawn(Other).bIsPlayer ) {
		Pawn(Other).GroundSpeed *= MegaSpeedFactor;
		Pawn(Other).WaterSpeed *= MegaSpeedFactor;
		Pawn(Other).AirSpeed *= MegaSpeedFactor;
		Pawn(Other).AccelRate *= MegaSpeedFactor;
	}

	Inv = Inventory(Other);
 	if ( Inv == None ) {
		bSuperRelevant = 0;
		if ( Other.IsA('TorchFlame') )
			Other.NetUpdateFrequency = 0.5;
		return true;
	}
	
	// probably never used (no mutators allowed in rated games)
	if ( MyGame.bNoviceMode && MyGame.bRatedGame && Level.NetMode == NM_Standalone )
		Inv.RespawnTime *= (0.5 + 0.1 * MyGame.Difficulty);

	if ( Other.IsA('TournamentWeapon') )
		return true;
	if ( bReplaceWeapons && Other.IsA('Weapon') ) {
		if ( Other.IsA('Stinger') )
			ReplaceWith(Other, "Botpack.PulseGun");
		else if ( Other.IsA('Rifle') )
			ReplaceWith( Other, "Botpack.SniperRifle" );
		else if ( Other.IsA('Razorjack') )
			ReplaceWith( Other, "Botpack.Ripper" );
		else if ( Other.IsA('Minigun') )
			ReplaceWith( Other, "Botpack.Minigun2" );
		else if ( Other.IsA('AutoMag') )
			ReplaceWith( Other, "Botpack.Enforcer" );
		else if ( Other.IsA('Eightball') )
			ReplaceWith( Other, "Botpack.UT_Eightball" );
		else if ( Other.IsA('FlakCannon') )
			ReplaceWith( Other, "Botpack.UT_FlakCannon" );
		else if ( Other.IsA('ASMD') )
			ReplaceWith( Other, "Botpack.ShockRifle" );
		else if ( Other.IsA('GesBioRifle') )
			ReplaceWith( Other, "Botpack.UT_BioRifle" );
		else if ( Other.IsA('DispersionPistol') )
			ReplaceWith( Other, "Botpack.ImpactHammer");
		else {
			bSuperRelevant = 0;
			return true;
		}
		return false;
	}
	
	if ( Other.IsA('TournamentAmmo') )
		return true;
	if ( bReplaceAmmo && Other.IsA('Ammo') ) {
		if ( Other.IsA('ASMDAmmo') )
			ReplaceWith( Other, "Botpack.ShockCore" );
		else if ( Other.IsA('RocketCan') )
			ReplaceWith( Other, "Botpack.RocketPack" );
		else if ( Other.IsA('StingerAmmo') )
			ReplaceWith(Other, "Botpack.PAmmo");
		else if ( Other.IsA('RazorAmmo') )
			ReplaceWith( Other, "Botpack.BladeHopper" );
		else if ( Other.IsA('RifleRound') )
			ReplaceWith( Other, "Botpack.RifleShell" );
		else if ( Other.IsA('RifleAmmo') )
			ReplaceWith( Other, "Botpack.BulletBox" );
		else if ( Other.IsA('FlakBox') )
			ReplaceWith( Other, "Botpack.FlakAmmo" );
		else if ( Other.IsA('Clip') )
			ReplaceWith( Other, "Botpack.EClip" );
		else if ( Other.IsA('ShellBox') )
			ReplaceWith( Other, "Botpack.MiniAmmo" );
		else if ( Other.IsA('Sludge') )
			ReplaceWith( Other, "Botpack.BioAmmo" );
		else {
			bSuperRelevant = 0;
			return true;
		}
		return false;
	}

	if ( bSetAutoActivate && Other.IsA('Pickup') )
		Pickup(Other).bAutoActivate = true;
	if ( Other.IsA('TournamentPickup') )
		return true;
	
	if ( Other.IsA('TournamentHealth') )
		return true;

	//log("Found "$Other$" at "$Other.location);
	//Assert(false);

	if ( bReplaceJumpBoots && Other.IsA('JumpBoots') ) {
		if ( !MyGame.bJumpMatch )
			ReplaceWith( Other, "Botpack.UT_JumpBoots" );
	}
	else if ( bReplaceAmplifier && Other.IsA('Amplifier') )
		ReplaceWith( Other, "Botpack.UDamage" );
	else if ( bReplaceArmor && Other.IsA('KevlarSuit') )
		ReplaceWith( Other, "Botpack.ThighPads");
	else if ( bReplaceHealth && Other.IsA('SuperHealth') )
		ReplaceWith( Other, "Botpack.HealthPack" );
	else if ( bReplaceArmor && Other.IsA('Armor') )
		ReplaceWith( Other, "Botpack.Armor2" );
	else if ( bReplaceHealth && Other.IsA('Bandages') )
		ReplaceWith( Other, "Botpack.HealthVial" );
	else if ( bReplaceHealth && Other.IsA('Health') && !Other.IsA('NaliFruit') )
		ReplaceWith( Other, "Botpack.MedBox" );
	else if ( bReplaceShieldbelt && Other.IsA('ShieldBelt') )
		ReplaceWith( Other, "Botpack.UT_ShieldBelt" );
	else if ( bReplaceInvisibility && Other.IsA('Invisibility') )
		ReplaceWith( Other, "Botpack.UT_Invisibility" );
	else if ( bReplaceWeapons || !Other.IsA('WeaponPowerUp') ) {
		bSuperRelevant = 0;
		return true;
	}
	return false;
}

defaultproperties
{
     bSetAutoActivate=True
     bKeepStationaryPawns=True
     bSetMegaSpeed=True
     MegaSpeedFactor=1.4
     bReplaceWeapons=True
     bReplaceAmmo=True
     bReplaceHealth=True
     bReplaceArmor=True
     bReplaceShieldbelt=True
     bReplaceInvisibility=True
     bReplaceAmplifier=True
}
