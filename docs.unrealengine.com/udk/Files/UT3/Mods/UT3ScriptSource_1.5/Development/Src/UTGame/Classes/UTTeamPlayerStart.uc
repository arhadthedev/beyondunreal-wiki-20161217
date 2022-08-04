/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTTeamPlayerStart extends PlayerStart
	native;

/** Locker to get weapons from for spawning player */
var UTWeaponLocker BestLocker;

/** True if tried and failed to find a best locker */
var bool bNoLockerFound;



// Players on different teams are not spawned in areas with the
// same TeamNumber unless there are more teams in the level than
// team numbers.
var() byte TeamNumber;			// what team can spawn at this start

// sprites used for this actor in the editor, depending on which team it's on
var editoronly array<Texture2D> TeamSprites;

function UTWeaponLocker GetBestLocker()
{
	local UTWeaponLocker Locker;
	local float Dist, BestDist;

	if ( (BestLocker == None) && !bNoLockerFound )
	{
		// find nearest weapon locker and provide the weapons
		ForEach DynamicActors(class'UTWeaponLocker', Locker)
		{
			Dist = VSizeSq(Location - Locker.Location);
			if ( (BestLocker == None) || (BestDist > Dist) )
			{
				BestDist = Dist;
				BestLocker = Locker;
			}
		}
		bNoLockerFound = ( BestLocker == None );
	}
	return BestLocker;
}

defaultproperties
{
	TeamSprites[0]=Texture2D'EnvyEditorResources.S_Player_Red'
	TeamSprites[1]=Texture2D'EnvyEditorResources.S_Player_Blue'
}
