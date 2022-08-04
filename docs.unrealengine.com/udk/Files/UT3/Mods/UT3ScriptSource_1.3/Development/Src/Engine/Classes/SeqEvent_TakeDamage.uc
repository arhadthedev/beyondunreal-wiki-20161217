/**
 * Activated when a certain amount of damage is taken.  Allows the designer to define how much and
 * which types of damage should be be required (or ignored).
 * Originator: the actor that was damaged
 * Instigator: the actor that did the damaging
 * Copyright 1998-2008 Epic Games, Inc. All Rights Reserved.
 */
class SeqEvent_TakeDamage extends SequenceEvent;

/** Damage must exceed this value to be counted */
var() float MinDamageAmount;

/** Total amount of damage to take before activating the event */
var() float DamageThreshold;

/** Types of damage that are counted */
var() array<class<DamageType> > DamageTypes<AllowAbstract>;

/** Types of damage that are ignored */
var() array<class<DamageType> > IgnoreDamageTypes<AllowAbstract>;

/** Current damage amount */
var float CurrentDamage;

/**
 * Searches DamageTypes[] for the specified damage type.
 *
 * Default case is to return true for no damage types listed.  This makes workflow a lot faster as you do not need to
 * add a damage type each time you use this event.
 */
final function bool IsValidDamageType(class<DamageType> inDamageType)
{
	local int Idx;
	local bool bValidDamageType;
	// if any damage types are specified, then verify the inDamageType is a child of at least one
	if (DamageTypes.Length > 0)
	{
		bValidDamageType = FALSE;
		for (Idx = 0; Idx < DamageTypes.Length; Idx++)
		{
			if (ClassIsChildOf(inDamageType,DamageTypes[Idx]))
			{
				bValidDamageType = TRUE;
				// no need to keep looking
				break;
			}
		}
		if (!bValidDamageType)
		{
			return FALSE;
		}
	}
	// check to see if the damage type is an ignored type
	if (IgnoreDamageTypes.Length > 0)
	{
		for (Idx = 0; Idx < IgnoreDamageTypes.Length; Idx++)
		{
			if (ClassIsChildOf(inDamageType,IgnoreDamageTypes[Idx]))
			{
				// should be ignored
				return FALSE;
			}
		}
	}
	return TRUE;
}

/**
 * Applies the damage and checks for activation of the event.
 */
final function HandleDamage(Actor inOriginator, Actor inInstigator, class<DamageType> inDamageType, int inAmount)
{
	local SeqVar_Float FloatVar;
	local bool bAlreadyActivatedThisTick;

	if (inOriginator != None &&
		bEnabled &&
		inAmount >= MinDamageAmount &&
		IsValidDamageType(inDamageType) &&
		(!bPlayerOnly ||
		 (inInstigator!= None && inInstigator.IsPlayerOwned())))
	{
		CurrentDamage += inAmount;

		if (CurrentDamage >= DamageThreshold)
		{
			bAlreadyActivatedThisTick = (bActive && ActivationTime ~= GetWorldInfo().TimeSeconds);
			if (CheckActivate(inOriginator,inInstigator,false))
			{
				// write to any variables that want to know the exact damage taken
				foreach LinkedVariables(class'SeqVar_Float', FloatVar, "Damage Taken")
				{
					//@hack carry over damage from multiple hits in the same tick
					//since Kismet doesn't currently support multiple activations in the same tick
					if (bAlreadyActivatedThisTick)
					{
						FloatVar.FloatValue += CurrentDamage;
					}
					else
					{
						FloatVar.FloatValue = CurrentDamage;
					}
				}
				// reset the damage counter on activation
				if (DamageThreshold <= 0.f)
				{
					CurrentDamage = 0.f;
				}
				else
				{
					CurrentDamage -= DamageThreshold;
				}
			}
		}
	}
}

function Reset()
{
	Super.Reset();

	CurrentDamage = 0.f;
}

defaultproperties
{
	ObjName="Take Damage"
	ObjCategory="Actor"
	ObjClassVersion=3

	DamageThreshold=100.f
	VariableLinks(1)=(ExpectedType=class'SeqVar_Float',LinkDesc="Damage Taken",bWriteable=true)
}
