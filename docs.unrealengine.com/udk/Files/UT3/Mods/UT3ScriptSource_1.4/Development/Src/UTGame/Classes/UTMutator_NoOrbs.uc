﻿// Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
class UTMutator_NoOrbs extends UTMutator;

function InitMutator(string Options, out string ErrorMessage)
{
	local UTOnslaughtFlagBase F;

	ForEach AllActors(class'UTOnslaughtFlagBase', F)
	{
		F.DisableOrbs();
	}
	super.InitMutator(Options, ErrorMessage);
}

defaultproperties
{
	GroupNames[0]="WARFARE"
}
