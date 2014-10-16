package net.gltd.gtms.GUI.notification
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	
	import spark.components.Window;
	
	public class Alert extends EventDispatcher
	{
		public function Alert(target:IEventDispatcher=null)
		{
			
		}
		public static function ShowAlert (parentWindow:Window,title:String,message:String):void {
			var a:mx.controls.Alert;// = mx.controls.Alert.show(event.data.body,event.data.subject);
			 
			
		}
	}
}