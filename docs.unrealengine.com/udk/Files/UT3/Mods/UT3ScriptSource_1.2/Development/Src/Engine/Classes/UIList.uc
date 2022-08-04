/**
 * The "container" component of the UI system's list functionality, which is composed fo three components:
 * data source, container widget, and formatter.
 *
 * The UIList acts as the conduit for list data to the UI.  UIList knows nothing about the type of data it contains.
 * It is responsible for tracking the number of elements it has, the size of each cell, handling input (including
 * tracking which elements are selected, changing the selected element, etc.), adding and removing elements from the
 * list, and passing data back and forth between the data source and the presenter components.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIList extends UIObject
	native(UIPrivate)
	implements(UIDataStorePublisher);

/** Different ways to auto-size list cells */
enum ECellAutoSizeMode
{
	/** Auto-sizing not enabled */
	CELLAUTOSIZE_None<DisplayName=None>,

	/**
	 * Cells will be uniformly sized so that all cells can be displayed within the bounds of the list.  The configured
	 * cell size is ignored, and the bounds of the list are not adjusted.
	 */
	CELLAUTOSIZE_Uniform<DisplayName=Uniform Fill>,

	/**
	 * Cells will be sized to fit their contents.  The configured cell size is ignored, and the bounds of the list are
	 * not adjusted.
	 */
	CELLAUTOSIZE_Constrain<DisplayName=Best Fit>,

	/**
	 * Cells will be sized to fit their contents.  The configured cell size is ignored, and the bounds of the list are
	 * adjusted to display all cells
	 */
	CELLAUTOSIZE_AdjustList<DisplayName=Adjust List Bounds>,
};

/** Determines how the cells in this list are linked. */
enum ECellLinkType
{
	/** no linking - one to one mapping between cells and elements */
	LINKED_None<DisplayName=Disabled>,

	/** rows are linked; each column in the list will represent a single element; not yet implemented */
	LINKED_Rows<DisplayName=Span Rows>,

	/** columns are linked; each row in the list represents a single element */
	LINKED_Columns<DisplayName=Span Columns>,
};

/** Determines how list elements are wrapped */
enum EListWrapBehavior
{
	/**
	 * no wrapping (default); when the end of the list is reached, the user will not be able to scroll further
	 */
	LISTWRAP_None,

	/**
	 * Smooth wrapping; if space is available after rendering the last element, starts over at the first element and
	 * continues rendering elements until no more space is available.
	 * @todo - not yet implemented
	 */
	LISTWRAP_Smooth,

	/**
	 * Jump wrapping; list stops rendering at the last element, but if the user attempts to scroll past the end of the
	 * list, the index jumps back to the opposite side of the list.
	 */
	LISTWRAP_Jump,
};

/**
 * Provides information about which cells the mouse is currently hovering over.
 */
struct native transient CellHitDetectionInfo
{
	/**
	 * the column that was hit; INDEX_NONE if the location did not correspond to a valid column
	 */
	var	int HitColumn;

	/**
	 * the row that was hit; INDEX_NONE if the location did not correspond to a valid row
	 */
	var int HitRow;

	/**
	 * if the hit location was within the region used for resizing a column, indicates the column that will be resized;
	 */
	var int ResizeColumn;

	/**
	 * if the hit location was within the region used for resizing a column, indicates the column that will be resized;
	 */
	var int ResizeRow;

	
};

/** how many pixels wide the region is that is used for resizing a column/row */
const ResizeBufferPixels=5;

/**
 * Default height for cells in the list.  A value of 0 indicates that the cell heights are dynamic.
 *
 * If rows are linked, this value is only applied to cells that have a value of 0 for CellSize.
 */
var(Presentation)			UIScreenValue_Extent		RowHeight;

/**
 * Minimum size a column is allowed to be resized to.
 */
var(Presentation)			UIScreenValue_Extent		MinColumnSize;

/**
 * Default width for cells in the list.  A value of 0 indicates that the cell widths are dynamic.  Dynamic behavior is as follows:
 * Linked columns: columns are expanded to fill the width of the list
 * Non-linked columns: columns widths will be adjusted to fit the largest string in the list
 *
 * If columns are linked, this value is only applied to cells that have a value of 0 for CellSize.
 */
var(Presentation)			UIScreenValue_Extent		ColumnWidth;

/**
 * Amount of spacing to use inside the cells of the column headers.
 */
var(Presentation)			UIScreenValue_Extent		HeaderCellPadding;

/**
 * Amount of spacing to place between the column header and the first element.
 */
var(Presentation)			UIScreenValue_Extent		HeaderElementSpacing;

/**
 * Amount of spacing to use between each element in the list.
 */
var(Presentation)			UIScreenValue_Extent		CellSpacing;

/**
 * Amount of spacing to use inside each cell.
 */
var(Presentation)			UIScreenValue_Extent		CellPadding;

/**
 * Index into the Items array for currently active item.  In most cases, the active item will be the same as the selected
 * item.  Active item does not imply selected, however.  A good example of this is a multi-select list that has no selected
 * items, but which has focus - corresponds to the item that would be selected if the user pressed 'space' or 'enter'.
 */
var	transient				int							Index;

/** The index of the element which is located at the beginning of the visible region. */
var	transient				int							TopIndex;

/**
 * Maximum number of items that can be visible at one time in the list.  Calculated using the current size of the list
 * and the list's cells.
 */
var(Presentation) editconst	transient	duplicatetransient int	MaxVisibleItems;

/**
 * Number of columns to display in the list.  How this is set is dependent on the value of CellLinkType.
 *
 * LINKED_None: Whatever value designer specifies is used.  Either the width of the list or the column widths must be dynamic.
 * LINKED_Rows: always the same value as MaxVisibleItems.
 * LINKED_Columns: determined by the number of cells which are bound to data providers.
 */
var(List)	protected{protected}	int					ColumnCount;

/**
 * Number of rows to display in the list.  How this is set is dependent on the value of CellLinkType.
 *
 * LINKED_None:		Whatever value designer specifies is used.  Either the height of the list or the column heights must be dynamic.
 * LINKED_Rows:		determined by the number of cells which are bound to data providers.
 * LINKED_Columns:	always the same value as MaxVisibleItems.
 */
var(List)	protected{protected}	int					RowCount;

/** Controls how columns are auto-sized. */
var(List)	ECellAutoSizeMode							ColumnAutoSizeMode;

/** Controls how rows are auto-sized */
var(List)	ECellAutoSizeMode							RowAutoSizeMode;

/**
 * Controls how the cells are mapped to elements.  If CellLinkType is not LINKED_None, the data provider for this list
 * must be capable of supplying multiple data fields for a single item.
 *
 * @todo - once this functionality is exposed through the UI, this variable should no longer be editable
 */
var(List)					ECellLinkType				CellLinkType;

/**
 * Controls the wrapping behavior of the list, or what happens when the use attempts to scroll past the last element
 */
var(Presentation)			EListWrapBehavior			WrapType;

/**
 * Determines whether more than one item can be selected at the same time.
 *
 * @todo - not yet implemented
 */
var(List)					bool						bEnableMultiSelect;

/**
 *	Determines if this list will display scrollbars
 */
var(List)					bool						bEnableVerticalScrollbar;

/** set to indicate that the scrollbars need to be initialized after in the ResolveFacePosition call */
var			transient		bool						bInitializeScrollbars;

/**
 * Controls whether items which are "disabled" can be selected.
 */
var(List)					bool						bAllowDisabledItemSelection;

/**
 * Controls how many clicks are required in order to submit the list selected item (triggers the kismet Submit List Selection event).
 * FALSE to require a double-click on an item; FALSE to require only a single click;
 */
var(List)					bool						bSingleClickSubmission<ToolTip=Enable to trigger the Submit List Selection kismet event with only a single click>;

/**
 * Controls whether the item currently under the cursor should be drawn using a different style.
 */
var(List) private{private}	bool						bUpdateItemUnderCursor<ToolTip=Item under the cursor will be in a different state; must be true for the fourth CellStyle to work>;

/**
 * For lists with bUpdateItemUnderCursor=TRUE, controls whether the selected item enters the hover state when mouse over.
 */
var(List) private{private}	bool						bHoverStateOverridesSelected;

/**
 * Controls whether the user is allowed to resize the columns in this list.
 */
var(List)					bool						bAllowColumnResizing;

/**
 *	The UIScrollbar object which is allows the UIList to be scrolled up/down
 */
var							UIScrollbar					VerticalScrollbar;


/** The cell styles that are applied to any cells which do not have a custom cell style configured. */
var							UIStyleReference			GlobalCellStyle[EUIListElementState.ELEMENT_MAX];

/**
 * The style to use for the list's column header text.  The string portion of the style is applied to text; the image portion
 * of the style is applied to images embedded in the column header text (NOT the column header's background).  If not valid,
 * the GlobalCellStyle for the normal cell state will be used instead
 */
var							UIStyleReference			ColumnHeaderStyle/*[EColumnHeaderState.COLUMNHEADER_MAX]*/;

/**
 * The style to use for column header background images, if this list uses them.  The CellDataComponent also needs valid
 * values for its ColumnHeaderBackground variable.
 */
var							UIStyleReference			ColumnHeaderBackgroundStyle[EColumnHeaderState.COLUMNHEADER_MAX];

/**
 * The style to apply to the overlay textures for each cell state.
 */
var							UIStyleReference			ItemOverlayStyle[EUIListElementState.ELEMENT_MAX];

/**
 * if TRUE, the schema fields assigned to each column/row will be rendered, rather than the actual data.
 * Used primarily by the UI edtitor.
 */
var(Debug)	transient		bool						bDisplayDataBindings;

/**
 * The column currently being resized, or INDEX_NONE if no columns are being resized.
 */
var	const	transient		int							ResizeColumn;

/** TRUE if the user clicks on a column header - prevents the OnClick delegate from being fired */
var	const	transient		bool						bSortingList;

/**
 * If this value is greater than 0, SetIndex() will not do anything.
 */
var	private	transient		int							SetIndexMutex;

/**
 * If this value is more than 0, the OnValueChanged delegate will not be called.
 */
var	private	transient		int							ValueChangeNotificationMutex;

// ===============================================
// Data Binding
// ===============================================
/** The data store that this list is bound to */
var(Data)						UIDataStoreBinding		DataSource;

/** the list element provider referenced by DataSource */
var	const	transient			UIListElementProvider	DataProvider;

/**
 * The elements of the list. Corresponds to the array indexes of the whichever array this list's data comes from.
 */
var	const	transient			array<int>				Items;

/**
 * The items which are currently selected.  The int values are the array indexes of the whichever array this list's data comes from.
 *
 * @todo - not yet implemented
 */
var	transient 	public{private}	array<int>				SelectedItems;

// ===============================================
// Components
// ===============================================
/** Component for rendering an optional list background */
// @todo add support for a list background
//var(Presentation) editinline			UIComp_DrawImage			BackgroundImageComponent;

/** Determines how to sort the list's elements. */
var(Presentation) editinline	UIComp_ListElementSorter	SortComponent;

/**
 * Handles the interaction between the list and the list's elements.  Encapsulates any special behavior associated
 * with a particular type of list data and controls how the list formats its data.
 */
var(Data) editinline			UIComp_ListPresenter		CellDataComponent;

// ===============================================
// Sounds
// ===============================================

/** this sound is played when the user clicks or presses A on an item that is enabled */
var(Sound)						name					SubmitDataSuccessCue;
/** this sound is played when the user clicks or presses A on an item that is disabled */
var(Sound)						name					SubmitDataFailedCue;
/** this sound is played when the user decreases the list's index */
var(Sound)						name					DecrementIndexCue;
/** this sound is played when the user increases the list's index */
var(Sound)						name					IncrementIndexCue;
/** this sound is played when the user sorts the list in ascending order */
var(Sound)						name					SortAscendingCue;
/** this sound is played when the user sorts the list in descending order */
var(Sound)						name					SortDescendingCue;



/* == Delegates == */
/**
 * Called when the user presses Enter (or any other action bound to UIKey_SubmitListSelection) while this list has focus.
 *
 * @param	Sender	the list that is submitting the selection
 */
delegate OnSubmitSelection( UIList Sender, optional int PlayerIndex=GetBestPlayerIndex() );

/**
 * Called anytime this list's elements are sorted.
 *
 * @param	Sender	the list that just sorted its elements.
 */
delegate OnListElementsSorted( UIList Sender );

/**
 * Handler for vertical scrolling activity
 * PositionChange should be a number of nudge values by which the slider was moved
 * The nudge value in the UIList slider is equal to one list Item.
 *
 * @param	Sender			the scrollbar that generated the event.
 * @param	PositionChange	indicates how many items to scroll the list by
 * @param	bPositionMaxed	indicates that the scrollbar's marker has reached its farthest available position,
 *                          unused in this function
 */
native final function bool ScrollVertical( UIScrollbar Sender, float PositionChange, optional bool bPositionMaxed=false );

/**
 * Removes the specified element from the list.
 *
 * @param	ElementToRemove		the element to remove from the list
 *
 * @return	the index [into the Items array] for the element that was removed, or INDEX_NONE if the element wasn't
 *			part of the list.
 */
native function int RemoveElement(int ElementToRemove);

/**
 * Returns the number of elements in the list.
 *
 * @return	the number of elements in the list
 */
native function int GetItemCount() const;

/**
 * Returns the maximum number of elements that can be displayed by the list given its current size and configuration.
 */
native function int GetMaxVisibleElementCount() const;

/**
 * Returns the maximum number of rows that can be displayed in the list, given its current size and configuration.
 */
native final function int GetMaxNumVisibleRows() const;

/**
 *  Returns the maximum number of columns that can be displayed in the list, given its current size and configuration.
 */
native final function int GetMaxNumVisibleColumns() const;

/**
 * Returns the total number of rows in this list.
 */
native final function int GetTotalRowCount() const;

/**
 * Returns the total number of columns in this list.
 */
native final function int GetTotalColumnCount() const;

/**
 * Changes the list's ColumnCount to the value specified.
 */
native final function SetColumnCount( int NewColumnCount );

/**
 * Changes the list's RowCount to the value specified.
 */
native final function SetRowCount( int NewRowCount );

/**
 * Returns the width of the specified column.
 *
 * @param	ColumnIndex		the index for the column to get the width for.  If the index is invalid, the list's configured CellWidth is returned instead.
 * @param	bColHeader		specify TRUE to apply HeaderCellPadding instead of CellPadding.
 * @param	bReturnUnformattedValue
 *							specify TRUE to return a value determined by the size of a typical character from the font applied to the cell; otherwise,
 *							uses the cell string's calculated StringExtent, which will include any scaling that has been applied.
 */
native final function float GetColumnWidth( optional int ColumnIndex=INDEX_NONE, optional bool bColHeader, optional bool bReturnUnformattedValue ) const;

/**
 * Returns the width of the specified row.
 *
 * @param	RowIndex		the index for the row to get the width for.  If the index is invalid, the list's configured RowHeight is returned instead.
 * @param	bColHeader		specify TRUE to apply HeaderCellPadding instead of CellPadding.
 * @param	bReturnUnformattedValue
 *							specify TRUE to return a value determined by the size of a typical character from the font applied to the cell; otherwise,
 *							uses the cell string's calculated StringExtent, which will include any scaling that has been applied.
 */
native virtual function float GetRowHeight( optional int RowIndex=INDEX_NONE, optional bool bColHeader, optional bool bReturnUnformattedValue ) const;

/**
 * Returns the width and height of the bounding region for rendering the cells, taking into account whether the scrollbar
 * and column header are displayed.
 */
native function vector2D GetClientRegion() const;

/**
 * Calculates the index of the element under the mouse or joystick cursor
 *
 * @param	bRequireValidIndex	specify FALSE to return the calculated index, regardless of whether the index is valid or not.
 *								Useful for e.g. drag-n-drop operations where you want to drop at the end of the list.
 *
 * @return	the index [into the Items array] for the element under the mouse/joystick cursor, or INDEX_NONE if the mouse is not
 *			over a valid element.
 */
native function int CalculateIndexFromCursorLocation( optional bool bRequireValidIndex=true ) const;

/**
 * If the mouse is over a column boundary, returns the index of the column that would be resized, or INDEX_NONE if the mouse is not
 * hovering over a column boundary.
 *
 * @param	ClickedCell	will be filled with information about which cells the cursor is currently over
 *
 * @return	if the cursor is within ResizeBufferPixels of a column boundary, the index of the column the left of the cursor; INDEX_NONE
 *			otherwise.
 *
 * @note: noexport to allow the C++ version of this function to have a slightly different signature.
 */
native noexport function int GetResizeColumn( optional out const CellHitDetectionInfo ClickedCell ) const;

/**
 * Returns the items that are currently selected.
 *
 * @return	an array of values that represent indexes into the data source's data array for the list elements that are selected.
 *			these indexes are NOT indexes into the UIList.Items array; rather, they are the values of the UIList.Items elements which
 *			correspond to the selected items
 */
native final function array<int> GetSelectedItems() const;

/**
 * Returns the value of the element associated with the current list index
 *
 * @return	the value of the element at Index; this is not necessarily an index into the UIList.Items array; rather, it is the value
 *			of the UIList.Items element located at Index
 */
native final function int GetCurrentItem() const;

/**
 * Returns the text value for the specified element.  (temporary)
 *
 * @param	ElementIndex	index [into the Items array] for the value to return.
 * @param	CellIndex		for lists which have linked columns or rows, indicates which column/row to retrieve.
 *
 * @return	the value of the specified element, or an empty string if that element doesn't have a text value.
 */
native final function string GetElementValue( int ElementIndex, optional int CellIndex=INDEX_NONE ) const;

/**
 * Finds the index for the element with the specified text.
 *
 * @param	StringValue		the value to find
 * @param	CellIndex		for lists which have linked columns or rows, indicates which column/row to check
 *
 * @return	the index [into the Items array] for the element with the specified value, or INDEX_NONE if not found.
 */
native final function int FindItemIndex( string ItemValue, optional int CellIndex=INDEX_NONE ) const;

/**
 * Sets the list's index to the value specified and activates the appropriate notification events.
 *
 * @param	NewIndex			An index into the Items array that should become the new Index for the list.
 * @param	bClampValue			if TRUE, NewIndex will be clamped to a valid value in the range of 0 -> ItemCount - 1
 * @param	bSkipNotification	if TRUE, no events are generated as a result of updating the list's index.
 *
 * @return	TRUE if the list's Index was successfully changed.
 */
native final virtual function bool SetIndex( int NewIndex, optional bool bClampValue=true, optional bool bSkipNotification=false );

/**
 * Changes the list's first visible item to the element at the index specified.
 *
 * @param	NewTopIndex		an index into the Items array that should become the new first visible item.
 * @param	bClampValue		if TRUE, NewTopIndex will be clamped to a valid value in the range of 0 - ItemCount - 1
 *
 * @return	TRUE if the list's TopIndex was successfully changed.
 */
native final virtual function bool SetTopIndex( int NewTopIndex, optional bool bClampValue=true );

/**
 * Determines whether the specified list element is disabled by the data source bound to this list.
 *
 * @param	ElementIndex	the index into the Items array for the element to retrieve the menu state for.
 */
native final function bool IsElementEnabled( INT ElementIndex );

/**
 * Determines whether the specified list element can be selected.
 *
 * @param	ElementIndex	the index into the Items array for the element to query
 *
 * @return	true if the specified element can enter the ELEMENT_Selected state.  FALSE if the index specified is invalid or
 *			cannot be selected.
 */
native final function bool CanSelectElement( int ElementIndex );

/**
 * Change the value of bUpdateItemUnderCursor to the specified value.
 */
native final function SetHotTracking( bool bShouldUpdateItemUnderCursor );

/**
 * Returns the value of bUpdateItemUnderCursor.
 */
native final function bool IsHotTrackingEnabled() const;

/** UIDataSourceSubscriber interface */
/**
 * Sets the data store binding for this object to the text specified.
 *
 * @param	MarkupText			a markup string which resolves to data exposed by a data store.  The expected format is:
 *								<DataStoreTag:DataFieldTag>
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 */
native final virtual function SetDataStoreBinding( string MarkupText, optional int BindingIndex=INDEX_NONE );

/**
 * Retrieves the markup string corresponding to the data store that this object is bound to.
 *
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	a datastore markup string which resolves to the datastore field that this object is bound to, in the format:
 *			<DataStoreTag:DataFieldTag>
 */
native final virtual function string GetDataStoreBinding( optional int BindingIndex=INDEX_NONE ) const;

/**
 * Resolves this subscriber's data store binding and updates the subscriber with the current value from the data store.
 *
 * @return	TRUE if this subscriber successfully resolved and applied the updated value.
 */
native final virtual function bool RefreshSubscriberValue( optional int BindingIndex=INDEX_NONE );

/**
 * Handler for the UIDataStore.OnDataStoreValueUpdated delegate.  Used by data stores to indicate that some data provided by the data
 * has changed.  Subscribers should use this function to refresh any data store values being displayed with the updated value.
 * notify subscribers when they should refresh their values from this data store.
 *
 * @param	SourceDataStore		the data store that generated the refresh notification; useful for subscribers with multiple data store
 *								bindings, to tell which data store sent the notification.
 * @param	PropertyTag			the tag associated with the data field that was updated; Subscribers can use this tag to determine whether
 *								there is any need to refresh their data values.
 * @param	SourceProvider		for data stores which contain nested providers, the provider that contains the data which changed.
 * @param	ArrayIndex			for collection fields, indicates which element was changed.  value of INDEX_NONE indicates not an array
 *								or that the entire array was updated.
 */
native final virtual function NotifyDataStoreValueUpdated( UIDataStore SourceDataStore, bool bValuesInvalidated, name PropertyTag, UIDataProvider SourceProvider, int ArrayIndex );

/**
 * Retrieves the list of data stores bound by this subscriber.
 *
 * @param	out_BoundDataStores		receives the array of data stores that subscriber is bound to.
 */
native final virtual function GetBoundDataStores( out array<UIDataStore> out_BoundDataStores );

/**
 * Notifies this subscriber to unbind itself from all bound data stores
 */
native final function ClearBoundDataStores();

/**
 * Returns whether element size is determined by the elements themselves.  For lists with linked columns, returns whether
 * the item height is autosized; for lists with linked rows, returns whether item width is autosized.
 */
native final function bool IsElementAutoSizingEnabled() const;

/**
 * Resolves this subscriber's data store binding and publishes this subscriber's value to the appropriate data store.
 *
 * @param	out_BoundDataStores	contains the array of data stores that widgets have saved values to.  Each widget that
 *								implements this method should add its resolved data store to this array after data values have been
 *								published.  Once SaveSubscriberValue has been called on all widgets in a scene, OnCommit will be called
 *								on all data stores in this array.
 * @param	BindingIndex		optional parameter for indicating which data store binding is being requested for those
 *								objects which have multiple data store bindings.  How this parameter is used is up to the
 *								class which implements this interface, but typically the "primary" data store will be index 0.
 *
 * @return	TRUE if the value was successfully published to the data store.
 */
native virtual function bool SaveSubscriberValue( out array<UIDataStore> out_BoundDataStores, optional int BindingIndex=INDEX_NONE );

/* == Kismet action handlers == */
protected final function OnSetListIndex( UIAction_SetListIndex Action )
{
	local int OutputLinkIndex;

	if ( Action != None )
	{
		if ( !SetIndex(Action.NewIndex, Action.bClampInvalidValues, !Action.bActivateListChangeEvent) )
		{
			// 1 is the index of the "Failed" output link
			OutputLinkIndex = 1;
		}

		// activate the appropriate output link on the action
		if ( !Action.OutputLinks[OutputLinkIndex].bDisabled )
		{
			Action.OutputLinks[OutputLinkIndex].bHasImpulse = true;
		}
	}
}

/**
 * Handler for GetTextValue action.
 */
function OnGetTextValue( UIAction_GetTextValue Action )
{
	Action.StringValue = GetElementValue(Index, 0);
}

/**
 * Sets up the scroll activity delegates in the scrollbars
 * @todo - this is a fix for the issue where delegates don't seem to be getting set properly in defaultproperties blocks.
 */
event Initialized()
{
	Super.Initialized();

	SetActiveCursorUpdate(bUpdateItemUnderCursor);
	if ( VerticalScrollbar != None )
	{
		VerticalScrollbar.OnScrollActivity = ScrollVertical;
		VerticalScrollbar.OnClickedScrollZone = ClickedScrollZone;
	}
}

/**
 * Propagate the enabled state of this widget.
 */
event PostInitialize()
{
	Super.PostInitialize();

	// when this widget is enabled/disabled, its children should be as well.
	ConditionalPropagateEnabledState(GetBestPlayerIndex());
}

/**
 * @return	TRUE if all mutexes are disabled.
 */
final event bool AllMutexesDisabled()
{
	return	IsSetIndexEnabled()
		&&	IsValueChangeNotificationEnabled();
}

/**
 * Increments all mutexes
 */
final event IncrementAllMutexes()
{
	DisableValueChangeNotification();
	DisableSetIndex();
}

/**
 * Decrements all mutexes
 *
 * @param	bDispatchUpdates	specify TRUE to refresh the list's index, formatting, and states.
 */
final event DecrementAllMutexes( optional bool bDispatchUpdates )
{
	EnableValueChangeNotification();
	EnableSetIndex();

	if ( bDispatchUpdates )
	{
		SetIndex(Index, true);
		if ( AllMutexesDisabled() )
		{
			RequestFormattingUpdate();
			RequestSceneUpdate(false, true);
		}
	}
}

/**
 * Enable calls to SetIndex(); useful when adding lots of items to avoid flicker.
 */
final event EnableSetIndex()
{
	if ( --SetIndexMutex < 0 )
	{
		ScriptTrace();
		`warn("EnableSetIndex called too many times on (" $ WidgetTag $ ")" @ Class.Name $ "'" $ PathName(Self) $ "'; resetting value back to 0.");

		SetIndexMutex = 0;
	}
}

/**
 * Disable calls to SetIndex(); useful when adding lots of items to avoid flicker.
 */
final event DisableSetIndex()
{
	SetIndexMutex++;
}

/**
 * @return	TRUE if calls to SetIndex() will be executed.
 */
final event bool IsSetIndexEnabled()
{
	return SetIndexMutex == 0;
}

/**
 * Enable calls to NotifyValueChanged(); useful when adding lots of items to avoid flicker.
 */
final event EnableValueChangeNotification()
{
	if ( --ValueChangeNotificationMutex < 0 )
	{
		ScriptTrace();
		`warn("EnableValueChangeNotification called too many times on (" $ WidgetTag $ ")" @ Class.Name $ "'" $ PathName(Self) $ "'; resetting value back to 0.");

		ValueChangeNotificationMutex = 0;
	}
}

/**
 * Disable calls to NotifyValueChanged(); useful when adding lots of items to avoid flicker.
 */
final event DisableValueChangeNotification()
{
	ValueChangeNotificationMutex++;
}

/**
 * @return	TRUE if calls to NotifyValueChanged() will be executed.
 */
final event bool IsValueChangeNotificationEnabled()
{
	return ValueChangeNotificationMutex == 0;
}

/**
 * Changes whether this list renders colum headers or not.  Only applicable if the owning list's CellLinkType is LINKED_Columns
 */
final function EnableColumnHeaderRendering( bool bShouldRenderColHeaders=true )
{
	if ( CellDataComponent != None )
	{
		CellDataComponent.EnableColumnHeaderRendering(bShouldRenderColHeaders);
	}
}

/**
 * Returns whether this list should render column headers
 */
final function bool ShouldRenderColumnHeaders()
{
	if ( CellDataComponent != None )
	{
		return CellDataComponent.ShouldRenderColumnHeaders();
	}

	return false;
}

/**
 * Handler for the vertical scrollbar's OnClickedScrollZone delegate.  Scrolls the list by a full page (MaxVisibleItems).
 *
 * @param	Sender			the scrollbar that was clicked.
 * @param	PositionPerc	a value from 0.0 - 1.0, representing the location of the click within the region between the increment
 *							and decrement buttons.  Values closer to 0.0 means that the user clicked near the decrement button; values closer
 *							to 1.0 are nearer the increment button.
 * @param	PlayerIndex		Player that performed the action that issued the event.
 */
function ClickedScrollZone( UIScrollbar Sender, float PositionPerc, int PlayerIndex )
{
	local int MouseX, MouseY;
	local float MarkerPosition;
	local bool bDecrement;

	local int NewTopItem;

	if ( GetCursorPosition(MouseX, MouseY) )
	{
		// this is the position of the marker's minor side (left or top)
		MarkerPosition = Sender.GetMarkerButtonPosition();

		// determine whether the user clicked in the region above or below the marker button.
		bDecrement = (Sender.ScrollbarOrientation == UIORIENT_Vertical)
			? MouseY < MarkerPosition
			: MouseX < MarkerPosition;

		NewTopItem = bDecrement ? (TopIndex - MaxVisibleItems) : (TopIndex + MaxVisibleItems);
		SetTopIndex(NewTopItem, true);
	}
}

/**
 * Called when a new UIState becomes the widget's currently active state, after all activation logic has occurred.
 *
 * @param	Sender					the widget that changed states.
 * @param	PlayerIndex				the index [into the GamePlayers array] for the player that activated this state.
 * @param	NewlyActiveState		the state that is now active
 * @param	PreviouslyActiveState	the state that used the be the widget's currently active state.
 */
final function OnStateChanged( UIScreenObject Sender, int PlayerIndex, UIState NewlyActiveState, optional UIState PreviouslyActiveState )
{
	if ( UIState_Pressed(NewlyActiveState) != None )
	{
		SetMouseCaptureOverride(true);
	}
	else if ( UIState_Pressed(PreviouslyActiveState) != None )
	{
		SetMouseCaptureOverride(false);
	}
}

DefaultProperties
{
	NotifyActiveStateChanged=OnStateChanged

	PrimaryStyle=(DefaultStyleTag="DefaultListStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
	DataSource=(RequiredFieldType=DATATYPE_Collection)
	bSupportsPrimaryStyle=false
	PrivateFlags=PRIVATE_PropagateState

	// don't allow columns to have negative values; using 0 here doesn't work very well because then GetColumnWidth()
	// returns the value of ColumnWidth instead of the cell's size.
	MinColumnSize=(Value=0.5)

	ColumnHeaderStyle=(DefaultStyleTag="DefaultColumnHeaderStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
//	ColumnHeaderStyle(COLUMNHEADER_PrimarySort)=(DefaultStyleTag="DefaultColumnHeaderStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
//	ColumnHeaderStyle(COLUMNHEADER_SecondarySort)=(DefaultStyleTag="DefaultColumnHeaderStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')

	ColumnHeaderBackgroundStyle(COLUMNHEADER_Normal)=(RequiredStyleClass=class'Engine.UIStyle_Image')
	ColumnHeaderBackgroundStyle(COLUMNHEADER_PrimarySort)=(RequiredStyleClass=class'Engine.UIStyle_Image')
	ColumnHeaderBackgroundStyle(COLUMNHEADER_SecondarySort)=(RequiredStyleClass=class'Engine.UIStyle_Image')

	GlobalCellStyle(ELEMENT_Normal)=(DefaultStyleTag="DefaultCellStyleNormal",RequiredStyleClass=class'Engine.UIStyle_Combo')
	GlobalCellStyle(ELEMENT_Active)=(DefaultStyleTag="DefaultCellStyleActive",RequiredStyleClass=class'Engine.UIStyle_Combo')
	GlobalCellStyle(ELEMENT_Selected)=(DefaultStyleTag="DefaultCellStyleSelected",RequiredStyleClass=class'Engine.UIStyle_Combo')
	GlobalCellStyle(ELEMENT_UnderCursor)=(DefaultStyleTag="DefaultCellStyleHover",RequiredStyleClass=class'Engine.UIStyle_Combo')

	ItemOverlayStyle(ELEMENT_Normal)=(DefaultStyleTag="ListItemBackgroundNormalStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	ItemOverlayStyle(ELEMENT_Active)=(DefaultStyleTag="ListItemBackgroundActiveStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	ItemOverlayStyle(ELEMENT_Selected)=(DefaultStyleTag="ListItemBackgroundSelectedStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
	ItemOverlayStyle(ELEMENT_UnderCursor)=(DefaultStyleTag="ListItemBackgroundHoverStyle",RequiredStyleClass=class'Engine.UIStyle_Image')

	Index=-1
	TopIndex=-1
	CellLinkType=LINKED_Columns
	bEnableVerticalScrollbar=true
	bInitializeScrollbars=true
	bAllowColumnResizing=true

	RowHeight=(Value=16)
	ColumnWidth=(Value=100)
	RowCount=4
	ColumnCount=1
	ColumnAutoSizeMode=CELLAUTOSIZE_Uniform
	RowAutoSizeMode=CELLAUTOSIZE_Constrain
	ResizeColumn=INDEX_NONE

	Begin Object Class=UIComp_ListPresenter Name=ListPresentationComponent
	End Object
	CellDataComponent=ListPresentationComponent

	SubmitDataSuccessCue=ListSubmit
	SubmitDataFailedCue=GenericError
	DecrementIndexCue=ListUp
	IncrementIndexCue=ListDown
	SortAscendingCue=SortAscending
	SortDescendingCue=SortDescending

	// States
	DefaultStates.Add(class'Engine.UIState_Focused')
	DefaultStates.Add(class'Engine.UIState_Active')
	DefaultStates.Add(class'Engine.UIState_Pressed')

	DebugBoundsColor=(R=255,G=255,B=255,A=255)
}
