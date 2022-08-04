/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Copyright 2005-2008 Dead Cow Studios. All Rights Reserved.
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Coder: Raven
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * This thing creates 
 */
class DLL_EXPORT_CLASS URMusicPlayerConfig : public UObject
{
	DECLARE_CLASS(URMusicPlayerConfig,UObject,CLASS_Config,RMusicPlayer)

	// Configuration.
	FString DriverName;

	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* static constructor (builds configuration menu)
	*/
	void StaticConstructor();
	/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	* returns selected driver
	*/
	int GetDriverNum();
};