package net.gltd.gtms.events
{
	import net.gltd.gtms.model.app.ExtensionModel;
	
	import flash.events.Event;
	
	public class ExtensionEvent extends Event
	{
		public	static	var		PLUGIN_READY		:String = "onPluginReady",
								PLUGIN_REMOVED		:String	= "onPluginRemoved";
		
		public			var		data				:ExtensionModel;
		public function ExtensionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}