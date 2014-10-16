package net.gltd.gtms.controller.app
{
	import net.gltd.gtms.events.ConnectionEvent;
	import net.gltd.gtms.events.SoundAlertEvent;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import mx.messaging.Channel;

	public class SoundsController
	{
		


		
		private var alertSound:Sound;
		private var chanel:SoundChannel;
		private var alertChannel:SoundChannel;
		public function SoundsController()
		{
			
		}
		[Init]
		public function init():void {
		}
		public function set soundAlert (p:Sound):void {
			alertSound = p as Sound;
			
		}
		private function play(s:Sound,addChanel:Boolean,loop:int):SoundChannel {
			var ch:SoundChannel;
			if(addChanel)chanel = ch = s.play(0,10,new SoundTransform(.6))
			else ch = s.play(0,loop,new SoundTransform(.6));
			
			return ch;
		}
		[MessageHandler (selector="onAlertSound")]
		public function onAlert(e:SoundAlertEvent):void {
			if (alertChannel) alertChannel.stop();
				alertChannel = play(alertSound,false,e.loop);
		}
	
		[MessageHandler (selector="onPlaySound")]
		public function onPlay(e:SoundAlertEvent):void {
			play(e.sound,true,e.loop)
	
		}
		
		
		[MessageHandler (selector="onStopSound")]
		public function onStop(e:SoundAlertEvent):void {
			chanel.stop()
		}
		
		[MessageHandler (selector="onDisconnected")]
		public function stopAll(e:ConnectionEvent):void {
			if (chanel)chanel.stop();
		}
		
		
	}
}