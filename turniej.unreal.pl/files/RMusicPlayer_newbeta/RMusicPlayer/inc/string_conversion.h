/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Part created by ENIGMA - Big THX men :)
 */
// new function
// handle the case where TCHAR is char
std::string toAnsiString(char const * const string)
{
	// no conversion necessary
	return string;
}

// new function
// handle the case where TCHAR is wchar_t
std::string toAnsiString(wchar_t const * const string)
{
	// create a vector big enough to hold the converted string
	std::vector< char > convertedCharacters(wcstombs(0, string, 0));
	// convert the characters
	wcstombs(&convertedCharacters[0], string, convertedCharacters.size());
	// convert to a string and return
	return std::string(convertedCharacters.begin(), convertedCharacters.end());
}

std::string toAnsiString(FString * string)
{
	return toAnsiString(**string);
}
