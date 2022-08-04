//=============================================================================
// DefaultHUDIcon.
//
// Uses the uses the standard EIChallengeHUD player icon. You can use this
// class, if you have a custom HUD icon for a HUD class, but you want to use
// the default icon for a certein subclass of that HUD.
// To use put the following line in the .int file of your mod:
// Object=(Name=EIChallengeHUD.DefaultHUDIcon,Class=Class,MetaClass=EIChallengeHUD.CustomHUDIcon,Description="MyPackage.MyHUDClass")
//=============================================================================
class DefaultHUDIcon extends CustomHUDIcon;

defaultproperties
{
}
