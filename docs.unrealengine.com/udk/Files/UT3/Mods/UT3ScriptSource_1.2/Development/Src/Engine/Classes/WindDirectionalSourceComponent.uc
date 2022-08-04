/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class WindDirectionalSourceComponent extends ActorComponent
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

var native private	transient noimport const pointer SceneProxy{FWindSourceSceneProxy};

var() float	Strength;
var() float Phase;
var() float Frequency;
var() float Speed;



defaultproperties
{
	Strength=1.0
	Frequency=1.0
	Speed=1024.0
}
