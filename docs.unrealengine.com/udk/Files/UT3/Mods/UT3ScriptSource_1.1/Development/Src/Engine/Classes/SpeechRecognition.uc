/**
 * Copyright 2004-2007 Epic Games, Inc. All Rights Reserved.
 */
class SpeechRecognition extends Object
	native
	collapsecategories
	hidecategories(Object);

struct native RecognisableWord
{
	var()		int				Id;
	/** This is the reference word, which is returned upon recognition. e.g. "Loque".  Does not need to be unique. */
	var()		string			ReferenceWord;
	/** This is the word string that is passed into the recognition. e.g. "Loke" */
	var()		string			PhoneticWord;
};

struct native RecogVocabulary
{
	/** Arrays of words that can be recognised - note that words need an ID unique among the contents of all three arrays */
	var()		array<RecognisableWord>	WhoDictionary;
	var()		array<RecognisableWord>	WhatDictionary;
	var()		array<RecognisableWord>	WhereDictionary;
	
	/** Name of vocab file */
	var			string					VocabName;
	
	/** Cached processed vocabulary data */
	var			array<byte>				VocabData;
	
	/** Working copy of vocab data */
	var			array<byte>				WorkingVocabData;
	
	
};

struct native RecogUserData
{
	/** Bitfield of active vocabularies */
	var			int					ActiveVocabularies;
	/** Workspace for recognition data */
	var			array<byte>			UserData;
};

/** Language to recognise data in */
var()		string					Language<ToolTip=Use 3 letter code eg. INT, FRA, etc.>;
/** Threshhold below which the recognised word will be ignored */
var()		float					ConfidenceThreshhold<ToolTip=Values between 1 and 100.>;

/** Array of vocabularies that can be swapped in and out */
var()		array<RecogVocabulary>	Vocabularies;

/** Cached neural net data */
var			array<byte>				VoiceData;
/** Working copy of neural net data */
var			array<byte>				WorkingVoiceData;
/** Cached user data */
var			array<byte>				UserData;

/** Cached user data - max users */
var			array<RecogUserData>	InstanceData[4];

/** Whether this object has been altered */
var duplicatetransient transient	bool	bDirty;
/** Whether the object was successfully initialised or not */
var duplicatetransient transient	bool	bInitialised;

/** Cached pointers to Fonix data */
var	duplicatetransient native const pointer	FnxVoiceData;



defaultproperties
{
	Language="INT"
	ConfidenceThreshhold=50
}
