#ifndef _LW_LAYOUTEXPORTMD3_H
#define _LW_LAYOUTEXPORTMD3_H

#include <lwserver.h>
#include <lwhost.h>
#include <lwmrbxprt.h>
#include <lwglobsrv.h>

#include "lwobjimp.h"
#include <lwmeshedt.h>
#include <lwmeshes.h>
#include "lwpanel.h"
#include "lwhost.h"
#include "lwgeneric.h"

#include "lw_base.h"

#define PLUGINNAME			LWMRBPREFIX"Quake3"
#define GLOBALPLUGINNAME	LWMRBPREFIX"Quake3Global"
#define PLUGINNAME_LOAD		"MRB::Import::MD3"
#define PLUGINNAME_MESH		"MRB::MeshEdit::MD3"

#define _PLUGINVERSION(a)		1.##a
#define PLUGINVERSION		(float)_PLUGINVERSION(PROG_PATCH_VER)

extern GlobalFunc		*LW_globalFuncs;
extern LWMRBExportFuncs	*LW_xprtFuncs;
extern LWMessageFuncs	*LW_msgsFuncs;
extern LWXPanelFuncs	*LW_xpanFuncs;

extern void				*LocalFuncs;
extern LWCommandFunc	LW_cmdFunc;

extern LWMRBExportType	 *getFunc();
extern LWMRBCallbackType *getCallback();

extern char	*DIR_SEPARATOR;
extern char	tmp[1024];

typedef struct
{	// User input values
	int				FrameForImport;
	int				AnchorTagIndex;
	int				ModelType;
	char			AnimCFG[1024];
} GUIData;

// Object Import function
extern int LW56_LoadinMD3();
extern int LW60_LoadinMD3();

// Meshedit function
extern int LW56_ImportMD3();
extern int LW60_ImportMD3();

// Basic name checker
int IsMD3NameOK(const char *name);

#endif //_LW_LAYOUTEXPORTMD3_H

