/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTProj_HeroShockBall extends UTProj_ShockBall;

var bool bAlreadyComboed;

function ComboExplosion()
{
	local UTProj_HeroShockball B;

	if ( bShuttingDown )
	{
		return;
	}

	Super.ComboExplosion();
	bAlreadyComboed = true;
	ForEach VisibleCollidingActors ( class'UTProj_HeroShockBall', B, 1000.0)
	{
		if ( !B.bAlreadyComboed )
		{
			B.bAlreadyComboed = true;
			B.SetTimer(0.35, false, 'ComboExplosion');
			break;
		}
	}
}



defaultproperties
{
	MyDamageType=class'UTDmgType_HeroShockBall'
	ComboDamageType=class'UTDmgType_HeroShockCombo'
	ComboTriggerType=class'UTDmgType_HeroShockPrimary'
	ComboExplosionEffect=class'UTEmit_HeroShockCombo'
	ComboRadius=300
}
