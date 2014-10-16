package net.gltd.gtms.model.im
{

	import net.gltd.gtms.events.ArchiveEvent;
	import net.gltd.gtms.events.ChatEvent;
	import net.gltd.gtms.model.contact.BuddyModel;
	import net.gltd.gtms.model.contact.IMBuddyModel;
	import net.gltd.gtms.model.contact.singl.buddiesHolder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;
	
	import org.igniterealtime.xiff.core.EscapedJID;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.Message;
	
	[Event(name="onNewMessage", type="net.gltd.gtms.events.ChatEvent")]
	[Event(name="onSendMessage", type="net.gltd.gtms.events.ChatEvent")]
	[Event(name="onListReady", type="net.gltd.gtms.events.ArchiveEvent")]
	[Event(name="onConversationReady", type="net.gltd.gtms.events.ArchiveEvent")]
	public class MessageModel extends EventDispatcher
	{
		
		protected	var		_tO							:uint = 0,
							_id							:String,
							_hasUnreaded				:Boolean = false,
							_hasOwnWindow				:Boolean = false,
							_show						:Class,
							_archiveCount				:Number = NaN,
							_archiveBeforeValueHeight	:Number;
								 
		public 		var		messages					:Vector.<Message>,
							readed						:Vector.<Message>,
							open						:Boolean = true,
							hasOpenTab					:Boolean = true,
							type						:String,
							windowid					:String,
							archives					:Array=[],
							sesionAllArchives			:Array=[],//Vector.<ArchiveMessageModel> = new Vector.<ArchiveMessageModel>(),
							archiveCurrentScope			:uint = NaN,
						
							archiveOffset				:uint = 13,// << "max"
							archiveStart				:String,
							
							currentArchiveChat			:int = 0;
							
							
		[Bindable]
		public		var		glowColor		:int = FlexGlobals.topLevelApplication.styleManager.getMergedStyleDeclaration('.chatIr').getStyle('backgroundColor');
							
		[Bindable]
		public		var		bd				:BuddyModel;
		
	
		private		var		_label			:String = "";
		
		[Bindable]
		public 		var		description		:String;
		
		public 		var		jid				:UnescapedJID;

					
		
		public function MessageModel(senderId:String,senderJID:UnescapedJID,type:String="im")
		{
			this.type 			= type;
			this._id			= senderId;
			this.messages		= new Vector.<Message>();
			this.readed			= new Vector.<Message>();
			this.jid			= senderJID;
			if (type == "im"){
				try {
					label	= buddiesHolder.getInstance().getBuddy(senderId).nickname;
					if (type=="im")bd = buddiesHolder.getInstance().getBuddy(senderId);// as IMBuddyModel;
				}catch (error:Error){
					label = senderId;
				}
			}
		}
		public function get id():String {
			//trace ( jid,  jid.escaped.bareJID,  jid.bareJID,">> _ID",_id);
			return jid.escaped.bareJID;
		}
		public function pushMessage(m:Message, doMark:Boolean=true):void {
			if (m==null)return;
			if (!hasUnreaded && doMark)markUser(true);
			messages.push(m);
			
			var che:ChatEvent =  new ChatEvent( ChatEvent.NEW_MESSAGE );
			che.message = m;
			dispatchEvent(	che );
		}
		public function getMessage():Message {
			var message:Message = messages.shift();
			readed.push( message );
			return message;
		}
		public function sendMessage(msg:String):void {
			var message:Message = new Message(jid.escaped,null,msg,null,Message.TYPE_CHAT,null,Message.STATE_ACTIVE);// 
			var event:ChatEvent = new ChatEvent( ChatEvent.SEND_MESSAGE );
			event.message = message;
			dispatchEvent( event );
			readed.push(message);
		}
		public function sendState(state:String):void {
			var message:Message = new Message(new EscapedJID(jid.bareJID),null,null,null,Message.TYPE_CHAT,null,state);
			var event:ChatEvent = new ChatEvent( ChatEvent.SEND_MESSAGE );
			event.message = message;
			dispatchEvent( event );
			
		}
		public function getArchiveConversation(withWho:EscapedJID,startDate:String):void {
			dispatchEvent(new ArchiveEvent(ArchiveEvent.GET_CONVERSATION,withWho,startDate));
		}
		protected function get archiveChatIndex():int {
			dispatchEvent(new Event("heightChanged"));
			return (bd.archiveList.length)-(++currentArchiveChat);
		}
		public function getNewArchiveConversation():void { 
			var index:int = archiveChatIndex; 
			if (index < 0) return;
			archiveStart = bd.archiveList[index].start;
			dispatchEvent(new ArchiveEvent(ArchiveEvent.GET_CONVERSATION,jid.escaped,archiveStart));
		}
		public function set hasUnreaded	(b:Boolean):void {
			_hasUnreaded = b;
			if (b)glowColor = FlexGlobals.topLevelApplication.styleManager.getMergedStyleDeclaration('.chatIrGlow').getStyle('backgroundColor');
			else glowColor = FlexGlobals.topLevelApplication.styleManager.getMergedStyleDeclaration('.chatIr').getStyle('backgroundColor');
		}
		[Bindable]
		public function get hasUnreaded	():Boolean {
			return _hasUnreaded
		}
		public function markUser(t:Boolean):void {
			if (t == hasUnreaded)return;
			hasUnreaded = t;
			if (type!="im")return;
			buddiesHolder.getInstance().getBuddy(id).mark = t;
			
		}
		public function contain(searchString:String):Boolean {
			try {
				if (bd != null) {
					if ( (label+bd.statusMsg+description).toLowerCase().indexOf(searchString) > -1 ) return true;
				}else {
					if ( (label+description).toLowerCase().indexOf(searchString) > -1) return true;
				}
				for (var i:uint = 0; i<readed.length;i++){
					if (readed[i].body.toLowerCase().indexOf(searchString) > -1){
						return true
					}
				}
			}catch (error:Error){
				
			}
			return false
			
		}
		public function set hasOwnWindow(b:Boolean):void {
			_hasOwnWindow = b;
			//if (!b)windowid = null;
		}
		public function get hasOwnWindow():Boolean {
			return _hasOwnWindow
		}
		
		public function openNewWindow(main:Boolean=false):void {
			hasOwnWindow = !main;
			var e:ChatEvent = new ChatEvent(ChatEvent.SEPARATED_WINDOW);
			e.id = id;
			e.obj = main;
			dispatchEvent( e );
				
		}
		public function conversationReady( withJID:EscapedJID,mId:String):void {
			dispatchEvent( new ArchiveEvent(ArchiveEvent.CONVERSATION_READY, withJID,mId) );
		}
	
		public function resetArchives():void {
			archives = [];
		}
		public function archiveListReady():void {
			dispatchEvent( new ArchiveEvent (ArchiveEvent.LIST_READY) );
		}
		
		
		public function archiveChatError():void {
			dispatchEvent( new ArchiveEvent(ArchiveEvent.CONVERSATION_ERROR) )
		}
		public function displayArchiveChat(arr:Array):void {
			archives = arr;
			dispatchEvent( new ArchiveEvent(ArchiveEvent.CONVERSATION_READY) );
		}
		
		
		public function contactArchive(arr:Array):void {
			archives = arr;
			//archives.sortOn("secs",Array.NUMERIC);
			//dispatchEvent( new ArchiveEvent(ArchiveEvent.CONVERSATION_READY) )
		}
		public function removeFromSource():void {
			var e:ChatEvent = new ChatEvent(ChatEvent.REMOVE_CHAT);
			e.id = id;
			dispatchEvent( e );
		}
		public function set label(s:String):void {
			_label = s;
		}
		[Bindable]
		public function get label():String {
			try {
				return bd.nickname;
			}catch (error:Error){}
			return _label
		}
		[Bindable]
		public function get archiveBeforeValue():Number {
		//	if (isNaN(archiveCurrentScope)) archiveCurrentScope = archiveCount;
			return archiveCurrentScope;
		}
		public function set archiveBeforeValue(n:Number):void {
			archiveCurrentScope = n;
		}
		[Bindable]
		public function get archiveBeforeValueHeight():Number {
			 
			if (isNaN( _archiveBeforeValueHeight)) return 0;
			return _archiveBeforeValueHeight
		}
		public function set archiveBeforeValueHeight(n:Number):void {
			_archiveBeforeValueHeight = n;
		}
		
		[Bindable]
		public function get archiveCount():Number {
			return _archiveCount;
		}
		public function set archiveCount(n:Number):void {
			_archiveCount = n; 
			archiveBeforeValue = n;;
		}
		
		
		public function archiveCurrentScopeInc():void {
			archiveBeforeValue = Math.max( archiveCurrentScope-archiveOffset ,0);
			if (bd.archiveList.length-currentArchiveChat==0)archiveBeforeValueHeight = 0;
			archiveBeforeValueHeight= Math.max(15,Math.min(120,4*(bd.archiveList.length-currentArchiveChat)) );
			
			
			
			
			
		}
		
	}
}