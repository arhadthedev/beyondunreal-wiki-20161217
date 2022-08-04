class UTLinkGeneratorBlue extends UTLinkGenerator;

defaultproperties
{
	TeamNum=1
	LinkBeamSystem=ParticleSystem'FX_Gametypes.Effects.P_Link_Generator_Beam_Blue'
	LinkBeamColor=(R=64,G=64,B=255,A=255)
	BeamEndpointTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Blue'
	BeamTemplate=ParticleSystem'FX_Gametypes.Effects.P_Link_Generator_Beam_Blue'
	
	Begin Object Class=AudioComponent Name=AmbientSoundComponent
		bStopWhenOwnerDestroyed=true
		bShouldRemainActiveIfDropped=true
		SoundCue=SoundCue'A_Vehicle_Paladin.SoundCues.A_Vehicle_Paladin_ShieldAmbient'
		bAutoPlay=false
	End Object
	Components.Add(AmbientSoundComponent)

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	Begin Object Class=SkeletalMeshComponent Name=DeployableMesh
		Animations=MeshSequenceA
		AnimSets(0)=AnimSet'Pickups.Deployables.Anims.K_Deployables_Shield'
		Materials(0)=Material'PICKUPS_2.Deployables.Materials.M_Deployables_LinkStation'
		SkeletalMesh=SkeletalMesh'Pickups.Deployables.Mesh.SK_Deployables_Shield'
		CollideActors=false
		BlockActors=false
		BlockRigidBody=false
		Translation=(X=0,Y=0,Z=0.0)
		CastShadow=false
		bUseAsOccluder=FALSE
		bAcceptsDecals=FALSE
		LightEnvironment=MyLightEnvironment
	End Object
	Components.Add(DeployableMesh)
	CollisionComponent=DeployableMesh
	ShieldBase=DeployableMesh

	Begin Object Class=ParticleSystemComponent Name=VisualEffect
		Template=ParticleSystem'PICKUPS_2.Deployables.Effects.FX_Deployables_LinkStation_Discharge'
		bAutoActivate=false
	End Object
	Components.Add(VisualEffect)
	DischargeEffect=VisualEffect

	SpawnSound=SoundCue'A_Pickups_Deployables.ShieldGenerator.ShieldGenerator_OpenCue'
	DestroySound=SoundCue'A_Pickups_Deployables.ShieldGenerator.ShieldGenerator_CloseCue'
	WallHitTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_HIT'

	MyDamageType=class'UTDmgType_LinkGenerator'
}
