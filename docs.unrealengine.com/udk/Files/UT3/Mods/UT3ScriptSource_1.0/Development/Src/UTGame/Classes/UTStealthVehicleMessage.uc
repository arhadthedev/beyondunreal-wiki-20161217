/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTStealthVehicleMessage extends UTLocalMessage;

var localized array<string>	MessageText;
var SoundCue ErrorSound;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.MessageText[Switch];
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	P.ClientPlaySound(default.ErrorSound);
}

defaultproperties
{
	DrawColor=(R=255,G=255,B=128,A=255)
	FontSize=2
	MessageArea=2
    bIsPartiallyUnique=true
    bBeep=false
	ErrorSound=soundcue'A_Gameplay.ONS.A_GamePlay_ONS_CoreImpactShieldedCue'
}
