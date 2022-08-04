# Microsoft Developer Studio Project File - Name="D3D8Drv" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=D3D8Drv - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "D3D8Drv.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "D3D8Drv.mak" CFG="D3D8Drv - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "D3D8Drv - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe
# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "..\Lib"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "D3D8DRV_EXPORTS" /YX /FD /c
# ADD CPP /nologo /Zp4 /MD /W4 /vd0 /GX /O2 /I "..\..\USource\Core\Inc" /I "..\..\USource\Engine\Inc" /I "..\..\DirectX8\Inc" /I "..\..\DirectX8\lib" /D "NDEBUG" /D "_WINDOWS" /D "WIN32" /D "UNICODE" /D "_UNICODE" /D ThisPackage=RD3D8Drv /D "NO_UNICODE_OS_SUPPORT" /D "WIN32_LEAN_AND_MEAN" /FAs /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 ..\..\USource\Core\Lib\Core.lib ..\..\USource\Engine\Lib\Engine.lib user32.lib gdi32.lib ..\..\DirectX8\Lib\d3dx8.lib ..\..\DirectX8\Lib\DxGuid.lib advapi32.lib /nologo /dll /map /machine:I386 /out:"..\..\System\RD3D8Drv.dll"
# Begin Target

# Name "D3D8Drv - Win32 Release"
# Begin Group "Src"

# PROP Default_Filter "*.cpp;*.h"
# Begin Source File

SOURCE=.\D3D8.cpp
# End Source File
# Begin Source File

SOURCE=.\D3D8.h
# End Source File
# Begin Source File

SOURCE=.\D3D8Drv.cpp
# ADD CPP /Yc"D3D8Drv.h"
# End Source File
# Begin Source File

SOURCE=.\D3D8Drv.h
# End Source File
# End Group
# End Target
# End Project
