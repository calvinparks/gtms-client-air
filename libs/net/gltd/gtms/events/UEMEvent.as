/*
** UEMEvent.as , package net.gltd.gtms.events **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 21, 2012 
*
*
*/ 
package net.gltd.gtms.events
{
	import flash.events.Event;
	
	public class UEMEvent extends Event
	{
		
		public	static	const		NEW_UEM			:String = "onNewEvent";
		
		public function UEMEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}