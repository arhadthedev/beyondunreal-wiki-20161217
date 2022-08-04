/*=============================================================================
	WebResponse is used by WebApplication to handle most aspects of sending
	http information to the client. It serves as a bridge between WebApplication
	and WebConnection.

	*  Ported to UE3 by Josh Markiewicz
	� 1997-2008 Epic Games, Inc. All Rights Reserved
=============================================================================*/

class WebResponse extends Object
	native
	config(Web);

/*
The correct order of sending a response is:

1. define content:
	AddHeader(...), Subst(...), ClearSubst(...), LoadParsedUHTM(...), headers, CharSet,
2. HTTPResponse(...)
	(optional, implies a 200 return when not explicitly send)
3. SendStandardHeaders(...)
	(optional, implied by SendText(...))
4. send content:
	IncludeUHTM(...), SendText(...)
*/

var array<string>				headers; // headers send before the content
var private native const Map_Mirror ReplacementMap{TMultiMap<FString, FString>};  // C++ placeholder.
var const config string 		IncludePath;
var localized string 			CharSet;
var WebConnection 				Connection;
var protected bool 				bSentText; // used to warn headers already sent
var protected bool 				bSentResponse;

;

native final function 			Subst(string Variable, coerce string Value, optional bool bClear);
native final function 			ClearSubst();
native final function 			IncludeUHTM(string Filename);
native final function 			IncludeBinaryFile(string Filename);
native final function string 	LoadParsedUHTM(string Filename); // For templated web items, uses Subst too
native final function string 	GetHTTPExpiration(optional int OffsetSeconds);

native final function Dump(); // only works in dev mode

event SendText(string Text, optional bool bNoCRLF)
{
	if(!bSentText)
	{
		SendStandardHeaders();
		bSentText = True;
	}

	if(bNoCRLF)
	{
		Connection.SendText(Text);
	}
	else {
		Connection.SendText(Text$Chr(13)$Chr(10));
	}
}

event SendBinary(int Count, byte B[255])
{
	Connection.SendBinary(Count, B);
}

function SendCachedFile(string Filename, optional string ContentType)
{
	if(!bSentText)
	{
		SendStandardHeaders(ContentType, true);
		bSentText = True;
	}
	IncludeUHTM(Filename);
}

function FailAuthentication(string Realm)
{
	HTTPError(401, Realm);
}

/**
 * Send the HTTP response code.
 */
function HTTPResponse(string Header)
{
	bSentResponse = True;
	HTTPHeader(Header);
}

/**
 * Will actually send a header. You should not call this method, queue the headers
 * through the AddHeader() method.
 */
function HTTPHeader(string Header)
{
	if(bSentText)
	{
		`Log("Can't send headers - already called SendText()");
	}
	else {
		if (!bSentResponse)
		{
			HTTPResponse("HTTP/1.1 200 Ok");
		}
		if (Len(header) == 0)
		{
			bSentText = true;
		}
		Connection.SendText(Header$Chr(13)$Chr(10));
	}
}

/**
 * Add/update a header to the headers list. It will be send at the first possible occasion.
 * To completely remove a given header simply give it an empty value, "X-Header:"
 * To add multiple headers with the same name (need for Set-Cookie) you'll need
 * to edit the headers array directly.
 */
function AddHeader(string header, optional bool bReplace=true)
{
	local int i, idx;
	local string part, entry;
	i = InStr(header, ":");
	if (i > -1)
	{
		part = Caps(Left(header, i+1)); // include the :
	}
	else {
		return; // not a valid header
	}
	foreach headers(entry, idx)
	{
		if (InStr(Caps(entry), part) > -1)
		{
			if (bReplace)
			{
				if (i+2 >= len(header))
				{
					headers.remove(idx, 1);
				}
				else {
					headers[idx] = header;
				}
			}
			return;
		}
	}
	if (len(header) > i+2)
	{
		// only add when it contains a value
		headers.AddItem(Header);
	}
}

/**
 * Send the stored headers.
 */
function SendHeaders()
{
	local string hdr;
	foreach headers(hdr)
	{
		HTTPHeader(hdr);
	}
}

function HTTPError(int ErrorNum, optional string Data)
{
	switch(ErrorNum)
	{
	case 400:
		HTTPResponse("HTTP/1.1 400 Bad Request");
		SendText("<TITLE>400 Bad Request</TITLE><H1>400 Bad Request</H1>If you got this error from a standard web browser, please mail epicgames.com and submit a bug report.");
		break;
	case 401:
		HTTPResponse("HTTP/1.1 401 Unauthorized");
		AddHeader("WWW-authenticate: basic realm=\""$Data$"\"");
		SendText("<TITLE>401 Unauthorized</TITLE><H1>401 Unauthorized</H1>");
		break;
	case 404:
		HTTPResponse("HTTP/1.1 404 Object Not Found");
		SendText("<TITLE>404 File Not Found</TITLE><H1>404 File Not Found</H1>The URL you requested was not found.");
		break;
	default:
		break;
	}
}

/**
 * Send the standard response headers.
 */
function SendStandardHeaders( optional string ContentType, optional bool bCache )
{
	if(ContentType == "")
	{
		ContentType = "text/html";
	}
	if(!bSentResponse)
	{
		HTTPResponse("HTTP/1.1 200 OK");
	}
	AddHeader("Server: UnrealEngine UWeb Web Server Build "$Connection.WorldInfo.EngineVersion, false);
	AddHeader("Content-Type: "$ContentType, false);
	if (bCache)
	{
		AddHeader("Cache-Control: max-age="$Connection.WebServer.ExpirationSeconds, false);
		// Need to compute an Expires: tag .... arrgggghhh
		AddHeader("Expires: "$GetHTTPExpiration(Connection.WebServer.ExpirationSeconds), false);
	}
	AddHeader("Connection: Close"); // always close
	SendHeaders();
	HTTPHeader("");
}

function Redirect(string URL)
{
	HTTPResponse("HTTP/1.1 302 Document Moved");
	AddHeader("Location: "$URL);
	SendText("<head><title>Document Moved</title></head>");
	SendText("<body><h1>Object Moved</h1>This document may be found <a HREF=\""$URL$"\">here</a>.");
}


function bool SentText()
{
	return bSentText;
}

function bool SentResponse()
{
	return bSentResponse;
}

defaultproperties
{
     //IncludePath="/Web"
     //CharSet="iso-8859-1"
}
