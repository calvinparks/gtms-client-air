/*
** UEMfeature.as , package net.gltd.gtms.controller.notification **  
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
package net.gltd.gtms.GUI.UEM
{
	public class UEMfeature
	{
		public	var		label		:String,
						action		:Function,
						args		:Array;
		public function UEMfeature(l:String,a:Function,ar:Array)
		{
			label = l;
			action = a;
			args = ar;
		}
	}
}