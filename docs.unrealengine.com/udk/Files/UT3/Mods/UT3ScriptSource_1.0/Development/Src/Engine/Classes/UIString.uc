/**
 * UIString is the core renderable entity for all data that is presented by the UI.  UIStrings are divided into one
 * or more UIStringNodes, where each node corresponds to either normal text or markup data.  Markup data is defined
 * as text that will be replaced by some data retrieved from a data store, referenced by DataStoreName:PropertyName.
 * Markup can change the current style: <Styles:NormalText>, can enable or disable a style attribute:
 * <Attributes:B> <Attributes:/B>, or it can indicate that the markup should be replaced by the value of the property
 * from the data store specified in the markup: <SomeDataStoreName:PropertyName>.
 * UIStrings dynamically generate UIStringNodes by parsing the input text. For example, passing the following string
 * to a UIString generates 7 tokens:
 * "The name specified '<SceneData:EnteredName>' is not available.  Press <ButtonImages:IMG_A> to continue or <ButtonImages:IMG_B> to cancel."
 * The tokens generated correspond to:
 *	(0)="The name specified '"
 *	(1)=" <SceneData:EnteredName>"
 *	(2)="' is not available.  Press "
 *	(3)="<ButtonImages:IMG_A>"
 *	(4)=" to continue or "
 *	(5)="<ButtonImages:IMG_B>"
 *	(6)=" to cancel."
 *
 * The source text for a UIString must be specified outside of the UIString itself.  There is no such thing as a
 * stand-alone UIString.  When used in a label, for example, the property which contains the text which will be used
 * in the label is specified by the UILabel.  This value may contain references to other data sources using markup, but
 * UIStrings cannot be bound to a data store by themselves.  When used in a list, the element cell will be responsible
 * for giving the UIString its source text.
 *
 * @todo UIString is supposed to support persistence, so that designers can override the extents for individual nodes
 *	in the string, so it should not be marked transient
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIString extends UIRoot
	within UIScreenObject
	native(inherit)
	transient;



/**
 * The text nodes contained by this UIString.  Each text node corresponds to a single atomically renderable
 * element, such as a string of text, an inline image (like a button icon), etc.
 */
var	native transient	array<pointer>				Nodes{FUIStringNode};

/**
 * The default style that will be used for initializing the styles for all nodes contained by this string.
 * Initialized using the owning widget's style, then modified by any per-widget style customizations enabled for the widget.
 */
var transient			UICombinedStyleData			StringStyleData;

/** the width and height of the entire string */
var transient			Vector2D					StringExtent;

/**
 * Parses a string containing optional markup (such as tokens and inline images) and stores the result in Nodes.
 *
 * @param	InputString		A string containing optional markup.
 * @param	bIgnoreMarkup	if TRUE, does not attempt to process any markup and only one UITextNode is created
 *
 * @return	TRUE if the string was successfully parsed into the Nodes array.
 */
native final virtual function bool SetValue( string InputString, bool bIgnoreMarkup );

/**
 * Returns the complete text value contained by this UIString, in either the processed or unprocessed state.
 *
 * @param	bReturnProcessedText	Determines whether the processed or raw version of the value string is returned.
 *									The raw value will contain any markup; the processed string will be text only.
 *									Any image tokens are converted to their text counterpart.
 *
 * @return	the complete text value contained by this UIString, in either the processed or unprocessed state.
 */
native final function string GetValue( optional bool bReturnProcessedText=true ) const;

/**
 * Retrieves the configured auto-scale percentage.
 *
 * @param	BoundingRegionSize		the bounding region to use for determining autoscale factor (only relevant for certain
 *									auto-scale modes).
 * @param	StringSize				the size of the string, unwrapped and non-scaled; (only relevant for certain
 *									auto-scale modes).
 * @param	out_AutoScalePercent	receives the autoscale percent value.
 */
native final function GetAutoScaleValue( Vector2D BoundingRegionSize, Vector2D StringSize, out Vector2D out_AutoScalePercent ) const;

/**
 * @return	TRUE if this string's value contains markup text
 */
native final function bool ContainsMarkup() const;

DefaultProperties
{
	StringStyleData=(TextClipMode=CLIP_Normal)
}
