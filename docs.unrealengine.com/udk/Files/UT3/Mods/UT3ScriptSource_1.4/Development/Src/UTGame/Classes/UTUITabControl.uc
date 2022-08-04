/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * UT3 extended version of the UITabControl
 */
class UTUITabControl extends UITabControl
	native(UI);

;

var()		name	DefaultTabWidgetTag;

var(Style)	name	CalloutLabelStyleName;

/** these labels will contain button callouts for activating the PrevPage / NextPage input aliases, on consoles */
var	transient	UILabel		PrevPageCalloutLabel;
var	transient	UILabel		NextPageCalloutLabel;

/**
 * Hide all the pages.  This allows us to not care what page was left on in the editor
 */
event PostInitialize()
{
	local int i;

	// Hide all of the pages

	for (i=0; i < Pages.Length; i++)
	{
		Pages[i].SetVisibility(false);
	}

	// Disable page previews on PS3/360
	if(IsConsole())
	{
		bAllowPagePreviews=FALSE;
	}

	Super.PostInitialize();
}

/**
 * Attempt to activate the default tab
 */
function bool ActivateBestTab( int PlayerIndex, optional bool bFocusPage=true, optional int StartIndex=0 )
{
	local UTUIScene Parent;
	local WorldInfo WI;
	local UTGameReplicationInfo GRI;

	//Force the score tab to be the active tab instead of gametab in non-campaign scenarios
	if (DefaultTabWidgetTag == 'GameTab')
	{
		Parent = UTUIScene(GetScene());
		if (Parent != None)
		{
			WI = Parent.GetWorldInfo();

			if (WI != none)
			{
				GRI = UTGameReplicationInfo(WI.GRI);
				if ((WI.NetMode == NM_Standalone) || (GRI != None && !GRI.bStoryMode)) 
				{
					DefaultTabWidgetTag = 'ScoreTab';
				}
			}
		}
	}

	if ( DefaultTabWidgetTag != '' && ActivateTabByTag( DefaultTabWidgetTag ) )
	{
		return true;
	}

	// We either couldn't find it or it couldn't be activated.  Use the default code.
	return Super.ActivateBestTab( PlayerIndex, bFocusPage, StartIndex);

}


function int FindPageIndexByTag(name TabTag)
{
	local int i;
	for (i=0; i<Pages.Length;i++)
	{
		if ( Pages[i].WidgetTag == TabTag )
		{
        	return i;
        }
    }
    return INDEX_None;
}

/**
 * Activate a page by it's widget tag
 */
function bool ActivateTabByTag(name TabTag, optional int PlayerIndex, optional bool bFocusPage=true)
{
	local int TIndex;

	TIndex = FindPageIndexByTag(TabTag);
	if ( TIndex != INDEX_None )
	{
		if ( ActivatePage(Pages[TIndex], PlayerIndex, bFocusPage) )
		{
			return true;
		}
	}
	return false;
}

/**
 * Removes a page by it's widget tag
 */

function RemoveTabByTag(name TabTag, optional int PlayerIndex)
{
	local int TIndex;
	TIndex = FindPageIndexByTag(TabTag);
	if ( TIndex != INDEX_None )
	{
		RemovePage(Pages[TIndex],PlayerIndex);
	}
}

function bool ProcessInputKey( const out InputEventParameters EventParms )
{
	//@TODO: This is currently a hack, need to figure out what we want to support in UT and what we dont.
	return false;
}

defaultproperties
{
	TabButtonSize=(Value=0.033566,ScaleType=UIEXTENTEVAL_PercentOwner,Orientation=UIORIENT_Vertical)
	CalloutLabelStyleName=CycleTabs
}
