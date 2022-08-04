/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class DistributionFloat extends Component
	inherits(FCurveEdInterface)
	native
	collapsecategories
	hidecategories(Object)
	editinlinenew
	abstract;

struct native RawDistributionFloat extends RawDistribution
{


	var() export noclear DistributionFloat Distribution;
};





/** Can this variable be baked out to a FRawDistribution? Should be TRUE 99% of the time*/
var(Baked) bool bCanBeBaked;

/** Set internally when the distribution is updated so that that FRawDistribution can know to update itself*/
var bool bIsDirty;

defaultproperties
{
	bCanBeBaked=true
	// make sure the FRawDistribution is initialized
	bIsDirty=true 
}
