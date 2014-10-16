/*
** UEMQueue.as , package net.gltd.gtms.controller.app **  
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
	import net.gltd.gtms.utils.FilterArrayCollection;
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	
	import flash.desktop.NativeApplication;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeWindowBoundsEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.AIREvent;
	import mx.events.FlexEvent;
	
	import org.flexunit.asserts.fail;
	
	import spark.components.Window;
	
	public class UEMQueue extends EventDispatcher
	{
		
		public		static		var		QUEUE				:FilterArrayCollection,
										HIDDEN				:FilterArrayCollection,
										WAITING				:FilterArrayCollection,
										
										prevComplete		:Boolean = true;
		
		
		private		static		var		minPositionY		:int,
										maxPositionY		:int,
										minPositionX		:int,
										maxPositionX		:int,
										
										bounds				:Rectangle,
										uemWidth			:int		 = 230,
										hGap				:int		 = 5,
										vGap				:int		 = 5,
										
										currentY			:int,
										currentX			:int;
										
										

		
		
		public function UEMQueue():void {
			
			QUEUE = new FilterArrayCollection();
			HIDDEN = new FilterArrayCollection();
			WAITING = new FilterArrayCollection();
			
			if (NativeApplication.supportsDockIcon)
			{
				maxPositionY =  Screen.mainScreen.bounds.y + Screen.mainScreen.bounds.height - 88;
				maxPositionX = Screen.mainScreen.bounds.x + Screen.mainScreen.bounds.width - 35;
			}else {
				maxPositionY =  Screen.mainScreen.bounds.y + Screen.mainScreen.bounds.height - 29;
				maxPositionX = Screen.mainScreen.bounds.x + Screen.mainScreen.bounds.width - 15;
			}
			
			minPositionY = Screen.mainScreen.bounds.y + 26;
			minPositionX = maxPositionX - 2*(uemWidth) - hGap;
			var w:uint	= Math.abs(maxPositionX - minPositionX);
			var h:uint	= Math.abs(maxPositionY - minPositionY);
			bounds = new Rectangle(minPositionX,minPositionY, w, h);
			
			currentX = bounds.x + bounds.width;
			currentY = bounds.y + bounds.height;
			 
		}
		public static function AddToQueue(uem:Window):void
		{
			open(uem);
			
			/*
			if (prevComplete)open(uem);
			else {
				var i:int = WAITING.getIndexByKey("ownerID",uem['ownerID']);
				if (i > -1)WAITING.removeItemAt(i);
				WAITING.addItem(uem)
			}*/
		}
		
		private static function onWindowOpened(event:Event):void {
			currentY -= event.currentTarget.height;
			currentY -= vGap;
			(event.currentTarget as Window).move( currentX - (event.currentTarget as Window).width, currentY);
			(event.currentTarget as Window).visible = true;
			if (WAITING.length>0)open( WAITING.removeItemAt(0) as Window );
			else prevComplete = true;
		}
		
		private static function open(uem:Window):void {
			
			var _x:int = currentX - uem.width;
			var _y:int = currentY;
			
			prevComplete = false;
			uem.addEventListener(AIREvent.WINDOW_COMPLETE,onWindowOpened)
			uem.addEventListener(Event.CLOSING,onClosing,false,0,true);
			uem.addEventListener(Event.CLOSE,onClose,false,0,true);
			uem.visible = false;
			uem.open(false);
			
			uem.nativeWindow.y = 0;
			uem.move(_x,_y);
		
			QUEUE.addItem(uem);
			
		}
		
		public static function onClosing(event:Event):void { 
			var h:uint = 0
			try {
				h = event.currentTarget.height + vGap;
				var ind:uint = QUEUE.getItemIndex(event.currentTarget);
				var w:Window;
				for (var i:uint = ind+1; i<QUEUE.length;i++){
					w = QUEUE.getItemAt(i) as Window;
					if (w.nativeWindow.closed || w.closed)continue;
					TweenMax.to (w.nativeWindow,.2,{y:w.nativeWindow.y + h,delay:i/50,ease:Sine.easeOut});
				}
			 
				if (ind>-1)	QUEUE.removeItemAt(ind);
				
			}catch (error:Error){
				
			}
			event.currentTarget.removeEventListener(Event.CLOSING,onClosing)
		}
		public static function onClose(event:Event):void {
			try {
				currentY +=	(event.currentTarget.height + vGap);
				TweenMax.killTweensOf(event.currentTarget.nativeWindow);
			}catch (error:Error){
				
			}
			event.currentTarget.removeEventListener(Event.CLOSE,onClose);
			
		}
	}
}