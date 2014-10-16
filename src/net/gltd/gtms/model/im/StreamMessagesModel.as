package net.gltd.gtms.model.im
{
	import net.gltd.gtms.GUI.UEM.UEM;
	import net.gltd.gtms.GUI.UEM.UEMfeature;
	import net.gltd.gtms.controller.app.SettingsManager;
	import net.gltd.gtms.model.muc.StreamModel;
	import net.gltd.gtms.view.im.chatv2.StreamNavigatorContent;
	
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.events.MessageEvent;
	
	public class StreamMessagesModel extends MessageModel
	{
		[Bindable]
		public var 	stream			:StreamModel;
		
		public var	streamView		:StreamNavigatorContent,
					uemReadHandeler	:Function,
					dispatchSound	:Function;
		
		//private	var	_id		:String;
		
		public function StreamMessagesModel(model:StreamModel)
		{
			this.stream = model;
			this._id = model.id;
			super(model.id, null, model.kind);
			
			stream.addEventListener(MessageEvent.MESSAGE,onMessage);
		}
		private function onMessage(event:MessageEvent):void {
			
			try {
				trace ("onMessage",streamView);
				if (streamView!=null)trace ("streamView.enabled",streamView.enabled);
				if (streamView == null || streamView.selected == false){
					if (SettingsManager.ALLERTS["notificationStreams"].popup == true) UEM.newUEM(stream.name+"StreamMessage","Stream: "+stream.name,event.data.body,[new UEMfeature(UIphrases.IM_MSG_EVENT_BUTTON_READ,uemReadHandeler,[stream.name])],null,SettingsManager.ALLERTS["notificationStreams"].time);
					if (SettingsManager.ALLERTS["notificationStreams"].sound == true)dispatchSound();
				}
			}catch (error:Error){
				trace (error.getStackTrace());
			}
		
		}
		 public override function get id():String {
			 return _id;
		 }
		 
		 [Bindable]
		 public override function get label():String {
			 return stream.label;
		 }
		 public override function set label(s:String):void {
			 super.label = s;
		 }
		
		 
		 public override function contain(searchString:String):Boolean {
			 if ( (label+stream.description+stream.keywords).toLowerCase().indexOf(searchString) > -1) return true;
			/* for (var i:uint = 0; i<readed.length;i++){
				 if (readed[i].body.toLowerCase().indexOf(searchString) > -1){
					 return true
				 }
			 }*/
			 return false
		 }
		 public override function markUser(t:Boolean):void {
			 if (t == hasUnreaded)return;
			 hasUnreaded = t;
			 stream.hasMessage = t;
			 
		 }
		
	}
}