//=============================================================================
// NoHUDIcon.
//
// Deactivates the player status icon for a certain HUD class. This will
// not activate the HUD's implementation of the icon if the HUD uses the same
// method to display it. Instead the icon will be deactivated completely.
// To use put the following line in the .int file of your mod:
// Object=(Name=EIChallengeHUD.NoHUDIcon,Class=Class,MetaClass=EIChallengeHUD.CustomHUDIcon,Description="MyPackage.MyHUDClass")
//=============================================================================
class NoHUDIcon extends CustomHUDIcon;

simulated function bool AllowDrawCustomStatus(EIChallengeHUD MyOwner)
{
	return false;
}

defaultproperties
{
}
