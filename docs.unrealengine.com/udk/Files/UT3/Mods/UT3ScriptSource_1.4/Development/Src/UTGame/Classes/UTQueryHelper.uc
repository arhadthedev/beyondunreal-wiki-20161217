/**
 * A central helper class for performing non-trivial server queries, such as those required by the 'Join IP' and
 * 'Add IP' buttons in the Join Game and Favourites tabs on the server browser.
 *
 * N.B. This extends Interaction to allow state code execution (Object subclasses don't normally support states)
 *
 * Copyright 2008 Epic Games, Inc. All Rights Reserved
 */
Class UTQueryHelper extends Interaction;

`include(UTOnlineConstants.uci)

enum EQueryError
{
	QE_None,
	QE_Uninitialized,
	QE_QueryInProgress,
	QE_NotLoggedIn,
	QE_InvalidIP,
	QE_InvalidResult,
	QE_JoinFailed,
	QE_Custom
};


var bool bInitialized;
var UTUIScene SceneRef;

var string SearchIP;
var string SearchPort;
var int CurSearchResultIdx; // Cached search result index; not saved as an 'OnlineGameSearchResult', as that is unsafe

var UTDataStore_GameSearchFind SearchDataStore;
var OnlineGameInterface GameInterface;

var bool bDisplayQueryMessage;
var bool bQueryInProgress;

var string JoinPassword;
var bool bJoinSpectate;
var string DirectConnectURL;

var EQueryError LastError;


// Always use this function to get a reference to a query helper (inputting any valid UTUIScene)
static final function UTQueryHelper GetQueryHelper(UTUIScene InScene)
{
	local UTQueryHelper QH;

	QH = UTQueryHelper(FindObject("Transient.QueryHelper", Class'UTQueryHelper'));

	// If there is no existing instance of this object class, create one
	if (QH == none)
		QH = new(none, "QueryHelper") Class'UTQueryHelper';

	if (InScene != none)
		QH.SceneRef = InScene;

	if (!QH.bInitialized)
		QH.Initialize();

	return QH;
}


// ***** Main query functions

// Searches for a single server matching the specified address (set the 'OnFindServerByIPComplete' delegate before calling)
// Returns 'True' if the query began successfully, and 'bQueryMessageBox' determines whether messages will be displayed while querying
function bool FindServerByIP(string Address, optional bool bQueryMessageBox=true)
{
	local int i;
	local array<string> IPTest;

	LastError = QE_None;

	if (bQueryInProgress)
	{
		LastError = QE_QueryInProgress;
		return False;
	}

	if (SearchDataStore == none)
	{
		LastError = QE_Uninitialized;
		return False;
	}

	if (Class'UIInteraction'.static.GetLoginStatus(SceneRef.GetBestPlayerIndex()) != LS_LoggedIn)
	{
		LastError = QE_NotLoggedIn;
		return False;
	}


	i = InStr(Address, ":");

	if (i != INDEX_None)
	{
		SearchIP = Left(Address, i);
		SearchPort = Mid(Address, i+1);
	}
	else
	{
		SearchIP = Address;
		SearchPort = "7777";
	}

	if (int(SearchPort) == 0)
		SearchPort = "7777";


	// Test that the IP is valid
	ParseStringIntoarray(SearchIP, IPTest, ".", True);

	if (IPTest.Length != 4)
	{
		LastError = QE_InvalidIP;
		return False;
	}


	// Set the search data store values
	SearchDataStore.SearchIP = SearchIP;
	SearchDataStore.SearchPort = SearchPort;

	// Kick off the search
	bDisplayQueryMessage = bQueryMessageBox;
	GotoState('FindIPQuery');


	return True;
}

// The result of the search initiated by the above function
delegate OnFindServerByIPComplete(OnlineGameSearchResult Result);


// Searches for and joins the server matching the specified address (parameters are mostly the same as 'FindServerByIP')
// If the server can't be found by Gamespy, then the user is given an option to connect directly, based upon 'FallbackURL'
// NOTE: When this is called, the query handler will automatically release itself
function JoinServerByIP(string Address, optional bool bQueryMessageBox=true, optional bool bSpectate, optional string FallbackURL)
{
	OnFindServerByIPComplete = JoinServerBySearchResult;
	bJoinSpectate = bSpectate;
	DirectConnectURL = FallbackURL;
	LastError = QE_None;

	if (!FindServerByIP(Address, bQueryMessageBox) && bQueryMessageBox)
		DisplayFindIPError(True);
}

// Joins the server specified by the 'Result' parameter
// NOTE: When this is called, the query handler will automatically release itself
function JoinServerBySearchResult(OnlineGameSearchResult Result)
{
	OnFindServerByIPComplete = none;

	if (Result.GameSettings != none)
	{
		GotoState('JoinServerQuery');
		JoinServerBySearchResult(Result);
	}
	else
	{
		if (bDisplayQueryMessage)
			DisplayFindIPError(True);
		else
			Release();
	}
}


// ***** Query states

// State function stubs (implemented within states)
function bool OnSetupQueryFilters(OnlineGameSearch Search);	// Use this to initiate any master-server/clientside filters before searching
function OnFindOnlineGamesUpdate(bool bWasSuccessful);		// Use this to receive regular updates during the query
function OnFindOnlineGamesComplete(bool bWasSuccessful);	// Use this for notification of when the query has finished

function OnCancelFindOnlineGames(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex);
function OnCancelFindOnlineGamesComplete(bool bWasSuccessful);

function BeginJoin(OnlineGameSearchResult JoinTarget, optional string Password);	// Function for kicking off a join game query
function OnJoinGameComplete(bool bSuccessful);						// Internal join game handler

function OnPasswordDialogClosed(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex);


// Base query state, which handles the most generic query code
state QueryBase
{
	// Sets up filters/messages and kicks off the find server query
	function BeginState(name PreviousStateName)
	{
		local UTUIScene_MessageBox MessageBoxScene;

		// Reset error messages
		LastError = QE_None;

		GameInterface.AddFindOnlineGamesCompleteDelegate(OnFindOnlineGamesUpdate);
		SearchDataStore.OnSetupQueryFilters = OnSetupQueryFilters;

		if (bDisplayQueryMessage)
		{
			MessageBoxScene = SceneRef.GetMessageBoxScene();
			MessageBoxScene.DisplayCancelBox("<Strings:UTGameUI.MessageBox.QueryPending_Message>",, OnCancelFindOnlineGames);
		}

		bQueryInProgress = True;
		SearchDataStore.SubmitGameSearch(Class'UIInteraction'.static.GetPlayerControllerId(SceneRef.GetBestPlayerIndex()));
	}

	function OnFindOnlineGamesUpdate(bool bWasSuccessful)
	{
		local UTUIScene_MessageBox MessageBoxScene;

		if (!SearchDataStore.HasOutstandingQueries())
		{
			GameInterface.ClearFindOnlineGamesCompleteDelegate(OnFindOnlineGamesUpdate);

			// Close the 'querying' message box
			MessageBoxScene = SceneRef.GetMessageBoxScene();

			if (MessageBoxScene != none && MessageBoxScene.IsSceneActive(true))
				MessageBoxScene.Close();


			OnFindOnlineGamesComplete(bWasSuccessful);
		}
	}

	// Handles cancelling of the current search
	function OnCancelFindOnlineGames(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
	{
		bDisplayQueryMessage = False;

		if (SearchDataStore == none || SearchDataStore.HasOutstandingQueries())
		{
			GameInterface.AddCancelFindOnlineGamesCompleteDelegate(OnCancelFindOnlineGamesComplete);
			GameInterface.CancelFindOnlineGames();
		}
		else
		{
			OnCancelFindOnlineGamesComplete(True);
		}
	}

	function OnCancelFindOnlineGamesComplete(bool bWasSuccessful)
	{
		GameInterface.ClearCancelFindOnlineGamesCompleteDelegate(OnCancelFindOnlineGamesComplete);
		OnFindOnlineGamesComplete(False);
	}

	function EndState(name NextStateName)
	{
		bQueryInProgress = False;
	}
}


// Query for finding a server matching the specified IP and Port
state FindIPQuery extends QueryBase
{
	function bool OnSetupQueryFilters(OnlineGameSearch Search)
	{
		local RawOnlineGameSearchOrClause CurRawFilter;

		Search.bIsLANQuery = False;
		Search.bUsesArbitration = False;
		Search.ResetFilters();

		// Unfortunately, the IP can't be filtered by the master server; however, the port can, so use it to cut down on results
		CurRawFilter.OrParams.Length = 1;
		CurRawFilter.OrParams[0].EntryValue = "hostport";
		CurRawFilter.OrParams[0].ComparisonOperator = "=";
		CurRawFilter.OrParams[0].ComparedValue = "'"$SearchPort$"'";

		Search.RawFilterQueries.AddItem(CurRawFilter);


		return False;
	}

	function OnFindOnlineGamesComplete(bool bWasSuccessful)
	{
		local OnlineGameSearch GameSearch;
		local string Address;
		local int i;
		local OnlineGameSearchResult Result;

		// Iterate the results, looking for a server matching the specified port and IP
		GameSearch = SearchDataStore.GetCurrentGameSearch();
		Address = SearchIP$":"$SearchPort;

		for (i=0; i<GameSearch.Results.Length; ++i)
		{
			if (GameSearch.Results[i].GameSettings.ServerIP == Address)
			{
				Result = GameSearch.Results[i];
				CurSearchResultIdx = i;
				break;
			}
		}


		GotoState('');
		OnFindServerByIPComplete(Result);
	}
}

// State used to handle joining servers
state JoinServerQuery
{
	function JoinServerBySearchResult(OnlineGameSearchResult Result)
	{
		local int LockedValue;
		local UTUIScene_MessageBox MessageBoxScene;
		local UTUIScene_InputBox PasswordInputScene;

		// Reset any previous error messages
		LastError = QE_None;

		// If there is a message box scene fading out, force it to close immediately or it will take new message box scenes with it
		MessageBoxScene = SceneRef.GetMessageBoxScene();

		if (MessageBoxScene != none && MessageBoxScene.bHideOnNextTick)
			MessageBoxScene.OnHideComplete();


		// If the server is passworded, display the password message box; otherwise begin joining immediately
		if (Result.GameSettings.GetStringSettingValue(CONTEXT_LOCKEDSERVER, LockedValue) && LockedValue == CONTEXT_LOCKEDSERVER_YES)
		{
			PasswordInputScene = SceneRef.GetInputBoxScene();

			if (PasswordInputScene.bHideOnNextTick)
			{
				PasswordInputScene.OnHideComplete();
				PasswordInputScene = SceneRef.GetInputBoxScene();
			}

			PasswordInputScene.SetPasswordMode(True);
			PasswordInputScene.DisplayAcceptCancelBox("<Strings:UTGameUI.MessageBox.EnterServerPassword_Message>",
									"<Strings:UTGameUI.MessageBox.EnterServerPassword_Title>",
									OnPasswordDialogClosed);
		}
		else
		{
			BeginJoin(Result);
		}
	}

	// When the password box is closed, begin joining
	function OnPasswordDialogClosed(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
	{
		local UTUIScene_InputBox PasswordInputScene;
		local OnlineGameSearchResult CurResult;

		PasswordInputScene = UTUIScene_InputBox(MessageBox);

		if (PasswordInputScene != none && SelectedOption == 0)
		{
			// The current server result can't be safely stored in a non-local variable, so retrieve it based upon the stored index instead
			SearchDataStore.GetSearchResultFromIndex(CurSearchResultIdx, CurResult);

			BeginJoin(CurResult, Class'UTUIFrontEnd_HostGame'.static.StripInvalidPasswordCharacters(PasswordInputScene.GetValue()));

			// Instantly close the password input scene
			PasswordInputScene.OnHideComplete();
		}
		else
		{
			GotoState('');
		}
	}


	function BeginJoin(OnlineGameSearchResult JoinTarget, optional string Password)
	{
		if (JoinTarget.GameSettings == none)
		{
			LastError = QE_InvalidResult;
			DisplayFindIPError(True);

			return;
		}


		JoinPassword = Password;
		SceneRef.ConditionallyStartSplitscreen();

		GameInterface.AddJoinOnlineGameCompleteDelegate(OnJoinGameComplete);
		GameInterface.JoinOnlineGame(SceneRef.GetBestControllerId(), JoinTarget);
	}

	function OnJoinGameComplete(bool bSuccessful)
	{
		local string URL;
		local UTUIScene CurScene;

		GameInterface.ClearJoinOnlineGameCompleteDelegate(OnJoinGameComplete);

		if (bSuccessful)
		{
			GameInterface.GetResolvedConnectString(URL);


			URL = "Open"@URL;

			if (JoinPassword != "")
				URL $= "?Password="$JoinPassword;

			if (bJoinSpectate)
				URL $= "?SpectatorOnly=1";

			URL $= "?Name="$SceneRef.GetPlayerName();


			`log("UTQueryHelper::OnJoinGameComplete: - Join Game Successful, travelling:"@URL);

			// Locally reference 'SceneRef' before it gets cleared in EndState
			CurScene = SceneRef;
			GotoState('');

			CurScene.ConsoleCommand(URL);
		}
		else
		{
			LastError = QE_JoinFailed;
			DisplayFindIPError(True);
		}
	}

	// Since it should be assumed that the QueryHandler will be disused when attempting to join a game, clean up here
	function EndState(name NextStateName)
	{
		Release();
	}
}


// ***** Misc functions

// Initializes default values
function Initialize()
{
	local DataStoreClient DSClient;
	local OnlineSubsystem OS;

	bInitialized = True;
	LastError = QE_None;


	DSClient = Class'UIInteraction'.static.GetDataStoreClient();

	if (DSClient != none)
		SearchDataStore = UTDataStore_GameSearchFind(DSClient.FindDataStore('UTGameFind'));

	OS = Class'GameEngine'.static.GetOnlineSubsystem();

	if (OS != none)
		GameInterface = OS.GameInterface;
}

// Clear volatile values (object references etc.)
singular function Release()
{
	GotoState('');

	if (SearchDataStore != none)
		SearchDataStore.ClearAllSearchResults();

	SceneRef = none;
	SearchDataStore = none;
	GameInterface = none;

	CurSearchResultIdx = INDEX_None;
	bQueryInProgress = False;
	bInitialized = False;
	LastError = QE_None;
}


// Function used to display a message when Gamespy can't find a server, with the option to ask if the client wants to connect directly
function DisplayFindIPError(optional bool bAskForDirectConnect, optional string InDirectConnectURL, optional EQueryError ErrorType=LastError,
	optional string CustomError)
{
	local UTUIScene_MessageBox CurMsg;
	local string ErrorMessage;

	// Reset the last error, so that it doesn't get incorrectly shown again
	LastError = QE_None;

	if (SceneRef != none)
	{
		CurMsg = SceneRef.GetMessageBoxScene();

		if (CurMsg != none)
		{
			// Construct the initial error message
			switch (ErrorType)
			{
			case QE_None:
				ErrorMessage = Localize("MessageBox", "FindServerIPFail_Message", "UTGameUI");
				break;

			case QE_Uninitialized:
				ErrorMessage = Localize("MessageBox", "FindServerIPUninitialized_Message", "UTGameUI");
				break;

			case QE_QueryInProgress:
				ErrorMessage = Localize("MessageBox", "FindServerIPInProgress_Message", "UTGameUI");
				break;

			case QE_NotLoggedIn:
				ErrorMessage = Localize("MessageBox", "FindServerIPNotLoggedIn_Message", "UTGameUI");
				break;

			case QE_InvalidIP:
				ErrorMessage = Localize("MessageBox", "FindServerIPInvalid_Message", "UTGameUI");
				break;

			case QE_InvalidResult:
				ErrorMessage = Localize("MessageBox", "FindServerIPInvalidResult_Message", "UTGameUI");
				break;

			case QE_JoinFailed:
				ErrorMessage = Localize("MessageBox", "FindServerIPJoinFailed_Message", "UTGameUI");
				break;

			case QE_Custom:
				ErrorMessage = CustomError;
				break;
			}


			// Setup the message box
			if (CurMsg.bHideOnNextTick)
			{
				CurMsg.OnHideComplete();
				CurMsg = SceneRef.GetMessageBoxScene();
			}

			if (InDirectConnectURL != "")
				DirectConnectURL = InDirectConnectURL;


			if (bAskForDirectConnect && DirectConnectURL != "" && ErrorType != QE_InvalidIP)
			{
				ErrorMessage @= Localize("MessageBox", "FindServerIPFailConnect_Message", "UTGameUI");
				CurMsg.DisplayAcceptCancelBox(ErrorMessage, "<Strings:UTGameUI.MessageBox.FindServerIPFail_Title>",
								OnFindIPErrorDialog_Closed);
			}
			else
			{
				CurMsg.DisplayAcceptCancelBox(ErrorMessage, "<Strings:UTGameUI.MessageBox.FindServerIPFail_Title>");
			}
		}
	}
}

// Called when the client requests to connect directly
function OnFindIPErrorDialog_Closed(UTUIScene_MessageBox MessageBox, int SelectedOption, int PlayerIndex)
{
	local UTUIScene CurScene;

	if (SelectedOption == 0)
	{
		CurScene = SceneRef;
		Release();

		`log("Direct connect, URL"@DirectConnectURL);
		CurScene.ConsoleCommand("open"@DirectConnectURL);
	}
}


defaultproperties
{
	CurSearchResultIdx=INDEX_None
}
