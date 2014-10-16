/*
** WindowManager.as **  
*
*	 Globility Limited
* 
*	 Copyright 2012. All rights reserved. 
* 
*	 Author: Piotr Kownacki ( pinczo@pinczo.net )
*	 pinczo 
*	 communified_v3.1 
*	 Created: Jun 11, 2012 
*
*
*/ 
package net.gltd.gtms.controller.app
{
	import net.gltd.gtms.GUI.window.CustomWindow;
	
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	import spark.components.Window;
	
	public class WindowManager extends EventDispatcher
	{
		public static		const	INFO_ACTION							:String		= "showInfo",
									MAXIMIZE_ACTION						:String		= "maximizeWindow",
									MINIMIZE_ACTION						:String		= "minimizeWindow",
									RESTORE_ACTION						:String		= "restoreWindow",
									CLOSE_ACTION						:String		= "closeWindow",
									HIDE_ACTION							:String		= "hideWindow",
									SHOW_ACTION							:String		= "showWindow";
		
		private				var		_isMax								:Boolean	= false,
									_natWindow							:NativeWindow,
									_window								:*;
									
		
		public				var		stickWindows						:ArrayCollection = new ArrayCollection(),
									hidden								:Boolean = false,
									info								:Function,
									isSticky							:Boolean,
									
									minEnabled							:Number = NaN,
									maxEnabled							:Number = NaN,
									closeEnabled						:Number = NaN;
									
									
									
		
		
		public function set natWindow(n:NativeWindow):void {
			_natWindow = n;
			
			_natWindow.addEventListener(NativeWindowBoundsEvent.MOVE,onNWBounds);
			_natWindow.addEventListener(NativeWindowBoundsEvent.RESIZING,onNWBounds);
			_natWindow.addEventListener(Event.ACTIVATE,onActivate);
			_natWindow.addEventListener(Event.CLOSING,onClose);
			_natWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,onStateChanging);
		}
		[Bindable]
		public function get natWindow():NativeWindow {
			return _natWindow;
		}
		[Bindable]
		public function get window():* {
			return _window;
		}
		
		public function set window(n:*):void {
			_window = n;	
		} 
		private function onActivate(event:Event):void {
			if (isSticky && !FlexGlobals.topLevelApplication._topAppControls.windowManager.isMax)FlexGlobals.topLevelApplication.nativeWindow.orderToFront()
			for (var i:uint = 0; i<stickWindows.length; i++){
				var w:Window = stickWindows.getItemAt(i).window;
				if (w != null && !w.closed){
					w.orderToFront();
				}
			}
			
		}
		public function set isMax(b:Boolean):void {
			_isMax = b;
			try {
				window['resizable'] = !b;
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			try {
				window['moveable'] = !b;
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
		}
		public function get isMax():Boolean {
			return _isMax;
		}
		private function onStateChanging(event:NativeWindowDisplayStateEvent):void {
			var v:Boolean = false;
			var i:uint;
			var w:CustomWindow;
			if (event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED){
				isMax = true;
				for (i = 0; i<stickWindows.length; i++){
					if (!stickWindows.getItemAt(i).manager.isSticky == true) continue;
					stickWindows.getItemAt(i).bolck = true;
					w = stickWindows.getItemAt(i).window;
					unStickWindow(w);
				}
				return;
			}
			if (event.beforeDisplayState == NativeWindowDisplayState.MAXIMIZED)isMax = false;
			if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED){
				v = false;
			}else {
				v = true;
			}
			for (i = 0; i<stickWindows.length; i++){
				w = stickWindows.getItemAt(i).window;
				if (w != null && !w.closed){
					if (!stickWindows.getItemAt(i).manager.isSticky == true) continue;
					if (v && stickWindows.getItemAt(i).bolck){
					
						stickWindows.getItemAt(i).bolck = false;
						restoreWindow(stickWindows.getItemAt(i).window);
					
					}
					w.visible = v;
				}
			}
		
			if (v)onNWBounds(null);
			
		
			 
			
		}
		public function restoreWindow(w:CustomWindow):void {
			w.minimizable = Boolean(w.windowManager.minEnabled);
			w.maximizable = Boolean(w.windowManager.maxEnabled);
			w['closeable'] = Boolean(w.windowManager.closeEnabled);
			w['moveable'] = false;
			
			w.orderToFront();
		}
		public function unStickWindow(w:CustomWindow,stayInPlace:String="yes"):void {
			//w = stickWindows.getItemAt(i).window;
			w.minimizable = true;//Boolean((stickWindows.getItemAt(i).manager as WindowManager).minEnabled);
			w.maximizable =  Boolean(w.windowManager.maxEnabled);
			w['closeable'] = true;//Boolean((stickWindows.getItemAt(i).manager as WindowManager).closeEnabled);
			w['moveable'] = true;
			w.orderToFront();
			if (stayInPlace!="yes"){
				if (stayInPlace=="left" )w.move(20,30);
				else w.move( Screen.mainScreen.bounds.x+Screen.mainScreen.bounds.width - w.width - 90,90);
			}
		}
		private function onNWBounds(event:NativeWindowBoundsEvent):void {
			if (isMax)return;
			for (var i:uint = 0; i<stickWindows.length; i++){
				if (stickWindows.getItemAt(i).block == true) continue;
				if (!stickWindows.getItemAt(i).manager.isSticky == true) continue;
				if (stickWindows.getItemAt(i).manager.isMax == true) continue;
				var w:Window = stickWindows.getItemAt(i).window;
				if (w != null && !w.closed){
					var p:Point = getStickWindowPos(stickWindows.getItemAt(i).stick, new Point(w.width,w.height));
					w.nativeWindow.x = p.x;
					w.nativeWindow.y = p.y;
				}
			}
		
			
		}
		
		private function onClose(event:Event):void {
			_natWindow.removeEventListener(NativeWindowBoundsEvent.MOVE,onNWBounds);
			_natWindow.removeEventListener(NativeWindowBoundsEvent.RESIZING,onNWBounds);
			_natWindow.removeEventListener(Event.CLOSING,onClose);
			_natWindow.removeEventListener(Event.ACTIVATE,onActivate);
			_natWindow.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,onStateChanging)
			for (var i:uint = 0; i<stickWindows.length; i++){
				var w:Window = stickWindows.getItemAt(i).window;
				if (w != null && !w.closed){
					w.close();
				}
			}
		}
		public function getStickWindowPos(d:String,v:Point):Point {
			var p:Point = new Point();
			switch(d)
			{
				case 'left':
				{
					p.x = _natWindow.x - v.x + 1;
					p.y = _natWindow.y + 40;
					break;
				}
				case 'right':
				{
					p.x = _natWindow.x + natWindow.width - 1;
					p.y = _natWindow.y + 40;
					break;
				}
					
				default:
				{
					p.x = natWindow.x + (natWindow.width/2) - (v.x / 2);
					p.y = natWindow.y + (natWindow.height/2) - (v.y / 2);
					break;
				}
			}
			return p;
		}
		public function stickAction():void {
			isSticky = !isSticky;
			var p:Point ;
			if (isSticky){
				restoreWindow(window);
				p = new Point( FlexGlobals.topLevelApplication.nativeWindow.x + FlexGlobals.topLevelApplication.nativeWindow.width - 1,FlexGlobals.topLevelApplication.nativeWindow.y + 40);
				natWindow.x = p.x;
				natWindow.y = p.y; 
				return;
			}
			p = new Point(natWindow.x + 10, natWindow.y+10);
			natWindow.x = p.x;
			natWindow.y = p.y;
			unStickWindow(window);
		}
		public function windowAction(type:String,window:NativeWindow=null):void {
			try {
				if (window == null)window = this.natWindow;
				switch(type)	{
					case INFO_ACTION:
					{	
						if (info!=null)info()
						break;
					}
					case MAXIMIZE_ACTION:
					{
						if (isMax){
							windowAction(RESTORE_ACTION,window);
							return;
						}
						isMax = true;
						window.maximize()
						break;
					}
					case RESTORE_ACTION:
					{
						window.restore();
						isMax = false;
						break;
						
					}
					case MINIMIZE_ACTION:
					{	
						window.minimize();
						break;
					}
					case CLOSE_ACTION:
					{			
						if (hidden){
							windowAction(HIDE_ACTION);
							return;
						}
						window.close();
						break;
					}
					case HIDE_ACTION:
					{
						window.visible = false;
						window.orderToBack();
						for (var i:uint = 0; i<stickWindows.length;i++){
							(stickWindows.getItemAt(i).window as Window).close();
						}
						break;
					}
					case SHOW_ACTION:
					{
						window.visible = true;
						window.orderToFront();
						window.activate();
					}
					
				}
			}catch (error:Error){
				MLog.Log(error.getStackTrace());
			}
			
		}
	}
}