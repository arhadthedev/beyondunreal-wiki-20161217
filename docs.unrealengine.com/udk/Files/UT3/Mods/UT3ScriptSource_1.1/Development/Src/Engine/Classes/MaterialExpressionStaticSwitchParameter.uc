/**
 * Copyright 2004-2007 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionStaticSwitchParameter extends MaterialExpressionParameter
	native(Material)
	collapsecategories
	hidecategories(Object);

var() bool	DefaultValue;
var() bool	ExtendedCaptionDisplay;

var ExpressionInput A;
var ExpressionInput B;

//the override that will be set when this expression is being compiled from a static permutation
var const native transient pointer InstanceOverride{const FStaticSwitchParameter};


