/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * News/DLC scene for UT3.
 */
class UTUIFrontEnd_News extends UTUIFrontEnd;

/** References to tab pages. */
var transient UTUITabPage_News NewsTab;
var transient UTUITabPage_EpicContent EpicContentTab;
var transient UTUITabPage_MyContent MyContentTab;


/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize( )
{
	Super.PostInitialize();


	// Add tab pages to tab control
	NewsTab = UTUITabPage_News(FindChild('pnlNews', true));
	if(NewsTab != none)
	{
		TabControl.InsertPage(NewsTab, 0, 0, false);
	}

	EpicContentTab = UTUITabPage_EpicContent(FindChild('pnlEpicContent', true));
	if(EpicContentTab != none)
	{
		TabControl.InsertPage(EpicContentTab, 0, 1, false);
	}

	MyContentTab = UTUITabPage_MyContent(FindChild('pnlMyContent', true));
	if(MyContentTab != none)
	{
		TabControl.InsertPage(MyContentTab, 0, 2, false);
	}

	// Disable content tabs for now
	if(IsGame())
	{
		if(true)
		{
			TabControl.RemovePage(EpicContentTab,0);
			TabControl.RemovePage(MyContentTab,0);
		}
		else  // @todo: This is for later when we show the content tabs.
		{
			EpicContentTab.ReadContent();
		}
	}
}

/** Sets up the scene's button bar. */
function SetupButtonBar()
{
	if(ButtonBar != None)
	{	
		ButtonBar.Clear();
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);

		/** - @todo: Enable after patch
		if(IsConsole(CONSOLE_PS3))
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ImportContent>", OnButtonBar_ImportContent);
		}
		*/

		UTTabPage(TabControl.ActivePage).SetupButtonBar(ButtonBar);
	}
}

/** Callback for when the user wants to back out of this screen. */
function OnBack()
{
	CloseScene(self);
}

/** Callback for when the user wants to import content from a memory stick. */
function OnImportContent()
{
	ImportMod();
}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Back(UIScreenObject InButton, int InPlayerIndex)
{
	OnBack();

	return true;
}

function bool OnButtonBar_ImportContent(UIScreenObject InButton, int InPlayerIndex)
{
	OnImportContent();

	return true;
}

/** Callback for when the import has finished for a mod. */
function OnImportModFinished()
{
	// Tell the my content tab to refresh the content list.
	MyContentTab.OnContentListChanged();
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

	bResult = UTTabPage(TabControl.ActivePage).HandleInputKey(EventParms);

	if(bResult==false && EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
		{
			OnBack();
			bResult=true;
		}
		/** - @todo: Enable after patch
		else if(EventParms.InputKeyName=='XboxTypeS_X')
		{
			OnImportContent();
			bResult=true;
		}
		*/
	}

	return bResult;
}


defaultproperties
{
	
}