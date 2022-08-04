// EnhancedItems by Wormbo
//=============================================================================
// EnhancedDeathMessage.
//
//	- used with EnhancedWeapon and EnhancedProjectile
//	- replaces UT's DeathMessagePlus (replacement through EIDeathMessageMutator)
//=============================================================================

/*
Killing messages use the following placeholders:
%k	killer
%o	victim
%w	weapon
%p	projectile

Suicide messages use the following placeholders:
%o	victim
%w	weapon
%p	projectile
If the suicide string does not contain "%o",
the suicider's name is placed in front of the string.

Switch >1: use DeathMessagePlus for death message
Switch  1: Suicide
Switch  0: Kill w/ direct hit
Switch -1: Kill w/ splash damage
Switch -2: Kill head shot
Switch -3: Head shot suicide
Switch -4: Splash damage kill, but announce head shot
Switch -5: Splash damage suicide, but announce head shot

RelatedPRI_1 is the Killer.
RelatedPRI_2 is the Victim.
OptionalObject is the Killer's Weapon or Projectile Class.
*/
//=============================================================================

class EnhancedDeathMessage extends DeathMessagePlus;

static function string GetString(
	optional int iSwitch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	local int HitType;	// 0 = direct hit, 1 = head shot, 2 = splash damage
	local string TempString;
	
	if ( OptionalObject == None || iSwitch > 1
			|| (class<Weapon>(OptionalObject) != None && class<EnhancedWeapon>(OptionalObject) == None) )
		return Super.GetString(iSwitch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	
	if ( RelatedPRI_1 == None || RelatedPRI_1.PlayerName == "" )
		return "";
	
	if ( iSwitch == -3 ) {
		iSwitch = 1;
		HitType = 1;
	}
	if ( iSwitch == -5 ) {
		iSwitch = 1;
		HitType = 2;
	}
	else if ( iSwitch == -2 ) {
		iSwitch = 0;
		HitType = 1;
	}
	else if ( iSwitch == -1 || iSwitch == -4 ) {
		iSwitch = 0;
		HitType = 2;
	}
	
	switch (iSwitch) {
		case 0:	// Killed somebody
			if ( RelatedPRI_2 == None || RelatedPRI_2.PlayerName == "" )
				return "";
			if ( Class<EnhancedWeapon>(OptionalObject) == None && Class<EnhancedProjectile>(OptionalObject) == None )
				return "";
			return ParseKillMessage(RelatedPRI_1.PlayerName, RelatedPRI_2.PlayerName, OptionalObject, HitType);
			break;
		case 1: // Suicided
			TempString = GetSuicideString(OptionalObject, HitType, RelatedPRI_1.bIsFemale);
			if ( InStr(TempString, "%o") < 0 )
				TempString = RelatedPRI_1.PlayerName$TempString;
			else
				class'PickupPlus'.static.ReplaceText(TempString, "%o", RelatedPRI_1.PlayerName);
			return TempString;
			break;
	}
	log("Unexpected message parameters: Switch ="@iSwitch@"OptionalObject ="@OptionalObject@"PRI1:"@(RelatedPRI_1!=None)@"PRI2:"@(RelatedPRI_2!=None));
}

static function string ParseKillMessage(string Killer, string Victim, Object Other, int HitType)
{
	local string TempString, WeaponName, ProjectileName;
	
	if ( class<EnhancedWeapon>(Other) != None ) {
		Switch (HitType) {
		Case 2:
			TempString = class<EnhancedWeapon>(Other).Default.SplashHitString;
			break;
		Case 1:
			TempString = class<EnhancedWeapon>(Other).Default.HeadHitString;
			break;
		default:
			TempString = class<EnhancedWeapon>(Other).Default.DirectHitString;
			break;
		}
		WeaponName = class<EnhancedWeapon>(Other).Default.ItemName;
		ProjectileName = class<EnhancedWeapon>(Other).Default.ProjectileName;
	}
	else if ( class<EnhancedProjectile>(Other) != None ) {
		Switch (HitType) {
		Case 2:
			TempString = class<EnhancedProjectile>(Other).Default.SplashHitString;
			break;
		Case 1:
			TempString = class<EnhancedProjectile>(Other).Default.HeadHitString;
			break;
		default:
			TempString = class<EnhancedProjectile>(Other).Default.DirectHitString;
			break;
		}
		if ( class<EnhancedProjectile>(Other).Default.FiredFrom != None )
			WeaponName = class<EnhancedProjectile>(Other).Default.FiredFrom.Default.ItemName;
		ProjectileName = class<EnhancedProjectile>(Other).Default.ProjectileName;
	}
	
	class'PickupPlus'.static.ReplaceText(TempString, "%k", Killer);
	class'PickupPlus'.static.ReplaceText(TempString, "%o", Victim);
	class'PickupPlus'.static.ReplaceText(TempString, "%w", WeaponName);
	class'PickupPlus'.static.ReplaceText(TempString, "%p", ProjectileName);
	return TempString;
}

static function string GetSuicideString(Object Other, int HitType, bool bFemale)
{
	local string TempString;
	
	if ( class<EnhancedWeapon>(Other) != None ) {
		if ( bFemale ) {
			if ( HitType == 1 )
				return class<EnhancedWeapon>(Other).Default.HeadSuicideFString;
			TempString = class<EnhancedWeapon>(Other).Default.SuicideFString;
		} else {
			if ( HitType == 1 )
				return class<EnhancedWeapon>(Other).Default.HeadSuicideString;
			TempString = class<EnhancedWeapon>(Other).Default.SuicideString;
		}
	}
	else if ( class<EnhancedProjectile>(Other) != None ) {
		if ( bFemale ) {
			if ( HitType == 1 )
				return class<EnhancedProjectile>(Other).Default.HeadSuicideFString;
			TempString = class<EnhancedProjectile>(Other).Default.SuicideFString;
		} else {
			if ( HitType == 1 )
				return class<EnhancedProjectile>(Other).Default.HeadSuicideString;
			TempString = class<EnhancedProjectile>(Other).Default.SuicideString;
		}
	}
	
	if ( TempString != "" ) {
		if ( class<EnhancedProjectile>(Other) != None ) {
			class'PickupPlus'.static.ReplaceText(TempString, "%p", Class<EnhancedProjectile>(Other).Default.ProjectileName);
			if ( Class<EnhancedProjectile>(Other).Default.FiredFrom != None )
				class'PickupPlus'.static.ReplaceText(TempString, "%w", Class<EnhancedProjectile>(Other).Default.FiredFrom.Default.ItemName);
		}
		if ( class<EnhancedWeapon>(Other) != None ) {
			class'PickupPlus'.static.ReplaceText(TempString, "%w", Class<EnhancedWeapon>(Other).Default.ItemName);
			class'PickupPlus'.static.ReplaceText(TempString, "%p", Class<EnhancedWeapon>(Other).Default.ProjectileName);
		}
		return TempString;
	}
	if ( bFemale )
		return class'TournamentGameInfo'.Default.FemaleSuicideMessage;
	else
		return class'TournamentGameInfo'.Default.MaleSuicideMessage;
}

static function ClientReceive(PlayerPawn P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
		optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local int PlayerSelect;	// 1 = headshot kill, 2 = headshot victim, 3 = headshot suicide
	
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( P.PlayerReplicationInfo == RelatedPRI_1 ) {
		if ( RelatedPRI_1 == RelatedPRI_2 )
			PlayerSelect = 3;
		else
			PlayerSelect = 1;
	}
	else if ( P.PlayerReplicationInfo == RelatedPRI_2 )
		PlayerSelect = 2;
	
	if ( Switch < -1 && PlayerSelect > 0 ) {
		if ( class<EnhancedWeapon>(OptionalObject) != None
				&& class<EnhancedWeapon>(OptionalObject).default.HeadShotMessage != None )
			P.ReceiveLocalizedMessage(class<EnhancedWeapon>(OptionalObject).default.HeadShotMessage, PlayerSelect);
		else if ( class<EnhancedProjectile>(OptionalObject) != None
				&& class<EnhancedProjectile>(OptionalObject).default.HeadShotMessage != None )
			P.ReceiveLocalizedMessage(class<EnhancedProjectile>(OptionalObject).default.HeadShotMessage, PlayerSelect);
	}
}

defaultproperties
{
}
