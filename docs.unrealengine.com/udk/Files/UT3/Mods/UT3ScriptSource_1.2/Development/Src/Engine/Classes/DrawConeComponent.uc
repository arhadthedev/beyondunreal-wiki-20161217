/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class DrawConeComponent extends PrimitiveComponent
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew;

var()	color			ConeColor;
var()	float			ConeRadius;
var()	float			ConeAngle;
var()	int				ConeSides;



defaultproperties
{
	ConeColor=(R=150,G=200,B=255,A=255)
	ConeRadius=100.0
	ConeAngle=44.0
	ConeSides=16

	HiddenGame=True
}
