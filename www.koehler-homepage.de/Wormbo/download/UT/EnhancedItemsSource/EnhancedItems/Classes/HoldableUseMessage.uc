class HoldableUseMessage extends PickupMessagePlus;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (128.0 / 768) * ClipY;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( OptionalObject != None ) {
		if ( Switch == 0 )
			return Class<HoldablePowerup>(OptionalObject).Default.UseText;
		else
			return Class<HoldablePowerup>(OptionalObject).Default.ReUseText;
	}
}

defaultproperties
{
     YPos=128.000000
}
