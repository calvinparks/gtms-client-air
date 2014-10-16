/*
** AppEvent.as , package net.gltd.gtms.events **  
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
	
	public class AppEvent extends Event
	{
		public	static	const		CHANGE_SCREEN			:String = "onChageScreen",
									APP_CLOSE				:String = "onAppClose",
									APP_MAXIMIZE			:String = "onAppMaximize",
									APP_MINIMIZE			:String = "onAppMinimize",
									APP_RESTORE				:String = "onAppRestore";
		
		
		public function AppEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}