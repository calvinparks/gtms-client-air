package net.gltd.gtms.model.muc
{
	import net.gltd.gtms.controller.muc.MUCInterfaceManager;
	import net.gltd.gtms.model.im.AvatarModel;
	import net.gltd.gtms.model.muc.xmlamapper.Field;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.igniterealtime.xiff.bookmark.GroupChatBookmark;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.events.RoomEvent;

	public class ChannelModel extends EventDispatcher
	{
		
		public	static		const	KIND_CHANNEL		:String = "kindChannel",
									KIND_PRIVATE_ROOM	:String = "kindPrivatRoom";
		
		private				var		_name				:String,
									_bareJID			:String,
									_jid				:EscapedJID,
									_details			:ChannelDetails,
									_avatar				:AvatarModel = new AvatarModel(AvatarModel.TYPE_ROOM),
									_kind				:String,
									_isFav				:Boolean = true,
									_info				:String,
									_followed			:Boolean,
									_autoJoin			:Boolean,
									_bookmark			:GroupChatBookmark,
									_locked				:Boolean,
									_gotoMessageId		:String,
									
									_room				:Room;
									
		public				var		isMy				:Boolean,
									askedAboutJoin		:Boolean,
									clickFunction		:Function,
									
									archiveList 		:Array,
									archiveGrList		:Array;
									
								 	
		public function ChannelModel(name:String,bareJID:String,kind:String):void 
		{ 
			this.name = name;
			this.bareJID = bareJID.toLowerCase();
			this.kind = kind;
			
		}
		public function set name(n:String):void {
			label = n;
			if (room)room.label = n;
		}
		public function get name():String {
			return _name;
		}
		public function set label(n:String):void {
			_name = n;
		}
		
		[Bindable]
		public function get label():String {
			return _name;
		}
		public function set info(n:String):void {
			_info = n;
		//	if (room)room.label = n;
		}
		[Bindable]
		public function get info():String {
			return _info;
		}
		public function set avatar(a:AvatarModel):void {
			_avatar = a;
		}
		[Bindable]
		public function get avatar():AvatarModel {
			return _avatar;
		}
	
		[Bindable]
		public function get kind():String {
			return _kind;
		}
		public function set kind(n:String):void {
			_kind = n;
		}
		[Bindable]
		public function get isFavorite():Boolean {
			return _isFav;
		}
		public function set isFavorite(n:Boolean):void {
			_isFav = n;
		}
		
		[Bindable]
		public function get locked():Boolean {
			return _locked;
		}
		public function set locked(n:Boolean):void {
			_locked = n;
		}
		
		public function set bareJID(n:String):void {
			_bareJID = n;
			_jid = new EscapedJID(_bareJID);
		}
		public function get bareJID():String {
			return _bareJID;
		}
		public function set jid(j:EscapedJID):void {
			_jid = j;
			_bareJID = j.bareJID;
		}
		public function get jid():EscapedJID {
			return _jid;
		}
		public function get id():String {
			return bareJID;
		}
		
		
		public function set details(d:ChannelDetails):void {
			_details = d;
			try {
				//_info = (_details.x.field[2] as Field).value;
				for (var i:uint = 0; i< _details.x.field.length;i++){
					if ((_details.x.field[i] as Field).label == "Subject"){
						_info = (_details.x.field[i] as Field).value;
						break;
					}
				}
				
				for (i = 0; i< _details.feature.length; i++){
				//	trace (_details.feature[i], _details.feature[i].feature);
					if ( _details.feature[i].feature == "muc_passwordprotected"){
						locked = true;
					}
				}
				
				if (d.identity.name && d.identity.name.indexOf("_") == -1){ 
					this.name = d.identity.name;
				}
				
			}catch (error:Error){}
		}
		
		public function get details():ChannelDetails {
			return _details;
		}
		[Bindable]
		public function get icon():Class {
			//if (locked) return MUCInterfaceManager.lockIco;
			if (kind == KIND_CHANNEL) return MUCInterfaceManager.channelIco;
			return MUCInterfaceManager.streamIco;
		}
		public function set icon(d:Class):void {
			
		}
		[Bindable]
		public function get favoriteIcon():Class {
			if (isFavorite) return MUCInterfaceManager.favoriteIco;
			return null;
		}
		public function set favoriteIcon(d:Class):void {
			
		}
		public function set followed(f:Boolean):void {
			 _followed = f;
		}
		[Bindable]
		public function get followed():Boolean {
			return _followed;
		}
		public function set autoJoin(f:Boolean):void {
			_autoJoin = f;
		}
		public function get autoJoin():Boolean {
			return _autoJoin;
		}
		
		public function set bookmark(item:GroupChatBookmark):void {
			_bookmark = item; 
			autoJoin = item!=null&&item.autoJoin;
			followed = item!=null;
		}
		public function get bookmark():GroupChatBookmark {
			return _bookmark;
		
		}
		
		public function set gotoMessageId(id:String):void {
			_gotoMessageId = id;
		}
		public function get gotoMessageId():String {
			return _gotoMessageId;
		}
		
		
		public function set room(r:Room):void {
			_room = r;
		
		}
		
		[Bindable]
		public function get room():Room {
			return _room;
		}
		
		public function initRoom(r:Room):void {
			room = r;
			_room.label = label;
			room.addEventListener(RoomEvent.ROOM_JOIN,onRoom);
			room.addEventListener(RoomEvent.ROOM_DESTROYED,onRoom);
			room.addEventListener(RoomEvent.ROOM_LEAVE,onRoom);
			
			room.addEventListener(RoomEvent.CONFIGURE_ROOM,onRoom);
			room.addEventListener(RoomEvent.CONFIGURE_ROOM_COMPLETE,onRoom);
			room.addEventListener(RoomEvent.GROUP_MESSAGE,onRoom);
			
			
			room.addEventListener(RoomEvent.USER_JOIN,onRoom);
			room.addEventListener(RoomEvent.USER_DEPARTURE,onRoom);
			room.addEventListener(RoomEvent.PRIVATE_MESSAGE,onRoom);
			room.addEventListener(RoomEvent.USER_BANNED,onRoom);
			room.addEventListener(RoomEvent.SUBJECT_CHANGE,onRoom);
			room.addEventListener(RoomEvent.USER_PRESENCE_CHANGE,onRoom);
			room.addEventListener(RoomEvent.USER_KICKED,onRoom);
			
			room.addEventListener(RoomEvent.AFFILIATIONS,onRoom);
			room.addEventListener(RoomEvent.AFFILIATION_CHANGE_COMPLETE,onRoom);
			
			
			//room.addEventListener(RoomEvent.CONFIGURE_ROOM,onRoomConf);
			//room.addEventListener(RoomEvent.CONFIGURE_ROOM_COMPLETE,onRoomConf);
			
			
			dispatchEvent( new Event("roomInited") );

			
		}
	 
		public function onRoom(event:RoomEvent):void {
			if ((event.currentTarget as Room).subject) info = (event.currentTarget as Room).subject;
			dispatchEvent( event.clone() );
			
			if (event.type == RoomEvent.ROOM_LEAVE){
				room = null;
			}
			
		}
	
		
	
		
	}
}