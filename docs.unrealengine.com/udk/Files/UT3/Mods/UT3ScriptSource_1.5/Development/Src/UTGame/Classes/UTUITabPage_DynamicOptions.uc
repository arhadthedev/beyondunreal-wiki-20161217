/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Version of UTUITabPage_Options which allows you to add options at runtime, but which doesn't used ata providers
 */
Class UTUITabPage_DynamicOptions extends UTUITabPage_Options;

var UTUIDynamicOptionList DynOptionList;


function PostInitialize()
{
	Super.PostInitialize();

	if (OptionList != none)
		DynOptionList = UTUIDynamicOptionList(OptionList);
}

/** Callback for when an option is focused, by default tries to set the description label for this tab page. */
function OnOptionList_OptionFocused(UIScreenObject InObject, UIDataProvider OptionProvider)
{
	local int i;

	i = DynOptionList.GetDynamicOptionIndexByObject(UIObject(InObject));

	if (i != INDEX_None)
		DescriptionLabel.SetDataStoreBinding(DynOptionList.DynamicOptionTemplates[i].Description);

	OnOptionFocused(InObject, none);
}

/** Appends a keyboard button to the buttonbar if we are on PS3 and a editbox option is selected. */
function ConditionallyAppendKeyboardButton(UTUIButtonBar ButtonBar)
{
	local UTUIScene UTScene;
	local int i;

	UTScene = UTUIScene(GetScene());

	if (UTScene != none)
	{
		if (ISconsole(CONSOLE_PS3) && DynOptionList != none && OptionList.CurrentIndex >= 0 && OptionList.GeneratedObjects.Length > OptionList.CurrentIndex)
		{
			i = DynOptionList.GetDynamicOptionIndexByName(OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionProviderName);

			if (i != INDEX_None && DynOptionList.DynamicOptionTemplates[i].OptionType == UTOT_EditBox)
				ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Keyboard>", OnButtonBar_ShowKeyboard);
		}
	}
}

/** Shows the onscreen keyboard using the currently selected option as a target. */
function OnShowKeyboard()
{
	local int i;
	local UIEditBox EditboxObject;
	local string FriendlyName;

	i = DynOptionList.GetDynamicOptionIndexByName(OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionProviderName);

	if (i != INDEX_None && DynOptionList.DynamicOptionTemplates[i].OptionType == UTOT_EditBox)
	{
		EditboxObject = UIEditBox(OptionList.GeneratedObjects[OptionList.CurrentIndex].OptionObj);
		FriendlyName = DynOptionList.DynamicOptionTemplates[i].FriendlyName;

		ShowKeyboard(EditboxObject, FriendlyName, FriendlyName, false, false, EditboxObject.GetValue(), EditboxObject.MaxCharacters);
	}
}

function OnResetToDefaults_Confirm(UTUIScene_MessageBox MessageBox, int SelectionIdx, int PlayerIndex);


