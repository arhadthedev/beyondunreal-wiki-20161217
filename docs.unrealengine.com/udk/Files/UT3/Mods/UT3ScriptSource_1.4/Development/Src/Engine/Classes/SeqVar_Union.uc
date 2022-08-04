/**
 * This class is used for linking variables of different types.  It contains a variable of each supported type and can
 * be connected to most types of variables links.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqVar_Union extends SequenceVariable
	native(inherit);



/**
 * The list of sequence variable classes that are supported by SeqVar_Union
 */
var		array<class<SequenceVariable> >	SupportedVariableClasses;

var()	int			IntValue;
var()	int			BoolValue;
var()	float		FloatValue;
var()	string		StringValue;
var()	Object		ObjectValue;

DefaultProperties
{
	ObjName="Union"
	ObjColor=(R=255,G=255,B=255,A=255)

	SupportedVariableClasses(0)=class'SeqVar_Bool'
	SupportedVariableClasses(1)=class'SeqVar_Int'
	SupportedVariableClasses(2)=class'SeqVar_Object'
	SupportedVariableClasses(3)=class'SeqVar_String'
	SupportedVariableClasses(4)=class'SeqVar_Float'
}
