/*
** ApplicationTab.as , package net.gltd.gtms.model.app **  
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
package net.gltd.gtms.model.app
{
	import net.gltd.gtms.controller.app.ApplicationTabController;
	
	import flash.events.MouseEvent;
	
	import spark.components.ToggleButton;

	public class ApplicationTab extends ToggleButton
	{
		private 		var	_callBack			:Function,
							_callBackParams		:Array,
							_scope				:String;
							
		public function ApplicationTab(icon:*, label:String, callBackFunction:Function=null, callBackParams:Array=null, add:Boolean=true,scope:String="main")
		{
			this.styleName = "applicationTab";
			this.setStyle("icon",icon);
			
			callBack = callBackFunction;
			callBackParams = callBackParams;
			
			this.scope = scope;
			
			if (add)ApplicationTabController.tab = this;	
			
			this.toolTip = label;
			
			this.addEventListener(MouseEvent.CLICK,onClick,false,0,true);
		}
		public function recover():void {
			ApplicationTabController.tab = this;	
		}
		
		public function kill():void {
			callBack = null;
			callBackParams = null;
			ApplicationTabController.remove(this);
		}
		private function onClick(event:MouseEvent):void {
			if (callBack != null){
				callBack.apply(null,callBackParams);
			}
		}
		public function set callBack(f:Function):void {
			_callBack = f;
		}
		public function get callBack():Function {
			return _callBack
		}
		public function set callBackParams(p:Array):void {
			_callBackParams = p;
		}
		public function get callBackParams():Array {
			return _callBackParams;
		}
		public function set scope(s:String):void {
			_scope = s;
		}
		public function get scope():String {
			return _scope;
		}
		
		
		
	}
}