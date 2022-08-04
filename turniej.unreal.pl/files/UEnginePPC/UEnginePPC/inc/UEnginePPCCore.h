/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Main header file
 * Header is loaded by all C++ files
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Author: Raven
 */

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!! Engine and core implementation
 */
#include "Engine.h"
#include "Core.h"
#include "FConfigCacheIni.h"

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * If you forget this You will have error like this:
 * '(...) inconsistent dll linkage.  dllexport assumed.(...)'
 */
#define UENGINEPPC_API DLL_EXPORT

#if _MSC_VER
#pragma pack (push,4)
#endif

#ifndef UENGINEPPC_API
#define UENGINEPPC_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern UENGINEPPC_API FName UENGINEPPC_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif NAMES_ONLY

#if _MSC_VER
#pragma pack (pop)
#endif

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * DEBUGGING !!
 */
#include "FOutputDeviceFile.h"
#define debugf GLog->Logf