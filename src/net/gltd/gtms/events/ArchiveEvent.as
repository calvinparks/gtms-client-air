package net.gltd.gtms.events
{
	import flash.events.Event;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	
	public class ArchiveEvent extends Event
	{
		
		public static	const	GET_LIST			:String = "onGetList",
								GET_CONVERSATION	:String = "onGetConversation",
								LIST_READY			:String = "onListReady",
								CONVERSATION_READY	:String = "onConversationReady",
								CONVERSATION_ERROR	:String = "onConversationError",
								TRANSCRIPT_READY	:String = "onTranscriptReady",
								CADDED_GET_LIST		:String = "onContactAddedGetArchive";
		
		public			var		forJID				:EscapedJID,
								date				:String,
								data				:Object;
		
		
		public function ArchiveEvent(type:String, forJID:EscapedJID=null, date:String=null, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.forJID = forJID;
			this.date = date;
			this.data = data;
			super(type, bubbles, cancelable);
		}
		public override function clone():Event {
			return new ArchiveEvent(this.type,this.forJID,this.date,this.data,this.bubbles,this.cancelable);
		}
	}
}