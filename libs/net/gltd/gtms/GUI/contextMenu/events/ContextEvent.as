/*
** NativeMenuEvent.as , package net.gltd.gtms.GUI.contextMenu.events **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 22, 2012 
*
*
*/ 
package net.gltd.gtms.GUI.contextMenu.events
{
	import net.gltd.gtms.GUI.contextMenu.ContextMenuItem;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	public class ContextEvent extends Event
	{
		
		public	static	const		SHOW_SUBMENU			:String = "onShowSubmenu";
		
		public			var			poit					:Point,
									contextItem				:ContextMenuItem,
									data					:*,
									ir						:*;
		public function ContextEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}