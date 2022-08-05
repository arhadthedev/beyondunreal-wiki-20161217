﻿//=============================================================================
// AccessControl.
//
// AccessControl is a helper class for GameInfo.
// The AccessControl class determines whether or not the player is allowed to
// login in the PreLogin() function, and also controls whether or not a player
// can enter as a spectator or a game administrator.
//
// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class AccessControl extends Info
	config(Game);

var globalconfig array<string>   IPPolicies;
var globalconfig array<UniqueNetID> BannedIDs;

struct BannedInfo
{
	var UniqueNetID BannedID;
	var string PlayerName;
	var string TimeStamp;
};

var globalconfig array<BannedInfo>   BannedPlayerInfo;

struct BannedHashInfo
{
	var string PlayerName;
	var string BannedHash;
};

var globalconfig array<BannedHashInfo> BannedHashes;

var	localized string          IPBanned;
var	localized string	      WrongPassword;
var	localized string          NeedPassword;
var localized string          SessionBanned;
var localized string		  KickedMsg;
var localized string          DefaultKickReason;
var localized string		  IdleKickReason;
/** String to display when kicked for banned CD hash key */
var localized string BannedCDHashKeyString;
/** String to display when kicked for a timed out CD hash key request */
var localized string TimedOutCDHashKeyString;

var class<Admin> AdminClass;

var private globalconfig string AdminPassword;	    // Password to receive bAdmin privileges.
var private globalconfig string GamePassword;		// Password to enter game.

var localized string ACDisplayText[3];
var localized string ACDescText[3];

var bool bDontAddDefaultAdmin;

struct SessionBanInfo
{
	var UniqueNetID BanID;
	var string BanHash;
	var string BanIP;
};

var array<SessionBanInfo> SessionBans;


/**
 * @return	TRUE if the specified player has admin priveleges.
 */
function bool IsAdmin(PlayerController P)
{
	if ( P != None )
	{
		if ( Admin(P) != None )
		{
			return true;
		}

		if ( P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.bAdmin )
		{
			return true;
		}
	}

	return false;
}

function bool SetAdminPassword(string P)
{
	AdminPassword = P;
	return true;
}

function SetGamePassword(string P)
{
	GamePassword = P;
	WorldInfo.Game.UpdateGameSettings();
}

function bool RequiresPassword()
{
	return GamePassword != "";
}

/**
 * Takes a string and tries to find the matching controller associated with it.  First it searches as if the string is the
 * player's name.  If it doesn't find a match, it attempts to resolve itself using the target as the player id.
 *
 * @Params	Target		The search key
 *
 * @returns the controller assoicated with the key.  NONE is a valid return and means not found.
 */
function Controller GetControllerFromString(string Target)
{
	local Controller C,FinalC;
	local int i;

	FinalC = none;
	foreach WorldInfo.AllControllers(class'Controller', C)
	{
		if (C.PlayerReplicationInfo != None && (C.PlayerReplicationInfo.PlayerName ~= Target || C.PlayerReplicationInfo.GetPlayerAlias() ~= Target))
		{
			FinalC = C;
			break;
		}
	}

	// if we didn't find it by name, attemtp to convert the target to a player index and look him up if possible.
	if ( C == none && WorldInfo != none && WorldInfo.GRI != none )
	{
		for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
		{
			if ( String(WorldInfo.GRI.PRIArray[i].PlayerID) == Target )
			{
				FinalC = Controller(WorldInfo.GRI.PRIArray[i].Owner);
				break;
			}
		}
	}

	return FinalC;
}

function Kick( string Target )
{
	local Controller C;

	C = GetControllerFromString(Target);
	if ( C != none && C.PlayerReplicationInfo != None )
	{
		if (PlayerController(C) != None)
		{
			KickPlayer(PlayerController(C), DefaultKickReason);
		}
		else if (C.PlayerReplicationInfo.bBot)
		{
			if (C.Pawn != None)
			{
				C.Pawn.Destroy();
			}
			if (C != None)
			{
				C.Destroy();
			}
		}
	}
}

function KickBan( string Target )
{
	local PlayerController P;
	local BannedInfo NewBanInfo;
	local BannedHashInfo NewBanHashInfo;
	//local string IP;

	P =  PlayerController( GetControllerFromString(Target) );
	if ( NetConnection(P.Player) != None )
	{
		// don't bother with IP ban on console - doesn't work
		/*
		if (!WorldInfo.IsConsoleBuild())
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIPPolicy(IP) )
			{
				IP = Left(IP, InStr(IP, ":"));
				`Log("Adding IP Ban for: "$IP);
				IPPolicies[IPPolicies.length] = "DENY," $ IP;
				SaveConfig();
			}
		}
		*/
		if ( P.PlayerReplicationInfo.UniqueId != P.PlayerReplicationInfo.default.UniqueId &&
			!IsIDBanned(P.PlayerReplicationInfo.UniqueID) )
		{
			//Legacy struct (read from ini only), now check primarily from new BannedPlayerInfo
			//BannedIDs.AddItem(P.PlayerReplicationInfo.UniqueId);

			NewBanInfo.BannedID = P.PlayerReplicationInfo.UniqueId;
			NewBanInfo.PlayerName = P.PlayerReplicationInfo.PlayerName;
			NewBanInfo.TimeStamp = Timestamp();
			BannedPlayerInfo.AddItem(NewBanInfo);

			SaveConfig();
		}

        //Add this player to the list of banned hashes
		if (P.HashResponseCache != "" && P.HashResponseCache != "0" && !IsHashBanned(P.HashResponseCache))
		{
			NewBanHashInfo.PlayerName = P.PlayerReplicationInfo.PlayerName;
			NewBanHashInfo.BannedHash = P.HashResponseCache;
			BannedHashes.AddItem(NewBanHashInfo);
			SaveConfig();
		}

		KickPlayer(P, DefaultKickReason);
		return;
	}
}

function SessionBan(string Target)
{
	local PlayerController P;

	P = PlayerController(GetControllerFromString(Target));

	if (P != none)
		SessionBanPlayer(P);
}

function bool KickPlayer(PlayerController C, string KickReason)
{
	local string KickString;

	// Do not kick logged admins
	if (C != None && !IsAdmin(C) && NetConnection(C.Player)!=None )
	{
		if (C.Pawn != None)
		{
			C.Pawn.Suicide();
		}

		/** Written to work around old clients not getting the proper string to let them know they need to update */
		/** Since ClientWasKicked() is a client side function that if modified they won't have anyway */
		//C.ClientWasKicked();
		KickString = Localize("AccessControl", "KickedMsg", "Engine");

		//Append a reason
		if (KickReason != "" && !(KickReason ~= DefaultKickReason))
		{
			KickString @= KickReason;
		}

		C.ClientSetProgressMessage(PMT_ConnectionFailure, KickString);

		if (C != None)
		{
			C.Destroy();
		}

		return true;
	}
	return false;
}

function SessionBanPlayer(PlayerController C)
{
	local SessionBanInfo SB;

	if (C != none && !IsAdmin(C) && NetConnection(C.Player) != none)
	{
		if (!WorldInfo.IsConsoleBuild())
		{
			SB.BanIP = C.GetPlayerNetworkAddress();
			SB.BanIP = Left(SB.BanIP, InStr(SB.BanIP, ":"));
		}

		SB.BanID = C.PlayerReplicationInfo.UniqueId;

		if (C.HashResponseCache != "" && C.HashResponseCache != "0")
			SB.BanHash = C.HashResponseCache;


		SessionBans.AddItem(SB);


		`log("Session banning '"$C.PlayerReplicationInfo.GetPlayerAlias()$"', IP:"@SB.BanIP$", Hash:"@SB.BanHash$", ID:"@
			Class'OnlineSubsystem'.static.UniqueNetIDToString(SB.BanID));


		KickPlayer(C, SessionBanned);
	}
}

function bool AdminLogin( PlayerController P, string Password )
{
	if (AdminPassword == "")
		return false;

	if (Password == AdminPassword)
	{
		P.PlayerReplicationInfo.bAdmin = true;
		return true;
	}
	return false;
}

function bool AdminLogout(PlayerController P)
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin = false;
		P.bGodMode = false;
		P.Suicide();

		return true;
	}

	return false;
}

function AdminEntered( PlayerController P )
{
	local string LoginString;

	LoginString = P.PlayerReplicationInfo.GetPlayerAlias()@"logged in as a server administrator.";

	`log(LoginString);
	WorldInfo.Game.Broadcast( P, LoginString );
}
function AdminExited( PlayerController P )
{
	local string LogoutString;

	LogoutString = P.PlayerReplicationInfo.GetPlayerAlias()@"is no longer logged in as a server administrator.";

	`log(LogoutString);
	WorldInfo.Game.Broadcast( P, LogoutString );
}

/**
 * Parses the specified string for admin auto-login options
 *
 * @param	Options		a string containing key/pair options from the URL (?key=value,?key=value)
 *
 * @return	TRUE if the options contained name and password which were valid for admin login.
 */
function bool ParseAdminOptions( string Options )
{
	local string InAdminName, InPassword;

	InPassword = class'GameInfo'.static.ParseOption( Options, "Password" );
	InAdminName= class'GameInfo'.static.ParseOption( Options, "AdminName" );

	return ValidLogin(InAdminName, InPassword);
}

/**
 * @return	TRUE if the specified username + password match the admin username/password
 */
function bool ValidLogin(string UserName, string Password)
{
	return (AdminPassword != "" && Password==AdminPassword);
}

//
// Accept or reject a player on the server.
// Fails login if you set the OutError to a non-empty string.
//
event PreLogin(string Options, string Address, out string OutError, bool bSpectator)
{
	// Do any name or password or name validation here.
	local string InPassword;

	OutError="";
	InPassword = WorldInfo.Game.ParseOption( Options, "Password" );

	if( (WorldInfo.NetMode != NM_Standalone) && WorldInfo.Game.AtCapacity(bSpectator) )
	{
		//This is passed to Localize in UnPenLev.cpp so the .int has to have this string and it doesn't
		//OutError = PathName(WorldInfo.Game.GameMessageClass) $ ".MaxedOutMessage";
		OutError = "Engine.GameMessage.MaxedOutMessage";
	}
	else if ( GamePassword != "" && !(InPassword == GamePassword) && (AdminPassword == "" || !(InPassword == AdminPassword)) )
	{
		OutError = (InPassword == "") ? "Engine.AccessControl.NeedPassword" : "Engine.AccessControl.WrongPassword";
	}

	if (!CheckIPPolicy(Address))
	{
		OutError = "Engine.AccessControl.IPBanned";
	}
}


function bool CheckIPPolicy(string Address)
{
	local int i, j;
`if(`notdefined(FINAL_RELEASE))
	local int LastMatchingPolicy;
`endif
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;

	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<IPPolicies.Length; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT")
			bAcceptPolicy = True;
			else if(Policy ~= "DENY")
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				`if(`notdefined(FINAL_RELEASE))
				LastMatchingPolicy = i;
				`endif
			}
		}
	}

	if(!bAcceptAddress)
	{
		`Log("Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);
	}
	else if (Address != "" && SessionBans.Find('BanIP', Address) != INDEX_None)
	{
		`log("Denied connection for "$Address$" due to session ban");
		bAcceptAddress = False;
	}

	return bAcceptAddress;
}

function bool IsHashBanned(const string HashToCheck)
{
	local int i;

	// Check for active session bans
	if (HashToCheck != "" && SessionBans.Find('BanHash', HashToCheck) != INDEX_None)
		return true;

	//Check the new array for banned id's
	for (i = 0; i < BannedHashes.length; i++)
	{
		if (BannedHashes[i].BannedHash == HashToCheck)
		{
			return true;
		}
	}

	return false;
}

function bool IsIDBanned(const out UniqueNetID NetID)
{
	local int i;

	// Check for active session bans
	if (SessionBans.Find('BanID', NetID) != INDEX_None)
		return True;

	//Check the new array for banned id's
	for (i = 0; i < BannedPlayerInfo.length; i++)
	{
		if (BannedPlayerInfo[i].BannedID == NetID)
		{
			return true;
		}
	}

	//Legacy struct for banning
	for (i = 0; i < BannedIDs.length; i++)
	{
		if (BannedIDs[i] == NetID)
		{
			return true;
		}
	}
	return false;
}

defaultproperties
{
	AdminClass=class'Engine.Admin'
}
