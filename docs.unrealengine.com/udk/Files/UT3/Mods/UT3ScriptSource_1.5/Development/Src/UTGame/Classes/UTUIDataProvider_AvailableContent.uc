/**
 * Dataprovider that returns a row for each available content package.
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class UTUIDataProvider_AvailableContent extends UTUIDataProvider_SimpleElementProvider
	native(UI);



/** Struct that defines a content package */
struct native AvailableContentPackage
{
	var string ContentName;
	var string ContentFriendlyName;
	var string ContentDescription;
};
var transient array<AvailableContentPackage> Packages;

/** all of the achievements possible **/
struct native AchievementUIInfo
{
	var int ID;
	var bool bIsCollapsable; /** can this be expanded/collapsed **/
	var bool bIsExpanded;
	var string Name;
	var string HowTo;       /** markup for how to complete the award **/
	var string ProgressStr; /** markup for progress text **/
	var string IconStr;     /** markup for award icon **/
	var UIRoot.TextureCoordinates IconCoordinates;
};

struct native AchievementParent
{
	var AchievementUIInfo Achievement;
	var array<AchievementUIInfo> SubAchievements;
};

var transient array<AchievementParent> AllAchievements;
var transient array<Pointer> CurrentAchievementView {FAchievementUIInfo};

struct native GameModeMapping
{
	var int GameModeID;	 //ID from PBD for gamemode/achievement map
	var string GameModeClassName; //Classname of game mode
	var string MarkupStr; //Markup for new icons
};

var transient array<GameModeMapping> GameModeMappings;

struct native MutatorMapping
{
	var int MutatorBit;	//ID from PBD for mutator bit
	var string MutatorClassName;
};   

var transient array<MutatorMapping> MutatorMappings;

struct native VehicleMapping
{
	var int VehicleIndex;  //ID from PBD for vehicle index
	var string VehicleName;
};	

var transient array<VehicleMapping> VehicleMappings;

/** @return Returns the number of elements(rows) provided. */
native function int GetElementCount();

/** Parses a string for downloadable content. */
native function ParseContentString(string ContentStr);

/** Recreate the data store given an index to collapse */
native function ToggleCollapse(int CurrentIndex);

/**
* GetMatchingProfileId
*/
function int GetMatchingProfileId( UTProfileSettings Profile, int MatchingId )
{
	local int Index;

	for (Index=0; Index<Profile.AchievementsArray.Length; Index++)
	{
		if (Profile.AchievementsArray[Index].Id == MatchingId)
		{
			return Index;
		}
	}

	return 0;
}

/** Return the byte value within a dword **/
function int GetByteValue( int value, int index )
{
	local int ByteMask;
	local int MaskedValue;

	ByteMask = 255 << (index * 8);

	MaskedValue = value & ByteMask;
	MaskedValue = MaskedValue >> (index * 8);

	return MaskedValue;
}

/** Count the number of bits on a value **/
function int CountBits( int value )
{
	local int CheckValue;
	local int BitCount;

	CheckValue = value;

	BitCount = 0;

	while (CheckValue > 0)
	{
		if ( (CheckValue & 1) > 0 )
		{
			++BitCount;
		}
		CheckValue = CheckValue >> 1;
	}

	return BitCount;
}

function string ConvertSecondsToString(int NumSeconds) 
{
	local int NumMinutes;
	local string TimeString;

	NumSeconds = Clamp(NumSeconds, 0, 59 * 60 + 59); //Clamp to 59:59

	if (NumSeconds > 0)
	{
		//Slice up the seconds
		NumMinutes = NumSeconds / 60;
		NumSeconds = NumSeconds % 60;
	}

	if (NumMinutes < 10)
	{
	   TimeString = "0" $ NumMinutes;
	}
	else
	{
		TimeString = string(NumMinutes);
	}

	TimeString $= ":";

	if (NumSeconds < 10)
	{
		TimeString $= "0" $ NumSeconds;
	}
	else
	{
		TimeString $= string(NumSeconds);
	}

	return TimeString;
}

/**
* Setup the Achievement list that details the player's progress
*
* @param PC Current scene player controller
*/
function SetupAchievementList( UTPlayerController PC )
{
	local int i, j;
	local UTProfileSettings Profile;
	local OnlineSubsystem OnlineSub;
	local MapContextMapping AMapContext;
	local OnlinePlayerInterfaceEx PlayerIntEx;
	local int CurrentValue;
	local int UnlockType;
	local int UnlockCriteria;
	local int AchievementID;
	local AchievementUIInfo SubAchievement;
	local string ProgressText;
	local int ByteCurrentValue;
	local int ByteCriteriaValue;
	local int ByteIndex;
	local int ProfileArrayIndex;
	local int MixItUpIndex;

	//Stores of game and map info (expensive to get, so cache here)
	local array<UTUIResourceDataProvider> GameTypeProviderList;
	local array<UTUIResourceDataProvider> MapNameProviderList;
	local array<UTUIResourceDataProvider> MutatorProviderList;

	// Check the profile for the "uncleared" achievements and build a list
	// that displays the progress
	Profile = UTProfileSettings(PC.OnlinePlayerData.ProfileProvider.Profile);
	if ( Profile != none )
	{
		// Get the player interface
		OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
		if (OnlineSub != None)
		{
			PlayerIntEx = OnlineSub.PlayerInterfaceEx;
		}

		//Get a listing of all the gametypes
		class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_GameModeInfo', GameTypeProviderList);

		//Get a listing of all maps
		class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_MapInfo', MapNameProviderList);

		//Get a listing of all mutators
		class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'UTUIDataProvider_Mutator', MutatorProviderList);

		// Fill in the progress text for each achievement for this player
		for (i = 0; i < AllAchievements.length; i++)
		{
			AchievementID = AllAchievements[i].Achievement.ID;
			AllAchievements[i].Achievement.IconStr = "<Images:UI_Frontend_Art3.Icons.Achievements;";

			//Clear the dynamic elements of the list
			AllAchievements[i].Achievement.ProgressStr = "";
			AllAchievements[i].SubAchievements.length = 0;

			SubAchievement.IconCoordinates.U = 0;
			SubAchievement.IconCoordinates.UL = 0;
			SubAchievement.IconCoordinates.V = 0;
			SubAchievement.IconCoordinates.VL = 0;
			
			if (PlayerIntEx != None && PlayerIntEx.IsAchievementUnlocked(AchievementId) == true)
			{
				ProgressText = Localize( "MidGameMenu", "Completed", "UTGameUI" );
				AllAchievements[i].Achievement.bIsCollapsable = false;
			}
			else
			{
				ProfileArrayIndex = GetMatchingProfileId( Profile, AchievementId );

				UnlockType = Profile.AchievementsArray[ProfileArrayIndex].UnlockType;
				UnlockCriteria = Profile.AchievementsArray[ProfileArrayIndex].UnlockCriteria;

				if ( UnlockType == EUnlockType_Count )
				{
					// Get the current achievement value
					if (Profile.GetAchievementValue(AchievementID, CurrentValue) == FALSE)
					{
						// Failed... so just set it 0
						`log("Achievement"@AchievementID@"failed to find a value");
						CurrentValue = 0;
					}

					// These achievements are in seconds, so just convert the values to minutes
					if ( AchievementID == EUTA_POWERUP_SeeingRed ||
						AchievementID == EUTA_POWERUP_NeverSawItComing ||
						AchievementID == EUTA_POWERUP_SurvivalFittest ||
						AchievementID == EUTA_POWERUP_DeliveringTheHurt ||
						AchievementID == EUTA_UT3GOLD_TheSlowLane)
					{
						ProgressText = ConvertSecondsToString(Clamp(CurrentValue,0,UnlockCriteria)) $ " / " $ ConvertSecondsToString(UnlockCriteria);
					}
					else
					{
						// Build a string and add it the progress string array 
						if (UnlockCriteria == 1)
						{
							if (CurrentValue == 0)
							{
								ProgressText = Localize( "MidGameMenu", "Incomplete", "UTGameUI" );
							}
							else
							{
								ProgressText = Localize( "MidGameMenu", "Completed", "UTGameUI" );
							}
						}
						else
						{
							ProgressText = Clamp(CurrentValue,0,UnlockCriteria) $ " / " $ UnlockCriteria;
						}
					}
				}
				else if ( UnlockType == EUnlockType_Bitmask )
				{
					// These have to be handled specially because they are 64 bit fields.
					if ( AchievementID == EUTA_VERSUS_AroundTheWorld ||
						AchievementID == EUTA_EXPLORE_AllPowerups )
					{
						//Count up the maps (safer)
						UnlockCriteria = 0;
					    AllAchievements[i].Achievement.bIsCollapsable = true;

						for (j=0; j<class'UTGame'.default.MapContexts.length; j++)
						{
							AMapContext = class'UTGame'.default.MapContexts[j];
							if (AMapContext.bIsValidAchievementMap)
							{
								UnlockCriteria++;
								if (!GetMapNameAndMarkup(MapNameProviderList, AMapContext.MapName, SubAchievement.Name, SubAchievement.IconStr))
								{
									SubAchievement.Name = "[" $ Localize("Extras", "HiddenAchievement2", "UTGameUI") $ "]";
									SubAchievement.HowTo = Localize("Extras", "HiddenAchievement2Desc", "UTGameUI");
									// use the generic icon
									SubAchievement.IconStr = AllAchievements[i].Achievement.IconStr;
									SubAchievement.IconCoordinates = AllAchievements[i].Achievement.IconCoordinates;
								}
								else
								{
									SubAchievement.HowTo = AllAchievements[i].Achievement.HowTo;
								}

								SubAchievement.Name = "    " $ SubAchievement.Name;

								if (AchievementID == EUTA_EXPLORE_AllPowerups)
								{
									if (Profile.CheckLikeTheBackOfMyHandMap(AMapContext.MapContextId))
									{
										SubAchievement.ProgressStr = Localize( "MidGameMenu", "Completed", "UTGameUI" );
									}
									else
									{
										SubAchievement.ProgressStr = Localize( "MidGameMenu", "Incomplete", "UTGameUI" );
									}
								}
								else if (AchievementID == EUTA_VERSUS_AroundTheWorld)
								{
									if (Profile.CheckAroundTheWorldMap(AMapContext.MapContextId))
									{
										SubAchievement.ProgressStr = Localize( "MidGameMenu", "Completed", "UTGameUI" );
									}
									else
									{
										SubAchievement.ProgressStr = Localize( "MidGameMenu", "Incomplete", "UTGameUI" );
									}
								}

								AllAchievements[i].SubAchievements.AddItem(SubAchievement);
							}
						}

						ProgressText = Profile.CountBits64InAchivementValue(AchievementID)@"/"@UnlockCriteria;
					}
					else
					{
						// Get the current achievement value
						if ( Profile.GetAchievementValue(AchievementID, CurrentValue) == FALSE )
						{
							// Failed... so just set it 0
							CurrentValue = 0;
						}

						//Mask the current value against the unlock criteria so we don't count too much
						ProgressText = CountBits(CurrentValue & UnlockCriteria) $ " / " $ CountBits(UnlockCriteria);

						if (AchievementID == EUTA_IA_EveryGameMode || AchievementID == EUTA_VERSUS_GetItOn)
						{
							 AllAchievements[i].Achievement.bIsCollapsable = true;
							for (j=0; j<GameModeMappings.length; j++)
							{
								if (!GetGameModeName(GameTypeProviderList, GameModeMappings[j].GameModeClassName, SubAchievement.Name))
								{
									// if the game wasn't found, then it's a bonus pack map
									SubAchievement.Name = "[" $ Localize("Extras", "HiddenAchievement2", "UTGameUI") $ "]";
									SubAchievement.HowTo = Localize("Extras", "HiddenAchievement2Desc", "UTGameUI");

									// use the generic icon
									SubAchievement.IconStr = AllAchievements[i].Achievement.IconStr;
									SubAchievement.IconCoordinates = AllAchievements[i].Achievement.IconCoordinates;
								}
								else
								{
									SubAchievement.IconStr = GameModeMappings[j].MarkupStr;
									SubAchievement.HowTo = AllAchievements[i].Achievement.HowTo;
								}

								SubAchievement.Name = "    " $ SubAchievement.Name;

								//From PBD index in code
								if (AchievementID == EUTA_IA_EveryGameMode)
									MixItUpIndex = 1;
								else if (AchievementID == EUTA_VERSUS_GetItOn)
									MixItUpIndex = 2;

								if (Profile.CheckMixItUp(GameModeMappings[j].GameModeID, MixItUpIndex))
								{
									SubAchievement.ProgressStr = Localize( "MidGameMenu", "Completed", "UTGameUI" );
								}
								else
								{
									SubAchievement.ProgressStr = Localize( "MidGameMenu", "Incomplete", "UTGameUI" );
								}

								AllAchievements[i].SubAchievements.AddItem(SubAchievement);
							}
						}
						else if (AchievementID == EUTA_EXPLORE_EveryMutator)
						{
							AllAchievements[i].Achievement.bIsCollapsable = true;
							for (j=0; j<MutatorMappings.length; j++)
							{
								if (!GetMutatorName(MutatorProviderList, MutatorMappings[j].MutatorClassName, SubAchievement.Name))
								{
									// if the mutator wasn't found, then it's a bonus pack map
									SubAchievement.Name = "[" $ Localize("Extras", "HiddenAchievement2", "UTGameUI") $ "]";
									SubAchievement.HowTo = Localize("Extras", "HiddenAchievement2Desc", "UTGameUI");

									// use the generic icon
									SubAchievement.IconStr = AllAchievements[i].Achievement.IconStr;
									SubAchievement.IconCoordinates = AllAchievements[i].Achievement.IconCoordinates;
								}
								else
								{
									SubAchievement.IconStr = AllAchievements[i].Achievement.IconStr; 
									SubAchievement.HowTo = AllAchievements[i].Achievement.HowTo;
									SubAchievement.IconCoordinates = AllAchievements[i].Achievement.IconCoordinates;
								}

								SubAchievement.Name = "    " $ SubAchievement.Name;

								if (Profile.CheckSpiceOfLifeBitmask(MutatorMappings[j].MutatorBit))
								{
									SubAchievement.ProgressStr = Localize( "MidGameMenu", "Completed", "UTGameUI" );
								}
								else
								{
									SubAchievement.ProgressStr = Localize( "MidGameMenu", "Incomplete", "UTGameUI" );
								}

								AllAchievements[i].SubAchievements.AddItem(SubAchievement);
							}
						}
						else if (AchievementID == EUTA_VEHICLE_JackOfAllTrades)
						{
							AllAchievements[i].Achievement.bIsCollapsable = true;
							for (j=0; j<VehicleMappings.length; j++)
							{
								GetVehicleName(VehicleMappings[j].VehicleName, SubAchievement.Name);

								SubAchievement.Name = "    " $ SubAchievement.Name;
								SubAchievement.IconStr = AllAchievements[i].Achievement.IconStr;
								SubAchievement.HowTo = AllAchievements[i].Achievement.HowTo;
								SubAchievement.IconCoordinates = AllAchievements[i].Achievement.IconCoordinates;

								if (Profile.CheckJackOfAllTradesBitmask(VehicleMappings[j].VehicleIndex))
								{
									SubAchievement.ProgressStr = Localize( "MidGameMenu", "Completed", "UTGameUI" );
								}
								else
								{
									SubAchievement.ProgressStr = Localize( "MidGameMenu", "Incomplete", "UTGameUI" );
								}

								AllAchievements[i].SubAchievements.AddItem(SubAchievement);
							}
						}
					}
				}
				else if ( UnlockType == EUnlockType_ByteCount )
				{
					// Get the current achievement value
					if (Profile.GetAchievementValue(AchievementID, CurrentValue) == FALSE)
					{
						// Failed... so just set it 0
						CurrentValue = 0;
					}

					// Only display the least significant for 'Get A Life' Achievement
					if ( AchievementID == EUTA_VERSUS_GetALife )
					{
						ByteCriteriaValue = GetByteValue( UnlockCriteria, 0 );
						ByteCurrentValue = GetByteValue( CurrentValue, 0 );
						ProgressText = Clamp(ByteCurrentValue, 0, ByteCriteriaValue) $ " / " $ ByteCriteriaValue;					
					}
					// Run through the bytes and display any that are non-zero
					else
					{
						for (ByteIndex = 0; ByteIndex < 4; ByteIndex++)
						{
							ByteCriteriaValue = GetByteValue( UnlockCriteria, ByteIndex );

							if ( ByteCriteriaValue > 0 )
							{
								ByteCurrentValue = GetByteValue( CurrentValue, ByteIndex );
								if (ByteIndex == 0)
								{
									ProgressText = Clamp(ByteCurrentValue, 0, ByteCriteriaValue) $ " / " $ ByteCriteriaValue;
								}
								else
								{
									ProgressText = ProgressText $ ", ";
									ProgressText = ProgressText $ Clamp(ByteCurrentValue, 0, ByteCriteriaValue) $ " / " $ ByteCriteriaValue;
								}
							}
						}
					}
				}
			}

			AllAchievements[i].Achievement.ProgressStr = ProgressText;
		}

		//Populate the list the first time
		ToggleCollapse(-1);
	}
}

function bool GetMapNameAndMarkup(out array<UTUIResourceDataProvider> ProviderList, string MapName, out string NewMapName, out string Markup)
{
	local int i;
	local UTUIDataProvider_MapInfo MapProvider;

	for (i = 0; i < ProviderList.length; i++)
	{
		MapProvider = UTUIDataProvider_MapInfo(ProviderList[i]);
		if (MapName ~= MapProvider.MapName)
		{
			NewMapName = MapProvider.FriendlyName;
			Markup = MapProvider.PreviewImageMarkup;
			return true;
		}
	}   

	return false;
}

function bool GetGameModeName(out array<UTUIResourceDataProvider> ProviderList, string GameModeClassName, out string FriendlyName)
{
	local int i;
	local UTUIDataProvider_GameModeInfo GameProvider;

	FriendlyName = "";
	for (i = 0; i < ProviderList.length; i++)
	{						
		GameProvider = UTUIDataProvider_GameModeInfo(ProviderList[i]);
		if (InStr(GameProvider.GameMode, GameModeClassName) >= 0)
		{
			FriendlyName = GameProvider.FriendlyName;
			return true;
		}
	}

	return false;
}

function bool GetMutatorName(out array<UTUIResourceDataProvider> ProviderList, string MutatorClassName, out string FriendlyName)
{
	local int i;
	local UTUIDataProvider_Mutator MutProvider;

	for (i = 0; i < ProviderList.length; i++)
	{						
		MutProvider = UTUIDataProvider_Mutator(ProviderList[i]);
		if (InStr(MutProvider.ClassName, MutatorClassName) >= 0)
		{
			FriendlyName = MutProvider.FriendlyName;
			return true;
		}
	}

	return false;
}

function GetVehicleName(string VehicleClassName, out string FriendlyName)
{
	FriendlyName = Localize(VehicleClassName, "VehicleNameString", "UTGame");
}

defaultProperties
{

	/* HACK FOR ACHIEVEMENTS */
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_Chapter1,Name="<Strings:UTGameUI.AchievementNames.Name39>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo39>",IconCoordinates=(U=1,UL=64,V=1,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_SignTreaty,Name="<Strings:UTGameUI.AchievementNames.Name0>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo0>",IconCoordinates=(U=67,UL=64,V=1,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_LiandriMainframe,Name="<Strings:UTGameUI.AchievementNames.Name1>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo1>",IconCoordinates=(U=133,UL=64,V=1,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_ReachOmicron,Name="<Strings:UTGameUI.AchievementNames.Name2>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo2>",IconCoordinates=(U=199,UL=64,V=1,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_DefeatAkasha,Name="<Strings:UTGameUI.AchievementNames.Name37>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo37>",IconCoordinates=(U=265,UL=64,V=1,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_SignTreatyExpert,Name="<Strings:UTGameUI.AchievementNames.Name3>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo3>",IconCoordinates=(U=331,UL=64,V=1,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_LiandriMainframeExpert,Name="<Strings:UTGameUI.AchievementNames.Name4>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo4>",IconCoordinates=(U=397,UL=64,V=1,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_ReachOmicronExpert,Name="<Strings:UTGameUI.AchievementNames.Name5>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo5>",IconCoordinates=(U=1,UL=64,V=67,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_CAMPAIGN_DefeatAkashaExpert,Name="<Strings:UTGameUI.AchievementNames.Name36>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo36>",IconCoordinates=(U=67,UL=64,V=67,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_COOP_Complete1,Name="<Strings:UTGameUI.AchievementNames.Name6>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo6>",IconCoordinates=(U=133,UL=64,V=67,VL=65))))

	AllAchievements.Add((Achievement=(Id=EUTA_COOP_Complete10,Name="<Strings:UTGameUI.AchievementNames.Name7>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo7>",IconCoordinates=(U=199,UL=64,V=67,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_COOP_CompleteCampaign,Name="<Strings:UTGameUI.AchievementNames.Name8>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo8>",IconCoordinates=(U=265,UL=64,V=67,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_IA_EveryGameMode,bIsCollapsable=true,Name="<Strings:UTGameUI.AchievementNames.Name9>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo9>",IconCoordinates=(U=331,UL=64,V=67,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_IA_Untouchable,Name="<Strings:UTGameUI.AchievementNames.Name10>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo10>",IconCoordinates=(U=397,UL=64,V=67,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_EXPLORE_AllPowerups,bIsCollapsable=true,Name="<Strings:UTGameUI.AchievementNames.Name11>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo11>",IconCoordinates=(U=1,UL=64,V=133,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_EXPLORE_EveryMutator,bIsCollapsable=true,Name="<Strings:UTGameUI.AchievementNames.Name12>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo12>",IconCoordinates=(U=67,UL=64,V=133,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_BrainSurgeon,Name="<Strings:UTGameUI.AchievementNames.Name13>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo13>",IconCoordinates=(U=133,UL=64,V=133,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_DontTaseMeBro,Name="<Strings:UTGameUI.AchievementNames.Name14>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo14>",IconCoordinates=(U=199,UL=64,V=133,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_GooGod,Name="<Strings:UTGameUI.AchievementNames.Name15>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo15>",IconCoordinates=(U=265,UL=64,V=133,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_Pistolero,Name="<Strings:UTGameUI.AchievementNames.Name16>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo16>",IconCoordinates=(U=331,UL=64,V=133,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_ShardOMatic,Name="<Strings:UTGameUI.AchievementNames.Name40>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo40>",IconCoordinates=(U=397,UL=64,V=133,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_Hammerhead,Name="<Strings:UTGameUI.AchievementNames.Name17>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo17>",IconCoordinates=(U=1,UL=64,V=199,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_StrongestLink,Name="<Strings:UTGameUI.AchievementNames.Name18>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo18>",IconCoordinates=(U=67,UL=64,V=199,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_HaveANiceDay,Name="<Strings:UTGameUI.AchievementNames.Name19>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo19>",IconCoordinates=(U=133,UL=64,V=199,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_WEAPON_BigGameHunter,Name="<Strings:UTGameUI.AchievementNames.Name20>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo20>",IconCoordinates=(U=199,UL=64,V=199,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_VEHICLE_Armadillo,Name="<Strings:UTGameUI.AchievementNames.Name21>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo21>",IconCoordinates=(U=265,UL=64,V=199,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_VEHICLE_JackOfAllTrades,bIsCollapsable=true,Name="<Strings:UTGameUI.AchievementNames.Name22>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo22>",IconCoordinates=(U=331,UL=64,V=199,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_VEHICLE_Ace,Name="<Strings:UTGameUI.AchievementNames.Name23>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo23>",IconCoordinates=(U=397,UL=64,V=199,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_VEHICLE_Deathwish,Name="<Strings:UTGameUI.AchievementNames.Name24>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo24>",IconCoordinates=(U=1,UL=64,V=265,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_POWERUP_SeeingRed,Name="<Strings:UTGameUI.AchievementNames.Name41>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo41>",IconCoordinates=(U=67,UL=64,V=265,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_POWERUP_NeverSawItComing,Name="<Strings:UTGameUI.AchievementNames.Name42>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo42>",IconCoordinates=(U=133,UL=64,V=265,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_POWERUP_SurvivalFittest,Name="<Strings:UTGameUI.AchievementNames.Name43>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo43>",IconCoordinates=(U=199,UL=64,V=265,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_POWERUP_DeliveringTheHurt,Name="<Strings:UTGameUI.AchievementNames.Name44>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo44>",IconCoordinates=(U=265,UL=64,V=265,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_GAME_HatTrick,Name="<Strings:UTGameUI.AchievementNames.Name34>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo34>",IconCoordinates=(U=67,UL=64,V=331,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_GAME_BeingAHero,Name="<Strings:UTGameUI.AchievementNames.Name45>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo45>",IconCoordinates=(U=133,UL=64,V=331,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_GAME_FlagWaver,Name="<Strings:UTGameUI.AchievementNames.Name46>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo46>",IconCoordinates=(U=199,UL=64,V=331,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_GAME_30MinOrLess,Name="<Strings:UTGameUI.AchievementNames.Name47>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo47>",IconCoordinates=(U=265,UL=64,V=331,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_GAME_PaintTownRed,Name="<Strings:UTGameUI.AchievementNames.Name48>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo48>",IconCoordinates=(U=331,UL=64,V=331,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_GAME_ConnectTheDots,Name="<Strings:UTGameUI.AchievementNames.Name49>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo49>",IconCoordinates=(U=397,UL=64,V=331,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_HUMILIATION_SerialKiller,Name="<Strings:UTGameUI.AchievementNames.Name25>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo25>",IconCoordinates=(U=1,UL=64,V=397,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_HUMILIATION_SirSlaysALot,Name="<Strings:UTGameUI.AchievementNames.Name26>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo26>",IconCoordinates=(U=67,UL=64,V=397,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_HUMILIATION_KillJoy,Name="<Strings:UTGameUI.AchievementNames.Name27>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo27>",IconCoordinates=(U=133,UL=64,V=397,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_HUMILIATION_OffToAGoodStart,Name="<Strings:UTGameUI.AchievementNames.Name38>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo38>",IconCoordinates=(U=199,UL=64,V=397,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_VERSUS_GetItOn,bIsCollapsable=true,Name="<Strings:UTGameUI.AchievementNames.Name28>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo28>",IconCoordinates=(U=331,UL=64,V=265,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_VERSUS_AroundTheWorld,bIsCollapsable=true,Name="<Strings:UTGameUI.AchievementNames.Name29>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo29>",IconCoordinates=(U=397,UL=64,V=265,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_VERSUS_GetALife,Name="<Strings:UTGameUI.AchievementNames.Name30>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo30>",IconCoordinates=(U=1,UL=64,V=331,VL=65))))
	AllAchievements.Add((Achievement=(Id=EUTA_RANKED_BloodSweatTears,Name="<Strings:UTGameUI.AchievementNames.Name35>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo35>",IconCoordinates=(U=1,UL=64,V=463,VL=65))))

	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_CantBeTrusted,Name="<Strings:UTGameUI.AchievementNames.Name50>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo50>",IconCoordinates=(U=265,UL=64,V=463,VL=64)))
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_Avenger,Name="<Strings:UTGameUI.AchievementNames.Name51>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo51>",IconCoordinates=(U=67,UL=64,V=463,VL=64)))
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_BagOfBones,Name="<Strings:UTGameUI.AchievementNames.Name52>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo52>",IconCoordinates=(U=199,UL=64,V=529,VL=64)))
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_SkullCollector,Name="<Strings:UTGameUI.AchievementNames.Name53>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo53>",IconCoordinates=(U=331,UL=64,V=463,VL=64)))
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_Titanic,Name="<Strings:UTGameUI.AchievementNames.Name54>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo54>",IconCoordinates=(U=133,UL=64,V=463,VL=64)))    
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_Behemoth,Name="<Strings:UTGameUI.AchievementNames.Name55>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo55>",IconCoordinates=(U=397,UL=64,V=463,VL=64))) 
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_Unholy,Name="<Strings:UTGameUI.AchievementNames.Name56>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo56>",IconCoordinates=(U=199,UL=64,V=463,VL=64))) 
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_TheSlowLane,Name="<Strings:UTGameUI.AchievementNames.Name57>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo57>",IconCoordinates=(U=67,UL=64,V=529,VL=64)))
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_Eradication,Name="<Strings:UTGameUI.AchievementNames.Name58>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo58>",IconCoordinates=(U=1,UL=64,V=529,VL=64)))
	AllAchievements.Add((Achievement=(Id=EUTA_UT3GOLD_Arachnophobia,Name="<Strings:UTGameUI.AchievementNames.Name59>",HowTo="<Strings:UTGameUI.AchievementNames.HowTo59>",IconCoordinates=(U=133,UL=64,V=529,VL=64)))

	GameModeMappings.Add((GameModeClassName="UTDeathmatch",GameModeID=0,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=265,V=529,UL=64,VL=64>"))
	GameModeMappings.Add((GameModeClassName="UTTeamGame",GameModeID=1,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=331,V=529,UL=64,VL=64>"))
	GameModeMappings.Add((GameModeClassName="UTCTFGame",GameModeID=2,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=397,V=529,UL=64,VL=64>"))
	GameModeMappings.Add((GameModeClassName="UTVehicleCTFGame",GameModeID=3,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=1,V=595,UL=64,VL=64>"))
	GameModeMappings.Add((GameModeClassName="UTOnslaughtGame",GameModeID=4,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=67,V=595,UL=64,VL=64>"))
	GameModeMappings.Add((GameModeClassName="UTDuelGame",GameModeID=5,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=265,V=595,UL=64,VL=64>"))
	GameModeMappings.Add((GameModeClassName="UTBetrayalGame",GameModeID=6,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=199,V=595,UL=64,VL=64>"))
	GameModeMappings.Add((GameModeClassName="UTGreedGame",GameModeID=7,MarkupStr="<UI_FrontEnd_Art3.Icons.Achievements;U=133,V=595,UL=64,VL=64>"))

	MutatorMappings.Add((MutatorClassName="UTMutator_BigHead",MutatorBit=0))
	MutatorMappings.Add((MutatorClassName="UTMutator_FriendlyFire",MutatorBit=1))
	MutatorMappings.Add((MutatorClassName="UTMutator_Handicap",MutatorBit=2))
	MutatorMappings.Add((MutatorClassName="UTMutator_Instagib",MutatorBit=3))
	MutatorMappings.Add((MutatorClassName="UTMutator_LowGrav",MutatorBit=4))
	MutatorMappings.Add((MutatorClassName="UTMutator_NoOrbs",MutatorBit=5))
	MutatorMappings.Add((MutatorClassName="UTMutator_NoPowerups",MutatorBit=6))
 	MutatorMappings.Add((MutatorClassName="UTMutator_NoTranslocator",MutatorBit=7))
	MutatorMappings.Add((MutatorClassName="UTMutator_Slomo",MutatorBit=8))
	MutatorMappings.Add((MutatorClassName="UTMutator_SlowTimeKills",MutatorBit=9))
 	MutatorMappings.Add((MutatorClassName="UTMutator_SpeedFreak",MutatorBit=10))
	MutatorMappings.Add((MutatorClassName="UTMutator_SuperBerserk",MutatorBit=11))
	MutatorMappings.Add((MutatorClassName="UTMutator_WeaponReplacement",MutatorBit=12))
	MutatorMappings.Add((MutatorClassName="UTMutator_WeaponsRespawn",MutatorBit=13))
	MutatorMappings.Add((MutatorClassName="UTMutator_Survival",MutatorBit=14))
	MutatorMappings.Add((MutatorClassName="UTMutator_Hero",MutatorBit=15))

	VehicleMappings.Add((VehicleName="UTVehicle_Cicada", VehicleIndex=0))
	VehicleMappings.Add((VehicleName="UTVehicle_DarkWalker", VehicleIndex=1))
	VehicleMappings.Add((VehicleName="UTVehicle_Fury", VehicleIndex=2)) 
	VehicleMappings.Add((VehicleName="UTVehicle_Goliath", VehicleIndex=3)) 
	VehicleMappings.Add((VehicleName="UTVehicle_HellBender", VehicleIndex=4))
	VehicleMappings.Add((VehicleName="UTVehicle_Leviathan", VehicleIndex=5))
	VehicleMappings.Add((VehicleName="UTVehicle_Manta", VehicleIndex=6)) 
	VehicleMappings.Add((VehicleName="UTVehicle_NightShade", VehicleIndex=7)) 
	VehicleMappings.Add((VehicleName="UTVehicle_Raptor", VehicleIndex=8)) 
	VehicleMappings.Add((VehicleName="UTVehicle_Scavenger", VehicleIndex=9)) 
	VehicleMappings.Add((VehicleName="UTVehicle_Scorpion", VehicleIndex=10)) 
	VehicleMappings.Add((VehicleName="UTVehicle_SPMA", VehicleIndex=11)) 
	VehicleMappings.Add((VehicleName="UTVehicle_StealthBender", VehicleIndex=12))
	VehicleMappings.Add((VehicleName="UTVehicle_Viper", VehicleIndex=13))
	VehicleMappings.Add((VehicleName="UTVehicle_Nemesis", VehicleIndex=14)) 
	VehicleMappings.Add((VehicleName="UTVehicle_Paladin", VehicleIndex=15)) 
}