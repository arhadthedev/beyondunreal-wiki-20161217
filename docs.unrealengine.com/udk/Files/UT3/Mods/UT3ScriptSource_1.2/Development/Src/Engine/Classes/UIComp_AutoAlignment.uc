/**
 * This component when present in a widget is supposed add ability to auto align its children widgets in a specified fashion
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIComp_AutoAlignment extends UIComponent
	within UIObject
	native(UIPrivate)
	HideCategories(Object)
	editinlinenew;
//
/// ** vertical auto alignment orientation setting * /
//enum EUIAutoAlignVertical
//{
//	UIAUTOALIGNV_None,
//	UIAUTOALIGNV_Top,
//	UIAUTOALIGNV_Center,
//	UIAUTOALIGNV_Bottom
//};
//
/// ** auto alignment orientation setting * /
//enum EUIAutoAlignHorizontal
//{
//	UIAUTOALIGNH_None,
//	UIAUTOALIGNH_Left,
//	UIAUTOALIGNH_Center,
//	UIAUTOALIGNH_Right
//};

/**
 * The settings which determines how this component will be aligning children widgets
 */

var()		EUIAlignment	HorzAlignment;
var()		EUIAlignment	VertAlignment;




DefaultProperties
{
	HorzAlignment=UIALIGN_Default
	VertAlignment=UIALIGN_Default
}
