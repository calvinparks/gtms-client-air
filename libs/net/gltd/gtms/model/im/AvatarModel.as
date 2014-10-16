package net.gltd.gtms.model.im
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;

	[Event(name="complete", type="flash.events.Event")]

	public class AvatarModel extends EventDispatcher
	{
		[Bindable]
		public static var pathSmall:Class;
		[Bindable]
		public static var pathLarge:Class;
		[Bindable]
		public static var pathGroup:Class;
		[Bindable]
		public static var pathWG:Class;

		public	var bmpData:BitmapData;
		
		public	var byteSource:ByteArray;

		private var loader:Loader;
		
		private var png:PNGEncoder = new PNGEncoder();
		
		public	var	type:String;
		
		public static const TYPE_CONTACT:String = "contact";
		public static const TYPE_ROOM:String = "group";
		public static const TYPE_WG:String = "wg";
		
		public function AvatarModel(type:String="contact")
		{
			this.type = type;
		}
		public function kill():void {
			loader = null;
			byteSource = null;
			bmpData = null;
		}
		[Bindable (event="icoUpdated")]
		public function get ico():* {
			if (bmpData)return bmpData;
			if (type == TYPE_ROOM) return pathGroup;
			return pathSmall;
		}
		public function set ico(o:*):void {
			if (o is BitmapData) bmpData = o;
			dispatchEvent(new Event("icoUpdated"));
		}
		[Bindable (event="avatarUpdated")]
		public function get foto():* {
			if (bmpData)return bmpData;
			if (type == TYPE_ROOM) return pathGroup;
			if (type == TYPE_WG) return pathWG;
			return pathLarge;
		}
		public function set foto(o:*):void {
			if (o is BitmapData) bmpData = o;
			dispatchEvent(new Event("avatarUpdated"));
		}
		public function add(data:ByteArray):void {
			if (data == null)return;
			loader = new Loader();
			var lc:LoaderContext = new LoaderContext();
			lc.allowLoadBytesCodeExecution = true;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, getBitmapData,false,0,true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ldrError,false,0,true);
			loader.loadBytes(data,lc);
		}	
		private function ldrError(e:IOErrorEvent):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, getBitmapData);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ldrError)
		}
		private function getBitmapData(event:Event):void {
			try {
				
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, getBitmapData);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ldrError)

				var content:* = loader.content;
	
				var scaleFactor:Number = 1;
				var newWidth:Number = 50;
				var newHeight:Number = 50;
				
				var maxWidth:uint = 120;
				var maxHeight:uint = 160;
				
				if ( content.width > maxWidth || content.height > maxHeight ){
					if(content.width > content.height) {
						scaleFactor = maxWidth / content.width;
					}
					else {
						scaleFactor = maxHeight / content.height;
					}
				}
				newWidth = content.width * scaleFactor;
				newHeight = content.height * scaleFactor;
				var scaleMatrix:Matrix = new Matrix();
				scaleMatrix.scale(scaleFactor, scaleFactor);
				
				var bitmapData	:BitmapData		= new BitmapData(newWidth,newHeight,true,0x00000000);	 
				bitmapData.draw(content, scaleMatrix);
			
				//var ba:ByteArray=new ByteArray();
				//ba.writeObject( bitmapData) //jpg.encode(bitmapData)
		
				byteSource = png.encode( (content as Bitmap).bitmapData );
				
				
				bmpData = (content as Bitmap).bitmapData//bitmapData;
				
				
				var _event:Event = new Event(Event.COMPLETE);
				dispatchEvent( _event );
				
				
				dispatchEvent(new Event("icoUpdated"));
				dispatchEvent(new Event("avatarUpdated"));
				
			}catch (error:*){
				trace ("error in AvatarModel");
			}
		
			
		}

	}
}