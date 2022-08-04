/** this is used when to hold constructed character data temporarily when a PRI is destroyed, so that if the same character comes back
 * shortly afterward (e.g. because the PRI was getting replaced via seamless travel) the mesh doesn't need to be re-created
 */
class UTProcessedCharacterCache extends Actor;

/** data for the character this player is using */
var CustomCharData CharacterData;
/** the mesh constructed from the above data */
var SkeletalMesh CharacterMesh;
/** Texture of render of custom character head. */
var Texture CharPortrait;
/** Mesh to use for first person arms. Should only be present for local players! */
var SkeletalMesh FirstPersonArmMesh;
/** Material applied to first person arms. Should only be present for local players! */
var MaterialInterface FirstPersonArmMaterial;
/** team the player was on */
var byte TeamIndex;

static function bool ShouldCacheCharacter(UTPlayerReplicationInfo PRI)
{
	return ( PRI.CharacterMesh != None || PRI.CharPortrait != PRI.default.CharPortrait ||
		PRI.FirstPersonArmMesh != None || PRI.FirstPersonArmMaterial != None );
}

/** caches the character data from the specified PRI */
function CachePRICharacter(UTPlayerReplicationInfo PRI)
{
	CharacterData = PRI.CharacterData;
	CharacterMesh = PRI.CharacterMesh;
	CharPortrait = PRI.CharPortrait;
	FirstPersonArmMesh = PRI.FirstPersonArmMesh;
	FirstPersonArmMaterial = PRI.FirstPersonArmMaterial;
	TeamIndex = PRI.GetTeamNum();
}

/** if the PRI's character data matches, updates the PRI then destroys the cache object
 * @return whether the data matched
 */
function bool GetCachedCharacter(UTPlayerReplicationInfo PRI)
{
	if (PRI.CharacterData != CharacterData)
	{
		return false;
	}
	else if (PRI.GetTeamNum() != TeamIndex)
	{
		// if the PRI has no team at all and might get one, wait a bit and retry
		if (PRI.Team == None && (WorldInfo.GRI == None || WorldInfo.GRI.GameClass == None || WorldInfo.GRI.GameClass.default.bTeamGame))
		{
			PRI.SetTimer(LifeSpan + 0.5, false, 'RetryProcessCharacterData');
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		PRI.SetCharacterMesh(CharacterMesh);
		PRI.CharPortrait = CharPortrait;
		PRI.SetFirstPersonArmInfo(FirstPersonArmMesh, FirstPersonArmMaterial);
		Destroy();
		return true;
	}
}

event Destroyed()
{
	Super.Destroyed();

	// if we were destroyed because the data was unclaimed, GC immediately to recover the memory
	if (LifeSpan <= 0.0)
	{
		WorldInfo.ForceGarbageCollection();
	}
}

defaultproperties
{
	LifeSpan=5.0
	bGameRelevant=true
}
