/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Achievement scene for UT3, lets players manage view their achievements.
 */
class UTUIFrontEnd_Achievements extends UTUIFrontEnd;

/** Tab page references for this scene. */
var UTUITabPage_AchievementList AchievementListTab;

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize()
{
	Super.PostInitialize();

	// Achievement List
	AchievementListTab = UTUITabPage_AchievementList(FindChild('pnlAchievementList', true));
	if(AchievementListTab != none)
	{
		TabControl.InsertPage(AchievementListTab, 0, INDEX_NONE, true);
	}

	// Let the currently active page setup the button bar.
	SetupButtonBar();
}

/** Sets up the button bar for the scene. */
function SetupButtonBar()
{
	if(ButtonBar != None)
	{
		ButtonBar.Clear();

		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);

		// Let the current tab page try to setup the button bar
		UTTabPage(TabControl.ActivePage).SetupButtonBar(ButtonBar);
	}
}

/** Callback for when the user wants to back out of this screen. */
function OnBack()
{
	CloseScene(self);
}

function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	OnBack();

	return true;
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;
	local UTTabPage CurrentTabPage;

	// Let the tab page's get first chance at the input
	CurrentTabPage = UTTabPage(TabControl.ActivePage);
	bResult=CurrentTabPage.HandleInputKey(EventParms);

	// If the tab page didn't handle it, let's handle it ourselves.
	if(bResult==false)
	{
		if(EventParms.EventType==IE_Released)
		{
			if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
			{
				OnBack();
				bResult=true;
			}
		}
	}

	return bResult;
}

defaultproperties
{
	bRequiresNetwork=true
	bRequiresOnlineService=true
}
