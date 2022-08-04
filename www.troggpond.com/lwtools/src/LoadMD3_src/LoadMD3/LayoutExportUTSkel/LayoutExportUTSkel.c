/**************************************
 *
 *  LayoutExportUTSkel.c
 *  Copyright (c) 2000,2001 Michael Bristol
 *  mbristol@bellatlantic.net
 *
 *  This file must remain as 'C' code
 *
 *  Main file for the Unreal Tournament Skeletal export module that
 *  interfaces with my LayoutRecorder plugin
 *
 *  Defines a Displacement plugin (which hands it's Activate and
 *  Interface functions over to LayoutRecorder) and a Global
 *  as is required for LayoutRecorder interfacing
 *
 *  Unreal Tounament is a trademark of Epic MegaGames, Inc.
 **************************************/

/* Layout include file */
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <malloc.h> // for _set_sbh_threshold(0) - works around a MS crash bug
#include <crtdbg.h>

/* Mystuff */
#include "LayoutExportUTSkel.h"

#include "lwdisplce.h"

GlobalFunc			*LW_globalFuncs	= 0;
LWMessageFuncs		*LW_msgsFuncs = 0;
LWXPanelFuncs		*LW_xpanFuncs = 0;
LWMRBExportFuncs	*LW_xprtFuncs = 0;
LWCommandFunc	     LW_cmdFunc   = 0;
unsigned long	     LW_sysInfo;

static int		Setup = 0;

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
	LW_sysInfo = ( unsigned long )LW_globalFuncs( LWSYSTEMID_GLOBAL, GFUSE_TRANSIENT );	
	LW_cmdFunc = (LWCommandFunc)LW_globalFuncs( LWCOMMANDINTERFACE_GLOBAL, GFUSE_ACQUIRE );
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

// version seems to be 1 for 5.6
// version seems to be 2 for 6.0

XCALL_(static int)
OBJECTIMPORT_UnrealSkeletal (long version, GlobalFunc *global, 
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

	// Load either .psk or .psa (as requested ...)
	pExt = local->filename + strlen(local->filename) -4;
	if (strcmp(pExt,".psk") == 0 || strcmp(pExt,".PSK") == 0)
	{	// Load skeelton file
		retval = Load_PSK(local);
		// Be done
		local->done(local->data);
	}
	else if (strcmp(pExt,".psa") == 0 || strcmp(pExt,".PSA") == 0)
	{	// Load Animation file
		retval = Load_PSA(local);
		// Be done
		local->done(local->data);
	}


	return retval;
};

// Animation import for Layout
XCALL_(static int)
GENERIC_UnrealSkeletal (long version,GlobalFunc *global,
								LWLayoutGeneric *local, void *serverData)
{
	int			retval = AFUNC_OK;
	AnimLoader *file = 0;

	XCALL_INIT;
    if ( version != LWLAYOUTGENERIC_VERSION ) return AFUNC_BADVERSION;

	_Setup(global);

	// .psa only
	file = Get_PSAFile();
	if (file->Skeleton != 0)
		retval = GLoad_PSK(local,file);

	if (file->Animations != 0)
		retval = GLoad_PSA(local,file);

	return retval;
};

ServerRecord ServerDesc[] = {
    { LWDISPLACEMENT_HCLASS,	PLUGINNAME,			DISPHANDLER_Activate},
    { LWDISPLACEMENT_ICLASS,	PLUGINNAME,			DISPINTERFACE_Interface},

    { LWGLOBALSERVICE_CLASS,	GLOBALPLUGINNAME,	GLOBALSERVICE_Initiate},

    { LWOBJECTIMPORT_CLASS,		IMPORTPLUGINNAME,   OBJECTIMPORT_UnrealSkeletal},
    { LWLAYOUTGENERIC_CLASS,	IMPORTPLUGINNAME,	GENERIC_UnrealSkeletal},

	{ NULL }
};
