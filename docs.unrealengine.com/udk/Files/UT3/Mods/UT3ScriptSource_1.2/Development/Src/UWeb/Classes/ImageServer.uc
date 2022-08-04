/*=============================================================================
ImageServer.uc - example image server

*  Ported to UE3 by Josh Markiewicz
� 1997-2008 Epic Games, Inc. All Rights Reserved
=============================================================================*/
class ImageServer extends WebApplication;

/* Usage:
[UWeb.WebServer]
Applications[0]="UWeb.ImageServer"
ApplicationPaths[0]="/images"
bEnabled=True

http://server.ip.address/images/test.jpg
*/

event Query(WebRequest Request, WebResponse Response)
{
	local string Image;

	Image = Request.URI;
	if( Right(Caps(Image), 4) == ".JPG" || Right(Caps(Image), 5) == ".JPEG" )
	{
		Response.SendStandardHeaders("image/jpeg", true);
	}
	else if( Right(Caps(Image), 4) == ".GIF" )
	{
		Response.SendStandardHeaders("image/gif", true);
	}
	else if( Right(Caps(Image), 4) == ".BMP" )
	{
		Response.SendStandardHeaders("image/bmp", true);
	}
	else if( Right(Caps(Image), 4) == ".PNG" )
	{
		Response.SendStandardHeaders("image/png", true);
	}
	else
	{
		Response.HTTPError(404);
		return;
	}
	Response.IncludeBinaryFile( Path $ Image );
}

