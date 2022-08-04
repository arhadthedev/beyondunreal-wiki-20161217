class UTWeaponAwardReplicationInfo extends ReplicationInfo;

var repnotify UTPlayerReplicationInfo WeaponAwards[10];

replication
{
	if (bNetDirty)
		WeaponAwards;
}

simulated event ReplicatedEvent(name VarName)
{
	local int i;
	local UTPlayerReplicationInfo PRI;

	if ( VarName == 'WeaponAwards' )
	{
		for( i=0; i<WorldInfo.GRI.PRIArray.Length; i++ )
		{
			PRI = UTPlayerReplicationInfo( WorldInfo.GRI.PRIArray[i] );
			if( PRI != none )
			{
				PRI.WeaponAwardIndex = -1;
			}
		}
		for ( i=0; i<10; i++ )
		{
			if ( WeaponAwards[i] != None )
			{
				WeaponAwards[i].WeaponAwardIndex = i;
			}
		}
	}
}
	
defaultproperties
{
	LifeSpan=10.0
	TickGroup=TG_DuringAsyncWork

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    NetUpdateFrequency=1
}
