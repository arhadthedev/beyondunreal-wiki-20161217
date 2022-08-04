/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Specific version of the menu list that draws a number of the currently selected character part.
 */
class UTUICharacterCustomizationList extends UTUIMenuList;

/** Text information. */
var transient	vector2D			PartSelectionPadding;
var transient	string				CurrentPartSelectionStr;
var()			color				PartSelectionTextColor;

/** Left/Right Selection Arrow */
var()				texture2D			LeftRightArrowImage;
var()				bool				bLeftArrowPressed;
var()				bool				bRightArrowPressed;
var()				float				LeftRightArrowHeightMultiplier;	/** Height of the selection left/right arrow in percentage. */
var()				float				LeftRightArrowWidthRatio;		/** Ratio if scroll ratio width to height. */
var()				vector2D			LeftRightArrowOffset;

/** Arrow state colors. */
var()				color				ArrowColorNormal;
var()				color				ArrowColorMouseOver;
var()				color				ArrowColorPressed;

/** We cache the rendering bounds of the Left/Right arrows for quick mouse look up. */
var transient float LeftArrowBounds[4];
var transient float RightArrowBounds[4];

var transient	ECharPart			CurrentlySelectedPartType;
var transient	array<int>			CurrentlySelectedPartIndex;
var transient	array<name>			PartCellTags;
var transient	array<ECharPart>	ListEnumMap;	/** Mapping of list index's to part enums. */
var transient	UTUIDataStore_CustomChar	CustomCharDataStore;


event PostInitialize()
{
	Super.PostInitialize();

	CustomCharDataStore=UTUIDataStore_CustomChar(UTUIScene(GetScene()).FindDataStore('UTCustomChar'));
	// Set the parts length of the array to the max possible
	CurrentlySelectedPartIndex.length = PART_MAX;
}

/** Sets the currently selected list item. */
event SelectItem(int NewSelection)
{
	Super.SelectItem(NewSelection);

	OnCurrentPartChanged(false);
}

/** @return	Returns the currently selected char part type. */
function ECharPart GetSelectedCharPartType()
{
	if(Selection >= 0 && Selection < ListEnumMap.length)
	{
		return ListEnumMap[Selection];
	}
	else
	{
		return ListEnumMap[0];
	}
}

/** Selects the previous part for the current part type. */
function SelectPrevPart()
{
	local int NumParts;
	local ECharPart CurrentType;

	CurrentType = ListEnumMap[Selection];
	NumParts = CustomCharDataStore.GetProviderElementCount(PartCellTags[CurrentType]);

	if(NumParts==0)
	{
		NumParts=1;
	}

	// Wrap the list
	if(CurrentlySelectedPartIndex[CurrentType]>0)
	{
		CurrentlySelectedPartIndex[CurrentType]--;
	}
	else
	{
		CurrentlySelectedPartIndex[CurrentType]=NumParts-1;
	}

	PlayUISound('ArmorPartChanged');

	OnCurrentPartChanged();
}

/** Selects the next part for the current part type. */
function SelectNextPart()
{
	local int NumParts;
	local ECharPart CurrentType;

	CurrentType = ListEnumMap[Selection];
	NumParts = CustomCharDataStore.GetProviderElementCount(PartCellTags[CurrentType]);

	if(NumParts==0)
	{
		NumParts=1;
	}

	// Increment but allow list wrap
	CurrentlySelectedPartIndex[CurrentType]=(CurrentlySelectedPartIndex[CurrentType]+1)%NumParts;

	PlayUISound('ArmorPartChanged');

	OnCurrentPartChanged();
}

/** Notification for when the current part for the current part type has changed. */
function OnCurrentPartChanged(optional bool bUpdatePreviewactor=true)
{
	local string PartID;
	local ECharPart CurrentPartType;
	local int NumParts;

	CurrentPartType = ListEnumMap[Selection];
	NumParts = CustomCharDataStore.GetProviderElementCount(PartCellTags[CurrentPartType]);
	if(bUpdatePreviewactor && GetPartID(CurrentPartType, CurrentlySelectedPartIndex[CurrentPartType], PartID))
	{
		UTUIFrontEnd_CharacterCustomization(GetScene()).OnPreviewPartChanged(CurrentPartType, PartID);
	}

	// Update the selection string, make sure it is 2 digits long.
	if(CurrentlySelectedPartIndex[CurrentPartType]<9)
	{
		CurrentPartSelectionStr="0"$(CurrentlySelectedPartIndex[ListEnumMap[Selection]]+1);
	}
	else
	{
		CurrentPartSelectionStr=""$(CurrentlySelectedPartIndex[ListEnumMap[Selection]]+1);
	}

	// Append the number of total parts to the end.
	if(NumParts<=0)
	{
		CurrentPartSelectionStr="00/00";
	}
	else if(NumParts < 9)
	{
		CurrentPartSelectionStr=CurrentPartSelectionStr$"/0"$NumParts;
	}
	else
	{
		CurrentPartSelectionStr=CurrentPartSelectionStr$"/"$NumParts;
	}
}

/** UI Input processing handler. */
function bool ProcessInputKey( const out SubscribedInputEventParameters EventParms )
{
	local bool bResult;

	bResult = false;

	if (EventParms.EventType == IE_Pressed || EventParms.EventType == IE_Repeat || EventParms.EventType == IE_DoubleClick)
	{
		if ( EventParms.InputAliasName == 'SelectionLeft' )
		{
			bLeftArrowPressed=true;
			SelectPrevPart();
			return true;
		}
		else if ( EventParms.InputAliasName == 'SelectionRight' )
		{
			bRightArrowPressed=true;
			SelectNextPart();
			return true;
		}
	}
	else if(EventParms.EventType==IE_Released)
	{
		if ( EventParms.InputAliasName == 'SelectionLeft' )
		{
			bLeftArrowPressed=false;
		}
		else if ( EventParms.InputAliasName == 'SelectionRight' )
		{
			bRightArrowPressed=false;
		}
	}

	// Try letting the left/right arrow's process input
	bResult = CheckArrowInput(EventParms);

	if(!bResult)
	{
		Super.ProcessInputKey(EventParms);
	}

	return bResult;
}


/** Checks to see if the user has clicked on the scroll arrows. */
function bool CheckArrowInput(const SubscribedInputEventParameters EventParms)
{
	local bool bResult;

	bResult = false;

	if(EventParms.EventType==IE_Pressed||EventParms.EventType==IE_DoubleClick)
	{
		if(CursorCheck(LeftArrowBounds[0],LeftArrowBounds[1],LeftArrowBounds[2],LeftArrowBounds[3]) && EventParms.InputAliasName == 'Click')
		{
			bLeftArrowPressed=true;
			bResult=true;
		}
		else if(CursorCheck(RightArrowBounds[0],RightArrowBounds[1],RightArrowBounds[2],RightArrowBounds[3]) && EventParms.InputAliasName == 'Click')
		{
			bRightArrowPressed=true;
			bResult=true;
		}
	}
	else if(EventParms.EventType==IE_Released)
	{
		if(bLeftArrowPressed && CursorCheck(LeftArrowBounds[0],LeftArrowBounds[1],LeftArrowBounds[2],LeftArrowBounds[3]) && EventParms.InputAliasName == 'Click')
		{
			// The user released their mouse on the button.
			SelectPrevPart();
			bResult=true;
		}
		else if(bRightArrowPressed && CursorCheck(RightArrowBounds[0],RightArrowBounds[1],RightArrowBounds[2],RightArrowBounds[3]) && EventParms.InputAliasName == 'Click')
		{
			// The user released their mouse on the button.
			SelectNextPart();
			bResult=true;
		}

		bLeftArrowPressed=false;
		bRightArrowPressed=false;
	}

	return bResult;
}


/** @return Returns whether or not OutValue contains the partID for the given part type and part index */
function bool GetPartID(ECharPart PartType, int PartIndex, out string OutValue)
{
	local bool Result;
	local array<int> ListElements;

	Result = false;
	ListElements = CustomCharDataStore.GetProviderListElements(PartCellTags[PartType]);
	if(PartIndex < ListElements.length)
	{
		PartIndex = ListElements[PartIndex];
		Result = CustomCharDataStore.GetValueFromProviderSet(PartCellTags[PartType], 'PartID', PartIndex, OutValue);
	}

	return Result;
}

/** Returns a part index given a part type and part ID. */
function int GetPartIndex(ECharPart PartType, string PartID)
{
	local int Result;
	local int ListIdx;
	local array<int> ListElements;

	ListElements = CustomCharDataStore.GetProviderListElements(PartCellTags[PartType]);
	Result = CustomCharDataStore.FindValueInProviderSet(PartCellTags[PartType], 'PartID', PartID);

	if(Result==INDEX_NONE)
	{
		Result=0;
	}

	// Find the list index the result corresponds to.
	for(ListIdx=0; ListIdx<ListElements.length; ListIdx++)
	{
		if(ListElements[ListIdx]==Result)
		{
			Result=ListIdx;
			break;
		}
	}

	return Result;
}

/** Sets the current selection for the specified part type. */
function SetPartSelection(ECharPart PartType, string PartID)
{
	if(PartType < CurrentlySelectedPartIndex.length)
	{
		CurrentlySelectedPartIndex[PartType]=GetPartIndex(PartType, PartID);
	}
}

/** Draws the background of the currently selected list element. */
function DrawSelectionBG(float YPos)
{
	local float Width,Height;
	local float ArrowWidth, ArrowHeight;
	local bool bOverArrow;

	Height = DefaultCellHeight * SelectionCellHeightMultiplier * ResScaling.Y;
	Width = Height * ScrollWidthRatio;

	Super.DrawSelectionBG(YPos);

	// Draw selected part text
	Canvas.SetPos(Width*PartSelectionPadding.X, YPos+Height*PartSelectionPadding.Y);
	Canvas.DrawColor=PartSelectionTextColor;
	DrawStringToFit(CurrentPartSelectionStr,Width*PartSelectionPadding.X,YPos+Height*PartSelectionPadding.Y,YPos+Height-(Height*PartSelectionPadding.Y));

	// Draw left/right selection arrows
	ArrowHeight = LeftRightArrowHeightMultiplier*Height;
	ArrowWidth = ArrowHeight*LeftRightArrowWidthRatio;

	LeftArrowBounds[0]=Width-ArrowWidth*2-Width*LeftRightArrowOffset.X;
	LeftArrowBounds[1]=YPos+(Height-ArrowHeight)/2+Height*LeftRightArrowOffset.Y;
	LeftArrowBounds[2]=LeftArrowBounds[0]+ArrowWidth;
	LeftArrowBounds[3]=LeftArrowBounds[1]+ArrowHeight;
	bOverArrow=CursorCheck(LeftArrowBounds[0], LeftArrowBounds[1], LeftArrowBounds[2], LeftArrowBounds[3]);
	DrawSelectionArrow(LeftArrowBounds[0], LeftArrowBounds[1], ArrowWidth, ArrowHeight,147,191,121,59,bOverArrow, bLeftArrowPressed);

	RightArrowBounds[0]=Width-ArrowWidth-Width*LeftRightArrowOffset.X;
	RightArrowBounds[1]=YPos+(Height-ArrowHeight)/2+Height*LeftRightArrowOffset.Y;
	RightArrowBounds[2]=RightArrowBounds[0]+ArrowWidth;
	RightArrowBounds[3]=RightArrowBounds[1]+ArrowHeight;
	bOverArrow=CursorCheck(RightArrowBounds[0], RightArrowBounds[1], RightArrowBounds[2], RightArrowBounds[3]);
	DrawSelectionArrow(RightArrowBounds[0], RightArrowBounds[1], ArrowWidth, ArrowHeight,268,191,121,59, bOverArrow, bRightArrowPressed);
}

/** Draws one of the left/right selection arrows. */
function DrawSelectionArrow(float DrawX, float DrawY, float DrawW, float DrawH, float TexU, float TexV, float TexUL, float TexVL, bool bOver, bool bPressed)
{
	if (bPressed)
	{
		Canvas.DrawColor=ArrowColorPressed;
	}
	else if(bOver)
	{
		Canvas.DrawColor=ArrowColorMouseOver;
	}
	else
	{
		Canvas.DrawColor=ArrowColorNormal;
	}

	Canvas.SetPos(DrawX,DrawY);
	Canvas.DrawTile(LeftRightArrowImage, DrawW, DrawH, TexU, TexV, TexUL, TexVL);
}


DefaultProperties
{
	ScrollWidthRatio=3;
	PartSelectionTextColor=(R=255,G=255,B=255,A=255)
	CurrentPartSelectionStr="01"
	PartSelectionPadding=(X=0.05,Y=0.25);

	ArrowColorNormal=(R=224,G=224,B=124,A=192)
	ArrowColorMouseOver=(R=240,G=240,B=189,A=255)
	ArrowColorPressed=(R=255,G=255,B=255,A=255)

	LeftRightArrowOffset=(X=0.05,Y=0.1);
	LeftRightArrowHeightMultiplier=0.5;
	LeftRightArrowWidthRatio=1.5;
	LeftRightArrowImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseC';

	ListEnumMap(7)=PART_Boots;
	ListEnumMap(6)=PART_Thighs;
	ListEnumMap(5)=PART_Arms;
	ListEnumMap(4)=PART_ShoPad;
	ListEnumMap(3)=PART_Torso;
	ListEnumMap(2)=PART_Goggles;
	ListEnumMap(1)=PART_Helmet;
	ListEnumMap(0)=PART_Facemask;

	PartCellTags(PART_ShoPad)="ShoulderPads"
	PartCellTags(PART_Arms)="Arms"
	PartCellTags(PART_Boots)="Boots"
	PartCellTags(PART_Thighs)="Thighs"
	PartCellTags(PART_Torso)="Torsos"
	PartCellTags(PART_Facemask)="Facemasks"
	PartCellTags(PART_Helmet)="Helmets"
	PartCellTags(PART_Goggles)="Goggles"

	bHideScrollArrows=true
	bHotTracking=false
}
