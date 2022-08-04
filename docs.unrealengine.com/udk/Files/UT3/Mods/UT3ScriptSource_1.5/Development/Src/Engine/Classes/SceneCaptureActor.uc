/**
 * SceneCaptureActor
 *
 * Base class for actors that want to capture the scene
 * using a scene capture component 
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SceneCaptureActor extends Actor
	native
	abstract;

/** component that renders the scene to a texture */
var() const SceneCaptureComponent SceneCapture;



defaultproperties
{
	// editor-only sprite
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	// allow for actor to tick locally on clients
	bNoDelete=true
	RemoteRole=ROLE_SimulatedProxy	
}
