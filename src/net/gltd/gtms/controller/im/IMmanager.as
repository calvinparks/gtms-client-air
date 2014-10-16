/*
** IMmanager.as , package net.gltd.gtms.controller.im **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Jun 23, 2012 
*
*
*/ 
package net.gltd.gtms.controller.im
{
	import net.gltd.gtms.controller.app.ApplicationManager;
	import flash.events.EventDispatcher;
	
	import modules.IM_module;
	
	public class IMmanager extends EventDispatcher
	{
		[Inject][Bindable]
		public	var		contactsManager			:ContactListManager;
		
		[Inject][Bindable]
		public	var		app						:ApplicationManager;
		
		[Observe]
		public function observe(im:IM_module):void { 
			im.searchBar.searchFunction = contactsManager.onSerachBar;
		//	app.dynamicContainer = im._dynamicContainer;
			
		}
		
	}
}