-----------------------------------------------------------------------------
                                     wUtils
                                  Version 105
                        by Michiel 'El Muerte' Hendriks
                           elmuerte@drunksnipers.com
                           and various contributers
-----------------------------------------------------------------------------

UT2003 has a nice set of methods and structures defined in XGame.xUtils, but 
there are more common used methods. That's why I started on wUtils, this is
a package that contains a collection of common methods.
You are free to use this package, you are also free to copy some code from
this package.
For documentation about wUtils and it's methods visit the Unreal Wiki page:
http://wiki.beyondunreal.com/wiki/WUtils

------------------------------- VERSION HISTORY -----------------------------
New in 105:
- wString: float to string
- wDraw: 
  - add optional presision to DrawDecimalNumberAt
  - new function: DrawBracket 

New in 104:
- wTime: new class
- wDraw: new class
- wString:
  - fixed the MaskedCompare routine
- wArray:
  - Join with bIgnoreEmpty doesn't add the delims on empty elements
  - added various float routines like MinF, MaxF, SortF, AddF, ...

New in 103:
- package name is now appened with version number, so this one is called
  wUtils103.u , this way you won't get in problems with diffirent version
  used by mods
- wString:
  - added optional string QuoteChar to StrShift to allow quoted strings
  - added optional bool ignoreEmpty to Split2 to ignore empty fields
  - added optional string QuateChar to Split2 to ignore empty fields
- wArray:
  - new function BinarySearch
  - new function GetCommonBegin

New in 102:
- wString:
  - new function StrSubst
  - new function ReplaceInString
  - fixed StrReplace to work with bOnlyFirst=true
- wMath
  - new function PowerMod
  - RSA encode/decode functions

New in 101:
- wString
  - StrShift fixed to support strings as delimiter
  - StrReplace, added an option bOnlyFirst to only replace the first element
  - added Capitalize, capitalize a string
  - added Split2, fixed version of split
- wMath
  - added CRC32 methods
- wArray
  - Join, added an optional bIgnoreEmpty parameter
  - added MaxI and MaxS to return the highest value of an array
  - added MinI and MinS to return the lowest value of an array

--------------------------------- SOURCE CODE -------------------------------
wUtils is provided under the Lesser GPL. The complete source code is 
available from the website. Please respect the Lesser GPL:
                      http://www.gnu.org/licenses/lgpl.txt

----------------------------- CONTACT INFORMATION ---------------------------
wUtils has been written by various Unreal Scripters, the code is maintained
by Michiel 'El Muerte' Hendriks. For more information visit wUtils' Unreal 
Wiki page: http://wiki.beyondunreal.com/wiki/WUtils

-----------------------------------------------------------------------------
Michiel 'El Muerte' Hendriks                        elmuerte@drunksnipers.com
The Drunk Snipsers - ICT Solutions                http://www.drunksnipers.com
-----------------------------------------------------------------------------