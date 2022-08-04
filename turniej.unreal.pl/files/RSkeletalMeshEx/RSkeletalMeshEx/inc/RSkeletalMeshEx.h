/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Main header file/
 * Header is loaded by:
 *  - ARSkeletalActor.cpp
 *  - RFunctions.cpp
 *  - RSkeletalMeshEx.cpp
 *  - URSkeletalMeshEx.cpp
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Author: Raven
 */

/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!! Stuff for string conversions
 */
#include <cstdlib>
#include <string>
#include <iostream>
#include <vector>
#include <afx.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <conio.h>
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!! Engine and core implementation
 */
#include "Engine.h"
#include "Core.h"
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * If you forget this You will have error like this:
 * '(...) inconsistent dll linkage.  dllexport assumed.(...)'
 */
#define RSKELETALMESHEX_API DLL_EXPORT
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * IMPORTANT!!
 * UCC generated header implementation
 * This file was created to glue UnrealScript and C++ code together
 */
#include "RSkeletalMeshExClasses.h"
#include "RFunctions.h"