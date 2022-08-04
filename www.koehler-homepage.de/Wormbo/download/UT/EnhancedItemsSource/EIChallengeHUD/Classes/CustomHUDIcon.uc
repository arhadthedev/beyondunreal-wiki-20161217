class CustomHUDIcon extends EIChallengeHUD abstract;

simulated function CheckCustomHUDConfig(EIChallengeHUD MyOwner)
{
	MyHUD = MyOwner.MyHUD;
	MyChallengeHUD = MyOwner.MyChallengeHUD;
	bHideStatus = MyOwner.bHideStatus;
	PlayerOwner = MyOwner.PlayerOwner;
	PawnOwner = MyOwner.PawnOwner;
}

simulated function bool AllowDrawCustomStatus(EIChallengeHUD MyOwner)
{
	return MyOwner.AllowDrawStatus();
}

simulated function DrawCustomStatus(Canvas Canvas, EIChallengeHUD MyOwner)
{
	MyOwner.DrawStatus(Canvas);
}

defaultproperties
{
}
