﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTWarfareBarricadeMessage extends UTLocalMessage
	abstract;

var localized string CantAttackMessage;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.CantAttackMessage;
}

defaultproperties
{
	MessageArea=2
	FontSize=1
	bIsPartiallyUnique=true
}