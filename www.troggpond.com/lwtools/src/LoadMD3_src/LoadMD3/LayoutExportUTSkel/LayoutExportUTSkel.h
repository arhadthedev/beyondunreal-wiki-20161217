/**************************************
 *
 *  LayoutExportUTSkel.h
 *  Copyright (c) 2000,2001 Michael Bristol
 *  mbristol@bellatlantic.net
 *
 *  This file must remain as 'C' code
 *
 *  Main header file for the Unreal Skeletal export module that
 *  interfaces with my LayoutRecorder plugin
 *
 *  Unreal Tounament is a trademark of Epic MegaGames, Inc.
 *
 **************************************/

#ifndef _LW_LAYOUTEXPORTMD3_H
#define _LW_LAYOUTEXPORTMD3_H

#include <lwserver.h>
#include <lwhost.h>
#include <lwsurf.h>
#include <lwglobsrv.h>
#include <lwmrbxprt.h>

#include "lwobjimp.h"
#include "lwmeshes.h"
#include "lwpanel.h"
#include "lwhost.h"
#include "lwhost.h"
#include "lwgeneric.h"

#include "lw_base.h"

#define PLUGINNAME			LWMRBPREFIX"UnrealSkel"
#define GLOBALPLUGINNAME	LWMRBPREFIX"UnrealSkelGlobal"
#define IMPORTPLUGINNAME	"MRB::Import::UnrealSkel"

#define _PLUGINVERSION(a)		1.##a
#define PLUGINVERSION		(float)_PLUGINVERSION(PROG_PATCH_VER)

extern GlobalFunc		*LW_globalFuncs;
extern LWMRBExportFuncs	*LW_xprtFuncs;
extern LWMessageFuncs	*LW_msgsFuncs;
extern LWXPanelFuncs	*LW_xpanFuncs;
extern LWCommandFunc     LW_cmdFunc;

extern unsigned long LW_sysInfo;

extern LWMRBExportType	 *getFunc();
extern LWMRBCallbackType *getCallback();

typedef struct
{
	void		*Animations;
	void		*Skeleton;
	int			SelectedAnimation;
} AnimLoader;

// Object Import function
extern int Load_PSA(LWObjectImport *local);
extern int Load_PSK(LWObjectImport *local);

extern int GLoad_PSA(LWLayoutGeneric *local,  AnimLoader *anim);
extern int GLoad_PSK(LWLayoutGeneric *local,  AnimLoader *anim);

extern AnimLoader *Get_PSAFile(void);


#endif //_LW_LAYOUTEXPORTMD3_H
