/**
 * Resonsible for how the data associated with this list is presented.  Updates the list's operating parameters
 * (CellHeight, CellWidth, etc.) according to the presentation type for the data contained by this list.
 *
 * Routes render messages from the list to the individual elements, adding any additional data necessary for the
 * element to understand how to render itself.  For example, a listdata component might add that the element being
 * rendered is the currently selected element, so that the element can adjust the way it renders itself accordingly.
 * For a tree-type list, the listdata component might add whether the element being drawn is currently open, has
 * children, etc.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_ListPresenter extends UIComp_ListComponentBase
	native(inherit)
	DependsOn(UIDataStorePublisher)
	implements(CustomPropertyItemHandler);

/**
 * Corresponds to a single cell in a UIList (intersection of a row and column).  Generally maps directly to a
 * single item in the list, but in the case of multiple columns or rows, a single list item may be associated with
 * multiple UIListElementCells (where each column for that row is represented by a UIListElementCell).
 *
 * The data for a UIListElementCell is accessed using a UIString. Contains one UIListCellRegion per UIStringNode
 * in the UIString, which can be configured to manually controls the extent for each UIStringNode.
 */
struct native UIListElementCell
{
	/** index of the UIListElement that contains this UIListElementCell */
	var	const	native	transient	int					ContainerElementIndex;

	/** pointer to the list that contains this element cell */
	var	const	transient	UIList						OwnerList;

	/** A UIString which contains data for this cell */
	var	transient			UIListString				ValueString;

	/**
	 * Allows the designer to specify a different style for each cell in a column/row
	 */
	var						UIStyleReference			CellStyle[EUIListElementState.ELEMENT_MAX];

	

	structdefaultproperties
	{
		CellStyle(ELEMENT_Normal)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
		CellStyle(ELEMENT_Active)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
		CellStyle(ELEMENT_Selected)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
		CellStyle(ELEMENT_UnderCursor)=(RequiredStyleClass=class'Engine.UIStyle_Combo')
	}
};


/**
 * Contains the data binding information for a single row or column in a list.  Also used for rendering the list's column
 * headers, if configured to do so.
 */
struct native UIListElementCellTemplate extends UIListElementCell
{
	/**
	 * Contains the data binding for each cell group in the list (row if columns are linked, columns if
	 * rows are linked, individual cells if neither are linked
	 */
	var()	editinline editconst	name				CellDataField;

	/**
	 * The string that should be rendered in the header for the column which displays the data for this cell.
	 */
	var()				editconst	string				ColumnHeaderText;

	/**
	 * The custom size for the linked cell (column/row).  A value of 0 indicates that the row/column's size should be
	 * controlled by the owning list according to its cell auto-size configuration.
	 */
	var()					UIScreenValue_Extent		CellSize;

	/**
	 * The starting position of this cell, in absolute pixels.
	 */
	var								float				CellPosition;

	
};

struct native UIListItemDataBinding
{
	/**
	 * The data provider that contains the data for this list element
	 */
	var	UIListElementCellProvider	DataSourceProvider;

	/**
	 * The name of the field from DataSourceProvider that contains the array of data corresponding to this list element
	 */
	var	name						DataSourceTag;

	/**
	 * The index into the array [DataSourceTag] in DataSourceProvider that this list element represents.
	 */
	var	int							DataSourceIndex;

	

};

/**
 * Corresponds to a single item in a UIList, which may be any type of data structure.
 *
 * Contains a list of UIListElementCells, which correspond to one or more data fields of the underlying data
 * structure associated with the list item represented by this object.  For linked-column lists, each
 * UIListElementCell is typically associated with a different field from the underlying data structure.
 */
struct native UIListItem
{
	/** The list element associated with the cells contained by this UIElementCellList. */
	var	const						UIListItemDataBinding					DataSource;

	/** the cells associated with this list element */
	var()	editinline editconst editfixedsize	array<UIListElementCell>	Cells;

	/** The current state of this cell (selected, active, etc.) */
	var()	editconst	transient 	noimport EUIListElementState			ElementState;

	
};

/**
 * Contains the data store bindings for the individual cells of a single element in this list.  This struct is used
 * for looking up the data required to fill the cells of a list element when a new element is added.
 */
struct native UIElementCellSchema
{
	/** contains the data store bindings used for creating new elements in this list */
	var() editinline	array<UIListElementCellTemplate>	Cells;

	
};


/**
 * Contains the formatting information configured for each individual cell in the UI editor.
 * Private/const because changing the value of this property invalidates all data in this, requiring that all data be refreshed.
 */
var()		const private									UIElementCellSchema	ElementSchema;

/**
 * Contains the element cells for each list item.  Each item in the ElementCells array is the list of
 * UIListElementCells for the corresponding element in the list.
 */
var()	editconst	editinline	transient noimport	init	array<UIListItem>	ListItems;

/**
 * Optional background image for the column headers; only applicable if bDisplayColumnHeaders is TRUE.
 */
var(Image)	instanced	editinlineuse						UITexture			ColumnHeaderBackground[EColumnHeaderState.COLUMNHEADER_MAX]<EditCondition=bDisplayColumnHeaders>;

/**
 * The image to render over each element.
 */
var(Image)	instanced	editinlineuse						UITexture			ListItemOverlay[EUIListElementState.ELEMENT_MAX];

/**
 * Texture atlas coordinates for the column header background textures; only applicable if bDisplayColumnHeaders is TRUE.
 * Values of 0 indicate that the texture is not part of an atlas.
 */
var(Image)													TextureCoordinates	ColumnHeaderBackgroundCoordinates[EColumnHeaderState.COLUMNHEADER_MAX]<EditCondition=bDisplayColumnHeaders>;

/**
 * the texture atlas coordinates for the SelectionOverlay. Values of 0 indicate that the texture is not part of an atlas.
 */
var(Image)													TextureCoordinates	ListItemOverlayCoordinates[EUIListElementState.ELEMENT_MAX];

/** Controls whether column headers are rendered for this list */
var()		private{private}								bool				bDisplayColumnHeaders;

/** set to indicate that the cells in this list needs to recalculate their extents */
var			transient										bool				bReapplyFormatting;



/**
 * Changes whether this list renders colum headers or not.  Only applicable if the owning list's CellLinkType is LINKED_Columns
 */
native final function EnableColumnHeaderRendering( bool bShouldRenderColHeaders=true );

/**
 * Returns whether this list should render column headers
 */
native final function bool ShouldRenderColumnHeaders() const;

/**
 * Returns whether the list's bounds will be adjusted for the specified orientation considering the list's configured
 * autosize and cell link type values.
 *
 * @param	Orientation		the orientation to check auto-sizing for
 */
native final function bool ShouldAdjustListBounds( EUIOrientation Orientation ) const;

/**
 * Returns the object that provides the cell schema for this component's owner list (usually the class default object for
 * the class of the owning list's list element provider)
 */
native final function UIListElementCellProvider GetCellSchemaProvider() const;

/**
 * Find the index of the list item which corresponds to the data element specified.
 *
 * @param	DataSourceIndex		the index into the list element provider's data source collection for the element to find.
 *
 * @return	the index [into the ListItems array] for the element which corresponds to the data element specified, or INDEX_NONE
 * if none where found or DataSourceIndex is invalid.
 */
native final function int FindElementIndex( int DataSourceIndex ) const;

DefaultProperties
{
	bDisplayColumnHeaders=true
	bReapplyFormatting=true

	// We create these in default properties so that the user is not required to
	Begin Object Class=UITexture Name=NormalOverlayTemplate
	End Object
	Begin Object Class=UITexture Name=ActiveOverlayTemplate
	End Object
	Begin Object Class=UITexture Name=SelectionOverlayTemplate
	End Object
	Begin Object Class=UITexture Name=HoverOverlayTemplate
	End Object
	ListItemOverlay(ELEMENT_Normal)=NormalOverlayTemplate
	ListItemOverlay(ELEMENT_Active)=ActiveOverlayTemplate
	ListItemOverlay(ELEMENT_Selected)=SelectionOverlayTemplate
	ListItemOverlay(ELEMENT_UnderCursor)=HoverOverlayTemplate
}
