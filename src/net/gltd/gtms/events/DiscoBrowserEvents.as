package net.gltd.gtms.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.data.IQ;
	
	public class DiscoBrowserEvents extends Event
	{
		public	static	var	FIELD_ITEM_CLICK			:String = "onFieldItemClick",
							IQ_READY_TO_SEND			:String = "onIQReady";
		
		public			var	data						:Object,
							iq							:IQ;
		
		
		public function DiscoBrowserEvents(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
	}
}