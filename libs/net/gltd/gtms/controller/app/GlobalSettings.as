/*
** GlobalSettings.as , package net.gltd.gtms.controller.app **  
* 
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.2 
*	 Created: Oct 11, 2012 
*
*
*/ 
package net.gltd.gtms.controller.app
{
	public class GlobalSettings
	{
		/** 	new AllertSettingsModel("notificationError","System Error",false,false,false,10000),
									new AllertSettingsModel("notificationContact","Contact (Connected / Disconnected)",true,true,false,10000),
									new AllertSettingsModel("notificationIM","New Message",true,true,true,15000) **/
		[Bindable]		
		public	static	var		ALLERTS						:Object;
		
		
	
	}
}