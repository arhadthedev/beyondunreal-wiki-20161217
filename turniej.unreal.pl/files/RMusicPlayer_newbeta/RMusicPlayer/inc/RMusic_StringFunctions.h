/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Add slashes
 */
FString AddSlashes(FString Text)
{
	guard(AddSlashes);
	int i;
	FString InputT;
	FString Replace = FString(TEXT("/"));
	FString With = FString(TEXT("//"));

	InputT = Text;
	Text = TEXT("");
	i = InputT.InStr(Replace);
	while(i != -1)
	{
		Text = Text + InputT.Left(i) + With;
		InputT = InputT.Mid(i + Replace.Len());
		i = InputT.InStr(Replace);
	}
	Text = Text+ InputT;	
	return Text;
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Add slashes and FString File at the end
 */
FString ConnectAddSlashes(FString Text, FString File)
{
	guard(ConnectAddSlashes);
	int i;
	FString InputT;
	FString Replace = FString(TEXT("/"));
	FString With = FString(TEXT("//"));

	InputT = Text;
	Text = TEXT("");
	i = InputT.InStr(Replace);
	while(i != -1)
	{
		Text = Text + InputT.Left(i) + With;
		InputT = InputT.Mid(i + Replace.Len());
		i = InputT.InStr(Replace);
	}
	Text = Text + InputT + File;	
	return Text;
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Removes spaces
 */
FString RemoveSpaces(FString Text)
{
	guard(RemoveSpaces);
	int i;
	FString InputT;
	FString Replace = FString(TEXT(" "));
	FString With = FString(TEXT(""));

	InputT = Text;
	Text = TEXT("");
	i = InputT.InStr(Replace);
	while(i != -1)
	{
		Text = Text + InputT.Left(i) + With;
		InputT = InputT.Mid(i + Replace.Len());
		i = InputT.InStr(Replace);
	}
	Text = Text + InputT;	
	return Text;
	unguard;
}
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Converts char to FName
 * Tnx Smirftsch for this one :)
 */
BSTR CharToFName(char StringA[256])
{
	int StringLengthA;
	int StringLengthW;
	BSTR BstrText;
	StringLengthA = lstrlenA(StringA);
	char * nString = new char[StringLengthA]; //Stripping spaces that are rendering the engine mad...

	for(int j=0, k=0;j<StringLengthA+1;j++)
	{
		if( ( StringA[j]>='0' && StringA[j]<='9' ) || ( StringA[j]>='a' && StringA[j]<='z' ) || ( StringA[j]>='A' && StringA[j]<='Z' ) )
				nString[k++]=StringA[j];
	}

	StringLengthA = lstrlenA(nString);
	StringLengthW = MultiByteToWideChar(CP_ACP, 0, nString, StringLengthA, 0, 0);
	BstrText = SysAllocStringLen(NULL, StringLengthW);

	MultiByteToWideChar(CP_ACP, 0, nString, StringLengthA, BstrText, StringLengthW);

	delete(nString);
	return BstrText;
}
UBOOL FStringDivide(FString Src, FString Divider, FString& LeftPart, FString& RightPart)
{
	int div_pos=Src.InStr(Divider);
	
	if(div_pos != -1)
	{
		LeftPart = Src.Left(div_pos);				
		RightPart = Src.Mid(LeftPart.Len()+Divider.Len(), Src.Len()-LeftPart.Len()-Divider.Len());			
		return 1;
	}
	else 
		return 0;
}

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * replaces 'replace' with 'with' in text
 */
FString FStrReplace( FString Text, FString Replace, FString With )
{
	int i;
	FString InputT;

	InputT = Text;
	Text = TEXT("");
	i = InputT.InStr(Replace);
	while(i != -1)
	{
		Text = Text + InputT.Left(i) + With;
		InputT = InputT.Mid(i + Replace.Len());
		i = InputT.InStr(Replace);
	}
	Text = Text+ InputT;	
	return Text;
}