package net.gltd.gtms.events.muc
{
	import net.gltd.gtms.model.muc.ChannelModel;
	
	import flash.events.Event;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.data.IQ;
	import org.igniterealtime.xiff.data.muc.MUCOwnerExtension;
	
	public class MUC_UI_Event extends Event
	{
		public	static const OPEN_NEW_WINDOW			:String = "onOpenNewWindow",
							 OPEN_NEW_STREAM_WINDOW		:String = "onOpenNewStreamWindow",
							 CREATE_NEW_CHANNEL			:String = "onCreateNewChannel",
							 SHOW_INFO					:String = "onShowInfo",
							 EDIT_CHANNEL				:String = "onEditChannel",
							 EDIT_STREAM				:String = "onEditStream";
		
		public	static const actionEdit					:String = "edit",
							 actionAdd					:String = "add";
		public			var	 extension					:MUCOwnerExtension,
							 service					:EscapedJID,
							 callBack					:Function,
							 itemJID					:EscapedJID,
							 itemName					:String,
							 itemKind					:String,
							 fieldmap					:Object,
							 item						:*,
							 action						:String,
							 subject					:String,
							 xmlData					:IQ;
							 
		public function MUC_UI_Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public override function clone():Event {
			var ev:MUC_UI_Event = new MUC_UI_Event(this.type, this.bubbles, this.cancelable);
			ev.extension = this.extension;
			ev.service = this.service;
			ev.callBack = this.callBack;
			ev.itemName = this.itemName;
			ev.itemJID = this.itemJID;
			ev.fieldmap = this.fieldmap;
			ev.item = this.item;
			ev.action = this.action;
			ev.subject = this.subject;
			
			return ev as Event;
		}
	}
}