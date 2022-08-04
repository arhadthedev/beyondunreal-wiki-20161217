/**
 *
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */

class UTOnslaughtMapInfo extends UTMapInfo
	native(Onslaught)
	dependson(UTOnslaughtNodeObjective);

/** full information on a node link (similar to 'NodeLink' but also includes the source node) */
struct native FullNodeLink
{
	/** the node to link from */
	var() UTOnslaughtNodeObjective FromNode;
	/** the node to link to */
	var() UTOnslaughtNodeObjective ToNode;
};

/** links nodes to the team that should start out owning them */
struct native NodeStartingOwner
{
	var() UTOnslaughtNodeObjective Node;
	var() UTOnslaughtPowerCore StartingOwnerCore;
};

/** links nodes to the minimum number of players required for them to appear */
struct native NodeMinPlayerCount
{
	var() UTOnslaughtNodeObjective Node;
	var() int MinPlayers;
};

/** link setup information */
struct native LinkSetup
{
	/** name of the link setup */
	var() name SetupName;
	/** node links in this setup */
	var() array<FullNodeLink> NodeLinks;
	/** standalone nodes in this setup */
	var() array<UTOnslaughtNodeObjective> StandaloneNodes;
	/** nodes that start with an owner in this setup */
	var() array<NodeStartingOwner> NodeStartingOwners;
	/** nodes that have a minimum player count in this setup */
	var() array<NodeMinPlayerCount> NodeMinPlayers;
	/** Actors that should be hidden/deactivated when this link setup is active */
	var() array<Actor> DeactivatedActors;
	/** Hides/Deactivates all actors with the specified Group */
	var() array<name> DeactivatedGroups;
	/** Actors that should be visible/activated when this link setup is active */
	var() array<Actor> ActivatedActors;
	/** Shows/activates all actors with the specified Group */
	var() array<name> ActivatedGroups;
};

/** list of link setups available */
var() array<LinkSetup> LinkSetups;
/** the currently active link setup (used to reverse effects when changing the one to use) */
var protected name ActiveSetupName;

/** when set, actors disabled in the EditorPreviewSetup are hidden in the editor */
var() const editoronly bool bEnableEditorPreview;
/** link setup to use for editor preview and in PIE */
var() const editoronly name EditorPreviewSetup;

/** exports a link setup to an .ini file (for creating custom setups) */
var() const transient bool bSaveSetupToIni;




/** saves the passed in setup to an .ini file of the same name as the current map */
native final function SaveLinkSetupToIni(name SetupName);

/** sets the given actor as active or inactive */
function SetActorActive(Actor TheActor, bool bActive)
{
	if (UTVehicleFactory(TheActor) != None)
	{
		UTVehicleFactory(TheActor).bDisabled = !bActive;
	}
	else if (UTOnslaughtFlagBase(TheActor) != None)
	{
		UTOnslaughtFlagBase(TheActor).SetEnabled(bActive);
	}
	else
	{
		// if we don't have specific handling, just set visibility and collision
		TheActor.SetHidden(!bActive);
		TheActor.SetCollision(bActive);
	}
}

/** applies the given link setup, if it exists, removing any currently active one first
 * @param SetupName the link setup to use
 */
function ApplyLinkSetup(name SetupName)
{
	local int i, j, k;
	local UTOnslaughtNodeObjective Node;
	local bool bFoundEmptySpace;
	local WorldInfo WI;
	local Actor A;
	local UTCustomLinkSetup CustomSetup;

	// first remove any previous link setup
	RemoveLinkSetup();

	// find the new one and apply it
	i = LinkSetups.Find('SetupName', SetupName);
	if (i == INDEX_NONE)
	{
		// try to load a custom one
		CustomSetup = class'UTCustomLinkSetup'.static.LoadLinkSetup(SetupName);
		if (CustomSetup != None)
		{
			i = LinkSetups.length;
			LinkSetups[i] = CustomSetup.TheLinkSetup;
		}
	}

	if (i != INDEX_NONE)
	{
		`Log("Activating link setup" @ SetupName);

		WI = WorldInfo(Outer);

		// server replicates links, don't overwrite them on clients
		if (WI.NetMode != NM_Client)
		{
			// find all nodes and kill all their links/starting owners
			foreach WI.DynamicActors(class'UTOnslaughtNodeObjective', Node)
			{
				for (j = 0; j < ArrayCount(Node.LinkedNodes); j++)
				{
					Node.LinkedNodes[j] = None;
					Node.StartingOwnerCore = None;
				}
			}

			// apply new links
			for (j = 0; j < LinkSetups[i].NodeLinks.length; j++)
			{
				if (LinkSetups[i].NodeLinks[j].FromNode != None && LinkSetups[i].NodeLinks[j].ToNode != None)
				{
					bFoundEmptySpace = false;
					for (k = 0; k < ArrayCount(LinkSetups[i].NodeLinks[j].FromNode.LinkedNodes); k++)
					{
						if (LinkSetups[i].NodeLinks[j].FromNode.LinkedNodes[k] == None)
						{
							LinkSetups[i].NodeLinks[j].FromNode.LinkedNodes[k] = LinkSetups[i].NodeLinks[j].ToNode;
							bFoundEmptySpace = true;
							break;
						}
					}
					if (!bFoundEmptySpace)
					{
						`Warn("Link setup" @ SetupName $ ": Too many links specified for" @ LinkSetups[i].NodeLinks[j].FromNode);
					}
				}
			}
		}

		// apply standalone nodes
		foreach WI.DynamicActors(class'UTOnslaughtNodeObjective', Node)
		{
			Node.bStandalone = (LinkSetups[i].StandaloneNodes.Find(Node) != INDEX_NONE);
		}

		// apply new starting owner
		for (j = 0; j < LinkSetups[i].NodeStartingOwners.length; j++)
		{
			if (LinkSetups[i].NodeStartingOwners[j].Node != None)
			{
				LinkSetups[i].NodeStartingOwners[j].Node.StartingOwnerCore = LinkSetups[i].NodeStartingOwners[j].StartingOwnerCore;
			}
		}

		// apply min player count
		for (j = 0; j < LinkSetups[i].NodeMinPlayers.length; j++)
		{
			if (LinkSetups[i].NodeMinPlayers[j].Node != None)
			{
				LinkSetups[i].NodeMinPlayers[j].Node.MinPlayerCount = LinkSetups[i].NodeMinPlayers[j].MinPlayers;
			}
		}

		// deactivate actors
		for (j = 0; j < LinkSetups[i].DeactivatedActors.length; j++)
		{
			if (LinkSetups[i].DeactivatedActors[j] != None)
			{
				SetActorActive(LinkSetups[i].DeactivatedActors[j], false);
			}
		}

		// activate actors
		for (j = 0; j < LinkSetups[i].ActivatedActors.length; j++)
		{
			if (LinkSetups[i].ActivatedActors[j] != None)
			{
				SetActorActive(LinkSetups[i].ActivatedActors[j], true);
			}
		}

		// deactivate/activate groups
		foreach WI.AllActors(class'Actor', A)
		{
			if (A.Group != 'None')
			{
				if (LinkSetups[i].ActivatedGroups.Find(A.Group) != INDEX_NONE)
				{
					SetActorActive(A, true);
				}
				else if (LinkSetups[i].DeactivatedGroups.Find(A.Group) != INDEX_NONE)
				{
					SetActorActive(A, false);
				}
			}
		}

		ActiveSetupName = SetupName;

		if (WI.NetMode != NM_Client)
		{
			if (UTOnslaughtGRI(WI.GRI) != None)
			{
				UTOnslaughtGRI(WI.GRI).LinkSetupName = ActiveSetupName;
				WI.GRI.bForceNetUpdate = TRUE;
			}
		}
	}

	if (ActiveSetupName == 'None')
	{
		`Warn("Failed to find link setup" @ SetupName);
		// fall back to default, if possible
		if (LinkSetups.Find('SetupName', 'Default') != INDEX_NONE)
		{
			ApplyLinkSetup('Default');
		}
	}
}

/** removes the currently activated link setup */
function RemoveLinkSetup()
{
	local int i, j, k;
	local bool bFound;
	local WorldInfo WI;
	local Actor A;
	local UTOnslaughtNodeObjective Node;

	if (ActiveSetupName != 'None')
	{
		WI = WorldInfo(Outer);
		bFound = false;
		// find the old setup and remove it
		for (i = 0; i < LinkSetups.length; i++)
		{
			if (LinkSetups[i].SetupName == ActiveSetupName)
			{
				// server replicates links, don't overwrite them on clients
				if (WI.NetMode != NM_Client)
				{
					// remove links
					for (j = 0; j < LinkSetups[i].NodeLinks.length; j++)
					{
						if (LinkSetups[i].NodeLinks[j].FromNode != None && LinkSetups[i].NodeLinks[j].ToNode != None)
						{
							for (k = 0; k < ArrayCount(LinkSetups[i].NodeLinks[j].FromNode.LinkedNodes); k++)
							{
								if (LinkSetups[i].NodeLinks[j].FromNode.LinkedNodes[k] == LinkSetups[i].NodeLinks[j].ToNode)
								{
									LinkSetups[i].NodeLinks[j].FromNode.LinkedNodes[k] = None;
									break;
								}
							}
						}
					}
				}

				// clear standalone nodes
				foreach WI.DynamicActors(class'UTOnslaughtNodeObjective', Node)
				{
					Node.bStandalone = false;
				}

				// clear new starting owner
				for (j = 0; j < LinkSetups[i].NodeStartingOwners.length; j++)
				{
					if (LinkSetups[i].NodeStartingOwners[j].Node != None)
					{
						LinkSetups[i].NodeStartingOwners[j].Node.StartingOwnerCore = None;
					}
				}

				// clear min player count
				for (j = 0; j < LinkSetups[i].NodeMinPlayers.length; j++)
				{
					if (LinkSetups[i].NodeMinPlayers[j].Node != None)
					{
						LinkSetups[i].NodeMinPlayers[j].Node.MinPlayerCount = 0;
					}
				}

				// activate actors that were deactivated
				for (j = 0; j < LinkSetups[i].DeactivatedActors.length; j++)
				{
					if (LinkSetups[i].DeactivatedActors[j] != None)
					{
						SetActorActive(LinkSetups[i].DeactivatedActors[j], true);
					}
				}

				// disable actors that were activated
				for (j = 0; j < LinkSetups[i].ActivatedActors.length; j++)
				{
					if (LinkSetups[i].ActivatedActors[j] != None)
					{
						SetActorActive(LinkSetups[i].ActivatedActors[j], false);
					}
				}

				// deactivate/activate groups
				foreach WI.AllActors(class'Actor', A)
				{
					if (A.Group != 'None')
					{
						if (LinkSetups[i].ActivatedGroups.Find(A.Group) != INDEX_NONE)
						{
							SetActorActive(A, false);
						}
						else if (LinkSetups[i].DeactivatedGroups.Find(A.Group) != INDEX_NONE)
						{
							SetActorActive(A, true);
						}
					}
				}
			}

			bFound = true;
			break;
		}

		if (!bFound)
		{
			`Warn("Failed to remove link setup" @ ActiveSetupName @ "- could not be found in LinkSetups array");
		}

		ActiveSetupName = 'None';

		if (WI.NetMode != NM_Client)
		{
			if (UTOnslaughtGRI(WI.GRI) != None)
			{
				UTOnslaughtGRI(WI.GRI).LinkSetupName = ActiveSetupName;
				WI.GRI.bForceNetUpdate = TRUE;
			}
		}
	}
}

/** accessor for ActiveSetupName */
function name GetActiveSetupName()
{
	return ActiveSetupName;
}

defaultproperties
{
	LinkSetups[0]=(SetupName=Default)
	bBuildTranslocatorPaths=false
}
