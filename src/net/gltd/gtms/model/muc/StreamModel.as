package net.gltd.gtms.model.muc
{
	import net.gltd.gtms.controller.im.ShowStatusManager;
	import net.gltd.gtms.controller.muc.MUCInterfaceManager;
	import net.gltd.gtms.model.im.AvatarModel;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.events.MessageEvent;

	[Event(name="message",type="org.igniterealtime.xiff.events.MessageEvent")]
	[Event(name="change",type="flash.events.Event")]
	public class StreamModel extends EventDispatcher
	{
		
		public	static		const	KIND_STREAM			:String = "kindStream";
		
		private				var		_name				:String,
									_id					:String,
									_interest			:String,
									_created			:String,
									_keywords			:Array = [],
									_enabled			:Boolean,
									_description		:String,
									_info				:String,
									_channels			:Array = [],
									_participants		:Array = [],
									_modified			:String,
									_subscription		:Object,
									_subscribed			:Boolean,
									
									_isFavorite			:Boolean = true,
									_avatar				:AvatarModel = new AvatarModel(AvatarModel.TYPE_ROOM),
									
									_messages			:Vector.<Message> = new Vector.<Message>(),
									
									_hasMessage			:Boolean = false;
									
		public				var		kind				:String,
									sourceObject		:Object,
									clickFunction		:Function;
		
		public function StreamModel(name:String=null,id:String=null)
		{
			this.kind = KIND_STREAM
			if (name!=null)this.name = name;
			if (id!=null)this.id = id;
		}
		public function set id(s:String):void {
			_id = s;
		}
		public function get id():String {
			return _id;
		}
		
		public function set interest(s:String):void {
			_interest = s;
		}
		public function get interest():String {
			return _interest;
		}
		
		public function set created(s:String):void {
			_created = s;
		}
		public function get created():String {
			return _created;
		}
		
		public function set description(s:String):void {
			_description = s;
			if (getMessagesLength() == 0)info = s;
		}
		[Bindable]
		public function get description():String {
			if (_description==null)return "";
			return _description;
		}
		
		public function set info(s:String):void {
			_info  = s;
		}
		[Bindable]
		public function get info():String {
			if (_info==null)return "";
			return _info;
		}
		
		
		
		
		
		public function set enabled(s:Boolean):void {
			_enabled  = s;
			icon = null
		}
		[Bindable]
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set modified(s:String):void {
			_modified  = s;
		}
		public function get modified():String {
			return _modified;
		}
		
		
		
		private function setKeywords(s:String):void {
			if (s==null)return;
			s = s.replace(/\(\.\)\*/g,'');		
			_keywords = s.split("|")
		}
	
		public function set keywords(s:String):void {
			setKeywords ( s )
		}
		public function get keywords():String {
			try {
				return _keywords.toString();
			}catch (error:Error){
				
			}
			return null;
		}
		public function getChannels():Array {
			return _channels;
		}
		public function setChannels(s:String):void {
			if (s==null)return;
			_channels = s.split("|")
			dispatchEvent( new Event(Event.CHANGE) );
		}
		public function set channels(s:String):void {
			setChannels( s );
		}
		public function get channels():String {
			try {
				return _channels.toString();
			}catch (error:Error){
				
			}
			return null;
		}
		public function getParticipants():Array {
			return _participants;
		}
		public function setParticipants(s:String):void {
			if (s==null)return;
			_participants = s.split("|");
			dispatchEvent( new Event(Event.CHANGE) );
		}
		public function set participants(s:String):void {
			setParticipants ( s );
		}
		public function get participants():String {
			try {
				return _participants.toString();
			}catch (error:Error){
				
			}
			return null;
		}
		
		public function set name(s:String):void  {
			 label = s;
		}
		public function get name():String {
			return _name;
		}
		public function set label(n:String):void {
			_name = n;
		}
		[Bindable]
		public function get label():String {
			return name;
		}
		
		public function set isFavorite(n:Boolean):void {
			_isFavorite = n;
		}
		[Bindable]
		public function get isFavorite():Boolean {
			return _isFavorite;
		}
		
		public function set avatar(a:AvatarModel):void {
			_avatar = a;
		}
		[Bindable]
		public function get avatar():AvatarModel {
			return _avatar;
		}
		
		[Bindable]
		public function get icon():Class {
			if (hasMessage) return ShowStatusManager.getIco("immessage");
			if (!enabled) return MUCInterfaceManager.streamIco;
			return MUCInterfaceManager.streamEnabledIco;
		}
		public function set icon(d:Class):void {
			
		}
		private var _favIco:Class;
		
		[Bindable]
		public function get favoriteIcon():Class {
			if (!subscribed) return MUCInterfaceManager.favoriteIco;
			return MUCInterfaceManager.favoriteRedIco;
		}
		public function set favoriteIcon(d:Class):void {
			_favIco = d;
		}
		
		public function pushMessage(m:Message):void {
			_messages.push( m );
			var event:MessageEvent = new MessageEvent();
			event.data = m;
			dispatchEvent( event );
			info = m.body;
			hasMessage = true;
		}
		public function getLastMessage():Message {
			return _messages[_messages.length - 1]
		}
		public function getMessage(nr:uint):Message {
			return _messages[nr];
		}
		public function getMessagesLength():uint {
			return _messages.length;
		}
		public function set subscribed(b:Boolean):void {
			_subscribed = b	
		}
		[Bindable]
		public function get subscribed():Boolean {
			return _subscribed
		}
		
		public function set hasMessage(b:Boolean):void {
			_hasMessage = b;
			icon = null;
		}
		[Bindable]
		public function get hasMessage():Boolean {
			return _hasMessage;
		}
		
		
		public function set subscription(obj:Object):void {
			if (obj == null){
				subscribed = false;
			}else {
				subscribed = obj.subscription == "subscribed";
			}
			_subscription = obj;
			favoriteIcon = _favIco;	
		}
		public function get subscription():Object {
			return _subscription;
		}
		
	}
}