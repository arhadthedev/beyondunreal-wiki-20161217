/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleColorByParameter extends ParticleModuleColorBase
	native(Particle)
	editinlinenew
	collapsecategories
	hidecategories(Object);
	
var(Color) name		ColorParam;
var(Color) color	DefaultColor;



defaultproperties
{
	bSpawnModule=true
	bUpdateModule=false
	
	DefaultColor=(R=255,G=255,B=255,A=255)
}
