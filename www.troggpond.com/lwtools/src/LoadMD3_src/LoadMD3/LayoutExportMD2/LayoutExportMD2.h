#ifndef _LW_LAYOUTEXPORTMD3_H
#define _LW_LAYOUTEXPORTMD3_H

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include <lwserver.h>
#include <lwhost.h>
#include <lwmrbxprt.h>
#include <lwglobsrv.h>

#include <lwobjimp.h>
#include <lwmeshes.h>
#include <lwpanel.h>
#include <lwgeneric.h>

#include <lw_base.h>

#define PLUGINNAME			LWMRBPREFIX"Quake2"
#define GLOBALPLUGINNAME	LWMRBPREFIX"Quake2Global"
#define IMPORTPLUGINNAME	"MRB::Import::MD2"

#define _PLUGINVERSION(a)		1.##a
#define PLUGINVERSION		(float)_PLUGINVERSION(PROG_PATCH_VER)

extern GlobalFunc		*LW_globalFuncs;
extern LWMRBExportFuncs	*LW_xprtFuncs;
extern LWMessageFuncs	*LW_msgsFuncs;
extern LWXPanelFuncs	*LW_xpanFuncs;

// Export-related values
extern LWMRBExportType	 *getFunc();
extern LWMRBCallbackType *getCallback();

extern char	*DIR_SEPARATOR;
extern char	tmp[1024];

// Import-related values
extern int Load_MD2(LWObjectImport *local);

typedef struct 
{
	int frame;
	int makemorphs;
} GUIData;

extern GUIData *Get_FrameNum(int range);

#ifdef __cplusplus
}
#endif // __cplusplus


#endif //_LW_LAYOUTEXPORTMD3_H
