/* Layout include file */
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <malloc.h> // for _set_sbh_threshold(0) - works around a MS crash bug
#include <crtdbg.h>

/* Mystuff */
#include "LayoutExportMD2.h"

#include "lwdisplce.h"

GlobalFunc			*LW_globalFuncs	= 0;
LWMessageFuncs		*LW_msgsFuncs = 0;
LWXPanelFuncs		*LW_xpanFuncs = 0;
LWMRBExportFuncs	*LW_xprtFuncs = 0;

static int		Setup = 0;

char	*DIR_SEPARATOR	= "\\";
char	tmp[1024];

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
DISPHANDLER_Activate (long version, GlobalFunc *global,
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

// version seems to be 1 for 5.6
// version seems to be 2 for 6.0

XCALL_(static int)
OBJECTIMPORT_Activate (long version, GlobalFunc *global, 
							LWObjectImport *local, void *serverData)
{
	int				retval = AFUNC_OK;
	unsigned short	lwpntIndexCounter = 0;

	const char		*pExt = (char *)NULL;	
	LWDirInfoFunc 	*DirInfo = (LWDirInfoFunc  *)global(LWDIRINFOFUNC_GLOBAL,GFUSE_TRANSIENT);

	XCALL_INIT;

    if ( version != LWOBJECTIMPORT_VERSION ) return AFUNC_BADVERSION;

	// Preload values
	local->result = LWOBJIM_NOREC;

	_Setup(global);

	// Set path ...
	StoreLastPath(DirInfo("Objects"));

	// Load .MD2
	pExt = local->filename + strlen(local->filename) -4;
	if (strcmp(pExt,".md2") == 0 || strcmp(pExt,".MD2") == 0)
	{	// Load file
		retval = Load_MD2(local);

		// Be done
		local->done(local->data);
	}

	return retval;
};

ServerRecord ServerDesc[] = {
    { LWDISPLACEMENT_HCLASS,	PLUGINNAME,	DISPHANDLER_Activate},
    { LWDISPLACEMENT_ICLASS,	PLUGINNAME,	DISPINTERFACE_Interface},

    { LWGLOBALSERVICE_CLASS,	GLOBALPLUGINNAME,	GLOBALSERVICE_Initiate},

    { LWOBJECTIMPORT_CLASS,		IMPORTPLUGINNAME,	OBJECTIMPORT_Activate},

	{ NULL }
};
