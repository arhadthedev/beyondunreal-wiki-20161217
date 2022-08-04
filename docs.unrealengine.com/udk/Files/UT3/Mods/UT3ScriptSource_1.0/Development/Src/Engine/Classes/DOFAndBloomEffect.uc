/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Depth of Field post process effect
 *
 */
class DOFAndBloomEffect extends DOFEffect
	native;

/** A scale applied to blooming colors. */
var() float BloomScale;



defaultproperties
{
	BloomScale=1.0
	BlurKernelSize=16.0
}