package net.gltd.gtms.events
{
	import net.gltd.gtms.model.xmpp.DiscoItemModel;
	
	import flash.events.Event;
	
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.Message;
	
	public class VideoEvent extends Event
	{
		public static	var			START_VIDEO_CALL	:String = "startVideoCall",
									START_FUZE_CALL		:String = "startFuzeCall",
									INCOMMING_VIDEO		:String = "incommingVideo",
									INCOMMING_FUZE_VIDEO:String = "incommingFuzeVideo",
									NET_STREAM_PUBLISH	:String = "netStreamPublish",
									NET_STREAM_UNPUBLISH:String = "netStreamUnPublish";
		
		public 			var msg							:Message,
							to							:String,
							system						:String,
							service						:DiscoItemModel,
							option						:String,
							members						:Array,
							videoCall					:Object,
							room						:Room;
							
		public function VideoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}