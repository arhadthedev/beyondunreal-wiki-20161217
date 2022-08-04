/**
 * Base class for DisplayingChapter titles on the screen.  Each game
 * should sub class this and do their own Activated() function
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_DisplayChapterTitleBase extends SequenceAction
	abstract;


// Total number of seconds to display the chapter title
var() float TotalDisplayTime;
// Time it will take to fade the text in and out
var() float TotalFadeTime;


defaultproperties
{
	ObjName="Display Chapter Title"
	ObjCategory=""
	bCallHandler=false
	ObjClassVersion=2

	TotalDisplayTime=6.0f
	TotalFadeTime=2.0f

	VariableLinks.Empty
}
