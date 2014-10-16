/*
** UEMwindow.as , package net.gltd.gtms.view.notification **  
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
	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Window;
	
	public class UEMwindow extends UEMBase
	{
		private	var	_timer:Timer;
		public	var ownerID:String;
		
		public function UEMwindow(ownerID:String, title:String, message:String, features:Array=null)
		{
			super();

			this.ownerID = ownerID;
			this.id = ownerID;
			this.maximizable = false;
			this.minimizable = false;
			this.resizable = false;
			this.type = NativeWindowType.LIGHTWEIGHT;
			this.systemChrome = "none";
			this.transparent = true;
			this.showStatusBar = false;
			this.alwaysInFront = true;
			super.heading = title;
			super.message = message;
			super.features = new ArrayCollection(features);
			//super.features.refresh()
			
						
		}
		public function update( title:String, message:String, features:Array=null):void {
			super.heading = title;
			super.message = message;
			super.features = new ArrayCollection(features);
			if (_timer != null){
				_timer.stop();
			}
		}
		public function set timer(dely:uint):void {
			if (_timer!=null){
				_timer.reset()
			}else {
				_timer = new Timer(dely,1);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
			}
			_timer.start();
		}
		private function onTimerComplete(event:TimerEvent):void {
			this.close();
		}
	}
}