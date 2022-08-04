/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTSeqAct_DisplayChapterTitle extends SeqAct_DisplayChapterTitleBase;

// Chapter to display
var() EUTChapterType DisplayChapter;

event Activated()
{
	local UTPlayercontroller PC;
	foreach GetWorldInfo().AllControllers( class'UTPlayercontroller', PC )
	{
		PC.DisplayChapterTitle( DisplayChapter, TotalDisplayTime, TotalFadeTime );
	}
}


defaultproperties
{
}
