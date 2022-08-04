/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class CoverSlipReachSpec extends ForcedReachSpec
	native;



// Value CoverLink.ECoverDirection for movement direction along this spec
var() editconst Byte SpecDirection;

defaultproperties
{
	ForcedPathSizeName=Common
	bSkipPrune=TRUE
}
