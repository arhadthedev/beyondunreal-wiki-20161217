/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * A version of UIContextMenu that has been adapted to use 2DStringList's (required in order to get them working)
 *
 * NOTE: It may not be possible to get this working through the UI Editor, if so, then use the 'OnOpenContextMenu'
 *		delegate to initialize (and fill, using 'SetMenuItems' etc.) the context menu through code
 */
Class UTUI_ContextMenu extends UIContextMenu;


// Used to determine when the context menu needs to rebind its data store
var name LastBoundField;


function bool SetContextTitle(UIObject Widget, string ContextTitle)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);
			StringList.SetColumnStr(i, 'ContextList', ContextTitle);

			RefreshSubscriberValue();
			return True;
		}
	}

	return False;
}

function bool SetMenuItems(UIObject Widget, array<string> NewMenuItems, optional bool bClearExisting=true, optional int InsertIndex=INDEX_None)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);

			if (bClearExisting)
			{
				// Ignores InsertIndex
				StringList.SetFieldRowLength(i, NewMenuItems.Length, True);
				StringList.UpdateFieldList(i, 'ContextList', NewMenuItems);
			}
			else if (InsertIndex == INDEX_None)
			{
				StringList.UpdateFieldList(i, 'ContextList', NewMenuItems);
			}
			else
			{
				StringList.InsertFieldListItems(i, 'ContextList', InsertIndex, NewMenuItems);
			}


			RefreshSubscriberValue();
			return True;
		}
	}

	return False;
}

function bool AddMenuItem(UIObject Widget, string Item, optional bool bDisabledItem, optional bool bAllowDuplicates)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local array<string> ListItem;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);

			if (bAllowDuplicates || StringList.FindFieldListItem(i, 'ContextList', Item) == INDEX_None)
			{
				ListItem[0] = Item;
				StringList.AddFieldRow(i, ListItem, bDisabledItem);

				RefreshSubscriberValue();
			}

			return True;
		}
	}

	return False;
}

function bool InsertMenuItem(UIObject Widget, string Item, optional int InsertIndex=INDEX_NONE, optional bool bAllowDuplicates)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local array<string> ListItem;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);

			if (bAllowDuplicates || StringList.FindFieldListItem(i, 'ContextList', Item) == INDEX_None)
			{
				ListItem[0] = Item;
				StringList.InsertFieldListItems(i, 'ContextList', ((InsertIndex == INDEX_None) ? 0 : InsertIndex), ListItem);

				RefreshSubscriberValue();
			}

			return True;
		}
	}

	return False;
}

function bool ClearMenuItems(UIObject Widget)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			StringList.EmptyField(WidgetDSTag);

			RefreshSubscriberValue();
			return True;
		}
	}

	return False;
}

function bool RemoveMenuItem(UIObject Widget, string ItemToRemove)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i, j;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);
			j = StringList.FindFieldListItem(i, 'ContextList', ItemToRemove);

			if (j != INDEX_None)
			{
				StringList.RemoveFieldRow(i, j);
				RefreshSubscriberValue();
			}


			return True;
		}
	}

	return False;
}

function bool RemoveMenuItemAtIndex(UIObject Widget, int IndexToRemove)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);
			StringList.RemoveFieldRow(i, IndexToRemove);

			RefreshSubscriberValue();
			return True;
		}
	}

	return False;
}

function bool GetAllMenuItems(UIObject Widget, out array<string> out_MenuItems)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);
			StringList.GetFieldList(i, 'ContextList', out_MenuItems);

			return True;
		}
	}

	return False;
}

function bool GetMenuItem(UIObject Widget, int IndexToGet, out string out_MenuItem)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);
			out_MenuItem = StringList.GetFieldRowElement(i, 0, IndexToGet);

			return True;
		}
	}

	return False;
}

function int FindMenuItemIndex(UIObject Widget, string ItemToFind)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);
			return StringList.FindFieldListItem(i, 'ContextList', ItemToFind);
		}
	}

	return INDEX_None;
}

function int GetMenuItemCount(UIObject Widget)
{
	local name WidgetDSTag;
	local UTUIDataStore_2DStringList StringList;
	local int i;

	if (Widget != none && Widget.WidgetID.A != 0)
	{
		WidgetDSTag = name("UTContext_"$ConvertWidgetIDToString(Widget));
		StringList = Get2DDataStoreRef(Widget, WidgetDSTag);

		if (StringList != none)
		{
			i = StringList.GetFieldIndex(WidgetDSTag);
			return StringList.GetFieldRowLength(i);
		}
	}

	return INDEX_None;
}




function UTUIDataStore_2DStringList Get2DDataStoreRef(UIObject Widget, optional name WidgetField)
{
	local DataStoreClient DSC;
	local UTUIDataStore_2DStringList StringDataStore;
	local int i;

	DSC = Class'UIInteraction'.static.GetDataStoreClient();

	StringDataStore = UTUIDataStore_2DStringList(DSC.FindDataStore('UT2DStringList'));

	if (StringDataStore == none)
	{
		StringDataStore = DSC.CreateDataStore(Class'UTUIDataStore_2DStringList');
		DSC.RegisterDataStore(StringDataStore);
	}

	if (StringDataStore != none && WidgetField != '' && StringDataStore.GetFieldIndex(WidgetField) == INDEX_None)
	{
		i = StringDataStore.AddField(WidgetField);
		StringDataStore.AddFieldList(i, 'ContextList');
	}

	if (LastBoundField != WidgetField)
	{
		LastBoundField = WidgetField;

		// This is very important, as it binds the owning widgets 'ContextMenuData' property to the specified databinding;
		//	doing this is a major requirement when trying to display context menus
		Widget.SetDefaultDataBinding("<UT2DStringList:"$WidgetField$">", CONTEXTMENU_BINDING_INDEX);
	}

	return StringDataStore;
}

defaultproperties
{
	CellLinkType=LINKED_None
	ColumnWidth=(Value=0)

	// Replace the buggy UIContextMenu-specific list presenter
	Begin Object Class=UIComp_ListPresenterCascade Name=UTContextMenuDataComponent
	End Object
	CellDataComponent=UTContextMenuDataComponent
}

