package net.gltd.gtms.events
{
	import flash.events.Event;
	import flash.media.Sound;
	
	public class SoundAlertEvent extends Event
	{
		
		public static const			PLAY_SOUND					:String = "onPlaySound",
									STOP_SOUND					:String = "onStopSound",
									ALERT_SOUND					:String = "onAlertSound";
		public 		  var			action						:String = "play",
									sound						:Sound,
									loop						:int = 1;
									
		
		public function SoundAlertEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}