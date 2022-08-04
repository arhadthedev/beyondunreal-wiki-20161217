class EWindowListBoxItem expands UWindowListBoxItem;

var string					Value;
var string					Value2;		// A second, non-displayed value
var int						SortWeight;

function int Compare(UWindowList T, UWindowList B)
{
	local EWindowListBoxItem TI, BI;
	local string TS, BS;
	
	TI = EWindowListBoxItem(T);
	BI = EWindowListBoxItem(B);
	
	if ( TI.SortWeight == BI.SortWeight ) {
		TS = Caps(TI.Value);
		BS = Caps(BI.Value);
		
		if ( TS == BS )
			return 0;
		
		if ( TS < BS )
			return -1;
		
		return 1;
	}
	else
		return TI.SortWeight - BI.SortWeight;
}

defaultproperties
{
}
