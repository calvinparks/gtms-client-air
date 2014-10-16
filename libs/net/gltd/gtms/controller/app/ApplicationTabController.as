/*
** ApplicationTabController.as , package net.gltd.gtms.controller.app **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jul 27, 2012 
*
*
*/ 
package net.gltd.gtms.controller.app
{
	import net.gltd.gtms.events.UserEvent;
	import net.gltd.gtms.model.app.ApplicationTab;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	[Event(name="onTabAdded", type="net.gltd.gtms.events.UserEvent")]
	[Event(name="onTabRemoved", type="net.gltd.gtms.events.UserEvent")]
	public class ApplicationTabController extends EventDispatcher
	{
		private static	var	_tabs			:ArrayCollection = new ArrayCollection();
		private static	var _dispatcher		:EventDispatcher;
		
		public	static	var	dH				:ApplicationTabController;	
		public function ApplicationTabController(caller:Function=null)
		{
			if (caller != ApplicationTabController.getInstance) {
				throw new Error("SINGELTON use -> getInstance()");
			}else {
				_dispatcher = this as EventDispatcher;
			}
			if (ApplicationTabController.dH != null) {
				throw new Error("Error");
			}
			 
		}
		public static function getInstance(): ApplicationTabController {
			if (dH == null) {
				dH = new ApplicationTabController(arguments.callee);
			}
			return dH;
			
		}
		public static function set tab (at:ApplicationTab):void {
			try {
				if (dH == null)getInstance();
				_tabs.addItem(at);
				var ue:UserEvent = new UserEvent( UserEvent.TAB_ADDED );
				ue.menuButton = at;
				dH.dispatchEvent( ue );
			}catch (error:Error){
				trace (error.getStackTrace());
			}
		}
	
		public static function remove(tab:ApplicationTab):void {
			_tabs.removeItemAt(	_tabs.getItemIndex(tab)	);
			var ue:UserEvent = new UserEvent( UserEvent.TAB_REMOVED );
			ue.menuButton = tab;
			dH.dispatchEvent( ue );
		}
		public function get tabs():ArrayCollection {
			return _tabs;
		}
		
		
	}
}