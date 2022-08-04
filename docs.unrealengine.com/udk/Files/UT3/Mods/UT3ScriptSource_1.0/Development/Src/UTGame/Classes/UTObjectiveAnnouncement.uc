/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
/** this is used to handle auto objective announcements (what the game thinks the player should do next) */
class UTObjectiveAnnouncement extends UTObjectiveSpecificMessage
	dependson(UTPlayerController);

static function ObjectiveAnnouncementInfo GetObjectiveAnnouncement(byte MessageIndex, Object Objective, PlayerController PC)
{
	local UTGameObjective GameObj;
	local UTOnslaughtPowerNode Node;
	local UTCarriedObject Flag;
	local ObjectiveAnnouncementInfo EmptyAnnouncement;
	local UTPickupFactory Pickup;
	local UTVehicle Vehicle;

	GameObj = UTGameObjective(Objective);
	if (GameObj != None)
	{
		Node = UTOnslaughtPowerNode(GameObj);
		if ( (Node != None) && (Node.PrimeCore != None) )
		{
			if ( Node.bDualPrimeCore || GameObj.WorldInfo.GRI.OnSameTeam(Node.PrimeCore, PC) )
			{
				return GameObj.WorldInfo.GRI.OnSameTeam(Node, PC) ? Node.PrimeDefendAnnouncement : Node.PrimeAttackAnnouncement;
			}
			else
			{
				return GameObj.WorldInfo.GRI.OnSameTeam(Node, PC) ? Node.EnemyPrimeDefendAnnouncement : Node.EnemyPrimeAttackAnnouncement;
			}
		}
		return GameObj.WorldInfo.GRI.OnSameTeam(GameObj, PC) ? GameObj.DefendAnnouncement : GameObj.AttackAnnouncement;
	}
	else
	{
		Flag = UTCarriedObject(Objective);
		if (Flag != None )
		{
			if ( Flag.Team != None && Flag.Team.TeamIndex < Flag.NeedToPickUpAnnouncements.length)
			{
				return Flag.NeedToPickUpAnnouncements[Flag.Team.TeamIndex];
			}
		}
		else
		{
			Pickup = UTPickupFactory(Objective);
			if ( Pickup != None )
			{
				if ( class<UTWeapon>(Pickup.InventoryType) != None )
				{
					return class<UTWeapon>(Pickup.InventoryType).Default.NeedToPickupAnnouncement;
				}
			}
			else
			{
				Vehicle = UTVehicle(Objective);
				if ( Vehicle != None )
				{
					return Vehicle.NeedToPickupAnnouncement;
				}
			}
		}
	}

	return EmptyAnnouncement;
}

static function bool ShouldBeRemoved(UTQueuedAnnouncement MyAnnouncement, class<UTLocalMessage> NewAnnouncementClass, int NewMessageIndex)
{
	// don't ever allow two objective messages to be in the queue simultaneously
	return (default.Class == NewAnnouncementClass);
}

static simulated function SetHUDDisplay( PlayerController P, int Switch, string Text, PlayerReplicationInfo RelatedPRI_1,
					PlayerReplicationInfo RelatedPRI_2, Object OptionalObject )
{
	if (UTHUD(P.myHUD) != None)
	{
		UTHUD(P.myHUD).SetDisplayedOrders(Text);
	}
}

defaultproperties
{
	bIsUnique=True
	FontSize=1
	MessageArea=3
	bBeep=false
	DrawColor=(R=255,G=255,B=255,A=255)
}
