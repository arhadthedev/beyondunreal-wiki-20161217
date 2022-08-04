/**
 * Abstract Light
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class Light extends Actor
	native;

var() editconst const LightComponent	LightComponent;






/** replicated copy of LightComponent's bEnabled property */
var repnotify bool bEnabled;

replication
{
	if (Role == ROLE_Authority)
		bEnabled;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bEnabled')
	{
		LightComponent.SetEnabled(bEnabled);
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/* epic ===============================================
* ::OnToggle
*
* Scripted support for toggling a light, checks which
* operation to perform by looking at the action input.
*
* Input 1: turn on
* Input 2: turn off
* Input 3: toggle
*
* =====================================================
*/
simulated function OnToggle(SeqAct_Toggle action)
{
	if (!bStatic)
	{
		if (action.InputLinks[0].bHasImpulse)
		{
			// turn on
			LightComponent.SetEnabled(TRUE);
		}
		else if (action.InputLinks[1].bHasImpulse)
		{
			// turn off
			LightComponent.SetEnabled(FALSE);
		}
		else if (action.InputLinks[2].bHasImpulse)
		{
			// toggle
			LightComponent.SetEnabled(!LightComponent.bEnabled);
		}
		bEnabled = LightComponent.bEnabled;
		ForceNetRelevant();
		SetForcedInitialReplicatedProperty(Property'Engine.Light.bEnabled', (bEnabled == default.bEnabled));
	}
}


defaultproperties
{
	// when you place a light in the editor it defaults to a point light
    // @see ActorFactorLight
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.LightIcons.Light_Point_Stationary_Statics'
		Scale=0.25  // we are using 128x128 textures so we need to scale them down
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	bStatic=TRUE
	bHidden=TRUE
	bNoDelete=TRUE
	bMovable=FALSE
	bRouteBeginPlayEvenIfStatic=FALSE
}
