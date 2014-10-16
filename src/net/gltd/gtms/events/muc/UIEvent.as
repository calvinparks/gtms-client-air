package net.gltd.gtms.events.muc
{
	import flash.events.Event;
	
	public class UIEvent extends Event
	{
		public	static	const		EVENT_FILTER_CHANGED			:String = "onFilterChanged";
		
		public			var			filterValue						:String;
		public function UIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}