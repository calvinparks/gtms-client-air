/*
** ContextMenuItem.as , package net.gltd.gtms.GUI.contextMenu **  
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
package net.gltd.gtms.GUI.contextMenu
{
	public class ContextMenuItem
	{
		private			var		_label			:String,
								_icon			:*,
								_icon2			:*,
								_enabled		:Boolean,
								_lineBefore		:Boolean,
								_callBack		:Function,
								_callBackParams	:Array,
								_subMenu		:Array;//Vector.<ContextMenuItem>;
							
							
		public	static	var 	UTILITIES_ICO	:*,
								PROFILE_ICO		:*,
								CHAT_ICO		:*;
		
		public	function	ContextMenuItem(label:String, icon:* = null, enabled:Boolean=true, lineBefore:Boolean=false, callBack:Function=null, callBackParams:Array=null, subMenu:Array=null, icon2:* = null)
		{
			_label			= label;
			_icon			= icon;
			_icon2			= icon2;
			_enabled		= enabled;
			_lineBefore		= lineBefore;
			_callBack		= callBack;
			_callBackParams	= callBackParams;
			_subMenu		= subMenu;
			
		}
		public function call():Boolean {
			if (_callBack == null)	return false
			_callBack.apply(null,_callBackParams);
			return true;
		}
		
		public function set label(l:String):void {
			_label = l;	
		}
		public function get label():String {
			return _label
		}
		
		public function set enabled(l:Boolean):void {
			_enabled = l;	
		}
		public function get enabled():Boolean {
			return _enabled
		}
		public function set lineBefore(l:Boolean):void {
			_lineBefore = l;	
		}
		public function get lineBefore():Boolean {
			return _lineBefore
		}
		public function set icon(l:*):void {
			_icon = l;	
		}
		public function get icon():* {
			return _icon
		}
		
		public function set icon2(l:*):void {
			_icon2 = l;	
		}
		public function get icon2():* {
			return _icon2
		}
		
		
		public function set callBack(l:Function):void {
			_callBack = l;	
		}
		public function get callBack():Function {
			return _callBack
		}
		
		public function set callBackParams(l:Array):void {
			_callBackParams = l;	
		}
		public function get callBackParams():Array {
			return _callBackParams
		}
		
		public function set subMenu(l:Array):void {
			_subMenu = l;	
		}
		public function get subMenu():Array {
			return _subMenu
		}
		
		
	}
}