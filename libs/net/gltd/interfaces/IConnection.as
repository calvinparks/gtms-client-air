/*
** IConnection.as **  
*
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.1 
*	 Created: Jun 12, 2012 
*
*
*/ 
package net.gltd.interfaces
{
	import org.igniterealtime.xiff.core.XMPPConnection;
	import org.igniterealtime.xiff.data.XMPPStanza;

	public interface IConnection
	{
		function send(o:XMPPStanza):void
		function get connection():XMPPConnection;
		
	}
}