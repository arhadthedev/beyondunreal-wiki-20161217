﻿/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class GameMessage extends LocalMessage;

var localized string SwitchLevelMessage;
var localized string LeftMessage;
var localized string FailedTeamMessage;
var localized string FailedPlaceMessage;
var localized string FailedSpawnMessage;
var localized string EnteredMessage;
var	localized string MaxedOutMessage;
var	localized string ArbitrationMessage;
var localized string OvertimeMessage;
var localized string GlobalNameChange;
var localized string NewTeamMessage;
var localized string NewTeamMessageTrailer;
var localized string NoNameChange;
var localized string VoteStarted;
var localized string VotePassed;
var localized string MapVoteEnabled;
var localized string MapVoteInitiated;
var localized string MustHaveStats;
var localized string CantBeSpectator;
var localized string CantBePlayer;
var localized string BecameSpectator;

var localized string NewPlayerMessage;
var localized string KickWarning;
var localized string NewSpecMessage, SpecEnteredMessage;

var localized string KickVoteMessage;
var localized string AnonKickVoteMessage;
var localized string KickVotePassMessage;
var localized string KickVoteSpamMessage;
var localized string MapVoteSubmitted;

//
// Messages common to GameInfo derivatives.
//
static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			return Default.OverTimeMessage;
			break;
		case 1:
			if (RelatedPRI_1 == None)
                return Default.NewPlayerMessage;

			return RelatedPRI_1.GetPlayerAlias()$Default.EnteredMessage;
			break;
		case 2:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.OldName@Default.GlobalNameChange@RelatedPRI_1.GetPlayerAlias();
			break;
		case 3:
			if (RelatedPRI_1 == None)
				return "";
			if (OptionalObject == None)
				return "";

            return RelatedPRI_1.GetPlayerAlias()@Default.NewTeamMessage@TeamInfo(OptionalObject).GetHumanReadableName()$Default.NewTeamMessageTrailer;
			break;
		case 4:
			if (RelatedPRI_1 == None)
				return "";

			return RelatedPRI_1.GetPlayerAlias()$Default.LeftMessage;
			break;
		case 5:
			return Default.SwitchLevelMessage;
			break;
		case 6:
			return Default.FailedTeamMessage;
			break;
		case 7:
			return Default.MaxedOutMessage;
			break;
		case 8:
			return Default.NoNameChange;
			break;
        case 9:
            return RelatedPRI_1.GetPlayerAlias()@Default.VoteStarted;
            break;
        case 10:
            return Default.VotePassed;
            break;
        case 11:
			return Default.MustHaveStats;
			break;
	case 12:
		return Default.CantBeSpectator;
		break;
	case 13:
		return Default.CantBePlayer;
		break;
	case 14:
		return RelatedPRI_1.GetPlayerAlias()@Default.BecameSpectator;
		break;
	case 15:
		return Default.KickWarning;
		break;
	case 16:
            if (RelatedPRI_1 == None)
                return Default.NewSpecMessage;

            return RelatedPRI_1.GetPlayerAlias()$Default.SpecEnteredMessage;
            break;

	case 17:
		return default.MapVoteEnabled;

	case 18:
		return default.MapVoteInitiated;

	case 19:
		return Repl(Repl(default.KickVoteMessage, "`v", RelatedPRI_1.GetPlayerAlias()), "`p", RelatedPRI_2.GetPlayerAlias());

	case 20:
		return Repl(default.AnonKickVoteMessage, "`p", RelatedPRI_2.GetPlayerAlias()); // Not a bug, I use the 2nd PRI here

	case 21:
		return Repl(default.KickVotePassMessage, "`p", RelatedPRI_1.GetPlayerAlias());

	case 22:
		return Repl(default.KickVoteSpamMessage, "`v", RelatedPRI_1.GetPlayerAlias());
	}
	return "";
}

defaultproperties
{
	bIsConsoleMessage=true
}
