/*
** UEM.as , package net.gltd.gtms.controller.app **  
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
	import net.gltd.gtms.events.UEMEvent;
	import net.gltd.gtms.utils.StringUtils;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import spark.components.PopUpAnchor;
	import spark.components.Window;
	
	public class UEM extends EventDispatcher
	{
		public	static	const 	defaultWidth			:uint = 270,
								defaultHeight			:uint = 105,
								smallHeight				:uint = 54,
								defaultTime				:uint = 6000;
								
							
		
		
		
		public static function newUEM(ownerID:String,title:String,message:String,features:Array=null,cond:Point = null, time:uint = defaultTime):void {
			ownerID = StringUtils.removeChar(ownerID);
			ownerID = StringUtils.removeChar(ownerID,"-");
			ownerID = StringUtils.removeChar(ownerID,"/");
			ownerID = StringUtils.removeChar(ownerID,"@");

			var exist:int = UEMQueue.QUEUE.getIndexByKey("ownerID",ownerID);
			var existW:int = UEMQueue.WAITING.getIndexByKey("ownerID",ownerID);
			var uem:UEMwindow;
			if(exist > -1){
				uem = UEMQueue.QUEUE.getItemAt(exist) as UEMwindow;
				uem.update(title,message,features);
				if (time>500) uem.timer = time;
				return
			}
			uem = new UEMwindow(ownerID,title,message,features);
			
			if (cond == null) cond = new Point(defaultWidth,defaultHeight);
			uem.width = cond.x;
			uem.height = cond.y;
			uem.id = "uem_"+StringUtils.generateRandomString(7);
			if (time>500) uem.timer = time;
			if (cond != null){
				
			}
			UEMQueue.AddToQueue(uem as Window);
		}
		public static function pushWindow(uem:* ):void {
			UEMQueue.AddToQueue(uem as Window);
		}
		public static function hideUEM(ownerID:String):void {
			UEMQueue.HIDDEN.addItem( UEMQueue.QUEUE.getItemByID(ownerID) );
			removeWindow( ownerID );
		}
		public static function showAllHidden():void {
			for (var i:uint = 0; i<UEMQueue.HIDDEN.length; i++){
				pushWindow(	UEMQueue.HIDDEN.removeItemAt(i));
			}
		}
		public static function removeWindow(ownerID:String):void {
			try {
				(getUEM(ownerID) as Window).close();
			}catch (error:Error){
			}
		}
		public static function getUEM(ownerID:String):* {
			var exist:int = UEMQueue.QUEUE.getIndexByKey("ownerID",ownerID);
			if (exist == -1) return null;
			
			return  UEMQueue.QUEUE.getItemAt(exist);
			
		}
		public static function killAll():void
		{
			for (var i:uint = 0;i <UEMQueue.QUEUE.length; i++){
				UEMQueue.QUEUE.getItemAt(i).close();
			}
			UEMQueue.HIDDEN.removeAll();
		}
		public static function killFor(user:String,kind:String):void {
			user = StringUtils.removeChar(user);
			user = StringUtils.removeChar(user,"-");
			user = StringUtils.removeChar(user,"/");
			user = StringUtils.removeChar(user,"@");
			 
			for (var i:uint = 0; i<UEMQueue.QUEUE.length;i++){
				if (UEMQueue.QUEUE.getItemAt(i).ownerID.indexOf(user) > -1 && UEMQueue.QUEUE.getItemAt(i).ownerID.indexOf(kind)>-1){
					removeWindow( UEMQueue.QUEUE.getItemAt(i).ownerID );
					return
				}
			}
			
			for ( i = 0; i<UEMQueue.WAITING.length;i++){
				if (UEMQueue.WAITING.getItemAt(i).ownerID.indexOf(user) > -1 && UEMQueue.WAITING.getItemAt(i).ownerID.indexOf(kind)>-1){
					 UEMQueue.WAITING.removeItemAt(i);
					 UEMQueue.prevComplete = true;
						 
					return
				}
			}
			
			
			
		}

		
		
	}
}