/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTBetrayalPawn extends UTPawn
	config(Game)
	native
	notplaceable;

var bool bTeamInvitation;

var int Count;

var SoundCue TeamInvitationSound, EndTeamSound;

/** cue used for TeamInvitations */
var soundcue AnnouncerSoundCue;	

/** currently playing TeamInvitation AudioComponent */
var AudioComponent CurrentAnnouncementComponent;



simulated native function byte GetTeamNum();

/**
 * Called when a pawn's weapon has fired and is responsibile for
 * delegating the creation off all of the different effects.
 *
 * bViaReplication denotes if this call in as the result of the
 * flashcount/flashlocation being replicated.  It's used filter out
 * when to make the effects.
 */
simulated function WeaponFired( bool bViaReplication, optional vector HitLocation)
{
	if (CurrentWeaponAttachment != None)
	{
		bTeamInvitation = (FiringMode == 1);

		if ( !IsFirstPerson() )
		{
			CurrentWeaponAttachment.ThirdPersonFireEffects(HitLocation);
		}
		else
		{
			CurrentWeaponAttachment.FirstPersonFireEffects(Weapon, HitLocation);
			if ( class'Engine'.static.IsSplitScreen() && CurrentWeaponAttachment.EffectIsRelevant(CurrentWeaponAttachment.Location,false,CurrentWeaponAttachment.MaxFireEffectDistance) )
			{
				// third person muzzle flash
				CurrentWeaponAttachment.CauseMuzzleFlash();
			}
		}

		if ( HitLocation != Vect(0,0,0) && (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || bViaReplication) )
		{
			CurrentWeaponAttachment.PlayImpactEffects(HitLocation);
		}
		bTeamInvitation = false;
	}
}

defaultproperties
{
	AnnouncerSoundCue=SoundCue'A_Announcer_Reward_Cue.SoundCues.AnnouncerCue'
	bPostRenderOtherTeam=true
}
