/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

// A DataStore for storing 2-dimensional arrays of strings at runtime, for populating UIList's through script
Class UTUIDataStore_2DStringList extends UIDataStore
	config(Game)
	native(UI)
	transient
	implements(UIListElementProvider)
	implements(UIListElementCellProvider);


struct native SAListData
{
	/** The tag to use for identifying this list (corresponds to the column cell tag) */
	var name ListTag;

	/** The column header used for this string list */
	var string ColumnHeader;

	/** The actual string list */
	var array<string> Strings;
};

struct native SAArrayData
{
	/** The tag used for binding this data to a list cell */
	var name Tag;

	/** The 2-dimensional string list associated with this tag */
	var array<SAListData> Lists;

	/** Used to indicate whether or not a particular row is disabled or enabled (0 or 1); each Lists.Strings element represents a row */
	var array<byte> RowStates;
};

struct native SAEditorData
{
	/** Corresponds to SAArrayData.Tag */
	var name Tag;

	/** Corresponds to SAArrayData.Lists.ListTag */
	var array<name> ListTags;
};


var array<SAArrayData> ListData;


// This array is only used within UnrealEd; it allows you to setup UIList columns from within UnrealEd, for data stores which only exist ingame.
// To use this, open UTGame.ini and search for the config section [UTGame.UTUIDataStore_2DStringList] (or create it if it isn't already there)
// and underneath it, add:
// EditorListData=(Tag=YourMarkupField,ListTags=(YourColumn0,YourColumn1,YourColumn3))
// e.g: EditorListData=(Tag="UTVoteGameList",ListTags=("GameList","VoteCount"))
//
// Then in UTEngine.ini, under [Engine.DataStoreClient], add:
// GlobalDataStoreClasses=UTGame.UTUIDataStore_2DStringList
//
// Then, within UnrealEd, set your UIList's MarkupString to: <UT2DStringList:YourMarkupField>
// After that, you should be able to select 'YourColumn0' etc. from the UIList's context menu, and configure them from within UnrealEd
var config array<SAEditorData> EditorListData;

// Hardcoded editor list data
var const array<SAEditorData> ConstEditorListData;




/**
 * @param FieldName		Name of the 2D String Array to find
 * @return the index of a string list
 */
native function int GetFieldIndex(name FieldName);

/**
 * @param FieldIdx		Index of the 2D String Array as returned by GetFieldIndex
 * @param ListName		Name of the string list to find
 * @return the index of the column within the specified string array
 */
final function int GetFieldListIndex(int FieldIdx, name ListName)
{
	if (FieldIdx < ListData.Length)
		return ListData[FieldIdx].Lists.Find('ListTag', ListName);

	return INDEX_None;
}


// Adds a new data store field, which can be directly bound to a UIList
//	FieldName: The name used to bind the new field, like so: UIList.SetDataStoreBinding("<UT2DStringList:FieldName>")
final function int AddField(name FieldName)
{
	local int i;

	i = GetFieldIndex(FieldName);

	if (i != INDEX_None)
		return i;

	i = ListData.Length;
	ListData.Length = i+1;

	ListData[i].Tag = FieldName;

	return i;
}

// Adds a new list to the field specified by FieldIdx; the same as adding a new column
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	ListName: The name to attribute to the new list/column, which is used to identify a specific list when calling other functions
final function int AddFieldList(int FieldIdx, name ListName)
{
	local int i;

	i = GetFieldListIndex(FieldIdx, ListName);

	if (i != INDEX_None)
		return i;


	i = ListData[FieldIdx].Lists.Length;
	ListData[FieldIdx].Lists.Length = i+1;

	ListData[FieldIdx].Lists[i].ListTag = ListName;

	return i;
}

// Adds a single row of strings to the end of the list
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	RowStrings: The row of strings to add to the list; the array index of each string determines which column the string is added to
//	bDisableSelection: If true, this row is marked as disabled, and is unselectable (and greyed out) in UIList's
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function int AddFieldRow(int FieldIdx, optional const out array<string> RowStrings, optional bool bDisableSelection, optional bool bBatchOp)
{
	local int i, ReturnVal;

	for (i=0; i<ListData[FieldIdx].Lists.Length; ++i)
		ReturnVal = ListData[FieldIdx].Lists[i].Strings.AddItem(((RowStrings.Length > i) ? RowStrings[i] : ""));


	// If 'i' is not greater than 0, then there the 'Lists' array is empty, and no rows were added
	if (i > 0)
	{
		ListData[FieldIdx].RowStates.AddItem(byte(!bDisableSelection));

		if (!bBatchOp)
			RefreshSubscribers(ListData[FieldIdx].Tag);

		return ReturnVal;
	}

	return INDEX_None;
}


// Directly sets the list length for the specified field
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	NewListsLength: The new length to apply to the lists
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function SetFieldListsLength(int FieldIdx, int NewListsLength, optional bool bBatchOp)
{
	ListData[FieldIdx].Lists.Length = NewListsLength;

	if (NewListsLength == 0)
		ListData[FieldIdx].RowStates.Length = 0;

	if (!bBatchOp)
		RefreshSubscribers(ListData[FieldIdx].Tag);
}

// Directly sets the number of rows (i.e. columns) that the current list contains
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	NewRowLength: Sets the number of rows
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function SetFieldRowLength(int FieldIdx, int NewRowLength, optional bool bBatchOp)
{
	local int i;

	for (i=0; i<ListData[FieldIdx].Lists.Length; ++i)
		ListData[FieldIdx].Lists[i].Strings.Length = NewRowLength;

	if (i > 0)
	{
		ListData[FieldIdx].RowStates.Length = NewRowLength;

		// Default all elements to enabled
		for (i=0; i<NewRowLength; ++i)
			ListData[FieldIdx].RowStates[i] = 1;

		if (!bBatchOp)
			RefreshSubscribers(ListData[FieldIdx].Tag);
	}
}

// Retrieves the length of the specified fields list
//	FieldIdx: The index of the field, as retrieved by the 'GetFieldIndex' function
final function int GetFieldListsLength(int FieldIdx)
{
	return ListData[FieldIdx].Lists.Length;
}

// Grabs the list of strings for the specified column/list
//	FieldIdx: The index of the field, as retrieved by the 'GetFieldIndex' function
//	ListName: The identifying name of the column, as set by 'AddFieldList'
//	ListStrings: The output array for the column strings
final function GetFieldList(int FieldIdx, name ListName, out array<string> ListStrings)
{
	local int i;

	i = GetFieldListIndex(FieldIdx, ListName);

	if (i != INDEX_None)
		ListStrings = ListData[FieldIdx].Lists[i].Strings;
}

// Retrieves the number of rows used in the specified field
//	FieldIdx: The index of the field, as retrieved by the 'GetFieldIndex' function
final function int GetFieldRowLength(int FieldIdx)
{
	return ListData[FieldIdx].RowStates.Length;
}

// Grabs the list of strings for the fields specified row
//	FieldIdx: The index of the field, as retrieved by the 'GetFieldIndex' function
//	RowIdx: The row index to grab the strings from
//	RowStrings: The string array which the specified row is outputted to
final function GetFieldRow(int FieldIdx, int RowIdx, out array<string> RowStrings)
{
	local int i;

	RowStrings.Length = ListData[FieldIdx].Lists.Length;

	for (i=0; i<RowStrings.Length; ++i)
		RowStrings[i] = ListData[FieldIdx].Lists[i].Strings[RowIdx];
}

// Retrieves the string located in the specified field, at the specified column/row
//	FieldIdx: The index of the field, as retrieved by the 'GetFieldIndex' function
//	ColumnIdx: The index of the column where the desired string element is located
//	RowIdx: The row index where the string is located
final function string GetFieldRowElement(int FieldIdx, int ColumnIdx, int RowIdx)
{
	return ListData[FieldIdx].Lists[ColumnIdx].Strings[RowIdx];
}

// Sets the name of the specified column, as displayed in UIList's
//	FieldIdx: The index of the field, as retrieved by the 'GetFieldIndex' function
//	ListName: The identifying name of the column, as set by 'AddFieldList'
//	ColumnStr: The displayed name to apply to the column
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function SetColumnStr(int FieldIdx, name ListName, string ColumnStr, optional bool bBatchOp)
{
	local int i;

	i = GetFieldListIndex(FieldIdx, ListName);

	if (i == INDEX_None)
		return;


	ListData[FieldIdx].Lists[i].ColumnHeader = ColumnStr;

	if (!bBatchOp)
		RefreshSubscribers(ListData[FieldIdx].Tag);
}


// Updates an entire column with the specified string array
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	ListName: The identifying name of the column, as set by 'AddFieldList'
//	ListStrings: The full list of strings that should be applied to the specified column
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function UpdateFieldList(int FieldIdx, name ListName, const out array<string> ListStrings, optional bool bBatchOp)
{
	local int i, j;

	i = GetFieldListIndex(FieldIdx, ListName);


	if (ListData[FieldIdx].Lists[i].Strings.Length == ListStrings.Length)
		ListData[FieldIdx].Lists[i].Strings = ListStrings;
	else
		for (j=0; j<ListStrings.Length; ++j)
			ListData[FieldIdx].Lists[i].Strings[j] = ListStrings[j];

	if (!bBatchOp)
		RefreshSubscribers(ListData[FieldIdx].Tag);
}

// Updates an entire row with the specified string array
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	RowIdx: The index of the row which is to be updated
//	RowStrings: The full list of strings which should be applied to the specified row
//	bDisableSelection: If true, this row is marked as disabled, and is unselectable (and greyed out) in UIList's
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function UpdateFieldRow(int FieldIdx, int RowIdx, const out array<string> RowStrings, optional bool bDisableSelection, optional bool bBatchOp)
{
	local int i;

	if (ListData[FieldIdx].RowStates.Length <= RowIdx)
		return;

	for (i=0; i<ListData[FieldIdx].Lists.Length; ++i)
		ListData[FieldIdx].Lists[i].Strings[RowIdx] = ((RowStrings.Length > i) ? RowStrings[i] : "");

	ListData[FieldIdx].RowStates[RowIdx] = byte(!bDisableSelection);

	if (!bBatchOp)
		RefreshSubscribers(ListData[FieldIdx].Tag);
}

// Similar to 'UpdateFieldList', except this allows you to update from within the middle of the list (using StartRowIdx)
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	ListName: The identifying name of the column, as set by 'AddFieldList'
//	StartRowIdx: The row index at which to start adding new list items
//	ListStrings: The full list of strings that should be applied to the specified column
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function InsertFieldListItems(int FieldIdx, name ListName, int StartRowIdx, const out array<string> ListStrings, optional bool bBatchOp)
{
	local int i, j;

	i = GetFieldListIndex(FieldIdx, ListName);

	if (ListData[FieldIdx].Lists[i].Strings.Length < StartRowIdx)
		ListData[FieldIdx].Lists[i].Strings.Length = StartRowIdx;

	for (j=0; j<ListStrings.Length; ++j)
		ListData[FieldIdx].Lists[i].Strings.InsertItem(StartRowIdx+j, ListStrings[j]);

	if (!bBatchOp)
		RefreshSubscribers(ListData[FieldIdx].Tag);
}

// Searches for the specified string within the specified column, and returns the items row index, or INDEX_None
//	FieldIdx: The index of the field, as retrieved by the 'GetFieldIndex' function
//	ListName: The identifying name of the column, as set by 'AddFieldList'
//	SearchItem: The string to search the column for
final function int FindFieldListItem(int FieldIdx, name ListName, string SearchItem)
{
	local int i;

	i = GetFieldListIndex(FieldIdx, ListName);
	return ListData[FieldIdx].Lists[i].Strings.Find(SearchItem);
}


// Removes the specfied field
//	FieldName: The field which is to be removed
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function RemoveField(name FieldName, optional bool bBatchOp)
{
	local int i;

	i = GetFieldIndex(FieldName);

	if (i != INDEX_None)
	{
		ListData.Remove(i, 1);

		if (!bBatchOp)
			RefreshSubscribers(FieldName);
	}
}

// Removes and entire column from the specified field
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	ListName: The identifying name of the column, as set by 'AddFieldList'
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function RemoveFieldList(int FieldIdx, name ListName, optional bool bBatchOp)
{
	local int i;

	i = GetFieldListIndex(FieldIdx, ListName);

	if (i != INDEX_None)
	{
		ListData[FieldIdx].Lists.Remove(i, 1);

		if (ListData[FieldIdx].Lists.Length == 0)
			ListData[FieldIdx].RowStates.Length = 0;

		if (!bBatchOp)
			RefreshSubscribers(ListData[FieldIdx].Tag);
	}
}

// Removes an entire row from the specified field
//	FieldIdx: The index of the field being modifed, as retrieved by the 'GetFieldIndex' function
//	RowIdx: The index of the row which is to be removed
//	bBatchOp: If true, this tells the data store that you are doing more than one operation, and the function will not refresh the subscribers
final function RemoveFieldRow(int FieldIdx, int RowIdx, optional bool bBatchOp)
{
	local int i;

	for (i=0; i<ListData[FieldIdx].Lists.Length; ++i)
		ListData[FieldIdx].Lists[i].Strings.Remove(RowIdx, 1);

	ListData[FieldIdx].RowStates.Remove(i, 1);

	if (!bBatchOp)
		RefreshSubscribers(ListData[FieldIdx].Tag);
}

// Completely empties, but does not remove, the specified field
//	FieldName: The field which is to be emptied
final function EmptyField(name FieldName)
{
	local int i;

	i = GetFieldIndex(FieldName);

	if (i != INDEX_None)
	{
		ListData[i].Lists.Length = 0;
		ListData[i].RowStates.Length = 0;
	}

	RefreshSubscribers(FieldName);
}

// Removes all rows (but not columns) from the specified field
//	FieldName: The field which is to be modified
final function EmptyFieldLists(name FieldName)
{
	local int i, j;

	i = GetFieldIndex(FieldName);

	if (i != INDEX_None)
	{
		for (j=0; j<ListData[i].Lists.Length; ++j)
			ListData[i].Lists[j].Strings.Length = 0;

		ListData[i].RowStates.Length = 0;
	}

	RefreshSubscribers(FieldName);
}


defaultproperties
{
	Tag=UT2DStringList
	WriteAccessType=ACCESS_WriteAll

	ConstEditorListData(0)=(Tag="UTVoteGameList",ListTags=("GameList","VoteCount"))
	ConstEditorListData(1)=(Tag="UTVoteMapList",ListTags=("MapList","VoteCount"))
	ConstEditorListData(2)=(Tag="UTVoteMutators",ListTags=("VoteCount","Mutator","MutVoteIdx"))
}
