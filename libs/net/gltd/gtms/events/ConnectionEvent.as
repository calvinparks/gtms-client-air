/*
** XmppEvent.as , package net.gltd.gtms.events **  
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
package net.gltd.gtms.events
{
	
	import flash.events.Event;
	
	public class ConnectionEvent extends Event
	{
		
		public	static	const	LOGIN_SUCCESS			:String = "onLoginSuccess",
								LOGIN_ERROR				:String	= "onLoginError",
								CONNECTION_SCUCCESS		:String = "onConnectionSucces",
								CONNECTION_TIMEOUT		:String = "onConnectionTimeout",
								DISCONNECTED			:String = "onDisconnected",
								NEW_SERVICE_ITEM		:String = "onNewServiceItem";
								
		
		
		public			var		errorMessage			:String,
								data					:Object;
		public function ConnectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}