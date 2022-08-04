/**
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 *
 * Advanced video settings for the PC.
 */
class UTUIFrontEnd_SettingsVideoAdvanced extends UTUIFrontEnd
	native(UIFrontEnd);

/** Possible settings enum. */
enum EPossibleVideoSettings
{
	PVS_ScreenPercentage,
	PVS_TextureDetail,
	PVS_WorldDetail,
	PVS_FXDetail,
	PVS_DecalQuality,
	PVS_LightingQuality,
	PVS_ShadowQuality,
	PVS_PostProcessQuality,
	PVS_VSyncValue,
	PVS_SmoothFramerate,
	PVS_PlayerFOV,
	PVS_EnableMotionBlur,

	PVS_FirstDirectWorldDetailSetting,
		PVS_StaticDecals,
		PVS_DynamicDecals,
		PVS_DynamicLights,
		PVS_DynamicShadows,
		PVS_LightEnvironmentShadows,
		PVS_CompositeDynamicLights,
		PVS_DirectionalLightmaps,
		PVS_DepthOfField,
		PVS_Bloom,
		PVS_QualityBloom,
		PVS_Distortion,
		PVS_DropParticleDistortion,
		PVS_SpeedTreeLeaves,
		PVS_SpeedTreeFronds,
		PVS_DetailMode,
		PVS_LensFlares,
		PVS_FogVolumes,
		PVS_FloatingPointRenderTargets,
		PVS_OneFrameThreadLag,
		PVS_SkeletalMeshLODBias,
		PVS_HighPolyChars,
		PVS_ParticleLODBias,
		PVS_ShadowFilterQualityBias,
	PVS_LastDirectWorldDetailSetting,
};

/** Array of setting types to widget names. */
var transient array<name>	SettingWidgetMapping;

/** Pointer to the options page. */
var transient UTUITabPage_Options	OptionsPage;

/** Reference to the messagebox scene. */
var transient UTUIScene_MessageBox MessageBoxReference;

/** Has the user customized any settings? */
var transient bool bCustomizedSettings;

/** Do we need to update the captions next tick? */
var transient bool bNeedsCaptionRefresh;

/** If any properties are modified which require a restart, this will trigger the restart warning dialog when the user clicks 'apply' */
var transient bool bRequireRestartWarning;




/**
 * Sets the value of the video setting.
 *
 * @param Setting	Setting to set the value of
 * @param Value		New value for the setting
 */
native function SetVideoSettingValue(EPossibleVideoSettings Setting, int Value);

/**
 * Sets the value of multiple video settings at once.
 *
 * @param Setting	Array of settings to set the value of
 * @param Value		New values for teh settings
 */
native function SetVideoSettingValueArray(array<EPossibleVideoSettings> Settings, array<int> Values);


/**
 * @param	Setting		Setting to get the value of
 * @return				Returns the current value of the specified setting.
 */
native function int GetVideoSettingValue(EPossibleVideoSettings Setting);

native function ResetToDefaults();

/** Post initialize callback. */
event PostInitialize()
{
	local int SettingIdx;
	local int WidgetIdx;
	local int CurrentValue;

	Super.PostInitialize();

	// Find widget references
	OptionsPage = UTUITabPage_Options(FindChild('pnlOptions', true));
	OptionsPage.OnAcceptOptions=OnAcceptOptions;
	OptionsPage.OnOptionChanged=None;

	// Set all of the default values
	for(SettingIdx=0; SettingIdx<SettingWidgetMapping.length; SettingIdx++)
	{
		CurrentValue = GetVideoSettingValue(EPossibleVideoSettings(SettingIdx));
		SetDataStoreStringValue("<Registry:" $ SettingWidgetMapping[SettingIdx] $ ">", string(CurrentValue));

		// Refresh the widget
		WidgetIdx = OptionsPage.OptionList.GetObjectInfoIndexFromName(SettingWidgetMapping[SettingIdx]);
		if (WidgetIdx != -1)
		{
			UIDataStoreSubscriber(OptionsPage.OptionList.GeneratedObjects[WidgetIdx].OptionObj).RefreshSubscriberValue();
		}
	}

	OptionsPage.OnOptionChanged=OnOptionChanged;

	// nothing has been customized yet
	bCustomizedSettings = false;

	UpdateSpecialCaptions();
}


/** Callback to setup the buttonbar for this scene. */
function SetupButtonBar()
{
	ButtonBar.Clear();
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Back>", OnButtonBar_Back);
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Accept>", OnButtonBar_Accept);
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.ResetToDefaults>", OnButtonBar_ResetToDefaults);
}

function bool OnButtonBar_ResetToDefaults(UIScreenObject InButton, int InPlayerIndex)
{
	OnResetToDefaults();

	return true;
}

/** Reset to defaults callback, resets all of the profile options in this widget to their default values. */
function OnResetToDefaults()
{
	local array<string> MessageBoxOptions;

	MessageBoxReference = GetMessageBoxScene();

	if(MessageBoxReference != none)
	{
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.ResetToDefaultAccept>");
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.Cancel>");

		MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
		MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.ResetToDefaults_Message>", "<Strings:UTGameUI.MessageBox.ResetToDefaults_Title>", OnResetToDefaults_Confirm, 1);
	}
}

/**
 * Callback for the reset to defaults confirmation dialog box.
 *
 * @param SelectionIdx	Selected item
 * @param PlayerIndex	Index of player that performed the action.
 */
function OnResetToDefaults_Confirm(UTUIScene_MessageBox MessageBox, int SelectionIdx, int PlayerIndex)
{
	if(SelectionIdx==0)
	{
		`log("Reseting to defaults, wabam!");
		ResetToDefaults();
		CloseScene(self);
	}
	else
	{
		OptionsPage.OptionList.SetFocus(none);
	}
}

/** Called when one of our options changes. */
function OnOptionChanged(UIScreenObject InObject, name OptionName, int PlayerIndex)
{
	local int SettingIdx;

	// Find the setting idx for this widget
	SettingIdx = SettingWidgetMapping.Find(OptionName);

	// if we customize any of the world detail settings, mark the world detail as custom
	if (SettingIdx >= PVS_FirstDirectWorldDetailSetting && SettingIdx <= PVS_LastDirectWorldDetailSetting)
	{
		bCustomizedSettings = true;

		if (SettingIdx == PVS_DetailMode || SettingIdx == PVS_SkeletalMeshLODBias || 
			SettingIdx == PVS_ParticleLODBias || SettingIdx == PVS_ShadowFilterQualityBias)
		{
			UpdateSpecialCaptions();
		}
	}

	if (SettingIdx == PVS_DirectionalLightmaps)
		bRequireRestartWarning = True;
}

/** Callback for when the user wants to exit this screen. */
function OnBack()
{
	CloseScene(self);
}

/** Callback for when the user wants to save their options. */
function OnAccept()
{
	local int SettingIdx;
	local int WidgetIdx;
	local int CurrentValue;
	local UIObject InObject;
	local array<EPossibleVideoSettings> SettingArray;
	local array<int> ValueArray;

	// if we customized any world settings, we need to mark the WorldDetail as custom
	if (bCustomizedSettings)
	{
		SettingArray.length = 1;
		SettingArray[0] = PVS_WorldDetail;
		ValueArray.length = 1;
		ValueArray[0] = 0;
	}

	// Save all out settings using the datastore value
	for(SettingIdx=0; SettingIdx<SettingWidgetMapping.length; SettingIdx++)
	{
		WidgetIdx = OptionsPage.OptionList.GetObjectInfoIndexFromName(SettingWidgetMapping[SettingIdx]);
		// don't set settings for removed options
		if (WidgetIdx == -1)
		{
			continue;
		}
		InObject = OptionsPage.OptionList.GeneratedObjects[WidgetIdx].OptionObj;

		// Force the widget to update its datastore value
		if(UISlider(InObject)!=None)
		{
			CurrentValue=UISlider(InObject).GetValue();
		}
		else if(UICheckbox(InObject)!=None)
		{
			CurrentValue=UICheckbox(InObject).IsChecked() ? 1 : 0;
		}

		SettingArray.length=SettingArray.length+1;
		SettingArray[SettingArray.length-1]=EPossibleVideoSettings(SettingIdx);

		ValueArray.length=ValueArray.length+1;
		ValueArray[ValueArray.length-1]=CurrentValue;
	}

	// Save out the options
	SetVideoSettingValueArray(SettingArray, ValueArray);

	if (bRequireRestartWarning)
	{
		MessageBoxReference  = DisplayMessageBox("<Strings:UTGameUI.Errors.SomeChangesMayNotBeApplied_Message>", "<Strings:UTGameUI.Errors.SomeChangesMayNotBeApplied_Title>");
		MessageBoxReference.OnClosed = WarningMessage_Closed;
	}
	else
	{
		CloseScene(Self);
	}
}

/** Callback for when the warning message has closed. */
function WarningMessage_Closed()
{
	MessageBoxReference.OnClosed = None;
	MessageBoxReference = None;
	CloseScene(self);
}

/** Callback for when the user accepts the options list. */
function OnAcceptOptions(UIScreenObject InScreenObject, int InPlayerIndex)
{
	OnAccept();
}

/** Button bar callbacks. */
function bool OnButtonBar_Accept(UIScreenObject InButton, int PlayerIndex)
{
	OnAccept();

	return true;
}

function bool OnButtonBar_Back(UIScreenObject InButton, int PlayerIndex)
{
	OnBack();

	return true;
}


/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	// Let the binding list get first chance at the input because the user may be binding a key.
	bResult=OptionsPage.HandleInputKey(EventParms);

	if(bResult == false)
	{
		if(EventParms.EventType==IE_Released)
		{
			if(EventParms.InputKeyName=='XboxTypeS_B' || EventParms.InputKeyName=='Escape')
			{
				OnBack();
				bResult=true;
			}
		}
	}

	return bResult;
}

event SetPlayerFOV(int NewFOV)
{
	local UTPlayerController PC;
	PC = GetUTPlayerOwner();
	if ( PC != none )
	{
		PC.FOV(NewFOV);
	}
}

function string LevelToName(int Level)
{
	switch(Level)
	{
		case -1:
			return Localize("SliderValues","ExtraLow","UTGame");
		case 0:
			return Localize("SliderValues","Low","UTGame");
		case 1:
			return Localize("SliderValues","Mid","UTGame");
		case 2:
			return Localize("SliderValues","High","UTGame");
	};
}

function UpdateCaption(EPossibleVideoSettings Setting, int Offset)
{
	local int WidgetIdx;
	local int Level;

	WidgetIdx = OptionsPage.OptionList.GetObjectInfoIndexFromName(SettingWidgetMapping[Setting]);
	Level = UISlider(OptionsPage.OptionList.GeneratedObjects[WidgetIdx].OptionObj).GetValue();
	UISlider(OptionsPage.OptionList.GeneratedObjects[WidgetIdx].OptionObj).CaptionRenderComponent.SetValue(LevelToName(Level + Offset));
	UISlider(OptionsPage.OptionList.GeneratedObjects[WidgetIdx].OptionObj).CaptionRenderComponent.RefreshValue();
}

event PerformUpdateSpecialCaptions()
{
	UpdateCaption(PVS_DetailMode, 0);
	UpdateCaption(PVS_SkeletalMeshLODBias, 2);
	UpdateCaption(PVS_ParticleLODBias, 2);
	UpdateCaption(PVS_ShadowFilterQualityBias, 1);

}

function UpdateSpecialCaptions()
{
	bNeedsCaptionRefresh = true;
}


DefaultProperties
{
	SettingWidgetMapping(PVS_ScreenPercentage)="ScreenPercentage";
	SettingWidgetMapping(PVS_TextureDetail)="TextureDetail";
	SettingWidgetMapping(PVS_WorldDetail)="WorldDetail";
	SettingWidgetMapping(PVS_FXDetail)="FXDetail";
	SettingWidgetMapping(PVS_DecalQuality)="DecalQuality";
	SettingWidgetMapping(PVS_LightingQuality)="LightingQuality";
	SettingWidgetMapping(PVS_ShadowQuality)="ShadowQuality";
	SettingWidgetMapping(PVS_PostProcessQuality)="PostProcessQuality";
	SettingWidgetMapping(PVS_VSyncValue)="VSyncValue";
	SettingWidgetMapping(PVS_SmoothFramerate)="SmoothFramerate";
	SettingWidgetMapping(PVS_PlayerFOV)="PlayerFOV";
	SettingWidgetMapping(PVS_EnableMotionBlur)="EnableMotionBlur";
	SettingWidgetMapping(PVS_StaticDecals)="StaticDecals";
	SettingWidgetMapping(PVS_DynamicDecals)="DynamicDecals";
	SettingWidgetMapping(PVS_DynamicLights)="DynamicLights";
	SettingWidgetMapping(PVS_DynamicShadows)="DynamicShadows";
	SettingWidgetMapping(PVS_LightEnvironmentShadows)="LightEnvironmentShadows";
	SettingWidgetMapping(PVS_CompositeDynamicLights)="CompositeDynamicLights";
	SettingWidgetMapping(PVS_DirectionalLightmaps)="DirectionalLightmaps";
	SettingWidgetMapping(PVS_DepthOfField)="DepthOfField";
	SettingWidgetMapping(PVS_Bloom)="Bloom";
	SettingWidgetMapping(PVS_QualityBloom)="QualityBloom";
	SettingWidgetMapping(PVS_Distortion)="Distortion";
	SettingWidgetMapping(PVS_DropParticleDistortion)="DropParticleDistortion";
	SettingWidgetMapping(PVS_SpeedTreeLeaves)="SpeedTreeLeaves";
	SettingWidgetMapping(PVS_SpeedTreeFronds)="SpeedTreeFronds";
	SettingWidgetMapping(PVS_DetailMode)="DetailMode";
	SettingWidgetMapping(PVS_LensFlares)="LensFlares";
	SettingWidgetMapping(PVS_FogVolumes)="FogVolumes";
	SettingWidgetMapping(PVS_FloatingPointRenderTargets)="FloatingPointRenderTargets";
	SettingWidgetMapping(PVS_OneFrameThreadLag)="OneFrameThreadLag";
	SettingWidgetMapping(PVS_SkeletalMeshLODBias)="SkeletalMeshLODBias";
	SettingWidgetMapping(PVS_HighPolyChars)="HighPolyChars";
	SettingWidgetMapping(PVS_ParticleLODBias)="ParticleLODBias";
	SettingWidgetMapping(PVS_ShadowFilterQualityBias)="ShadowFilterQualityBias";

}
