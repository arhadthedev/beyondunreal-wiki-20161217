/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
//=============================================================================
// CheatManager
// Object within playercontroller that manages "cheat" commands
// only spawned in single player mode
//=============================================================================

class UTCheatManager extends CheatManager within PlayerController
	native;

var class<LocalMessage> LMC;
var SpeechRecognition RecogObject;

/** Summon a vehicle */
exec function SummonV( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;

	class'Engine'.static.CheatWasEnabled();
	`log( "Fabricate " $ ClassName );
	NewClass = class<actor>( DynamicLoadObject( "UTGameContent.UTVehicle_"$ClassName, class'Class' ) );
	if ( NewClass == None )
	{
		NewClass = class<actor>( DynamicLoadObject( "UTGameContent.UTVehicle_"$ClassName$"_Content", class'Class' ) );
	}
	if( NewClass!=None )
	{
		if ( Pawn != None )
			SpawnLoc = Pawn.Location;
		else
			SpawnLoc = Location;
		Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
	}
}

/* AllWeapons
	Give player all available weapons
*/
exec function AllWeapons()
{
	local bool bTranslocatorBanned;
	local UTVehicleFactory VF;

	if( (WorldInfo.NetMode!=NM_Standalone) || (Pawn == None) )
		return;

	class'Engine'.static.CheatWasEnabled();
	GiveWeapon("UTGameContent.UTWeap_Avril_Content");
	GiveWeapon("UTGameContent.UTWeap_BioRifle_Content");
	GiveWeapon("UTGame.UTWeap_FlakCannon");
	GiveWeapon("UTGame.UTWeap_LinkGun");
	GiveWeapon("UTGameContent.UTWeap_Redeemer_Content");
	GiveWeapon("UTGame.UTWeap_RocketLauncher");
	GiveWeapon("UTGame.UTWeap_ShockRifle");
	GiveWeapon("UTGame.UTWeap_SniperRifle");
	GiveWeapon("UTGame.UTWeap_Stinger");
	bTranslocatorBanned = false;
	ForEach WorldInfo.AllNavigationPoints(class'UTVehicleFactory', VF)
	{
		bTranslocatorBanned = true;
	}
	if(!bTranslocatorBanned)
	{
		GiveWeapon("UTGameContent.UTWeap_Translocator_Content");
	}
}

exec function DoubleUp()
{
	local UTWeap_Enforcer MyEnforcer;

	class'Engine'.static.CheatWasEnabled();
	MyEnforcer = UTWeap_Enforcer(Pawn.FindInventoryType(class'UTWeap_Enforcer'));
	MyEnforcer.DenyPickupQuery(class'UTWeap_Enforcer', None);
}

exec function PhysicsGun()
{
	class'Engine'.static.CheatWasEnabled();
	if (Pawn != None)
	{
		GiveWeapon("UTGameContent.UTWeap_PhysicsGun");
	}
}

/* AllAmmo
	Sets maximum ammo on all weapons
*/
exec function AllAmmo()
{
	class'Engine'.static.CheatWasEnabled();
	if ( (Pawn != None) && (UTInventoryManager(Pawn.InvManager) != None) )
	{
		UTInventoryManager(Pawn.InvManager).AllAmmo(true);
		UTInventoryManager(Pawn.InvManager).bInfiniteAmmo = true;
	}
}

exec function Invisible(bool B)
{
	class'Engine'.static.CheatWasEnabled();
	if ( UTPawn(Pawn) != None )
	{
		UTPawn(Pawn).SetInvisible(B);
	}
}

exec function FreeCamera()
{
	class'Engine'.static.CheatWasEnabled();
		UTPlayerController(Outer).bFreeCamera = !UTPlayerController(Outer).bFreeCamera;
		UTPlayerController(Outer).SetBehindView(UTPlayerController(Outer).bFreeCamera);
}

exec function ViewBot()
{
	local Controller first;
	local bool bFound;
	local AIController C;

	class'Engine'.static.CheatWasEnabled();
	foreach WorldInfo.AllControllers(class'AIController', C)
	{
		if (C.Pawn != None && C.PlayerReplicationInfo != None)
		{
			if (bFound || first == None)
			{
				first = C;
				if (bFound)
				{
					break;
				}
			}
			if (C.PlayerReplicationInfo == RealViewTarget)
			{
				bFound = true;
			}
		}
	}

	if ( first != None )
	{
		SetViewTarget(first);
		UTPlayerController(Outer).SetBehindView(true);
		UTPlayerController(Outer).bFreeCamera = true;
		FixFOV();
	}
	else
		ViewSelf(true);
}

exec function KillBadGuys()
{
	local playercontroller PC;
	local UTPawn p;

	class'Engine'.static.CheatWasEnabled();
	PC = UTPlayerController(Outer);

	if (PC!=none)
	{
		ForEach DynamicActors(class'UTPawn', P)
		{
			if ( !WorldInfo.GRI.OnSameTeam(P,PC) && (PC.Pawn != none && PC.Pawn != P) )
			{
				P.TakeDamage(20000,PC, P.Location, Vect(0,0,0),class'UTDmgType_Rocket');
			}
		}
	}
}

exec function RBGrav(float NewGravityScaling)
{
	class'Engine'.static.CheatWasEnabled();
	WorldInfo.RBPhysicsGravityScaling = NewGravityScaling;
}

/** allows suiciding with a specific damagetype and health value for testing death effects */
exec function SuicideBy(string Type, optional int DeathHealth)
{
	local class<DamageType> DamageType;

	if (Pawn != None)
	{
		if (InStr(Type, ".") == -1)
		{
			Type = "UTGame." $ Type;
		}
		DamageType = class<DamageType>(DynamicLoadObject(Type, class'Class'));
		if (DamageType != None)
		{
			Pawn.Health = DeathHealth;
			if (Pawn.IsA('UTPawn'))
			{
				UTPawn(Pawn).AccumulateDamage = -DeathHealth;
				UTPawn(Pawn).AccumulationTime = WorldInfo.TimeSeconds;
			}
			Pawn.Died(Outer, DamageType, Pawn.Location);
		}
	}
}

exec function EditWeapon(string WhichWeapon)
{
	local utweapon Weapon;
	local array<string> weaps;
	local string s;
	local int i;

	class'Engine'.static.CheatWasEnabled();
	if (WhichWeapon != "")
	{
		ConsoleCommand("Editactor class="$WhichWeapon);
	}
	else
	{
		foreach AllActors(class'UTWeapon',Weapon)
		{
			s = ""$Weapon.Class;
			if ( Weaps.Find(s) < 0 )
			{
				Weaps.Length = Weaps.Length + 1;
				Weaps[Weaps.Length-1] = s;
			}
		}

		for (i=0;i<Weaps.Length;i++)
		{
			`log("Weapon"@i@"="@Weaps[i]);
		}
	}
}

exec function DestroyPowerCore(optional byte Team)
{
	local UTOnslaughtGame Game;

	class'Engine'.static.CheatWasEnabled();
	Game = UTOnslaughtGame(WorldInfo.Game);
	if (Game != None)
	{
		Game.PowerCore[Team].Health = 0;
		Game.PowerCore[Team].DisableObjective(None);
	}
}

/** kills all the bots that are not the current viewtarget */
exec function KillOtherBots()
{
	local UTBot B;

	class'Engine'.static.CheatWasEnabled();
	UTGame(WorldInfo.Game).DesiredPlayerCount = WorldInfo.Game.NumPlayers + 1;
	foreach WorldInfo.AllControllers(class'UTBot', B)
	{
		if ((B.Pawn == None || B.Pawn != ViewTarget) && (B.PlayerReplicationInfo == None || B.PlayerReplicationInfo != RealViewTarget))
		{
			if (B.Pawn != None)
			{
				B.Pawn.Suicide();
			}
			B.Destroy();
		}
	}
}

/** Cheat that unocks all possible characters. */
exec native function UnlockAllChars();


exec function TiltIt( bool bActive )
{
	SetControllerTiltActive( bActive );
}

exec function ShowStickBindings()
{
	local int BindIndex;
	`log( PlayerInput.Bindings.Length );

	for( BindIndex = 0; BindIndex < PlayerInput.Bindings.Length; ++BindIndex )
	{
		if( ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_LeftX' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_LeftY' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_RightX' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_RightY' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'GBA_Look_Gamepad' )

			)
		{
			`log( " name: " $ PlayerInput.Bindings[BindIndex].Name $ " command: " $ PlayerInput.Bindings[BindIndex].Command );
			//PlayerInput.Bindings[BindIndex].Command = TheCommand;
		}
		//`log( " " $ PlayerInput.Bindings[BindIndex].Command );
	}
}

exec function SetStickBind( float val )
{
	local int BindIndex;
	local string cmd;

	`log( "SetStickBind" );

	for( BindIndex = 0; BindIndex < PlayerInput.Bindings.Length; ++BindIndex )
	{
		if( 
			( PlayerInput.Bindings[BindIndex].Name == 'XboxTypeS_RightY' )
			||  ( PlayerInput.Bindings[BindIndex].Name == 'GBA_Look_Gamepad' )
			)
		{
			cmd = "Axis aLookup Speed=" $ val $ " DeadZone=0.3";
			PlayerInput.Bindings[BindIndex].Command = cmd;
			`log( " command: " $ cmd @ PlayerInput.Bindings[BindIndex].Command );
		}
	}
}

DefaultProperties
{

}


