//=============================================================================
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class FracturedStaticMeshActor extends Actor
	dependson(FracturedStaticMeshComponent)
	native(Mesh)
	placeable;

var() const editconst FracturedStaticMeshComponent	FracturedStaticMeshComponent;

/** Current health of each chunk */
var array<int> ChunkHealth;

/** Spawn one chunk of this mesh as its own Actor, with the supplied velocities. */
native function FracturedStaticMeshPart SpawnPart(int ChunkIndex, vector InitialVel, vector InitialAngVel);

/** Does the same as SpawnPart, but takes an array of chunks to make part of the new part. */
native function FracturedStaticMeshPart SpawnPartMulti(array<int> ChunkIndices, vector InitialVel, vector InitialAngVel);

/** Re-create physics state - needed if hiding parts would change physics collision of the object. */
native function RecreatePhysState();


event PostBeginPlay()
{
	super.PostBeginPlay();
	ResetHealth();
}

/** Used to init/reset health array. */
event ResetHealth()
{
	local int i;
	local FracturedStaticMesh FracMesh;

	FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);

	ChunkHealth.length = FracturedStaticMeshComponent.GetNumFragments();
	for(i=0; i<ChunkHealth.length; i++)
	{
		ChunkHealth[i] = FracMesh.FragmentHealthScale;
	}
}

/** Find all groups of chunks which are not connected to 'root' parts, and spawn them as new physics objects. */ 
function array<BYTE> BreakOffIsolatedIslands(array<BYTE> FragmentVis, array<int> IgnoreFrags, vector ChunkDir, array<FracturedStaticMeshPart> DisableCollWithPart)
{
	local FracturedStaticMeshPart BigPart;
	local array<FragmentGroup> FragGroups;
	local FragmentGroup FragGroup;
	local FracturedStaticMesh FracMesh;
	local vector ChunkAngVel;
	local int i, GroupIdx, FragIndex;

	FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);

	// Find disconnected islands - ignore the part we just hid.

	FragGroups = FracturedStaticMeshComponent.GetFragmentGroups(IgnoreFrags, FracMesh.MinConnectionSupportArea);

	// Iterate over each group..
	for(GroupIdx=0; GroupIdx<FragGroups.length; GroupIdx++)
	{
		FragGroup = FragGroups[GroupIdx];
		// If we are a fixed mesh - spawn off all groups which are not rooted
		// If we are dynamic piece, this actor becomes group 0, spawn all other groups as their own actors
		if(!FragGroup.bGroupIsRooted || (Physics == PHYS_RigidBody && GroupIdx > 0))
		{
			// .. if not, spawn this group as one whole part.
			ChunkAngVel = 0.25 * VRand() * FracMesh.ChunkAngVel;
			ChunkAngVel.Z *= 0.5f;
			// Spawn part- inherit owners velocity
			BigPart = SpawnPartMulti(FragGroup.FragmentIndices, (ChunkDir * FracMesh.ChunkLinVel) + Velocity, ChunkAngVel);
			// Disable collision between big chunk and both the little part that just broke off and the original mesh.
			for(i=0; i<DisableCollWithPart.length; i++)
			{
				BigPart.FracturedStaticMeshComponent.DisableRBCollisionWithSMC(DisableCollWithPart[i].FracturedStaticMeshComponent, TRUE);
			}
			BigPart.FracturedStaticMeshComponent.DisableRBCollisionWithSMC(FracturedStaticMeshComponent, TRUE);

			// Set all fragments in this group to be hidden.
			for(i=0; i<FragGroup.FragmentIndices.length; i++)
			{	
				FragIndex = FragGroup.FragmentIndices[i];
				FragmentVis[FragIndex] = 0;
			}

			// If composite (multiple chunks) - set rigid body impact stuff if desired
			if(FracMesh.bCompositeChunksExplodeOnImpact && (FragGroup.FragmentIndices.length > 1))
			{
				BigPart.FracturedStaticMeshComponent.SetNotifyRigidBodyCollision(TRUE);
				BigPart.FracturedStaticMeshComponent.ScriptRigidBodyCollisionThreshold = 0.1;
			}
		}
	}

	return FragmentVis;
}

/** TakeDamage will hide/spawn chunks when they get shot. */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local array<byte> FragmentVis;
	local vector ChunkDir, ChunkMiddle, LocalEffectPos;
	local FracturedStaticMesh FracMesh;
	local FracturedStaticMeshPart FracPart;
	local array<FracturedStaticMeshPart> NoCollParts;
	local int i, TotalVisible;
	local array<int> IgnoreFrags;
	local box ChunkBox;
	local rotator LocalEffectRot;

	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	// Ignore invalid damage type, hits to the core, to parts that are not destroyable, or parts which are already hidden (somehow)
	if( !DamageType.default.bCausesFracture || 
		HitInfo.Item == FracturedStaticMeshComponent.GetCoreFragmentIndex() || 
		!FracturedStaticMeshComponent.IsFragmentVisible(HitInfo.Item) ||
		!FracturedStaticMeshComponent.IsFragmentDestroyable(HitInfo.Item) )
	{
		return;
	}

	// Take away from chunks health
	ChunkHealth[HitInfo.Item] -= 1.0;
	//`log("FSM:TAKEDAMAGE"@HitInfo.Item@ChunkHealth[HitInfo.Item]);

	// If its hit zero health, hide part and spawn part.
	if(ChunkHealth[HitInfo.Item] <= 0)
	{
		FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);

		FragmentVis = FracturedStaticMeshComponent.GetVisibleFragments();

		// If physics object - ignore hits if you are the last part
		if(Physics == PHYS_RigidBody)
		{
			// Count up how many pieces are still left.
			for(i=0; i<FragmentVis.length; i++)
			{
				if(FragmentVis[i] != 0)
				{
					TotalVisible++;
				}
			}

			if(TotalVisible == 1)
			{
				return;
			}
		}

		FragmentVis[HitInfo.Item] = 0;

		// Start with average exterior normal of chunk
		ChunkDir = FracturedStaticMeshComponent.GetFragmentAverageExteriorNormal(HitInfo.Item);

		// If bad normal, or its pointing away from us, add in the shot momentum
		if((VSize(ChunkDir) < 0.01) || (Momentum Dot ChunkDir > -0.2))
		{
			ChunkDir + Normal(Momentum);
		}

		// Take out any downwards force
		ChunkDir.Z = Max(ChunkDir.Z, 0.0);
		// Reduce Z vel
		ChunkDir.Z /= FracMesh.ChunkLinHorizontalScale;
		// Normalize
		ChunkDir = Normal(ChunkDir);

		// Spawn part moving from center of mesh
		FracPart = SpawnPart(HitInfo.Item, (ChunkDir * FracMesh.ChunkLinVel) + Velocity, VRand() * FracMesh.ChunkAngVel);

		// Disable collision between spawned part and this mesh.
		FracPart.FracturedStaticMeshComponent.DisableRBCollisionWithSMC(FracturedStaticMeshComponent, TRUE);

		// Assign effect if there is one.
		if(FracMesh.FragmentDestroyEffect != None)
		{
			// Find translation/rotation of effect relative to big mesh origin.
			ChunkBox = FracturedStaticMeshComponent.GetFragmentBox(HitInfo.Item);
			ChunkMiddle = 0.5 * (ChunkBox.Min + ChunkBox.Max);

			LocalEffectPos = InverseTransformVector(FracturedStaticMeshComponent.LocalToWorld, ChunkMiddle);
			LocalEffectRot = rotator( InverseTransformNormal(FracturedStaticMeshComponent.LocalToWorld, ChunkDir) ); // Orient X down surface/spawn dir

			FracPart.ParticleComponent.SetTranslation( LocalEffectPos );
			FracPart.ParticleComponent.SetRotation( LocalEffectRot );
			FracPart.ParticleComponent.SetScale(FracMesh.FragmentDestroyEffectScale);
			FracPart.ParticleComponent.SetTemplate(FracMesh.FragmentDestroyEffect);

			FracPart.AttachComponent(FracPart.ParticleComponent);
		}

		// If no core - we have to look for un-rooted 'islands'
		if(FracturedStaticMeshComponent.GetCoreFragmentIndex() == INDEX_NONE)
		{
			IgnoreFrags[0] = HitInfo.Item;
			NoCollParts[0] = FracPart;
			FragmentVis = BreakOffIsolatedIslands(FragmentVis, IgnoreFrags, ChunkDir, NoCollParts);
		}

		// Right at the end, change fragment visibility
		FracturedStaticMeshComponent.SetVisibleFragments(FragmentVis);

		// If this is a physical part - reset physics state, to take notice of new hidden parts.
		if(Physics == PHYS_RigidBody)
		{
			RecreatePhysState();
		}
	}
}

/** 
 *	Break off all pieces in one go.
 */
event Explode()
{
	local array<byte> FragmentVis;
	local int i;
	local vector SpawnDir;
	local FracturedStaticMesh FracMesh;
	local FracturedStaticMeshPart FracPart;

	FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);

	// Iterate over all visible fragments spawning them
	FragmentVis = FracturedStaticMeshComponent.GetVisibleFragments();
	for(i=0; i<FragmentVis.length; i++)
	{
		// If this is a currently-visible, non-core fragment, spawn it off.
		if((FragmentVis[i] != 0) && (i != FracturedStaticMeshComponent.GetCoreFragmentIndex()))
		{
			SpawnDir = FracturedStaticMeshComponent.GetFragmentAverageExteriorNormal(i);
			// Spawn part- inherit this actors velocity
			FracPart = SpawnPart(i, (0.5 * SpawnDir * FracMesh.ChunkLinVel) + Velocity, 0.5 * VRand() * FracMesh.ChunkAngVel);
			FracPart.FracturedStaticMeshComponent.SetRBChannel(RBCC_Untitled1); // When something explodes we disallow collisions between all those parts.

			FragmentVis[i] = 0;
		}
	}

	// If dynamic, destroy original object
	if(Physics == PHYS_RigidBody)
	{
		Destroy();
	}
	// If not, just hide all parts.
	else
	{
		FracturedStaticMeshComponent.SetVisibleFragments(FragmentVis);
	}
}

/** Util to break off all parts within radius of the explosion */
event BreakOffPartsInRadius(vector Origin, float Radius, float RBStrength)
{
	local int i;
	local array<byte> FragmentVis;
	local array<int> IgnoreFrags;
	local array<FracturedStaticMeshPart> NoCollParts;
	local vector PartVel, FracCenter, ToFracCenter, ApproxExploDir;
	local FracturedStaticMesh FracMesh;
	local FracturedStaticMeshPart FracPart;
	local box FracBox;
	local float ChunkDist, VelScale;

	FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);

	// Iterate over visible, non-core meshes.
	FragmentVis = FracturedStaticMeshComponent.GetVisibleFragments();
	for(i=0; i<FragmentVis.length; i++)
	{
		if((FragmentVis[i] != 0) && (i != FracturedStaticMeshComponent.GetCoreFragmentIndex()))
		{
			FracBox = FracturedStaticMeshComponent.GetFragmentBox(i);
			FracCenter = 0.5 * (FracBox.Max + FracBox.Min);
			ToFracCenter = FracCenter - Origin;
			ChunkDist = VSize(ToFracCenter);
			if(ChunkDist < Radius)
			{
				//PartVel = FracturedStaticMeshComponent.GetFragmentAverageExteriorNormal(i);
				VelScale = 1.0 - (ChunkDist/Radius); // Reduce vel based on dist from explosion
				PartVel = (ToFracCenter/ChunkDist) * (RBStrength * VelScale); // Normalize dir vector and scale
				FracPart = SpawnPart(i, PartVel, VRand() * FracMesh.ChunkAngVel);

				FracPart.FracturedStaticMeshComponent.DisableRBCollisionWithSMC(FracturedStaticMeshComponent, TRUE);
				FracPart.FracturedStaticMeshComponent.SetRBChannel(RBCC_Untitled1); // disallow collisions between all those parts.

				NoCollParts[NoCollParts.length] = FracPart;
				IgnoreFrags[IgnoreFrags.length] = i;
				FragmentVis[i] = 0;
			}
		}
	}

	// Need to look for disconnected parts now - if no core.
	if(FracturedStaticMeshComponent.GetCoreFragmentIndex() == INDEX_NONE)
	{
		ApproxExploDir = Normal(FracturedStaticMeshComponent.Bounds.Origin - Origin);
		FragmentVis = BreakOffIsolatedIslands(FragmentVis, IgnoreFrags, ApproxExploDir, NoCollParts);
	}

	// Right at the end, change fragment visibility
	FracturedStaticMeshComponent.SetVisibleFragments(FragmentVis);

	// If this is a physical part - reset physics state, to take notice of new hidden parts.
	if(Physics == PHYS_RigidBody)
	{
		RecreatePhysState();
	}
}

defaultproperties
{
	bEdShouldSnap=TRUE
	bCollideActors=TRUE
	bBlockActors=TRUE
	bWorldGeometry=TRUE
	bGameRelevant=TRUE
	bRouteBeginPlayEvenIfStatic=FALSE
	bCollideWhenPlacing=FALSE
	bStatic=FALSE
	bMovable=FALSE
	bNoDelete=TRUE

	Begin Object Class=FracturedStaticMeshComponent Name=FracturedStaticMeshComponent0
		WireframeColor=(R=0,G=128,B=255,A=255)
		bAllowApproximateOcclusion=TRUE
		bCastDynamicShadow=FALSE
		bForceDirectLightMap=TRUE
		BlockRigidBody=TRUE
		bAcceptsDecals=FALSE
	End Object
	CollisionComponent=FracturedStaticMeshComponent0
	FracturedStaticMeshComponent=FracturedStaticMeshComponent0
	Components.Add(FracturedStaticMeshComponent0)
}
