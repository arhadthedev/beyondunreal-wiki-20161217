/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class DecalActor extends Actor
	native(Decal)
	placeable;

var() editconst const DecalComponent Decal;



defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=DecalComponent Name=NewDecalComponent
		bStaticDecal=true
	End Object
	Decal=NewDecalComponent
	Components.Add(NewDecalComponent)

	Begin Object Class=ArrowComponent Name=ArrowComponent0
		HiddenGame=true
	End Object
	Components.Add(ArrowComponent0)

	bStatic=true
	bMovable=false
}
