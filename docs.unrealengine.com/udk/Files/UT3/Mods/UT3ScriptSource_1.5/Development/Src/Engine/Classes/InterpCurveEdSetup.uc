/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class InterpCurveEdSetup extends Object
	native;

// Information about a particule curve being viewed.
// Property could be an FInterpCurve, a DistributionFloat or a DistributionVector
struct native CurveEdEntry
{
	var	Object	CurveObject;

	var color	CurveColor;
	var string	CurveName;

	var int		bHideCurve;
	var int		bColorCurve;
	var int		bFloatingPointColorCurve;
	var int		bClamp;
	var float	ClampLow;
	var float	ClampHigh;
};

struct native CurveEdTab
{
	var string					TabName;

	var array<CurveEdEntry>		Curves;

	// Remember the view setting for each tab.
	var float					ViewStartInput;
	var float					ViewEndInput;
	var float					ViewStartOutput;
	var float					ViewEndOutput;
};


var array<CurveEdTab>			Tabs;
var int							ActiveTab;



defaultproperties
{
	Tabs(0)=(TabName="Default",ViewStartInput=0.0,ViewEndInput=1.0,ViewStartOutput=-1.0,ViewEndOutput=1.0)
}
