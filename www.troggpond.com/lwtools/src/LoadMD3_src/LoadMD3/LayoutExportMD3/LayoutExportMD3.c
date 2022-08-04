/* Layout include file */
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <malloc.h> // for _set_sbh_threshold(0) - works around a MS crash bug
#include <crtdbg.h>

/* Mystuff */
#include "LayoutExportMD3.h"

#include "lwdisplce.h"

GlobalFunc			*LW_globalFuncs	= 0;
LWMessageFuncs		*LW_msgsFuncs = 0;
LWXPanelFuncs		*LW_xpanFuncs = 0;
LWMRBExportFuncs	*LW_xprtFuncs = 0;

LWDirInfoFunc 	    *DirInfo = 0;
void			    *LocalFuncs = 0;
LWCommandFunc		LW_cmdFunc		= (LWCommandFunc)0;

static int		Setup = 0;

char	*DIR_SEPARATOR	= "\\";
char	tmp[1024];

// Check name
int IsMD3NameOK(const char *name)
{
	char	*pExt = (char *)NULL;

	if (strlen(name) < 5)
		return 0;

	pExt = (char *)(name) + strlen(name) -4;
	if (*pExt == '.' && *(pExt + 3) == '3' &&
		(*(pExt +1) == 'm' || *(pExt +1) == 'M') &&
		(*(pExt +2) == 'd' || *(pExt +2) == 'D')
		)
		return 1;

	return 0;
}

void _Setup(GlobalFunc *global)
{
	int i = 0;
	if (Setup == 1) {
		return;
	}

    _CrtSetDbgFlag(_CrtSetDbgFlag(_CRTDBG_REPORT_FLAG) |_CRTDBG_LEAK_CHECK_DF);

	_set_sbh_threshold(0);
	Setup = 1;

	LW_globalFuncs = global;
	LW_msgsFuncs = (LWMessageFuncs *)LW_globalFuncs(LWMESSAGEFUNCS_GLOBAL,GFUSE_ACQUIRE );
	LW_xpanFuncs = (LWXPanelFuncs *)LW_globalFuncs( LWXPANELFUNCS_GLOBAL, GFUSE_ACQUIRE  );
	LW_xprtFuncs = (LWMRBExportFuncs*)LW_globalFuncs(LWMRBEXPORT_GLOBAL,GFUSE_ACQUIRE );
	if(!LW_xprtFuncs)
	{
		(*LW_msgsFuncs->error)("Unable to activate global "LWMRBEXPORT_GLOBAL,
						"     please add plugin MRB_Xhub.p" );
		return;
	}
}

	XCALL_(static int)
DISPHANDLER_Activate (long version,GlobalFunc *global,
								LWDisplacementHandler *local,void *serverData)
{
	int						retval = AFUNC_OK, i = 0;

	XCALL_INIT;
    if ( version != LWDISPLACEMENT_VERSION ) return AFUNC_BADVERSION;

	_Setup(global);
	if (LW_xprtFuncs == 0)
		return AFUNC_BADAPP;

	local->inst->priv = getFunc();
	return (int)LW_xprtFuncs->get_activation(version,global,local);
};
	
	XCALL_(static int)
DISPINTERFACE_Interface (
	long			 version,
	GlobalFunc		*global,
	LWInterface		*local,
	void			*serverData)
{

   if ( version != LWINTERFACE_VERSION ) return AFUNC_BADVERSION;

	_Setup(global);
	if (LW_xprtFuncs == 0)
		return AFUNC_BADAPP;

	return (int)LW_xprtFuncs->get_interface(version,global,local);
}

	XCALL_(static int)
GLOBALSERVICE_Initiate (
	long			 version,
	GlobalFunc		*global,
	void			*inst,
	void			*serverData)
{
   if ( version != LWGLOBALSERVICE_VERSION ) return AFUNC_BADVERSION;

	_Setup(global);
	if (LW_xprtFuncs == 0)
		return AFUNC_BADAPP;

	((LWGlobalService *)inst)->data = getCallback();

	return AFUNC_OK;
}

XCALL_(static int)
OBJECTIMPORT_Activate (long version, GlobalFunc *global, 
							LWObjectImport *local, void *serverData)
{

	int				retval = AFUNC_OK;
	unsigned short	lwpntIndexCounter = 0;

	char			*pExt = (char *)NULL;	
	XCALL_INIT;

	if (version != LWOBJECTIMPORT_VERSION) return AFUNC_BADVERSION;

	// Preload values
	local->result = LWOBJIM_NOREC;

	FindProductInfo(global);
	LocalFuncs	= local;

	LW_globalFuncs = global;
	LW_msgsFuncs = global(LWMESSAGEFUNCS_GLOBAL,GFUSE_TRANSIENT);
	if ( !LW_msgsFuncs)	return AFUNC_BADGLOBAL;

	// Set path ...

	DirInfo = (LWDirInfoFunc  *)global(LWDIRINFOFUNC_GLOBAL,GFUSE_TRANSIENT);
	StoreLastPath(DirInfo("Objects"));

	LW_cmdFunc = (LWCommandFunc)global( LWCOMMANDINTERFACE_GLOBAL, GFUSE_ACQUIRE );

	return LW60_LoadinMD3();
};

// version seems to be 3 for 5.6
// version seems to be 4 for 6.0

XCALL_(static int)
MESHEDIT_Activate (long version,GlobalFunc *global,void *local,void *serverData)
{

	int				retval = AFUNC_OK;

	unsigned short	lwpntIndexCounter = 0;

	char			*pExt = (char *)NULL;
	
	XCALL_INIT;

	if (version != LWMESHEDIT_VERSION) return AFUNC_BADVERSION;

	FindProductInfo(global);
	LocalFuncs	= local;

	LW_globalFuncs = global;
	LW_msgsFuncs = global(LWMESSAGEFUNCS_GLOBAL,GFUSE_TRANSIENT);
	if ( !LW_msgsFuncs)	return AFUNC_BADGLOBAL;

	// Set path ...
	DirInfo = (LWDirInfoFunc  *)global(LWDIRINFOFUNC_GLOBAL,GFUSE_TRANSIENT);
	StoreLastPath(DirInfo("Objects"));

	LW_cmdFunc = (LWCommandFunc)global( LWCOMMANDINTERFACE_GLOBAL, GFUSE_ACQUIRE );

	return LW60_ImportMD3();
};

ServerRecord ServerDesc[] = {
    { LWDISPLACEMENT_HCLASS,	PLUGINNAME,	DISPHANDLER_Activate},
    { LWDISPLACEMENT_ICLASS,	PLUGINNAME,	DISPINTERFACE_Interface},

    { LWGLOBALSERVICE_CLASS,	GLOBALPLUGINNAME,	GLOBALSERVICE_Initiate},

    { LWOBJECTIMPORT_CLASS,   	PLUGINNAME_LOAD,  OBJECTIMPORT_Activate},
	{ LWMESHEDIT_CLASS,		    PLUGINNAME_MESH, MESHEDIT_Activate},

	{ NULL }
};
